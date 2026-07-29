# Release signing

Ambulo is distributed as **self-signed APKs from GitHub Releases** — it is not
published to Google Play. There is no Play App Signing and no upload key: the
key you create here is the *release* key, and it is the only thing that gives
installed apps a continuous identity across updates.

Two consequences worth understanding before you generate anything:

- **The key is unrecoverable and unreplaceable.** Android refuses to install an
  update whose signature differs from the installed app. Lose the keystore and
  every existing user must uninstall (losing local data) before they can take
  another update. Back it up before you ship a single APK.
- **Users must sideload.** They will see "install unknown apps" warnings, and
  the certificate is self-signed, so nothing outside this repo vouches for it.
  Publishing checksums (the workflow does) is what lets someone confirm the
  file they downloaded is the file the workflow built.

Never commit a keystore, `android/key.properties`, or passwords. `.gitignore`
covers `/android/key.properties`, `/android/app/*.jks`, and
`/android/app/*.keystore`.

Throughout this document the key is named consistently:

| Thing | Value used here |
| --- | --- |
| Keystore backup location | `$HOME/ambulo-release-keystore.jks` |
| Keystore copy inside repo | `android/app/release-keystore.jks` (ignored) |
| Key alias | `ambulo-release` |

Substitute your own names if you prefer, but change them in *every* place —
including `ANDROID_KEY_ALIAS` in the GitHub secrets.

## Building without a keystore (contributors)

You do **not** need a signing key to work on Ambulo. Debug builds sign
themselves with the local Android debug key:

```bash
flutter build apk --debug
flutter run
```

Only maintainers cutting a release need the rest of this document.

## Create the keystore (one time)

Run this on a trusted machine. It writes the keystore *outside* the repository:

```bash
keytool -genkeypair -v \
  -keystore "$HOME/ambulo-release-keystore.jks" \
  -alias ambulo-release \
  -keyalg RSA -keysize 4096 -validity 10000
```

`keytool` prompts for a keystore password, a key password, and certificate
identity details (name/org/locale). For a self-signed open-source build the
identity fields are cosmetic — they show up in `keytool -printcert` output and
nowhere else — but they are baked into the certificate permanently, so pick
something you're willing to publish.

`-validity 10000` is ~27 years. Do not shorten it: an expired certificate
cannot sign further updates, and you cannot re-key without breaking installs.

Store both passwords and the `.jks` in a password manager or encrypted backup
now, before continuing. Inspect the certificate at any time (this prompts for
the keystore password but does not expose it):

```bash
keytool -list -v -keystore "$HOME/ambulo-release-keystore.jks" -alias ambulo-release
```

## Configure local builds

Copy the keystore into the ignored Android app directory:

```bash
cp "$HOME/ambulo-release-keystore.jks" android/app/release-keystore.jks
chmod 600 android/app/release-keystore.jks
```

Create `android/key.properties` with these exact property names (replace both
placeholders). `storeFile` is resolved relative to `android/app/`:

```properties
storeFile=release-keystore.jks
storePassword=YOUR_KEYSTORE_PASSWORD
keyAlias=ambulo-release
keyPassword=YOUR_KEY_PASSWORD
```

Confirm the configuration, then build signed APKs:

```bash
( cd android && ./gradlew verifyReleaseSigning )
flutter build apk --split-per-abi
```

`verifyReleaseSigning` checks that `key.properties` exists, defines all four
properties, and points at a keystore file that is actually present. It does
**not** validate the passwords — a wrong password fails later, during the
Gradle signing task itself, with a `keystore password was incorrect` error.

Outputs land in `build/app/outputs/flutter-apk/`. Verify the signer on the APK
you intend to hand out — use **`apksigner`**, from the Android SDK's
`build-tools/<version>/` directory:

```bash
apksigner verify --verbose --print-certs \
  build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

Expect `Verified using v2 scheme (APK Signature Scheme v2): true` and a
`Signer #1 certificate DN:` matching the identity you entered at keystore
creation.

> **Do not use `keytool -printcert -jarfile` on an APK.** It only understands
> v1 (JAR) signing, which the Android Gradle Plugin disables because Ambulo's
> `minSdk` is 26. It reports a correctly signed release APK as
> `Not a signed jar file` — a false negative that looks exactly like a real
> signing failure. `keytool -list -v` on the *keystore* is still correct; it is
> only the APK-inspection form that misleads.

If `key.properties` is absent, Gradle does **not** fall back to the debug key.
It would instead emit an *unsigned* APK under the exact same
`app-<abi>-release.apk` filename — nothing in the output distinguishes it, and
Android silently refuses to install it later. To close that trap, every
`assemble*Release` / `bundle*Release` task depends on `verifyReleaseSigning`
(`android/app/build.gradle.kts`), so an unconfigured release build fails
immediately with a message pointing here. Debug builds are unaffected.

### Which APK to hand out

`--split-per-abi` produces one APK per architecture, which keeps downloads
small but forces the recipient to know their device:

| APK | Use for |
| --- | --- |
| `arm64-v8a` | Effectively every Android phone from ~2017 onward |
| `armeabi-v7a` | Older 32-bit ARM devices |
| `x86_64` | Emulators, ChromeOS, x86 tablets |

The release workflow also builds a **universal** APK
(`ambulo-android-universal.apk`) that contains all three. It is roughly the
size of the three combined — point non-technical users at it when they can't
identify their ABI, and everyone else at `arm64-v8a`.

## Version bumps

Even without Play Store, Android compares `versionCode` on install: it refuses
to downgrade. Bump `version:` in `pubspec.yaml` before tagging a release —
Flutter maps `1.0.0+1` to `versionName=1.0.0` / `versionCode=1`, and the build
number after `+` is the part that must increase every release.

## Configure GitHub Actions

On GitHub, open **Settings → Secrets and variables → Actions → New repository
secret** and create all four:

| Secret | Value |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | Base64 encoding of the complete `.jks` file, no line wraps |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | `ambulo-release` |
| `ANDROID_KEY_PASSWORD` | Key password |

Generate the first value on macOS or Linux:

```bash
base64 < "$HOME/ambulo-release-keystore.jks" | tr -d '\n'
```

Paste that single line into `ANDROID_KEYSTORE_BASE64`.

`.github/workflows/release.yaml` decodes the keystore onto the ephemeral
runner, writes `android/key.properties`, runs `verifyReleaseSigning`, builds,
and deletes both files in an `always()` cleanup step. It fails immediately if
any of the four secrets is missing, so a fork without secrets gets a loud
error rather than an unsigned release.

**Forks and pull requests never receive these secrets.** GitHub withholds
repository secrets from `pull_request` runs originating in forks, and the test
workflow (`ci.yaml`) does not reference them at all.

## Running the release build

The workflow has two triggers:

**1. Publish a GitHub Release** (`release: [published]`) — builds Android +
web and attaches the four APKs, the web bundle, and one checksum file per
target (`SHA256SUMS-android.txt`, `SHA256SUMS-web.txt` — the Android and web
jobs run in parallel, so they cannot share a single filename). This is the
real distribution path.

```bash
# Bump pubspec.yaml version first, commit, then:
git tag v1.0.0 && git push origin v1.0.0
gh release create v1.0.0 --generate-notes
```

**2. Manual run** (`workflow_dispatch`) — from the Actions tab, or:

```bash
gh workflow run release.yaml
gh run watch
```

A dispatch run builds and signs exactly the same artifacts but uploads them as
**workflow artifacts** (downloadable from the run page for 30 days) instead of
attaching them to a release. Use it to test the signing pipeline, or to get a
signed build without publishing anything.

## Verifying a downloaded APK

Anyone can confirm a release APK matches what the workflow built. Download
`SHA256SUMS-android.txt` from the release into the same directory as the APK,
then:

```bash
sha256sum --check --ignore-missing SHA256SUMS-android.txt
```

`--ignore-missing` is what lets this pass when you downloaded only one of the
four APKs. On macOS use `shasum -a 256 --check --ignore-missing` instead.

And confirm it was signed by your key:

```bash
apksigner verify --print-certs ambulo-android-arm64-v8a.apk
```

The `Signer #1 certificate SHA-256 digest` it prints is your certificate
fingerprint. Publish that fingerprint in the README so users can detect a
substituted build — it is the closest a self-signed project gets to store
verification, and unlike the file checksums it stays constant across releases.

## iOS (not built by this workflow)

The release workflow builds Android and web only. iOS has no equivalent of
self-signed distribution: sideloading requires either an Apple Developer
Program membership ($99/yr) for ad-hoc/TestFlight distribution, or the user
building and signing locally with a free personal team (7-day install expiry).

For local iOS archives, sign in to Xcode with an Apple ID, select the **Runner**
target, set the Team under **Signing & Capabilities**, leave **Automatically
manage signing** enabled, then:

```bash
flutter build ipa --release
```

To add iOS to CI later, use a `macos-latest` matrix entry and store the
base64-encoded `.p12`, its password, the base64-encoded provisioning profile,
a keychain password, the team ID, and the profile UUID as secrets. Import the
certificate into a temporary keychain, install the profile under
`~/Library/MobileDevice/Provisioning Profiles/`, run `flutter build ipa`, and
delete the temporary keychain and profile in an `always()` cleanup step. Use
Fastlane `match` if more than one maintainer needs to rotate iOS assets.

## Release checklist

1. Back up the keystore and both passwords securely (do this once, first).
2. Set all four `ANDROID_*` repository secrets.
3. Bump `version:` in `pubspec.yaml`; the `+build` number must increase.
4. Run the workflow via `workflow_dispatch` once and verify the certificate on
   the downloaded artifact.
5. Publish the GitHub Release; confirm APKs and `SHA256SUMS` are attached.
6. Keep the keystore for every future update — it cannot be replaced.

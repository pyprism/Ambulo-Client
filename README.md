# Ambulo [![Tests](https://github.com/pyprism/Ambulo-Client/actions/workflows/ci.yaml/badge.svg)](https://github.com/pyprism/Ambulo-Client/actions/workflows/ci.yaml) [![codecov](https://codecov.io/gh/pyprism/Ambulo-Client/graph/badge.svg?token=wXEdmX4WZh)](https://codecov.io/gh/pyprism/Ambulo-Client)

Flutter client for [Ambulo](https://github.com/pyprism/Ambulo). A privacy first, self hostable location + fitness
tracker (an OwnTracks + Google Fit style app). Offline first: the local
Drift/SQLite database is the source of truth, and sync with your own server
is a manual, user triggered background reconciliation, never a blocking
requirement.

## Targets

- **Android + iOS (not tested)** — full sensor collection (location, steps, activity).
- **Web** — view/edit/import/export only. No sensor collection; login or
  register against a server is the first screen.

## Getting started

1. 
   ```
   flutter pub get
   flutter run # mobile: pick a connected device/emulator
   flutter run -d web-server # for running the web frotnend
   ```
2. (Optional )You need a running Ambulo server to sign in, sync, or use friend sharing.
   Mobile also supports a fully local only mode with no server at all onboarding lets you skip server setup entirely. 
   On web, a server is
   required (there's no local-only mode there).
   On first launch (or from Settings → server address), enter your server's
   base URL, e.g. `http://127.0.0.1:8000` for a local dev server.

## Web limitations

- No sensor collection (no GPS/pedometer/background tracking) — web is for
  viewing history, editing places/notes/workouts, and import/export.
- Drift's web backend needs two extra static assets that **must** be present
  and version-matched to the `sqlite3` package pin in `pubspec.yaml`:
  - `web/sqlite3.wasm` — download the matching version from the
    [sqlite3 GitHub releases](https://github.com/simolus3/sqlite3.dart/releases).
  - `web/drift_worker.js` — compiled from `web/drift_worker.dart`:
    ```
    dart compile js web/drift_worker.dart -o web/drift_worker.js
    ```
  Both are checked in; only regenerate them if you bump the `drift`/`sqlite3`
  package versions.

## Monitoring modes (mobile only)

Four modes, **Quit** by default: Quit (no tracking), Manual (record on tap
only), Significant (coarse OS driven tracking), Move (precise, foreground
service, opt in). Battery rules are enforced throughout: no `Timer` polling,
native low power location APIs, batched network I/O, adaptive back-off when
stationary.

## Tests

```
flutter analyze                              # static analysis
flutter test                                 # everything (see below)
flutter test test/import_export_test.dart    # one file
```

Most test files are pure unit/widget tests and always run. A few
(`*_integration_test.dart`) exercise a **live** Ambulo server at
`http://127.0.0.1:8000` (register/login/sync/friends/etc. round-trips) and
skip themselves automatically (printing why) if that server isn't reachable
— start your server's dev runner first if you want those to actually run
rather than skip.


import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// `android/key.properties` is intentionally ignored by Git. It is created
// locally or by the release workflow from GitHub Actions secrets.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning = keystorePropertiesFile.exists()

if (hasReleaseSigning) {
    keystorePropertiesFile.inputStream().use(keystoreProperties::load)
}

android {
    namespace = "com.ambulo.ambulo"
    // flutter_secure_storage's AAR metadata requires compileSdk 37+; Flutter's
    // own default (flutter.compileSdkVersion) still trails that.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications (Move-mode battery reminder) needs
        // java.time APIs desugared on API < 26.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.ambulo.ambulo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Health Connect's client library (androidx.health.connect:connect-client)
        // requires API 26+; overrides Flutter's default minSdk.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    if (hasReleaseSigning) {
        signingConfigs {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // Without key.properties there is no signing config at all; the
            // verifyReleaseSigning wiring below stops the build before it can
            // emit an unsigned artifact.
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

tasks.register("verifyReleaseSigning") {
    group = "verification"
    description = "Fails unless android/key.properties configures release signing."
    doLast {
        check(hasReleaseSigning) {
            "Missing android/key.properties — release build would be UNSIGNED.\n" +
                "Unsigned release APKs keep the normal app-<abi>-release.apk name but " +
                "Android refuses to install them.\n" +
                "Set up signing (see docs/RELEASE_SIGNING.md), or build a debug APK " +
                "instead: flutter build apk --debug"
        }

        val requiredProperties = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
        val missingProperties = requiredProperties.filter { keystoreProperties.getProperty(it).isNullOrBlank() }
        check(missingProperties.isEmpty()) {
            "android/key.properties is missing: ${missingProperties.joinToString()}"
        }

        val keystorePath = keystoreProperties.getProperty("storeFile")
        check(file(keystorePath).isFile) {
            "Android keystore not found: $keystorePath"
        }
    }
}

// An unsigned release APK is indistinguishable from a signed one by filename
// (both are app-<abi>-release.apk) and is useless — Android will not install
// it. Gate every release assemble/bundle task on the signing check so the
// failure happens up front with an actionable message rather than at install
// time on someone's phone. Debug builds are unaffected.
tasks.matching { it.name.matches(Regex("^(assemble|bundle).*Release$")) }.configureEach {
    dependsOn("verifyReleaseSigning")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.reader(Charsets.UTF_8).use { reader ->
        localProperties.load(reader)
    }
}

val flutterVersionCode = (localProperties.getProperty("flutter.versionCode") ?: "2").toInt()
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0.1"

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.trebuchetdynamics.fractal.forge"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.trebuchetdynamics.fractal.forge"
        // ARCore requirement baseline: API 24+
        minSdk = maxOf(flutter.minSdkVersion, 24)
        targetSdk = 35
        versionCode = flutterVersionCode
        versionName = flutterVersionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            val storeFileProp = keystoreProperties["storeFile"] as String?
            storeFile = if (storeFileProp != null) file(storeFileProp) else null
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        getByName("release") {
            // If key.properties is missing, sign with debug so local installs work.
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // Keep disabled while ARCore plugin is legacy/fragile under R8.
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

// Force ARCore to 1.44.0+ so its InstallService sets RECEIVER_NOT_EXPORTED,
// which Android 14 (API 34) requires.  arcore_flutter_plugin 0.1.0 bundles
// the ancient 1.13.0 SDK that crashes with a SecurityException on Android 14.
configurations.all {
    resolutionStrategy {
        force("com.google.ar:core:1.44.0")
    }
}

dependencies {
    // Play Core modular library for SDK 34+ compatibility
    // Replaces deprecated com.google.android.play:core:1.10.3
    implementation("com.google.android.play:feature-delivery:2.1.0")
    // Belt-and-suspenders: explicitly request the fixed ARCore version so Gradle's
    // conflict resolution picks it up even without the resolutionStrategy above.
    implementation("com.google.ar:core:1.44.0")
}

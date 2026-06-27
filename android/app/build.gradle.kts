import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // Flutter applies Kotlin support for projects that use Kotlin sources.
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
val releaseStoreFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
val hasReleaseSigning = keystorePropertiesFile.exists() &&
    releaseStoreFile?.exists() == true &&
    keystoreProperties["keyAlias"] != null &&
    keystoreProperties["keyPassword"] != null &&
    keystoreProperties["storePassword"] != null

android {
    namespace = "com.trebuchetdynamics.fractal.forge"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.trebuchetdynamics.fractal.forge"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutterVersionCode
        versionName = flutterVersionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = releaseStoreFile
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

gradle.taskGraph.whenReady {
    val releaseTaskRequested = allTasks.any { task ->
        task.name.contains("Release", ignoreCase = false)
    }
    if (releaseTaskRequested && !hasReleaseSigning) {
        throw GradleException(
            "Release builds require android/key.properties and a valid keystore; debug signing is not allowed for release.",
        )
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Android 15 edge-to-edge compatibility helpers used by MainActivity.
    implementation("androidx.core:core:1.16.0")

    // Play Core modular library for SDK 34+ compatibility
    // Replaces deprecated com.google.android.play:core:1.10.3
    implementation("com.google.android.play:feature-delivery:2.1.0")
}

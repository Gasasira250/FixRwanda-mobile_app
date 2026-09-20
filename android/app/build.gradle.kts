import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.reader(Charsets.UTF_8).use { localProperties.load(it) }
}

val mapsApiKey =
    (project.findProperty("MAPS_API_KEY") as String?)
        ?: System.getenv("MAPS_API_KEY")
        ?: localProperties.getProperty("MAPS_API_KEY")
        ?: ""

if (mapsApiKey.isBlank()) {
    println(
        "WARNING: MAPS_API_KEY is empty. Google Maps will stay blank on Android. " +
            "Set MAPS_API_KEY in android/local.properties or as an environment variable.",
    )
}

android {
    namespace = "rw.fixrwanda.fix_rwanda"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "rw.fixrwanda.fix_rwanda"
        minSdk = maxOf(21, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

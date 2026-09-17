import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

fun loadKeystoreProperties(fileName: String): Properties {
    val properties = Properties()
    val propertiesFile = rootProject.file(fileName)
    if (propertiesFile.exists()) {
        properties.load(FileInputStream(propertiesFile))
    }
    return properties
}

val vectorKeystoreProperties = loadKeystoreProperties("key.properties")
val exitexamKeystoreProperties = loadKeystoreProperties("key_exitexam.properties")
val remedialKeystoreProperties = loadKeystoreProperties("key_remedial.properties")

android {
    namespace = "com.vector_academy.app"
    compileSdk = flutter.targetSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // fvp and flutter_pdfview (pdfium) both ship libc++_shared.so.
    packaging {
        jniLibs {
            pickFirsts += "lib/**/libc++_shared.so"
        }
    }

    defaultConfig {
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (vectorKeystoreProperties.isNotEmpty()) {
            create("vectorAcademyRelease") {
                keyAlias = vectorKeystoreProperties["keyAlias"] as String
                keyPassword = vectorKeystoreProperties["keyPassword"] as String
                storeFile = vectorKeystoreProperties["storeFile"]?.let { file(it) }
                storePassword = vectorKeystoreProperties["storePassword"] as String
            }
        }
        if (exitexamKeystoreProperties.isNotEmpty()) {
            create("exitexamRelease") {
                keyAlias = exitexamKeystoreProperties["keyAlias"] as String
                keyPassword = exitexamKeystoreProperties["keyPassword"] as String
                storeFile = exitexamKeystoreProperties["storeFile"]?.let { file(it) }
                storePassword = exitexamKeystoreProperties["storePassword"] as String
            }
        }
        if (remedialKeystoreProperties.isNotEmpty()) {
            create("remedialRelease") {
                keyAlias = remedialKeystoreProperties["keyAlias"] as String
                keyPassword = remedialKeystoreProperties["keyPassword"] as String
                storeFile = remedialKeystoreProperties["storeFile"]?.let { file(it) }
                storePassword = remedialKeystoreProperties["storePassword"] as String
            }
        }
    }

    flavorDimensions += "app"
    productFlavors {
        create("vector_academy") {
            dimension = "app"
            applicationId = "com.vector_academy.app"
            resValue("string", "app_name", "Entrance Tricks")
            signingConfigs.findByName("vectorAcademyRelease")?.let { signingConfig = it }
        }
        create("exitexam") {
            dimension = "app"
            applicationId = "com.ethioexitexam.app"
            resValue("string", "app_name", "Ethio Exit Exam")
            signingConfigs.findByName("exitexamRelease")?.let { signingConfig = it }
        }
        create("remedial") {
            dimension = "app"
            applicationId = "com.remedialtricks.app"
            resValue("string", "app_name", "Remedial Tricks")
            signingConfigs.findByName("remedialRelease")?.let { signingConfig = it }
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            // Do not set signingConfig here: it would override per-flavor release keys.
        }
    }
}

flutter {
    source = "../.."
}

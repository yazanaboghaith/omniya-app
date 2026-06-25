// plugins {
//     id("com.android.application")
//     id("kotlin-android")
//     id("dev.flutter.flutter-gradle-plugin")
//     id("com.google.gms.google-services")
//     id("com.google.firebase.crashlytics")
// }

// android {
//     namespace = "com.example.omniya"
//     compileSdk = flutter.compileSdkVersion
//     ndkVersion = flutter.ndkVersion

//     compileOptions {
//         isCoreLibraryDesugaringEnabled = true
//         sourceCompatibility = JavaVersion.VERSION_17
//         targetCompatibility = JavaVersion.VERSION_17
//     }

//     kotlinOptions {
//         jvmTarget = JavaVersion.VERSION_17.toString()
//     }

//     defaultConfig {
//         applicationId = "com.example.omniya"
//         minSdk = 28
//         targetSdk = flutter.targetSdkVersion
//         versionCode = flutter.versionCode
//         versionName = flutter.versionName
//     }

//     buildTypes {
//         release {
//             signingConfig = signingConfigs.getByName("debug")
//         }
//     }
// }

// dependencies {
//     coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
//     implementation(platform("com.google.firebase:firebase-bom:33.1.0"))
//     implementation("com.google.firebase:firebase-crashlytics")

// }

// flutter {
//     source = "../.."
// }
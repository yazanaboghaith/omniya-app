plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

android {
    namespace = "com.example.omniya"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.omniya"
        
        // 1. استهداف أندرويد 9 (API 28) فما فوق لحذف ملفات التوافقية القديمة وتصغير الحجم
        minSdk = 28
        
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // إعداد التوقيع الحالي الخاص بك
            signingConfig = signingConfigs.getByName("debug")
            
            // 2. تفعيل تقنيات الضغط المتقدمة (R8 Optimizer) لحذف الأكواد غير المستخدمة وتشفيرها
            isMinifyEnabled = true
            
            // 3. تفعيل ضغط وحذف ملفات الـ Assets والموارد غير المستخدمة داخل التطبيق
            isShrinkResources = true
            
            // 4. استدعاء ملفات قواعد الضغط القياسية للأندرويد
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))
    implementation("com.google.firebase:firebase-crashlytics")
}

flutter {
    source = "../.."
}






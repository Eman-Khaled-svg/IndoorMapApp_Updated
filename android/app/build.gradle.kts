plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.indoormap"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.indoormap"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion  // غيّر من flutter.minSdkVersion إلى 21
        targetSdk = flutter.targetSdkVersion 
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
           signingConfig signingConfigs.debug
           minifyEnabled false     // خلي دي false
           shrinkResources false   // أضف السطر ده
        }
    }
}

flutter {
    source = "../.."
}
dependencies {
    implementation("com.google.android.gms:play-services-maps:18.2.0") // استخدم أحدث إصدار (18.2.0 هو مثال، تحقق من pub.dev للحصول على الأحدث)
}

# 🚀 Checkout.com Flutter Flow Integration using iOS and Android Native SDKs

A Flutter application that demonstrates seamless integration with [Checkout.com's Flow SDK](https://www.checkout.com/docs/payments/accept-payments/accept-a-payment-on-your-mobile-app/get-started-with-flow-for-mobile) using **Platform Views** on both **Android** and **iOS**.

- 💳 Card payments
- 🧾 Google Pay (Android)
- 🍏 Apple Pay (iOS)
- 🌊 Full Flow Component (Card + Apple Pay / Google Pay combined)
---

## 📱 Screens

The app consists of two buttons:

- **Card Payment**: Loads the Card UI component.
- **Google Pay / Apple Pay**: Loads the native wallet component (based on platform).
- **Pay with Flow**: Loads the full Checkout Flow experience, including wallet and card options.
---

## 🔧 Project Structure

```
ios/ 
└── Runner/ 
  ├── AppDelegate.swift # Registers method channel and both native view factories 
  ├── CheckoutPlatformView1.swift # Contains: 
    │├── CheckoutCardPlatformView1 # Card UI with SwiftUI 
    │├── CheckoutApplePayPlatformView1 # Apple Pay UI with SwiftUI 
    │├── CheckoutCardViewFactory1 
    │├── CheckoutApplePayViewFactory1 
    │├── CheckoutFlowViewFactory1 
    │├── CheckoutFlowPlatformView1
    │└── DummyPlatformView1 # Displays fallback for unsupported iOS versions
android/
└── app/src/main/java/kotlin/com/example/flow_flutter_new/ 
  ├── MainActivity.kt # Extends FlutterFragmentActivity, registers view factories 
  ├── CardPlatformView.kt # Renders Checkout Card UI using Compose 
  ├── CardViewFactory.kt # Factory for Card component 
  ├── GooglePayPlatformView.kt # Renders Google Pay UI using Compose 
  ├── GooglePayViewFactory.kt # Factory for Google Pay component 
  ├── FlowPlatformView.kt # Renders Flow UI using Compose 
  ├── FlowViewFactory.kt # Factory for Flow component 
```

---

## 📲 iOS Integration

### 🔹 Files
- `AppDelegate.swift`: Registers platform views and method channel
- `CheckoutPlatformView1.swift`: Contains Card, Apple Pay and Flow renderers using SwiftUI

### 🔹 Apple Pay Setup
Make sure you:
- Add your `merchantIdentifier` (e.g., `merchant.com.flowmobile.checkout`)
- Enable **Apple Pay capability** in Xcode
- Use iOS 13+ (for SwiftUI compatibility)

> Note: Real devices are required to test Apple Pay.

### 🔹 Permissions
No additional `Info.plist` permissions required for Apple Pay.

---

## 🤖 Android Integration

### ✅ Gradle Configuration

#### 🔹 Project-level `build.gradle.kts`
```kotlin
repositories {
    gradlePluginPortal()
    google()
    mavenCentral()
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
        maven { url = uri("https://maven.fpregistry.io/releases") }
    }
}
```

#### 🔹 App-level `build.gradle.kts`
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    compileSdk = 35
    defaultConfig {
        applicationId = "com.example.flow_flutter_new"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
    }
    buildFeatures { compose = true }
    composeOptions { kotlinCompilerExtensionVersion = "1.5.3" }
    kotlinOptions { jvmTarget = JavaVersion.VERSION_11.toString() }
}

dependencies {
    implementation("com.checkout:checkout-android-components:1.0.0-beta-1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.7")
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.8.7")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.7")
    implementation("androidx.lifecycle:lifecycle-extensions:2.2.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel:2.9.0-alpha13")
    implementation("androidx.savedstate:savedstate:1.2.1")
    implementation("androidx.activity:activity-compose:1.10.1")
    implementation(platform("androidx.compose:compose-bom:2025.03.01"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
    implementation("com.google.android.gms:play-services-wallet:19.4.0")
    implementation("com.google.android.gms:play-services-base:18.6.0")
}
```

### 🔹 Manifest Permissions
```xml
<uses-permission android:name="android.permission.INTERNET"/>

<application>
    <meta-data android:name="com.google.android.gms.wallet.api.enabled" android:value="true"/>
</application>
```

### 🔹 Requirements
- Make sure you use `FlutterFragmentActivity` instead of `FlutterActivity` to support Google Pay lifecycle.
- Test on **real device** for Google Pay.

---

## 🧪 Flutter UI

> In this demo we created a HomeScreen to display 3 buttons that initiate bottom sheets for Card, GooglePay/ApplePay and full Flow component.

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const platform = MethodChannel("checkout_bridge");

  Future<void> _launchCheckout(String viewType) async {
    await platform.invokeMethod("initializeCheckout", {
      "paymentSessionID": "your-session-id",
      "paymentSessionSecret": "your-secret",
      "publicKey": "your-public-key"
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Checkout.com Flow')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _launchCheckout("flow_card_view"),
              child: Text("Pay with Card"),
            ),
            ElevatedButton(
              onPressed: () => _launchCheckout("flow_googlepay_view"),
              child: Text("Pay with Google Pay / Apple Pay"),
            ),
            ElevatedButton(
              onPressed: () => _launchCheckout("flow_flow_view"),
              child: Text("Pay with Flow"),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🧾 Final Notes

- Make sure your **Apple Pay merchant ID** is valid and configured on Apple Developer Portal.
- Use correct payment session values by calling the /payment-sessions API
  - For Android: update payment session id, paymentSessionToken (in this demo it is added in card and googlepay platformView.kt) and paymentSessionSecret.
  - For iOS: update only payment session id and paymentSessionSecret.

---

## 🔥 Running the App
```bash
flutter pub get
flutter run
```

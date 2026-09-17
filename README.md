# Campersit Mobile

<p align="center">
  <img src="assets/images/logo.png" alt="Campersit Logo" width="160" />
</p>

A Flutter mobile application designed to monitor and manage IoT gateways, sensors, and actuators for campers and RVs using Firebase as the cloud backend.

---

## 📋 About the Project

**Campersit Mobile** allows users to:
- Authenticate securely via Firebase (Email/Password).
- Monitor real-time telemetry from connected sensors (temperature, air quality, motion, etc.).
- Manage gateways and configure alert thresholds or actuators remotely.

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- [Firebase CLI](https://firebase.google.com/docs/cli) and [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) (recommended).
- An Android/iOS emulator or a physical device connected.

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/dabredo/campersit-app.git
   cd campersit-app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   Generate the `lib/firebase_options.dart` file and native configuration for your Firebase project:
   ```bash
   flutterfire configure
   ```
   *(Alternatively, copy `lib/firebase_options.dart.example` to `lib/firebase_options.dart` and fill in your Firebase project credentials manually).*

4. **Run the application:**
   ```bash
   flutter run
   ```

---

## 🧪 Running Tests

To run the automated widget and unit tests:

```bash
flutter test
```

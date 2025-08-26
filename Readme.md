# Submee

A modern Flutter application built with best practices and a focus on performance.

## Table of Contents

- [Overview](#overview)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Environment Setup](#environment-setup)
- [Architecture](#architecture)
- [Development](#development)
  - [Key Management](#key-management)
  - [Building](#building)
- [Deployment](#deployment)
- [License](#license)

## Overview

Submee is a Flutter application designed to provide a seamless user experience with a focus on performance and maintainability. The app utilizes modern design principles and state management solutions to ensure a smooth and responsive interface.

## Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (version 3.27.1 or higher)
- [Dart](https://dart.dev/get-dart) (version 3.6.0 or higher)
- Android Studio or VS Code with Flutter extensions
- For iOS development: Xcode (latest version)
- For Android development: Android SDK

### Installation

1. Clone the repository:
   ```bash
   git clone 	git@github.com:krupikivan/subletme_mobile.git
   cd subletme_mobile
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Generate localization files:
   ```bash
   flutter pub run intl_utils:generate
   ```

4. Run the app:
   ```bash
   flutter run
   ```

### Environment Setup
Create a file at /assets/environment/local.env with the following variables:

```
API_BASE_URL=
GOOGLE_CLIENT_ID_SIGN_IN=
ENVIRONMENT=
VERSION_API_KEY=
```

## Architecture

This project follows a clean architecture pattern with:

- UI Layer: Flutter widgets and screens
- Business Logic Layer: State management with [Riverpod]
- Data Layer: Repositories and data sources
- Domain Layer: Business models and use cases

## Development

### Key Management

#### Check the debug key info

```bash
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android
```

#### Check the release key info

```bash
keytool -list -v \
-alias submeeAlias -keystore ./android/keystore/keystore.jks
```

### Building

#### Debug Build

```bash
flutter build apk --debug
# or for iOS
flutter build ios --debug
```

#### Release Build

```bash
flutter build appbundle --release
# or for iOS
flutter build ipa --release
```

## License

This project is licensed under the [MIT License](LICENSE).
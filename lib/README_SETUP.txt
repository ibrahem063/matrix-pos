Market POS Firebase - lib folder

Add these dependencies in pubspec.yaml:

dependencies:
  flutter:
    sdk: flutter
  firebase_core: any
  firebase_auth: any
  cloud_firestore: any
  provider: any
  intl: any

Setup:
1. Create Firebase project.
2. Enable Authentication > Email/Password.
3. Enable Firestore Database.
4. Run:
   dart pub global activate flutterfire_cli
   flutterfire configure
5. Put this lib folder in your Flutter project.
6. Run:
   flutter pub get
   flutter run

Firestore collections used:
- users
- products
- sales
- sales/{saleId}/items
- daily_reports
- daily_reports/{dayId}/top_products

Important:
The first account can be created from the Login screen using "إنشاء حساب Admin".

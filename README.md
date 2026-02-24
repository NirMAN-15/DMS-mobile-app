# DMS Mobile Application

Welcome to the offline-first **Distribution Management System (DMS)** mobile application built with Flutter & SQLite.
This single document explains exactly what every generated file in the codebase does, in simple terms.

---

## 1. Project Setup
### `pubspec.yaml`
**What it is:** The configuration file for your Flutter project.
**What happens here:** It tells Flutter what external tools and libraries your app needs to run.
**Core Features:**
* **`sqflite` & `path`:** The "engines" for the local SQLite database, allowing the app to store data directly on the phone for offline use.
* **`cupertino_icons`:** Adds standard Apple-style UI icons so the app looks native.

### `lib/main.dart`
**What it is:** The Starting Engine of the app.
**What happens here:** It's the very first piece of code that runs. It sets up the UI and decides which screen to show the user first.
**Core Features:**
* **Database Pre-Check:** Before the UI even draws, it wakes up the `DatabaseHelper` and checks if the user currently has an active offline session.
* **Smart Routing:** If the user is already logged in, it skips the `LoginScreen` and navigates straight into the `RouteListScreen` dashboard. If not, it forces them to login.

---

## 2. Global Styling & Design
### `lib/core/app_colors.dart` & `lib/core/app_theme.dart`
**What they are:** The central design system for the app.
**What happens here:** Instead of hard-coding the color "blue" or specific font sizes on every single screen, we define styles once here. 
**Core Features:**
* **Custom Color Palette:** Defines the primary blue, accent colors, text colors, and error colors. Rebranding is as simple as changing one color code.
* **Global Theme (`AppTheme.lightTheme`):** Automatically applies consistent styles everywhere. AppBars default to blue, TextFields get rounded borders, and ElevatedButtons have correct padding globally.

---

## 3. Data Blueprints 
### `lib/models/shop.dart`
**What it is:** The data blueprint (or template) for a "Shop".
**What happens here:** It tells the app exactly what information a shop must have (ID, name, address, GPS coordinates, and whether the salesperson visited it yet).
**Core Features:**
* **`toMap()`:** A translator function. SQLite databases can only read simple Maps (dictionaries), not complex Dart objects. This converts the `Shop` object into a database-friendly format.
* **`fromMap()`:** The reverse translator. When reading data from SQLite, this converts it back into a Dart `Shop` object that the UI can easily display.

---

## 4. Offline Database Logic
### `lib/data/database_helper.dart`
**What it is:** The "Kitchen" or the Database Manager.
**What happens here:** This is the most crucial file for offline mode. It creates, opens, reads, and writes to the local SQLite database stored safely on the phone's hard drive.
**Core Features:**
* **Singleton Pattern:** Ensures the app only opens one connection to the database at a time to prevent crashes.
* **Table Creation:** Automatically creates the `shops` table to store locations and the `auth_session` table to handle offline logins.
* **Dummy Data Injector:** Automatically adds fake shops when the app installs, so you can test the UI easily on Day 1.
* **Core Functions:** Has methods to `login()`, check if `isLoggedIn()`, `getShops()`, and `markShopVisited()`.

---

## 5. User Interface (Screens)
### `lib/screens/login_screen.dart`
**What it is:** The page the user sees if they aren't logged in.
**What happens here:** It presents a branded login form. When the user clicks "Login", it communicates with the `DatabaseHelper` to create a secure offline session.
**Core Features:**
* **Form Validation:** Checks if both text inputs are filled out.
* **Loading State:** The button displays a circular loading spinner when clicked, preventing double-clicks.
* **Mock Auth:** Saves a fake "JWT Token" into the SQLite `auth_session` table so the app remembers the user across app restarts.

### `lib/screens/route_list_screen.dart`
**What it is:** The main dashboard or "Waiter's Notepad" for the sales representative.
**What happens here:** It displays a list of all shops the rep needs to visit today, driven entirely by the offline SQLite database.
**Core Features:**
* **Offline Banner:** Shows a visual banner at the top letting the rep know they are safely working in offline mode.
* **Dynamic Status Update:** Clicking "Visit" on a shop safely updates that row in the database. The screen instantly refetches the data, hiding the visit button and showing a green checkmark.
* **Mock Sync:** Has a sync button that simulates pushing these localized SQLite changes up to the cloud.

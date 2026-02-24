# Distribution Management System (DMS) - Mobile App

## 📱 Project Overview
This repository contains the mobile application for our Distribution Management System (DMS). In our system's architecture, this mobile app acts as the "waiter taking orders" out in the field. It is designed specifically for sales representatives to manage their daily routes, process orders, and sync data seamlessly.

## 🛠 Tech Stack
* **Framework:** Flutter (Dart)
* **Local Storage:** SQLite (for offline data storage)
* **Backend Integration:** Connects to a Node.js/Express backend using a PostgreSQL database hosted on Supabase
* **Security:** JWT (JSON Web Tokens) for API authentication over HTTPS

## ✨ Key Features
* **Offline-First Capabilities:** Built with an "Offline Mode" magic trick, allowing reps to work without an active internet connection.
* **Morning Sync:** Sales reps can download their daily product lists and shop data at the start of the day.
* **Order Processing:** Create orders and calculate totals completely offline.
* **Hardware Integration:** Print physical invoices to a 58mm Bluetooth POS printer directly from the app.
* **Location Services:** Captures GPS coordinates during the onboarding of new customer shops.
* **Cloud Syncing:** Automatically syncs offline orders back to the central database once an internet connection is restored.

## 📂 Strict File Structure
All code must be placed exactly according to this blueprint. **Do not invent new folder structures.** ```text
dms_mobile/
├── lib/
│   ├── core/            # Constants, colors, theme
│   ├── data/            # Local SQLite database setup (database_helper.dart)
│   ├── models/          # Data blueprints (Product, Order, Shop)
│   ├── screens/         # UI pages (LoginScreen, CartScreen, PrintScreen)
│   ├── services/        # API calls (api_service.dart) & Bluetooth config
│   ├── widgets/         # Reusable UI (CustomCards, AppBars)
│   └── main.dart        # App entry point
├── pubspec.yaml         # Package dependencies

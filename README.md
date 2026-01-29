# Insurance Claim Management System

A Flutter web app for managing hospital insurance claims. Built as part of my internship assignment.

**Live Demo:** https://insurance-claim-app-gk.web.app

## What it does

This app helps manage insurance claims for hospitals. You can:

- Create claims for patients with their policy details
- Add multiple bills to each claim
- Track advances paid and settlement amounts
- The app automatically calculates pending amounts
- Move claims through different statuses (Draft → Submitted → Approved/Rejected → Settled)

## Features

- **Dashboard** - See all claims at a glance, filter by status, search by patient name
- **Claim Management** - Create, edit, view claim details
- **Bill Tracking** - Add/edit/delete bills, automatic total calculation
- **Status Workflow** - Claims follow a proper workflow (can't skip steps)
- **Dark Mode** - Because why not
- **Analytics** - Some charts showing claim statistics
- **Cloud Sync** - Data stored in Firebase Firestore

## Status Flow

```
Draft → Submitted → Approved → Partially Settled → Settled
                  ↘ Rejected (end state)
```

## Tech Stack

- Flutter (Web)
- Firebase Firestore for database
- Firebase Hosting for deployment
- Provider for state management

## Running Locally

```bash
# Install dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome
```

## Project Structure

```
lib/
├── main.dart
├── models/          # Data models (Claim, Bill, etc.)
├── providers/       # State management
├── screens/         # App screens
├── widgets/         # Reusable UI components
├── services/        # Firebase & storage
└── utils/           # Helpers, constants, theme
```

## Screenshots

The app has a clean UI with:
- Stats cards showing totals
- Claim cards with status badges
- Filter tabs for quick filtering
- Search and sort options

## Assignment Requirements

This was built for a Flutter Intern assignment. Requirements covered:
- Patient claim creation ✓
- Bills, advances, settlements management ✓
- Status workflow (Draft/Submitted/Approved/Rejected/Partially Settled) ✓
- Add/edit bills with auto calculations ✓
- Dashboard view ✓
- Deployed on web ✓

## Links

- **Live App:** https://insurance-claim-app-gk.web.app
- **GitHub:** https://github.com/GAURAV834KUMAR/insurance-claim-app

---

Made by Gaurav Kumar

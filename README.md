# 🚀 Startup Idea Evaluator AI & Voting App

[![Flutter Version](https://img.shields.io/badge/Flutter-%E2%89%A53.38-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-%E2%89%A53.10-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![State Management](https://img.shields.io/badge/State-Provider%20v6-8A2BE2?logo=dart)](https://pub.dev/packages/provider)
[![Platform Compatibility](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-4CAF50)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An enterprise-grade, beautifully designed Flutter application to submit, evaluate, upvote, and rank startup pitches. Powered by **interactive simulated AI analysis** and backed by robust **local persistent storage**. The application incorporates high-fidelity Material 3 design tokens, native device clipboard integrations, staggered entry animations, and fully automatic theme transitions (Light & Dark modes).

---

## 🎨 Premium Visual Highlights
- **Staggered Motion Design**: Staggered fade-and-slide entry animations on lists and leaderboard podium blocks.
- **Micro-interactions**: Elastic bouncing feedback on upvote actions and interactive radial badge color coding.
- **Futuristic AI Processing Overlay**: Immersive loading sequences simulating heavy multi-stage analysis steps when evaluating pitch feasibility.
- **Podium Rankings**: A gorgeous 3D-styled physical podium showcasing 1st, 2nd, and 3rd place champions complete with gold, silver, and bronze trophies.

---

## 🛠️ The Tech Stack

The application has been engineered for high-performance and lightweight overhead:

| Technology / Library | Purpose | Key Benefit |
| :--- | :--- | :--- |
| **Flutter & Dart SDK** | Multiplatform framework & compiler | Compile native code across 6 operating systems from a single codebase. |
| **SharedPreferences** | Local SQLite/Shared Preference wrapper | Persist startup lists and theme preferences across app launches instantly. |
| **Provider** | Reactive State Management | Implements standard dependency injection & unidirectional reactive state trees. |
| **Uuid** | Unique Identifier Generator | Generates globally unique cryptographically strong v4 IDs for every pitch. |
| **Google Fonts** | Custom Typography Integration | Bundles the high-premium *Outfit* (for displays) & *Inter* (for bodies) font styles. |

---

## ✨ Application Features

### 📝 1. AI Pitch Evaluator (Submission Screen)
- Interactive forms with validation rules (minimizing layout failures).
- Real-time text analyzer that simulated-scores concepts from **65 to 98/100**, rewarding highly detailed descriptions.
- Engaging animated progress overlay demonstrating market fit analysis, rival evaluations, and scalability estimations.
- Instant, smooth navigation redirecting users to the explore dashboard upon submission completion.

### 🔍 2. Explore Pitches (Listing Screen)
- Seamless ListView of all concepts featuring expandable details.
- Tap a card's "Read Full Pitch" to slide open the description using performance-friendly `AnimatedCrossFade`.
- Color-coded AI score tags matching evaluated category grades (Gold for Unicorn Class, Violet for High Potential, Teal/Blue for Solid Concepts).
- Segmented header button to sort lists descending **By Vote Count** or **By AI Rating** instantly.

### 🏆 3. Leaderboard Podium (Top 5 Ranking)
- Limits displayed concepts strictly to the **Top 5 highest upvoted ideas**.
- Dynamic physical podium displaying 1st, 2nd, and 3rd rank placeholders.
- Seamlessly handles cases where fewer than three ideas are available, with custom fallback empty state layouts.

### 🌓 4. Seamless Dark Mode Toggle
- Floating sun/moon action button available inside the app's transparent top bar.
- Instantly toggles themes across Slate-themed Dark Mode and Slate-Clean Light Mode.
- Persists user preferences dynamically in the SharedPreferences storage directory so the choice is remembered.

### 📋 5. Clipboard Smart Share
- A designated share button positioned on each individual concept card.
- Tapping copies clean markdown-styled startup details (Title, Tagline, AI Rating) to the clipboard.
- Displays a custom, beautiful floating SnackBar indicating successful copying.

---

## 🚀 How to Run Locally

Follow these step-by-step terminal instructions to build, inspect, and execute the project locally.

### Prerequisites
Make sure you have [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and configured on your system. Run `flutter doctor` to confirm.

### Step 1: Clone and Navigate
Clone this repository (or download the source directory) and enter the directory in your terminal:
```bash
cd startup_evaluator
```

### Step 2: Fetch Dependencies
Download the package dependencies from pub.dev:
```bash
flutter pub get
```

### Step 3: Verify Code Health
Run a static analysis check to ensure the code compiles without syntax warnings or errors:
```bash
flutter analyze
```

### Step 4: Launch the App
Run the app on a connected device (physical phone, web browser, or simulator):
```bash
flutter run
```
> [!TIP]
> If multiple devices are available, you can target specific platforms. For example:
> - Run in Chrome: `flutter run -d chrome`
> - Run in an Android Emulator: `flutter run -d emulator`

---

## 📦 Downloads & Walkthroughs

* 📱 **[APK Download Link](https://drive.google.com/file/d/1KlGDMYiFaIcPw6jzvW7w1DWyw2z7_YLY/view?usp=sharing)**
* 🎥 **[Video Walkthrough YouTube Link](https://www.loom.com/share/e68630629de9457f925ad1a9fe656166)** 

---

## 📁 Clean Architecture Folder Structure

The project has been organized into a robust structure inside the `lib/` directory:

```text
lib/
├── main.dart                 # Application entry point, Theme Configurations & Root Shell
├── models/
│   └── idea.dart             # Pitch Data Model (JSON serialization & copyWith)
├── services/
│   └── idea_service.dart     # ChangeNotifier managing states, seeds & SharedPreferences
└── screens/
    ├── idea_submission_screen.dart # AI form submissions and loaders
    ├── idea_listing_screen.dart    # ListView explore catalog, expansions & filters
    └── leaderboard_screen.dart     # Top 5 podium podium list & animators
```

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

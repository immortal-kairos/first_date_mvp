# Dating App MVP - Project Context & Rules

## 1. Project Vision & Persona
- **Goal:** A badass, high-vibe dating app prioritizing authentic connections.
- **Vibe:** Bold, high-performance, and direct.
- **Strict Rule:** Never suggest or implement features related to smoking, alcohol, or drugs.
- **Philosophy:** "Logic First." Verify matching algorithms with unit tests before building UI.

## 2. Tech Stack
- **Frontend:** Flutter (Mobile)
  - **State Management:** `flutter_bloc` (Strictly used for logic/state separation).
  - **Routing:** `go_router`.
  - **Styling:** Material 3, Hot Pink (`0xFFFF4081`) primary.
- **Backend:** - **Auth/Data:** Firebase (Auth, Firestore).
  - **AI Logic:** Python (FastAPI/Flask) for matching algorithms (Planned).
- **Local AI:** Ollama (qwen2.5-coder:7b) for local development assistance.

## 3. Key Commands (PowerShell)
- **Run (Dev):** `flutter run | Tee-Object -FilePath "error_log.txt"` (Auto-logs errors)
- **Run (Clean):** `flutter run`
- **Build APK:** `flutter build apk`
- **Clean Project:** `flutter clean; flutter pub get`
- **Lint:** `flutter analyze`
- **Fix Imports:** `flutter pub deps` (Check installed packages)

## 4. Architecture & Structure
- `/lib`
  - `/auth`: Authentication logic (Blocs) and Screens.
  - `/features`: Feature-based modular structure (e.g., `/chat`, `/matching`).
  - `main.dart`: Entry point, Firebase Init, and Router config.
- `/backend` (Planned): Python logic for AI matching.

## 5. Implementation Guidelines
- **State Management:** Always use `BlocProvider` and `BlocBuilder`. Avoid `setState` for complex logic.
- **Security:** Use environment variables for API keys. Never hardcode secrets.
- **Imports:** Use absolute imports (e.g., `import 'package:first_date/auth/...'`) to avoid path errors.
- **Error Handling:** All network/Firebase requests must be wrapped in `try-catch` blocks with user-friendly error messages (SnackBars).

## 6. Current Status (Feb 2026)
- **Infrastructure:** Firebase connected, Google Services configured.
- **Auth:** Phone Login UI and Logic (`AuthBloc`) implemented.
- **Next Step:** OTP Verification and Profile Creation.
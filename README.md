# 📸 Story App (Flutter)

A Flutter-based mobile application that allows users to share and explore stories with images. This app integrates user authentication, RESTful API interaction, and advanced declarative navigation.

## 🚀 Features

### 🔐 Authentication
- Login and Register screens with secure password input (obscured characters).
- Session and token are saved using Shared Preferences.
- Redirects users based on session status:
  - Logged-in users go directly to the main page.
  - Unauthenticated users are redirected to the login screen.
- Logout functionality to clear session and token data.

### 📰 Story Page
- Displays a list of stories from the API.
- Shows user name and photo for each story.
- Tap on a story to see its details including:
  - User name
  - Image
  - Description

### ➕ Add Story
- Allows users to upload a new story.
- Upload includes an image and a short description.
- Sends story data to the API.

### 🧭 Advanced Navigation
- Uses declarative navigation for clean and scalable route management.

---

## 🛠 Tech Stack
- Flutter & Dart
- RESTful API integration
- Provider (for state management)
- Shared Preferences (for session management)
- Declarative Navigation 2.0

---

## 📷 Screenshots

![Story App Screenshot](https://raw.githubusercontent.com/fikrihandy/fikrihandy.github.io/refs/heads/abdullah-web/assets/img/portfolio/story-app-flutter.png)


---

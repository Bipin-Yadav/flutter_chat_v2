# ⚡ Telegram-Style Realtime Chat App with WebRTC Video & Audio Calling

A premium, full-stack real-time chat application built with **Flutter**, **Node.js (TypeScript)**, **MySQL**, and **WebRTC** for immersive audio and video calls. The user interface has been fully redesigned to mimic the clean, minimalist look and feel of **Telegram**.

---

## 📸 Screenshots & Demo

> [!TIP]
> Create a folder named `screenshots` in the root of this project and place your images inside. Name them exactly as shown below (`conversations.png`, `chat.png`, `login.png`, `call.png`) to load them directly into this README!

| **Conversations List** | **Chat Room** |
|:---:|:---:|
| ![Conversations Screen](screenshots/conversations.png) | ![Chat Screen](screenshots/chat.png) |

| **Clean Minimalist Login** | **Real-Time WebRTC Call** |
|:---:|:---:|
| ![Login Screen](screenshots/login.png) | ![Call Screen](screenshots/call.png) |

---

## ✨ Features

* **💬 Telegram-Style UI**: A beautiful, minimalist redesign featuring a clean primary Telegram Blue theme, thin dividers, sliding **Sidebar Navigation Drawer**, and custom user avatars.
* **⚡ Real-Time Messaging**: Instant text messaging powered by WebSockets.
* **🎨 Hash-Colored Avatars**: Automatic name parsing that generates initials and a unique background gradient dynamically based on the user's name hash.
* **📞 WebRTC Video & Audio Calls**: High-quality, low-latency peer-to-peer audio and video calls.
* **🔍 Search & Filter**: Interactive contacts and conversations search bar.
* **🔒 Dynamic URL Auto-Detection**: Seamlessly connects to the local server on both desktop and mobile browsers on your local network without editing configurations.
* **🗄️ Relational Database Sync**: Synchronized real-time storage powered by **MySQL** and **TypeORM**.

---

## 🛠️ Technology Stack

### Frontend (Client)
* **Framework**: Flutter (Dart)
* **State & Connection**: Askless Framework (WebSocket Client)
* **Real-time Call protocol**: Flutter WebRTC
* **Design**: Custom Material 3 widgets

### Backend (Server)
* **Runtime**: Node.js (TypeScript)
* **Server Framework**: Askless Server (WebSocket Server)
* **Database Driver**: TypeORM with MySQL database

---

## 📂 Project Structure

```text
├── flutter_app/                # Flutter Client Application
│   ├── lib/
│   │   ├── core/               # Shared widgets (UserAvatar, CenterContent), routes, and configs
│   │   └── features/           # Modular features (call, chat, loading, login_and_registration)
│   └── pubspec.yaml
│
└── nodejs_websocket_backend/   # Node.js TypeScript Backend
    ├── src/
    │   ├── entity/             # TypeORM Database Entities (User, Message, Call)
    │   ├── environment/        # DB configurations
    │   └── index.ts            # Entrypoint & Askless server handlers
    └── package.json
```

---

## 🚀 Getting Started

### 1. Database Setup
1. Start your local MySQL database (via XAMPP, Docker, or native installer).
2. Create an empty database for the project:
   ```sql
   CREATE DATABASE flutter_chat_app_with_nodejs;
   ```

### 2. Run the Backend Server
1. Navigate to the backend directory:
   ```bash
   cd nodejs_websocket_backend
   ```
2. Verify database connection credentials in `src/environment/db.ts`.
3. Install dependencies and start the development server:
   ```bash
   npm install
   npm run dev
   ```
   *Your server will print: `Server started on ws://localhost:3000`.*

### 3. Run the Flutter Client
1. Navigate to the Flutter app directory:
   ```bash
   cd flutter_app
   ```
2. Get dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   * **Web Browser** (Auto-detects IP address):
     ```bash
     flutter run -d chrome
     ```
   * **Mobile / Emulator**:
     Ensure `serverUrl` in `lib/core/data/data_sources/connection_remote_ds.dart` is set to your computer's local IP (e.g. `192.168.1.100`), then run:
     ```bash
     flutter run
     ```

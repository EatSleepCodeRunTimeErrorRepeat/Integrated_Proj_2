# PeakSmartTH: Real-Time Peak Hour Tracking Notifier

**PeakSmartTH** is a mobile application designed to help residents in Thailand save money and energy by tracking real-time peak and off-peak electricity hours. The app allows users to select their electricity provider (MEA or PEA) and provides official peak-hour schedules. Users can schedule reminders for their own energy-saving notes and receive automated alerts before peak periods begin and end, allowing them to adjust their appliance usage and avoid higher electricity costs.

## Features

- **User Authentication:** Secure user registration and login system with both email/password and Google Sign-In.
- **Provider Selection:** Users can select their electricity provider (MEA or PEA) to receive the correct schedule.
- **Real-Time Status Dashboard:** The home screen displays a clear, color-coded card showing the current status (On-Peak or Off-Peak) with a live countdown timer to the next period change.
- **Full Schedule & Calendar:** A complete calendar view that displays holidays and marks days that have user-created notes. The daily view shows a merged timeline of official peak/off-peak periods and personal notes.
- **Note Management (CRUD):** Users can create, edit, and delete personal notes or energy-saving tips for any day on the calendar.
- **Local Notification System:**
    - **Note Reminders:** Users can set a specific time on any note to receive a local notification reminder.
    - **Peak Hour Alerts:** The app automatically schedules alerts to be delivered 15 minutes before the start and end of every On-Peak and Off-Peak period.
- **Profile Management:** Users can change their display name and set a profile picture from their device's gallery, which is saved locally.
- **Ad Integration:** Includes a non-intrusive banner ad powered by Google AdMob.

## Tech Stack & Architecture

This project is built on a three-platform architecture to ensure a clear separation of concerns, meeting the project's technical requirements.

- **Frontend (Mobile App):**
  - **Framework:** Flutter
  - **State Management:** Riverpod
  - **Key Packages:** `flutter_local_notifications`, `http`, `image_picker`, `path_provider`, `shared_preferences`

- **Backend (Server):**
  - **Runtime:** Node.js with Express.js
  - **Language:** TypeScript
  - **Database Interface:** Prisma ORM
  - **Security:** JSON Web Tokens (JWT), `bcryptjs`
  - **Platform:** Docker Container

- **Database:**
  - **Service:** MongoDB
  - **Platform:** MongoDB Atlas (Cloud)

```
[Flutter App on Emulator/Device] <--> [Node.js API in Docker] <--> [MongoDB Atlas Cloud Database]
```

## Setup and Installation

### Backend Setup

You can run the backend either locally with Node.js or within a Docker container.

#### **Option 1: Running Locally**
1.  Navigate to the `backend` directory: `cd backend`
2.  Create a `.env` file in the `backend` root and populate it with your credentials:
    ```env
    DATABASE_URL="mongodb+srv://..."
    PORT=8000
    JWT_TOKEN_SECRET="your_jwt_secret"
    JWT_TOKEN_REFRESH_SECRET="your_jwt_refresh_secret"
    GOOGLE_CLIENT_ID="your_google_web_client_id.apps.googleusercontent.com"
    ```
3.  Install dependencies: `npm install`
4.  Sync the database schema: `npx prisma db push`
5.  Seed the database with initial data: `npx prisma db seed`
6.  Start the development server: `npm run dev`

---
#### **Option 2: Running with Docker (Recommended)**

**Prerequisites:** Make sure you have [Docker](https://www.docker.com/products/docker-desktop/) installed and running on your machine.

1.  **Navigate to the `backend` directory:**
    ```sh
    cd backend
    ```

2.  **Create the Environment File:**
    Create a `.env` file in the `backend` root and populate it with your credentials (same as the local setup). The Docker container will use this file automatically.

3.  **Build and Start the Container:**
    This single command will build the Docker image from the `Dockerfile` and start the backend service in the background.
    ```sh
    docker-compose up --build -d
    ```

4.  **Seed the Database:**
    After the container is running, you need to execute the seed command **inside** the container. Run this command from your `backend` directory:
    ```sh
    docker-compose exec backend npx prisma db seed
    ```
    This tells Docker to execute the `npx prisma db seed` command within the running `backend` service container.

5.  **Viewing Logs:**
    To see the real-time logs from the running container (for debugging), open a new terminal and use:
    ```sh
    docker-compose logs -f backend
    ```

6.  **Stopping the Container:**
    To stop the service when you are finished, run:
    ```sh
    docker-compose down
    ```

### Frontend Setup

1.  Navigate to the `frontend` directory: `cd frontend`
2.  Update `lib/utils/constants.dart` with your computer's local network IP address if you are testing on a physical phone. For the emulator, `'10.0.2.2'` should work correctly.
3.  Install dependencies: `flutter pub get`
4.  Run the app: `flutter run`

## Known Issues & Limitations

### Notification Delivery on Specific Devices

The application's logic for scheduling local notifications for both peak hours and user-created notes is fully implemented. Using the debug tools built into the app's settings screen, we can verify that all notification requests are successfully accepted and queued by the Android Operating System.

However, due to aggressive, non-standard battery management on certain physical devices (e.g., Oppo) and potential restrictions in new Android emulator APIs, the OS may de-prioritize or fail to deliver these scheduled notifications when the app is in the background. The "Send Immediate Test Notification" button works perfectly, confirming the app's basic permissions are correct. This is a demonstration of a real-world Android development challenge known as platform-specific behavior.

## Contributors
- Ryan Letchman (64130500256)
- Louise Madison Maganda (66130500814)
- Vikaskumar Dubey (66130500834)
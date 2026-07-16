# CareCompanion - Elderly Care Application

CareCompanion is a Flutter-based elderly care application designed to improve the quality of life for senior citizens and simplify caregiver monitoring. The application provides medication reminders, health tracking, emergency alerts, and real-time location monitoring through a secure and user-friendly system.

## Features

### Elderly Application
- Phone Authentication (OTP)
- Medication Management and Reminders
- Health Monitoring (Blood Pressure, Blood Sugar, and Heart Rate)
- Emergency SOS Button
- Real-Time Location Sharing
- Voice Assistance (Text-to-Speech)
- Geofencing Support
- User-Friendly Interface for Elderly Users

### Caregiver Application
- Real-Time Elderly Monitoring
- Health Reports Dashboard
- Medication Tracking
- Emergency Alert Notifications
- Real-Time Location Tracking
- Daily Medication Compliance Monitoring
- Alert Management System

## Architecture

The project follows Clean Architecture principles and consists of:

```
Presentation Layer
        │
        ▼
     Providers
        │
        ▼
     Use Cases
        │
        ▼
 Repository Interfaces
        │
        ▼
Repository Implementations
        │
        ▼
   Firebase Sources
        │
        ▼
 Firebase Services
```

## Technologies Used

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Messaging
- Flutter Riverpod
- Geolocator
- Flutter Local Notifications
- Flutter TTS
- Shared Preferences
- Clean Architecture

## Project Structure

```
lib/
├── core/
│   ├── constants.dart
│   ├── failures.dart
│   ├── network_info.dart
│   └── extensions.dart
│
├── data/
│   ├── models/
│   ├── repositories/
│   └── sources/
│
├── logic/
│   ├── providers/
│   ├── repositories/
│   └── use_cases/
│
├── services/
├── router/
└── ui/
    ├── caregiver_app/
    ├── elderly_app/
    └── shared/
```

## Logic Layer Responsibilities

The Logic Layer includes:

- Repository Interfaces
- Repository Implementations
- Use Cases
- Riverpod Providers
- Business Logic Management
- Firebase Integration
- Error Handling
- Network Connectivity Handling

## Main Features Workflow

### Authentication

```
Phone Number
      │
      ▼
 Firebase Authentication
      │
      ▼
      OTP
      │
      ▼
 Verification
      │
      ▼
    Login
```

### Emergency Alerts

```
Elderly User
      │
      ▼
 Press Emergency Button
      │
      ▼
    Get Location
      │
      ▼
   Create Alert
      │
      ▼
 Cloud Firestore
      │
      ▼
 Real-Time Updates
      │
      ▼
 Caregiver Receives Alert
```

### Health Monitoring

```
Add Health Reading
        │
        ▼
   Cloud Firestore
        │
        ▼
  Real-Time Synchronization
        │
        ▼
 Caregiver Dashboard Updates
```

## Team Contribution

### Role: Flutter Developer (Logic Layer)

- Implemented the Logic Layer using Clean Architecture.
- Developed Repository Interfaces and Implementations.
- Built Use Cases and Riverpod Providers.
- Integrated Firebase services with the application's business logic.
- Contributed to debugging, maintenance, and improving application stability and performance.



## Future Improvements

- AI-based health recommendations.
- Advanced health analytics.
- Wearable device integration.
- Multi-language support.
- Enhanced accessibility features.


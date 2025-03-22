# Firebase Setup Guide for Bichitras Attendance System

This guide will help you set up Firebase for your application.

## Step 1: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter your project name (e.g., "Bichitras Attendance System")
4. Configure Google Analytics as needed
5. Click "Create project"

## Step 2: Register your app with Firebase

### For Android:

1. In the Firebase console, click the Android icon to add an Android app
2. Enter your app's package name (found in `android/app/build.gradle` as `applicationId`)
3. Enter a nickname for your app (optional)
4. Enter your app signing certificate SHA-1 (optional for now, required for some Firebase services)
5. Click "Register app"
6. Download the `google-services.json` file
7. Place the file in the `android/app` directory of your Flutter project

### For iOS:

1. In the Firebase console, click the iOS icon to add an iOS app
2. Enter your app's bundle ID (found in Xcode under the "General" tab)
3. Enter a nickname for your app (optional)
4. Enter your App Store ID (optional)
5. Click "Register app"
6. Download the `GoogleService-Info.plist` file
7. Using Xcode, add the file to the root of your Xcode project
8. Make sure "Copy items if needed" is selected

## Step 3: Install FlutterFire CLI

```bash
# Install the FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure your apps
flutterfire configure --project=your-firebase-project-id
```

This will generate a `firebase_options.dart` file in your `lib` directory.

## Step 4: Firebase Firestore Setup

### Create Collections

1. Go to Firestore Database in the Firebase Console
2. Click "Create database"
3. Start in production mode or test mode as needed
4. Choose a location for your database
5. Create the following collections:

#### Users Collection
```
users/
  {userId}/
    email: string
    name: string
    phone: string
    role: string ('admin', 'manager', 'employee')
    createdAt: timestamp
    lastLogin: timestamp
```

#### Employees Collection
```
employees/
  {userId}/
    name: string
    email: string
    phone: string
    position: string
    department: string
    role: string
    employmentType: string ('fullTime', 'partTime', 'contract', 'intern')
    workType: string ('onsite', 'remote', 'hybrid')
    assignedProjects: array<string>
    reportingTo: string
    joiningDate: timestamp
```

#### Attendance Collection
```
attendance/
  {documentId}/
    employeeId: string
    date: timestamp
    checkIn: timestamp
    checkOut: timestamp
    status: string ('present', 'absent', 'leave', 'halfDay')
    workingHours: number
    project: string
    task: string
    notes: string
```

#### Projects Collection
```
projects/
  {projectId}/
    name: string
    description: string
    startDate: timestamp
    deadline: timestamp
    status: string ('planning', 'inProgress', 'onHold', 'completed', 'cancelled')
    progress: number
    clientName: string
    budget: number
    projectManager: string (userId)
    teamMembers: array<string> (userIds)
    milestones: array<map>
    technologies: array<string>
```

#### Tasks Collection
```
tasks/
  {taskId}/
    title: string
    description: string
    projectId: string
    status: string ('todo', 'inProgress', 'review', 'done')
    priority: string ('low', 'medium', 'high', 'critical')
    dueDate: timestamp
    estimatedTime: number
    actualTime: number
    assignees: array<string> (userIds)
    tags: array<string>
    dependencies: array<string> (taskIds)
    createdBy: string (userId)
    createdAt: timestamp
    updatedAt: timestamp
```

#### Time Entries Collection
```
timeEntries/
  {entryId}/
    userId: string
    taskId: string
    projectId: string
    date: timestamp
    duration: number (minutes)
    description: string
    createdAt: timestamp
```

## Step 5: Setup Firebase Authentication

1. In the Firebase console, go to "Authentication"
2. Click "Get started"
3. Enable the "Email/Password" sign-in method
4. Optionally, configure other sign-in methods as needed (Google, Facebook, etc.)

## Step 6: Setup Firebase Storage (for profile pictures, documents, etc.)

1. In the Firebase console, go to "Storage"
2. Click "Get started"
3. Select a storage location
4. Configure the security rules as needed

## Step 7: Setup Firebase Security Rules

Update the Firestore security rules to something like this:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read and write their own data
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow admins to read and write all data
    match /{document=**} {
      allow read, write: if request.auth != null && 
                           get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Allow employees to read and write specific data
    match /attendance/{document} {
      allow create: if request.auth != null && 
                     request.resource.data.employeeId == request.auth.uid;
      allow read: if request.auth != null && 
                   resource.data.employeeId == request.auth.uid;
    }
    
    // Tasks can be read by assignees
    match /tasks/{taskId} {
      allow read: if request.auth != null && 
                   resource.data.assignees.hasAny([request.auth.uid]);
    }
    
    // Projects can be read by team members
    match /projects/{projectId} {
      allow read: if request.auth != null && 
                   resource.data.teamMembers.hasAny([request.auth.uid]);
    }
  }
}
```

## Step 8: Initialize Firebase in your App

Make sure your `main.dart` file initializes Firebase as shown in the code.

## Step 9: Test Your Integration

1. Run your app using `flutter run`
2. Make sure Firebase is correctly initialized
3. Test Firebase Auth by signing in/out
4. Test Firestore by creating and reading data
5. Test Firebase Storage by uploading and downloading files

## Troubleshooting

- If you see errors related to Firebase initialization, make sure your `firebase_options.dart` file is correctly generated.
- If authentication fails, check your Firebase Authentication settings in the console.
- If Firestore operations fail, check your security rules and database structure.
- If you're having dependency issues, run `flutter clean` and then `flutter pub get`.

## Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/docs/overview/)
- [Firebase Documentation](https://firebase.google.com/docs) 
# Attendance System

A comprehensive Flutter application for tracking employee attendance, managing projects, and assigning tasks with time tracking capabilities.

![App Banner](https://via.placeholder.com/1200x400?text=Attendance+System+Banner)

## 📋 Overview

The Attendance System is a powerful cross-platform application designed to help organizations efficiently manage attendance tracking, project workflows, and task assignments. Built with Flutter, this application offers a seamless user experience across multiple platforms while providing robust features for both employees and administrators.

## ✨ Features

### For Employees
- **Daily Attendance Tracking**: Clock in and out with a simple tap
- **Project-Based Time Tracking**: Associate work hours with specific projects and tasks
- **Task Management**: View assigned tasks and update progress
- **Personal Dashboard**: Monitor work hours, active projects, and pending tasks
- **Break Management**: Track break time during work hours

### For Administrators
- **Employee Management**: Add, edit, and manage employee information
- **Project Management**: Create and assign projects with detailed tracking
- **Task Assignment**: Assign tasks to employees with priority, deadline, and estimated hours
- **Attendance Overview**: View attendance records and work hours for all employees
- **Reports**: Generate comprehensive reports on projects, tasks, and attendance

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.0.0 or later)
- Dart SDK (v2.17.0 or later)
- Android Studio / Visual Studio Code
- Firebase account (for cloud features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Sam-gah/attendence_system.git
   cd attendence_system
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase setup** (for cloud features)
   - Create a Firebase project
   - Add your application to the Firebase project
   - Download and place the `google-services.json` file in the `android/app` directory
   - Download and place the `GoogleService-Info.plist` file in the `ios/Runner` directory
   - Follow instructions in `firebase_setup.md` for detailed configuration

4. **Run the application**
   ```bash
   flutter run
   ```

## 📱 Usage

### Employee Flow
1. **Sign in** with your credentials
2. **Clock in** when starting your work day
3. **Select a project** you're working on
4. **Add task details** including description and estimated hours
5. **Clock out** when you're done for the day

### Administrator Flow
1. **Sign in** with admin credentials
2. **Navigate to Admin Dashboard** for an overview of attendance and projects
3. **Manage employees** through the team management section
4. **Create projects** and assign team members
5. **Assign tasks** to employees with details and deadlines
6. **Generate reports** for attendance and project progress

## 🧰 Technical Details

### Architecture
- **Flutter** for cross-platform development
- **Firebase Firestore** for database
- **Firebase Authentication** for user management
- **Provider** for state management
- **SharedPreferences** for local storage

### Key Components
- Attendance tracking system with daily records
- Project and task management workflows
- User role-based access control
- Offline data synchronization
- Time tracking with detailed reporting

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2023 Sam-gah

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 📞 Contact & Support

For questions, feedback, or support, please contact:
- Email: bichitras@bichitras.com
- GitHub Issues: [https://github.com/Sam-gah/attendence_system/issues](https://github.com/Sam-gah/attendence_system/issues)

## 🙏 Acknowledgements

- Flutter team for the amazing framework
- Firebase for the backend services
- All contributors who have helped improve this project

---

*Note: Replace placeholder images and contact information with actual data before publishing your README.*

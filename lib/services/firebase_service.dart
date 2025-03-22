import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;

  // Collections
  CollectionReference get users => _firestore.collection('users');
  CollectionReference get employees => _firestore.collection('employees');
  CollectionReference get attendance => _firestore.collection('attendance');
  CollectionReference get projects => _firestore.collection('projects');
  CollectionReference get tasks => _firestore.collection('tasks');
  CollectionReference get timeEntries => _firestore.collection('timeEntries');

  // Authentication methods
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  // User management
  Future<void> createUserProfile(String uid, Map<String, dynamic> userData) {
    return users.doc(uid).set(userData);
  }

  Future<DocumentSnapshot> getUserProfile(String uid) {
    return users.doc(uid).get();
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> userData) {
    return users.doc(uid).update(userData);
  }

  // Employee management
  Future<void> createEmployee(String uid, Map<String, dynamic> employeeData) {
    return employees.doc(uid).set(employeeData);
  }

  Future<DocumentSnapshot> getEmployee(String uid) {
    return employees.doc(uid).get();
  }

  Future<QuerySnapshot> getAllEmployees() {
    return employees.get();
  }

  Stream<QuerySnapshot> streamEmployees() {
    return employees.snapshots();
  }

  // Attendance management
  Future<void> markAttendance(String employeeId, Map<String, dynamic> attendanceData) {
    return attendance.add({
      'employeeId': employeeId,
      'timestamp': FieldValue.serverTimestamp(),
      ...attendanceData,
    });
  }

  Stream<QuerySnapshot> getEmployeeAttendance(String employeeId) {
    return attendance
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Project management
  Future<DocumentReference> createProject(Map<String, dynamic> projectData) {
    return projects.add(projectData);
  }

  Future<void> updateProject(String projectId, Map<String, dynamic> projectData) {
    return projects.doc(projectId).update(projectData);
  }

  Stream<QuerySnapshot> streamProjects() {
    return projects.snapshots();
  }

  // Task management
  Future<DocumentReference> createTask(Map<String, dynamic> taskData) {
    return tasks.add(taskData);
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> taskData) {
    return tasks.doc(taskId).update(taskData);
  }

  Stream<QuerySnapshot> streamProjectTasks(String projectId) {
    return tasks.where('projectId', isEqualTo: projectId).snapshots();
  }

  Stream<QuerySnapshot> streamUserTasks(String userId) {
    return tasks.where('assignees', arrayContains: userId).snapshots();
  }

  // Time tracking
  Future<DocumentReference> recordTimeEntry(Map<String, dynamic> timeData) {
    return timeEntries.add({
      'timestamp': FieldValue.serverTimestamp(),
      ...timeData,
    });
  }

  // Update employee status
  Future<void> updateEmployeeStatus(String employeeId, Map<String, dynamic> statusData) {
    return employees.doc(employeeId).update({
      'status': statusData,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getUserTimeEntries(String userId, DateTime startDate, DateTime endDate) {
    return timeEntries
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .orderBy('date', descending: true)
        .snapshots();
  }
} 
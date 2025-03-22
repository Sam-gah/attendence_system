import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../roles/role.dart';
import '../models/user.dart';

class ApiService {
  // This is a mock implementation for local testing
  bool _useMockData = true;
  
  // Replace with your actual backend URL when ready
  static const String baseUrl = 'http://your-django-backend/api';
  String? _token;

  // Mock data for testing
  final Map<String, dynamic> _mockUser = {
    'id': 'mock-user-123',
    'name': 'Test User',
    'email': 'test@example.com',
    'role': 'employee',
    'phone': '123-456-7890',
  };

  final List<Map<String, dynamic>> _mockEmployees = [
    {
      'id': 'mock-user-123',
      'name': 'Test User',
      'email': 'test@example.com',
      'role': 'employee',
      'phone': '123-456-7890',
      'position': 'Developer',
      'department': 'Engineering',
      'employmentType': 'fullTime',
      'workType': 'onsite',
      'assignedProjects': ['project-1', 'project-2'],
      'reportingTo': 'manager-1',
      'joiningDate': '2023-01-01',
    }
  ];

  final List<Map<String, dynamic>> _mockAttendance = [
    {
      'id': 'attendance-1',
      'employeeId': 'mock-user-123',
      'date': '2023-12-01',
      'checkIn': '09:00',
      'checkOut': '17:00',
      'status': 'present',
    },
    {
      'id': 'attendance-2',
      'employeeId': 'mock-user-123',
      'date': '2023-12-02',
      'checkIn': '08:45',
      'checkOut': '17:30',
      'status': 'present',
    },
  ];

  // Set token after login
  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // For testing, we can simulate network delay
  Future<void> _simulateNetworkDelay() async {
    if (_useMockData) {
      await Future.delayed(Duration(milliseconds: 300 + Random().nextInt(700)));
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    if (_useMockData) {
      await _simulateNetworkDelay();
      // Simulate not logged in if no token
      if (_token == null) return null;
      return _mockUser;
    }
    
    if (_token == null) return null;
    
    final response = await http.get(
      Uri.parse('$baseUrl/auth/user/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (_useMockData) {
      await _simulateNetworkDelay();
      
      // Simulate basic validation
      if (email == 'test@example.com' && password == 'password') {
        _token = 'mock-token-${DateTime.now().millisecondsSinceEpoch}';
        return {
          'token': _token,
          'user': _mockUser,
        };
      } else if (email == 'admin@example.com' && password == 'admin') {
        _token = 'mock-token-${DateTime.now().millisecondsSinceEpoch}';
        return {
          'token': _token,
          'user': {
            'id': 'mock-admin-456',
            'name': 'Admin User',
            'email': 'admin@example.com',
            'role': 'admin',
            'phone': '987-654-3210',
          },
        };
      } else {
        throw Exception('Invalid email or password');
      }
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setToken(data['token']); // Save token for future requests
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<void> logout() async {
    if (_useMockData) {
      await _simulateNetworkDelay();
      _token = null;
      return;
    }
    
    _token = null;
  }

  // Attendance
  Future<Map<String, dynamic>> markAttendance(String employeeId) async {
    if (_useMockData) {
      await _simulateNetworkDelay();
      
      final now = DateTime.now();
      final newAttendance = {
        'id': 'attendance-${now.millisecondsSinceEpoch}',
        'employeeId': employeeId,
        'date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        'checkIn': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        'status': 'present',
      };
      
      _mockAttendance.add(newAttendance);
      return newAttendance;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/attendance/mark/'),
      headers: _headers,
      body: jsonEncode({
        'employee_id': employeeId,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to mark attendance');
    }
  }

  // Get employee details
  Future<Map<String, dynamic>> getEmployeeDetails(String employeeId) async {
    if (_useMockData) {
      await _simulateNetworkDelay();
      
      final employee = _mockEmployees.firstWhere(
        (emp) => emp['id'] == employeeId,
        orElse: () => throw Exception('Employee not found'),
      );
      
      return employee;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/employees/$employeeId/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get employee details: ${response.body}');
    }
  }

  // Get attendance history
  Future<List<Map<String, dynamic>>> getAttendanceHistory(String employeeId) async {
    if (_useMockData) {
      await _simulateNetworkDelay();
      
      return _mockAttendance
        .where((attendance) => attendance['employeeId'] == employeeId)
        .toList();
    }

    final response = await http.get(
      Uri.parse('$baseUrl/attendance/history/$employeeId/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to get attendance history');
    }
  }
} 
class EmployeeAttendance {
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final String status; // 'Présent', 'Absent', 'Congé', 'Non défini'

  EmployeeAttendance({
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.status,
  });

  factory EmployeeAttendance.fromJson(Map<String, dynamic> json) {
    // Handle nested employee object or direct fields
    Map<String, dynamic> employeeData = {};
    if (json.containsKey('employee') && json['employee'] != null) {
      employeeData = json['employee'] as Map<String, dynamic>;
    }
    
    // Normalize field names as specified in requirements
    final employeeId = json['employeeId'] ?? 
                     json['userId'] ?? 
                     json['user_id'] ?? 
                     json['employee_id'] ?? 
                     employeeData['id'] ?? 
                     '';
    
    final employeeName = json['employeeName'] ?? 
                        json['name'] ?? 
                        employeeData['name'] ?? 
                        employeeData['first_name'] != null && employeeData['last_name'] != null
                            ? '${employeeData['first_name']} ${employeeData['last_name']}'
                            : employeeData['email'] ?? 
                              'Inconnu';
    
    String statusBackend = (json['status'] ?? 'non_defini').toString().toLowerCase();
    String statusFrontend;
    
    // Map backend status to frontend French status
    switch (statusBackend) {
      case 'present':
        statusFrontend = 'Présent';
        break;
      case 'absent':
        statusFrontend = 'Absent';
        break;
      case 'conge':
        statusFrontend = 'Congé';
        break;
      case 'non_defini':
      case 'non défini':
        statusFrontend = 'Non défini';
        break;
      default:
        statusFrontend = 'Non défini';
    }
    
    return EmployeeAttendance(
      employeeId: employeeId.toString(),
      employeeName: employeeName,
      date: DateTime.parse(json['date'] ?? ''),
      status: statusFrontend,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'employeeName': employeeName,
      'date': date.toIso8601String().split('T')[0],
      'status': status,
    };
  }

  EmployeeAttendance copyWith({
    String? employeeId,
    String? employeeName,
    DateTime? date,
    String? status,
  }) {
    return EmployeeAttendance(
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}
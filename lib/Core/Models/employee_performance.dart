class EmployeePerformance {
  final String userId;
  final String userName;
  final int presentDays;
  final double salaireH;
  final double salaryAmount;

  EmployeePerformance({
    required this.userId,
    required this.userName,
    required this.presentDays,
    required this.salaireH,
    required this.salaryAmount,
  });

  factory EmployeePerformance.fromMap(Map<String, dynamic> map) {
    return EmployeePerformance(
      userId: map['userId']?.toString() ?? '',
      userName: map['user_name']?.toString() ?? 'Unknown',
      presentDays: (map['present_days'] as num?)?.toInt() ?? 0,
      salaireH: (map['salaire_h'] as num?)?.toDouble() ?? 0.0,
      salaryAmount: (map['salary_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
import 'package:keeptex/Core/Models/UserModel.dart';

class EmployeeCardVM {
  final String id;
  final String name;
  final String? phone;
  final String? cin;
  final double salaireH;
  final int presentDays;
  final int absentDays;
  final int congeDays;
  final double accounte; // avance / compte courant
  final UserModel user;
  
  double get salaryAmount => presentDays * salaireH * 8;
  
  const EmployeeCardVM({
    required this.id,
    required this.name,
    this.phone,
    this.cin,
    required this.salaireH,
    required this.presentDays,
    required this.absentDays,
    required this.congeDays,
    required this.accounte,
    required this.user,
  });
}
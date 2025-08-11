import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../BaseScaffold.dart';
import '../../Services/UserService.dart';
import '../../Services/AttendanceService.dart';
import '../../Core/Models/UserModel.dart';
import '../../Core/Models/employee_attendance.dart';


class EmployeesSchedulesPage extends StatefulWidget {
  const EmployeesSchedulesPage({super.key});

  @override
  State<EmployeesSchedulesPage> createState() => _EmployeesSchedulesPageState();
}

class _EmployeesSchedulesPageState extends State<EmployeesSchedulesPage> {
  DateTime selectedDate = DateTime.now();
  String selectedFilter = 'Tous'; // conservé si tu veux réactiver les filtres plus tard
  List<UserModel> employees = [];
  List<EmployeeAttendance> attendances = [];
  bool isLoading = true;

  final UserService _userService = UserService();
  final AttendanceService _attendanceService = AttendanceService();

  // Helpers de mapping (depuis AttendanceService)
  String _toBackend(String fr) => _attendanceService.mapFrontendToBackendStatus(fr);

  // ✅ null-safe : si be == null -> "Non défini"
  String _toFrontendSafe(String? be) =>
      be == null ? 'Non défini' : _attendanceService.mapBackendToFrontendStatus(be);

  /// Normalise n'importe quel statut (FR ou backend) vers FR pour l’UI
  String _normalizeToFR(String any) => _toFrontendSafe(_toBackend(any));

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    try {
      setState(() => isLoading = true);

      // 1) Charger les employés
      final allUsers = await _userService.getAllUsers();
      final employeeList = allUsers.where((u) => u.role == 'employee').toList();

      // 2) Charger les présences de la date
      final attendanceList = await _attendanceService.getAttendanceByDate(selectedDate);

      // 3) Fusion (1 présence par employé) + statut toujours FR
      final merged = employeeList.map((employee) {
        final att = attendanceList.firstWhere(
              (a) => a.employeeId == employee.id?.toString(),
          orElse: () => EmployeeAttendance(
            employeeId: employee.id?.toString() ?? '0',
            employeeName: employee.name ?? (employee.email ?? 'Unknown'),
            date: selectedDate,
            status: 'Non défini',
          ),
        );
        return att.copyWith(
          status: _normalizeToFR(att.status),
          date: selectedDate, // force la date affichée
        );
      }).toList();

      setState(() {
        employees = employeeList;
        attendances = merged;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement: $e')),
        );
      }
    }
  }

  Future<void> _updateEmployeeAttendance(String employeeId, String statusFR) async {
    try {
      await _attendanceService.markAttendance(employeeId, selectedDate, statusFR);
      await _loadEmployees(); // refléter la DB
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Présence mise à jour avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildHeader(),
          _buildStatsCards(),
          _buildAttendanceList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Pointage du ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _loadEmployees,
                icon: const Icon(Icons.refresh),
                tooltip: 'Rafraîchir',
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                    await _loadEmployees();
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Changer date'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _markAllPresent,
                icon: const Icon(Icons.check_circle),
                label: const Text('Tout présent'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _markAllAbsent,
                icon: const Icon(Icons.cancel),
                label: const Text('Tout absent'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _saveBulkAttendance,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
              const SizedBox(width: 8),

            ],
          ),
        ],
      ),
    );
  }

  /// 🔢 Cartes statistiques — affiche Congés
  Widget _buildStatsCards() {
    final totalEmployees = employees.length;

    int presentCount = 0, absentCount = 0, congeCount = 0;
    for (final a in attendances) {
      final be = _toBackend(a.status); // 'present' | 'absent' | 'conge' | 'non_defini'
      if (be == 'present') presentCount++;
      if (be == 'absent')  absentCount++;
      if (be == 'conge')   congeCount++;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatCard('Employés', '$totalEmployees', Colors.blue),
          const SizedBox(width: 16),
          _buildStatCard('Congés', '$congeCount', Colors.purple),
          const SizedBox(width: 16),
          _buildStatCard('Présents', '$presentCount', Colors.green),
          const SizedBox(width: 16),
          _buildStatCard('Absents', '$absentCount', Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (employees.isEmpty) {
      return const Expanded(child: Center(child: Text('Aucun employé trouvé')));
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: employees.length,
        itemBuilder: (context, index) => _buildEmployeeCard(employees[index]),
      ),
    );
  }

  String _initials(String? name, String? fallbackEmail) {
    final s = (name ?? '').trim();
    if (s.isEmpty) {
      final e = (fallbackEmail ?? '').trim();
      return e.isNotEmpty ? e[0].toUpperCase() : '?';
    }
    return s[0].toUpperCase();
  }

  Widget _buildEmployeeCard(UserModel employee) {
    final att = attendances.firstWhere(
          (a) => a.employeeId == (employee.id?.toString() ?? '0'),
      orElse: () => EmployeeAttendance(
        employeeId: employee.id?.toString() ?? '0',
        employeeName: employee.name ?? (employee.email ?? 'Unknown'),
        date: selectedDate,
        status: 'Non défini',
      ),
    );

    final displayStatus = _normalizeToFR(att.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(displayStatus),
          child: Text(
            _initials(employee.name, employee.email),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          employee.name ?? 'Sans nom',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${employee.email}'),
            Text('Statut: $displayStatus'),
            Text('Date: ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () => _showEditAttendanceDialog(att.copyWith(status: displayStatus), employee),
        ),
      ),
    );
  }

  Color _getStatusColor(String statusFR) {
    final s = statusFR.toLowerCase();
    if (s.startsWith('présent')) return Colors.green;
    if (s.startsWith('absent'))  return Colors.red;
    if (s.startsWith('cong'))    return Colors.purple; // 'congé'/'conge'
    if (s.startsWith('non'))     return Colors.grey;   // non défini
    return Colors.grey;
  }

  void _showAddAttendanceDialog() {
    UserModel? selectedEmployee;
    String status = 'Présent';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un pointage'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<UserModel>(
                decoration: const InputDecoration(labelText: 'Employé'),
                items: employees
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.name ?? 'Sans nom')))
                    .toList(),
                onChanged: (value) => selectedEmployee = value,
              ),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: 'Statut'),
                items: const [
                  DropdownMenuItem(value: 'Présent', child: Text('Présent')),
                  DropdownMenuItem(value: 'Absent', child: Text('Absent')),
                  DropdownMenuItem(value: 'Congé', child: Text('Congé')),
                  DropdownMenuItem(value: 'Non défini', child: Text('Non défini')),
                ],
                onChanged: (value) => status = value ?? 'Non défini',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (selectedEmployee != null) {
                await _updateEmployeeAttendance(selectedEmployee!.id?.toString() ?? '0', status);
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showEditAttendanceDialog(EmployeeAttendance attendance, UserModel employee) {
    String status = _normalizeToFR(attendance.status);
    const valid = ['Présent', 'Absent', 'Congé', 'Non défini'];
    if (!valid.contains(status)) status = 'Non défini';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier ${attendance.employeeName}'),
        content: DropdownButtonFormField<String>(
          value: status,
          decoration: const InputDecoration(labelText: 'Statut'),
          items: valid.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (value) => status = value ?? 'Non défini',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              try {
                final employeeId = employee.id?.toString();
                if (employeeId == null || employeeId.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Erreur: ID employé invalide')),
                    );
                  }
                  return;
                }
                await _attendanceService.markAttendance(employeeId, attendance.date, status);
                await _loadEmployees();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Statut mis à jour avec succès'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur lors de la mise à jour: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }



  void _markAllPresent() {
    setState(() {
      attendances = attendances.map((a) => a.copyWith(status: 'Présent')).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tous les employés marqués comme présents (non sauvegardé)')),
    );
  }

  void _markAllAbsent() {
    setState(() {
      attendances = attendances.map((a) => a.copyWith(status: 'Absent')).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tous les employés marqués comme absents (non sauvegardé)')),
    );
  }

  Future<void> _saveBulkAttendance() async {
    try {
      setState(() => isLoading = true);

      final records = attendances.map((a) => {
        'userId': a.employeeId,
        'status': _toBackend(a.status), // toujours backend ici
        'checkIn': null,
        'checkOut': null,
        'notes': null,
      }).toList();

      await _attendanceService.saveBulk(selectedDate, records);
      await _loadEmployees(); // rafraîchir depuis la DB

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pointages enregistrés avec succès'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'enregistrement: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../BaseScaffold.dart';
import '../../Services/UserService.dart';
import '../../Services/AttendanceService.dart';
import '../../Core/Models/UserModel.dart';

class EmployeesSchedulesPage extends StatefulWidget {
  const EmployeesSchedulesPage({super.key});

  @override
  State<EmployeesSchedulesPage> createState() => _EmployeesSchedulesPageState();
}

class _EmployeesSchedulesPageState extends State<EmployeesSchedulesPage> {
  DateTime selectedDate = DateTime.now();
  String selectedFilter = 'Tous';
  List<UserModel> employees = [];
  List<EmployeeAttendance> attendances = [];
  bool isLoading = true;
  final UserService _userService = UserService();
  final AttendanceService _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    try {
      setState(() => isLoading = true);
      final allUsers = await _userService.getAllUsers();
      
      setState(() {
        employees = allUsers.where((user) => user.role == 'employee').toList();
        // Créer des données d'attendance pour chaque employé
        attendances = employees.map((employee) => EmployeeAttendance(
          id: '',
          employeeId: employee.id?.toString() ?? '0',
          employeeName: employee.name ?? 'Unknown',
          date: selectedDate,
          status: 'Non défini',
          checkIn: '',
          checkOut: '',
          advance: employee.accounte?.toDouble() ?? 0.0,
        )).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des employés: $e')),
        );
      }
    }
  }

  List<EmployeeAttendance> get filteredAttendances {
    List<EmployeeAttendance> filtered = attendances.where((attendance) {
      return attendance.date.year == selectedDate.year &&
             attendance.date.month == selectedDate.month &&
             attendance.date.day == selectedDate.day;
    }).toList();

    if (selectedFilter != 'Tous') {
      filtered = filtered.where((attendance) => attendance.status == selectedFilter).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(),
                _buildFilters(),
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
                    setState(() {
                      selectedDate = date;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Changer date'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final connected = await _attendanceService.testConnection();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            connected 
                              ? 'Connexion au serveur réussie'
                              : 'Erreur de connexion au serveur'
                          ),
                          backgroundColor: connected ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: ${e.toString()}')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.wifi),
                label: const Text('Tester connexion'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedFilter,
              decoration: const InputDecoration(
                labelText: 'Filtrer par',
                border: OutlineInputBorder(),
              ),
              items: ['Tous', 'Présent', 'Absent', 'Non défini']
                  .map((filter) => DropdownMenuItem(
                        value: filter,
                        child: Text(filter),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedFilter = value!;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () => _showAddAttendanceDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final totalEmployees = employees.length;
    final totalAdvance = employees.fold(0.0, (sum, employee) => sum + (employee.accounte?.toDouble() ?? 0.0));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatCard('Employés', totalEmployees.toString(), Colors.blue),
          const SizedBox(width: 16),
          _buildStatCard('Total Acomptes', '${totalAdvance.toStringAsFixed(2)} DT', Colors.orange),
          const SizedBox(width: 16),
          _buildStatCard('Présents Auj.', 
              filteredAttendances.where((a) => a.status == 'Présent').length.toString(), 
              Colors.green),
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
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (employees.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text('Aucun employé trouvé'),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          return _buildEmployeeCard(employee);
        },
      ),
    );
  }

  Widget _buildEmployeeCard(UserModel employee) {
    final attendanceForToday = attendances.firstWhere(
      (attendance) => attendance.employeeId == (employee.id?.toString() ?? '0') &&
                      attendance.date.year == selectedDate.year &&
                      attendance.date.month == selectedDate.month &&
                      attendance.date.day == selectedDate.day,
      orElse: () => EmployeeAttendance(
        id: '',
        employeeId: employee.id?.toString() ?? '0',
        employeeName: employee.name ?? 'Unknown',
        date: selectedDate,
        status: 'Non défini',
        checkIn: '',
        checkOut: '',
        advance: employee.accounte?.toDouble() ?? 0.0,
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(attendanceForToday.status),
          child: Text(
            (employee.name ?? '')[0].toUpperCase(),
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
            Text('Statut: ${attendanceForToday.status}'),
            Text('Date: ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
            if (attendanceForToday.status == 'Présent') ...[
              Text('Entrée: ${attendanceForToday.checkIn} - Sortie: ${attendanceForToday.checkOut}'),
            ],
            if (attendanceForToday.advance > 0) ...[
              Text(
                'Acompte: ${attendanceForToday.advance.toStringAsFixed(2)} DH',
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditAttendanceDialog(attendanceForToday, employee),
            ),
            if (attendanceForToday.advance == 0) ...[
              IconButton(
                icon: const Icon(Icons.money, color: Colors.green),
                onPressed: () => _showAdvanceDialog(attendanceForToday, employee),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Présent':
        return Colors.green;
      case 'Absent':
        return Colors.red;
      case 'Non défini':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }



  void _showAddAttendanceDialog() {
    UserModel? selectedEmployee;
    String status = 'Présent';
    final TextEditingController checkInController = TextEditingController(text: '08:30');
    final TextEditingController checkOutController = TextEditingController(text: '17:30');

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
                onChanged: (value) {
                  selectedEmployee = value;
                },
              ),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: 'Statut'),
                items: ['Présent', 'Absent']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => status = value!,
              ),
              if (status == 'Présent') ...[
                TextField(
                  controller: checkInController,
                  decoration: const InputDecoration(labelText: 'Heure d\'entrée'),
                ),
                TextField(
                  controller: checkOutController,
                  decoration: const InputDecoration(labelText: 'Heure de sortie'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedEmployee == null) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez sélectionner un employé')),
                  );
                }
                return;
              }
              
              final employeeId = selectedEmployee!.id?.toString();
              if (employeeId == null || employeeId.isEmpty) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erreur: ID employé invalide')),
                  );
                }
                return;
              }
              
              try {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enregistrement en cours...')),
                  );
                }
                
                if (status == 'Présent') {
                  await _attendanceService.markPresent(employeeId, selectedDate);
                  setState(() {
                    final index = employees.indexWhere((e) => e.id == selectedEmployee!.id);
                    if (index != -1) {
                      employees[index] = selectedEmployee!.copyWith(conge: (selectedEmployee!.conge ?? 0) + 1);
                    }
                  });
                } else if (status == 'Absent') {
                  await _attendanceService.markAbsent(employeeId, selectedDate);
                  setState(() {
                    final index = employees.indexWhere((e) => e.id == selectedEmployee!.id);
                    if (index != -1) {
                      employees[index] = selectedEmployee!.copyWith(absence: (selectedEmployee!.absence ?? 0) + 1);
                    }
                  });
                }
                
                // Ajouter le pointage à la liste locale
                setState(() {
                  attendances.add(EmployeeAttendance(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    employeeId: employeeId,
                    employeeName: selectedEmployee!.name ?? 'Unknown',
                    date: selectedDate,
                    status: status,
                    checkIn: checkInController.text,
                    checkOut: checkOutController.text,
                    advance: 0.0,
                  ));
                });
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pointage ajouté avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de l\'ajout: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

 void _showEditAttendanceDialog(EmployeeAttendance attendance, UserModel employee) {
    String status = attendance.status;
    final TextEditingController checkInController = TextEditingController(text: attendance.checkIn);
    final TextEditingController checkOutController = TextEditingController(text: attendance.checkOut);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier ${attendance.employeeName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: status,
              decoration: const InputDecoration(labelText: 'Statut'),
              items: ['Présent', 'Absent', 'Non défini']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) {
                status = value!;
              },
            ),
            if (status == 'Présent') ...[
              TextField(
                controller: checkInController,
                decoration: const InputDecoration(labelText: 'Heure d\'entrée'),
              ),
              TextField(
                controller: checkOutController,
                decoration: const InputDecoration(labelText: 'Heure de sortie'),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
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

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mise à jour en cours...')),
                    );
                  }

                  if (status == 'Présent') {
                    await _attendanceService.markPresent(employeeId, attendance.date);
                    setState(() {
                      final index = employees.indexWhere((e) => e.id == employee.id);
                      if (index != -1) {
                        employees[index] = employee.copyWith(conge: (employee.conge ?? 0) + 1);
                      }
                    });
                  } else if (status == 'Absent') {
                    await _attendanceService.markAbsent(employeeId, attendance.date);
                    setState(() {
                      final index = employees.indexWhere((e) => e.id == employee.id);
                      if (index != -1) {
                        employees[index] = employee.copyWith(absence: (employee.absence ?? 0) + 1);
                      }
                    });
                  }
                
                setState(() {
                  attendance.status = status;
                  attendance.checkIn = checkInController.text;
                  attendance.checkOut = checkOutController.text;
                });
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Statut mis à jour avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la mise à jour: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
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

  void _showAdvanceDialog(EmployeeAttendance attendance, UserModel employee) {
    final TextEditingController advanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Acompte pour ${attendance.employeeName}'),
        content: TextField(
          controller: advanceController,
          decoration: const InputDecoration(
            labelText: 'Montant (DH)',
            suffixText: 'DH',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
              onPressed: () async {
                try {
                  final employeeId = employee.id;
                  if (employeeId == null || employeeId.isEmpty) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erreur: ID employé invalide')),
                      );
                    }
                    return;
                  }

                  final amount = double.tryParse(advanceController.text) ?? 0.0;
                  if (amount <= 0) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez entrer un montant valide')),
                      );
                    }
                    return;
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ajout de l\'acompte de $amount DH...')),
                    );
                  }

                  await _attendanceService.addAdvance(employeeId, amount);
                  
                  // Update both attendance and employee account
                  setState(() {
                    attendance.advance = amount;
                    final index = employees.indexWhere((e) => e.id == employee.id);
                    if (index != -1) {
                      employees[index] = employee.copyWith(accounte: (employee.accounte ?? 0.0) + amount);
                    }
                  });
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Acompte de $amount DH ajouté avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur lors de l\'ajout: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Ajouter'),
            ),
        ],
      ),
    );
  }
}

class EmployeeAttendance {
  String id;
  String employeeId;
  String employeeName;
  DateTime date;
  String status;
  String checkIn;
  String checkOut;
  double advance;

  EmployeeAttendance({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.status,
    required this.checkIn,
    required this.checkOut,
    required this.advance,
  });
}

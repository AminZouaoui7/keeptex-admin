import 'package:flutter/material.dart';
import 'package:keeptex/Services/PerformanceService.dart';
import 'package:intl/intl.dart';
import '../../BaseScaffold.dart';

  class EmployeesPerformancePage extends StatefulWidget {
    const EmployeesPerformancePage({super.key});

    @override
    State<EmployeesPerformancePage> createState() => _EmployeesPerformancePageState();
  }

  class _EmployeesPerformancePageState extends State<EmployeesPerformancePage> {
    final PerformanceService _performanceService = PerformanceService();
    DateTime selectedMonth = DateTime.now();
    List<Map<String, dynamic>> _rows = [];
    double _total = 0.0;
    String _monthLabel = '';
    bool _loading = false;
    
    // Constants for rate calculation
    static const double _W_ABSENT = 1.0;
    static const double _W_CONGE = 0.3;
    static const double _W_ACCOMPTE = 0.5;

    // State additions for sorting and rate calculation
    int? _sortColumnIndex = 2; // Rate column
    bool _sortAscending = false; // tri décroissant
    int _denomDays = 30;

    // Helper functions to extract values from multiple possible keys
    int _getIntFromKeys(Map<String, dynamic> map, List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value != null) {
          if (value is int) return value;
          if (value is num) return value.toInt();
          if (value is String) return int.tryParse(value) ?? 0;
        }
      }
      return 0;
    }

    double _getDoubleFromKeys(Map<String, dynamic> map, List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value != null) {
          if (value is double) return value;
          if (value is num) return value.toDouble();
          if (value is String) return double.tryParse(value) ?? 0.0;
        }
      }
      return 0.0;
    }

    double _clamp01(double value) => value.clamp(0.0, 1.0);

    double _computeRate(int present, int absent, int conge, double acompte, double salaryAmount, int denomDays) {
      if (denomDays <= 0) return 0.0;
      
      final p = present / denomDays;
      final a = absent / denomDays;
      final c = conge / denomDays;
      
      final ratioAcompte = salaryAmount > 0 ? (acompte / salaryAmount).clamp(0.0, 1.0) : 0.0;
      
      final rate = p - (_W_ABSENT * a) - (_W_CONGE * c) - (_W_ACCOMPTE * ratioAcompte);
      return _clamp01(rate) * 100;
    }

    int _daysInMonth(DateTime d) => DateTime(d.year, d.month + 1, 0).day;

    @override
    void initState() {
      super.initState();
      _loadPerformance();
    }

    Future<void> _loadPerformance() async {
      setState(() => _loading = true);
      try {
        final yyyymm = '${selectedMonth.year}-${selectedMonth.month.toString().padLeft(2, '0')}';
        debugPrint('[PERF] fetching $yyyymm');
        final res = await _performanceService.getMonthlyPerformance(yyyymm);

        _denomDays = _daysInMonth(selectedMonth);
        if (_denomDays <= 0) _denomDays = 30;

        final rows = List<Map<String, dynamic>>.from(res.rows).map((e) {
          final present = _getIntFromKeys(e, ['present_days', 'present', 'present_j', 'presents']);
          final absent = _getIntFromKeys(e, ['absent_days', 'absent', 'absent_j', 'absents']);
          final conge = _getIntFromKeys(e, ['conge_days', 'conge', 'conge_j', 'conges']);
          final acompte = _getDoubleFromKeys(e, ['accompte', 'accounte', 'advance', 'advance_amount']);
          final salaryAmount = _getDoubleFromKeys(e, ['salary_amount', 'salaire_total', 'total_salary']);

          final rate = _computeRate(present, absent, conge, acompte, salaryAmount, _denomDays);

          return {
            ...e,
            '_present': present,
            '_absent': absent,
            '_conge': conge,
            '_acompte': acompte,
            '_salaryAmount': salaryAmount,
            'rate': rate,
          };
        }).toList();

        rows.sort((a, b) {
          final ra = (a['rate'] as num?)?.toDouble() ?? 0.0;
          final rb = (b['rate'] as num?)?.toDouble() ?? 0.0;
          return rb.compareTo(ra); // desc
        });

        if (!mounted) return;
        setState(() {
          _rows = rows;
          _total = res.total;
          _monthLabel = yyyymm;
          _sortColumnIndex = 2; // Rate column
          _sortAscending = false;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur performance: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }

    Future<void> _selectMonth() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedMonth,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        initialDatePickerMode: DatePickerMode.year,
        helpText: 'Sélectionner le mois',
        fieldLabelText: 'Mois/Année',
      );

      if (picked != null) {
        setState(() {
          selectedMonth = DateTime(picked.year, picked.month);
        });
        await _loadPerformance();
      }
    }

    @override
    Widget build(BuildContext context) {
      return BaseScaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Performance du mois: ${DateFormat('MMMM yyyy', 'fr').format(selectedMonth)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),

                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _loadPerformance,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Actualiser'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _rows.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucune donnée pour ce mois',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                sortColumnIndex: _sortColumnIndex,
                                sortAscending: _sortAscending,
                                headingRowColor: WidgetStateProperty.all(
                                  Colors.blue[50],
                                ),
                                columns: [
                                  const DataColumn(label: Text('Employé')),
                                  const DataColumn(label: Text('Jours présents'), numeric: true),
                                  DataColumn(
                                    label: const Text('Rate'),
                                    numeric: true,
                                    onSort: (i, asc) {
                                      setState(() {
                                        _sortColumnIndex = i;
                                        _sortAscending = asc;
                                        _rows.sort((a, b) {
                                          final ra = (a['rate'] as num?)?.toDouble() ?? 0.0;
                                          final rb = (b['rate'] as num?)?.toDouble() ?? 0.0;
                                          return asc ? ra.compareTo(rb) : rb.compareTo(ra);
                                        });
                                      });
                                    },
                                  ),
                                  const DataColumn(label: Text('Salaire/h (DT)'), numeric: true),
                                  const DataColumn(label: Text('Salaire (DT)'), numeric: true),
                                ],
                                rows: _rows.map((e) => DataRow(
                                  cells: [
                                    DataCell(Text(e['user_name']?.toString() ?? '')),
                                    DataCell(Text((e['present_days'] ?? 0).toString())),
                                    DataCell(Text(((e['rate'] as num?) ?? 0).toStringAsFixed(1))), // % avec 1 décimale
                                    DataCell(Text((e['salaire_h'] is num) ? (e['salaire_h'] as num).toStringAsFixed(2) : '0.00')),
                                    DataCell(
                                      Text(
                                        ((e['salary_amount'] as num?) ?? 0).toStringAsFixed(2),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                )).toList(),
                            ),
                          ),
              ),
              ),
              if (_rows.isNotEmpty) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Total salaires: ',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${_total.toStringAsFixed(2)} DT',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
  }

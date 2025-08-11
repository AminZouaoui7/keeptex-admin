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
      if (!mounted) return;
      setState(() {
        _rows = List<Map<String, dynamic>>.from(res.rows);
        _total = res.total;
        _monthLabel = yyyymm;
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
                ElevatedButton.icon(
                  onPressed: _selectMonth,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text('Changer mois'),
                ),
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
                              headingRowColor: WidgetStateProperty.all(
                                Colors.blue[50],
                              ),
                              columns: const [
                                DataColumn(label: Text('Employé')),
                                DataColumn(
                                  label: Text('Jours présents'),
                                  numeric: true,
                                ),
                                DataColumn(
                                  label: Text('Salaire/h (DT)'),
                                  numeric: true,
                                ),
                                DataColumn(
                                  label: Text('Salaire (DT)'),
                                  numeric: true,
                                ),
                              ],
                              rows: _rows.map((e) => DataRow(
                                cells: [
                                  DataCell(Text(e['user_name']?.toString() ?? '')),
                                  DataCell(Text(e['present_days']?.toString() ?? '0')),
                                  DataCell(Text((e['salaire_h'] as num?)?.toStringAsFixed(2) ?? '0.00')),
                                  DataCell(
                                    Text(
                                      (e['salary_amount'] as num?)?.toStringAsFixed(2) ?? '0.00',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
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

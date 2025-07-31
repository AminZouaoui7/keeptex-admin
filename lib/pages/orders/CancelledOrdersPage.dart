import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../BaseScaffold.dart';
import '../../Core/Models/CommandeModel.dart';
import '../../Services/CommandeService.dart';

class CancelledOrdersPage extends StatefulWidget {
  const CancelledOrdersPage({super.key});

  @override
  State<CancelledOrdersPage> createState() => _CancelledOrdersPageState();
}

class _CancelledOrdersPageState extends State<CancelledOrdersPage> {
  late Future<List<CommandeModel>> _cancelledOrdersFuture;
  final CommandeService _commandeService = CommandeService();

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  void refreshData() {
    setState(() {
      _cancelledOrdersFuture = _commandeService.getAllCommandes().then((list) =>
          list.where((c) => c.etat.toLowerCase() == "annulée").toList());
    });
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy – HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<CommandeModel>>(
          future: _cancelledOrdersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucune commande annulée.'));
            }

            final cancelledOrders = snapshot.data!;

            return RefreshIndicator(
              onRefresh: () async => refreshData(),
              child: ListView.builder(
                itemCount: cancelledOrders.length,
                itemBuilder: (context, index) {
                  final order = cancelledOrders[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.cancel, color: Colors.red),
                      title: Text('Commande ${order.id}'),
                      subtitle: Text(
                        'Client: ${order.clientName}\n${formatDate(order.date)}',
                      ),
                      isThreeLine: true,
                      trailing: const Text(
                        'Annulée',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

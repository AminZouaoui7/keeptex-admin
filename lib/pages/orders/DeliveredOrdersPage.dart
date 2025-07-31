import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../BaseScaffold.dart';
import '../../Core/Models/CommandeModel.dart';
import '../../Services/CommandeService.dart';

class DeliveredOrdersPage extends StatefulWidget {
  const DeliveredOrdersPage({super.key});

  @override
  State<DeliveredOrdersPage> createState() => _DeliveredOrdersPageState();
}

class _DeliveredOrdersPageState extends State<DeliveredOrdersPage> {
  late Future<List<CommandeModel>> _deliveredOrdersFuture;
  final CommandeService _commandeService = CommandeService();

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  void refreshData() {
    setState(() {
      _deliveredOrdersFuture = _commandeService.getAllCommandes().then((list) =>
          list.where((c) => c.etat.toLowerCase() == "termine").toList());
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
          future: _deliveredOrdersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucune commande livrée.'));
            }

            final deliveredOrders = snapshot.data!;

            return RefreshIndicator(
              onRefresh: () async => refreshData(),
              child: ListView.builder(
                itemCount: deliveredOrders.length,
                itemBuilder: (context, index) {
                  final order = deliveredOrders[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text('Commande ${order.id}'),
                      subtitle: Text(
                        'Client: ${order.clientName}\n${formatDate(order.date)}',
                      ),
                      isThreeLine: true,
                      trailing: const Text(
                        'Livrée',
                        style: TextStyle(color: Colors.green),
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

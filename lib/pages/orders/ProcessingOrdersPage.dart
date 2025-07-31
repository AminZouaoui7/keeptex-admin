import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../BaseScaffold.dart';
import '../../Core/Models/CommandeModel.dart';
import '../../Services/CommandeService.dart';

class ProcessingOrdersPage extends StatefulWidget {
  const ProcessingOrdersPage({super.key});

  @override
  State<ProcessingOrdersPage> createState() => _ProcessingOrdersPageState();
}

class _ProcessingOrdersPageState extends State<ProcessingOrdersPage> {
  late Future<List<CommandeModel>> _processingOrdersFuture;
  final CommandeService _commandeService = CommandeService();

  final List<String> etapesCommande = [
    "en attente",
    "conception",
    "patronnage",
    "coupe",
    "confection",
    "finition",
    "controle",
    "termine"
  ];

  final List<String> etapesEnCours = [
    "conception",
    "patronnage",
    "coupe",
    "confection",
    "finition",
    "controle"
  ];

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  void refreshData() {
    setState(() {
      _processingOrdersFuture = _commandeService.getAllCommandes().then((list) =>
          list.where((c) => etapesEnCours.contains(c.etat.toLowerCase())).toList());
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
          future: _processingOrdersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur: \${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucune commande en cours de traitement.'));
            }

            final orders = snapshot.data!;

            return RefreshIndicator(
              onRefresh: () async => refreshData(),
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return OrderCard(
                    order: order,
                    etapesCommande: etapesCommande,
                    formatDate: formatDate,
                    updateEtat: (newEtat) async {
                      await _commandeService.updateEtatCommande(order.id! as String, newEtat);
                      refreshData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('État mis à jour en "\$newEtat"'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
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

class OrderCard extends StatefulWidget {
  final CommandeModel order;
  final List<String> etapesCommande;
  final String Function(DateTime?) formatDate;
  final Function(String) updateEtat;

  const OrderCard({
    super.key,
    required this.order,
    required this.etapesCommande,
    required this.formatDate,
    required this.updateEtat,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Commande ${widget.order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Chip(
                  label: Text(widget.order.etat),
                  backgroundColor: Colors.teal.shade50,
                  labelStyle: const TextStyle(color: Colors.teal),
                ),
                IconButton(
                  icon: AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more),
                  ),
                  onPressed: () => setState(() => isExpanded = !isExpanded),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 6),
                Text(widget.formatDate(widget.order.date)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 18),
                const SizedBox(width: 6),
                Text('Client: ${widget.order.clientName}'),
              ],
            ),
            const SizedBox(height: 12),
            if (isExpanded) ...[
              const Divider(height: 20),
              Wrap(
                runSpacing: 8,
                children: [
                  Text('🧵 Modèle: ${widget.order.typeModele}'),
                  Text('🧶 Tissu: ${widget.order.typeTissue}'),
                  Text('🎨 Couleur: ${widget.order.couleur}'),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 20,
                runSpacing: 8,
                children: [
                  Text('Qté totale: ${widget.order.quantiteTotale}'),
                  Text('Prix total: ${widget.order.prixTotal.toStringAsFixed(2)} €'),
                  Text('Acompte: ${widget.order.acompteRequis.toStringAsFixed(2)} €'),
                ],
              ),
              if (widget.order.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('📝 \${widget.order.description}'),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

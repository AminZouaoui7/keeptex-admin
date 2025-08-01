import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../BaseScaffold.dart';
import '../../Core/Models/CommandeModel.dart';
import '../../Services/CommandeService.dart';

class AllOrdersPage extends StatefulWidget {
  const AllOrdersPage({super.key});

  @override
  State<AllOrdersPage> createState() => _AllOrdersPageState();
}

class _AllOrdersPageState extends State<AllOrdersPage> {
  late Future<List<CommandeModel>> _ordersFuture;
  List<CommandeModel> _allOrders = [];
  List<CommandeModel> _filteredOrders = [];
  final CommandeService _commandeService = CommandeService();
  String selectedFilter = 'Tous';

  final List<String> etapesCommande = [
    "en attente",
    "conception",
    "patronnage",
    "coupe",
    "confection",
    "finition",
    "controle",
    "termine",
    "annulee",
  ];

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  void refreshData() {
    setState(() {
      _ordersFuture = _commandeService.getAllCommandes().then((orders) {
        _allOrders = orders;
        applyFilter();
        return orders;
      });
    });
  }

  void applyFilter() {
    setState(() {
      if (selectedFilter == 'Tous') {
        _filteredOrders = _allOrders;
      } else {
        _filteredOrders = _allOrders
            .where((order) => order.etat.toLowerCase() == selectedFilter.toLowerCase())
            .toList();
      }
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
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucune commande trouvée.'));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<String>(
                  value: selectedFilter,
                  isExpanded: true,
                  items: ['Tous', ...etapesCommande].map((etat) {
                    return DropdownMenuItem(
                      value: etat,
                      child: Text(' $etat'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedFilter = value;
                      applyFilter();
                    }
                  },
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => refreshData(),
                    child: ListView.builder(
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = _filteredOrders[index];
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
                                  content: Text('État mis à jour en "$newEtat"'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
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
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: Offset(0, 0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: 1.0,
        child: Card(
          elevation: 6,
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                    IconButton(
                      icon: AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.expand_more),
                      ),
                      onPressed: () {
                        setState(() => isExpanded = !isExpanded);
                      },
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
                const SizedBox(height: 6),
                DropdownButton<String>(
                  value: widget.etapesCommande.contains(widget.order.etat)
                      ? widget.order.etat
                      : widget.etapesCommande[0],
                  items: widget.etapesCommande.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    );
                  }).toList(),
                  onChanged: (newValue) async {
                    if (newValue != null && newValue != widget.order.etat) {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Confirmation"),
                          content: Text('Changer l\'état en "$newValue" ?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Annuler"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Confirmer"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await widget.updateEtat(newValue);
                      }
                    }
                  },
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 20),
                      Text('Commande ${widget.order.id}'),
                      Text('Client: ${widget.order.clientName}'),
                      Text('🧵 Modèle: ${widget.order.typeModele}'),
                      Text('🧶 Tissu: ${widget.order.typeTissue}'),
                      Text('🎨 Couleur: ${widget.order.couleur}'),
                      Text('Qté totale: ${widget.order.quantiteTotale}'),
                      Text('Prix total: ${widget.order.prixTotal.toStringAsFixed(2)} €'),
                      Text('Acompte requis: ${widget.order.acompteRequis.toStringAsFixed(2)} €'),
                      const SizedBox(height: 8),

                      if (!widget.order.acomptePaye)
                        ElevatedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Confirmation"),
                                content: const Text("Confirmer le paiement de l'acompte ?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text("Annuler"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text("Confirmer"),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              try {
                                await CommandeService().marquerAcompteCommePaye(widget.order.id!);

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("✅ Acompte marqué comme payé."),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  setState(() {
                                    widget.order.acomptePaye = true;
                                  });
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Erreur : $e"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          icon: const Icon(Icons.check),
                          label: const Text("Marquer acompte payé"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                        )
                      else
                        const Text("✅ Acompte déjà payé", style: TextStyle(color: Colors.green)),

                      if (widget.order.description.isNotEmpty)
                        Text('📝 Description : ${widget.order.description}'),
                    ],
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

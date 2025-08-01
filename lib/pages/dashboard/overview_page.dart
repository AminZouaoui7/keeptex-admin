// lib/pages/dashboard/overview_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../BaseScaffold.dart';
import '../../constants.dart';
import '../../Services/CommandeAnalyticsService.dart';
import '../../Core/Models/CommandeModel.dart';
import '../../Core/Models/UserModel.dart';
import '../../Services/CommandeService.dart';
import '../../Services/UserService.dart';

class OverviewPage extends StatefulWidget {
  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final CommandeAnalyticsService _analyticsService = CommandeAnalyticsService();
  final CommandeService _commandeService = CommandeService();
  
  late Future<Map<String, dynamic>> _analyticsFuture;
  
  @override
  void initState() {
    super.initState();
    _analyticsFuture = _analyticsService.getCommandeAnalytics();
  }
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 5),
            _buildTopMetricsRow(),
            const SizedBox(height: 10),
            _buildChartsRow(),
            const SizedBox(height: 10),
            _buildDashboardCards(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTopMetricsRow() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _analyticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }
        
        final analytics = snapshot.data ?? {
          'totalCommandes': 0,
          'commandesEnCours': 0,
          'commandesTerminees': 0,
          'montantTotal': 0.0,
        };
        
        return LayoutBuilder(
          builder: (context, constraints) {
            // Utiliser Wrap pour une meilleure adaptation à l'espace disponible
            return Wrap(
              spacing: 15, // Espacement horizontal entre les éléments
              runSpacing: 15, // Espacement vertical entre les lignes
              alignment: WrapAlignment.start,
              children: [
                _buildMetricCardForWrap(
                  constraints: constraints,
                  title: 'Commandes Totales',
                  value: '${analytics['totalCommandes']}',
                  subtitle: '${analytics['commandesEnCours']} en cours',
                  color: Constants.vertJade,
                ),
                _buildMetricCardForWrap(
                  constraints: constraints,
                  title: 'Commandes Terminées',
                  value: '${analytics['commandesTerminees']}',
                  subtitle: '${analytics['commandesAnnulees']} annulées',
                  color: Constants.bleuOcean,
                ),
                _buildMetricCardForWrap(
                  constraints: constraints,
                  title: 'Chiffre d\'Affaires',
                  value: '${analytics['montantTotal'].toStringAsFixed(2)} €',
                  subtitle: '${analytics['montantRestant'].toStringAsFixed(2)} € restants',
                  color: Constants.vertSarcelle,
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  // Widget adapté pour être utilisé dans un Wrap
  Widget _buildMetricCardForWrap({
    required BoxConstraints constraints,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    // Calculer la largeur en fonction de l'espace disponible
    double cardWidth = constraints.maxWidth < 700 
        ? constraints.maxWidth // Pleine largeur sur petit écran
        : (constraints.maxWidth / 3) - 15; // Diviser l'espace sur grand écran
        
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );  
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8), // Réduire le padding
      decoration: BoxDecoration(
        color: Colors.indigo.shade900,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 12), // Réduire la taille de police
          ),
          const SizedBox(height: 2), // Réduire l'espacement
          Text(
            value,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), // Réduire la taille de police
          ),
          const SizedBox(height: 2), // Réduire l'espacement
          Text(
            subtitle,
            style: TextStyle(color: Colors.white70, fontSize: 10), // Réduire la taille de police
          ),
        ],
      ),
    );
  }

  Widget _buildChartsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Utiliser Wrap pour s'adapter automatiquement à la taille de l'écran
        return Wrap(
          spacing: 15,
          runSpacing: 15,
          children: [
            SizedBox(
              width: constraints.maxWidth < 900 ? constraints.maxWidth : constraints.maxWidth / 3 - 10,
              child: _buildLineChartCard(),
            ),
            SizedBox(
              width: constraints.maxWidth < 900 ? constraints.maxWidth : constraints.maxWidth / 3 - 10,
              child: _buildBarChartCard(),
            ),
            SizedBox(
              width: constraints.maxWidth < 900 ? constraints.maxWidth : constraints.maxWidth / 3 - 10,
              child: _buildMultiLineChartCard(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLineChartCard() {
    return Container(
      height: 180, // Réduire encore plus la hauteur
      padding: const EdgeInsets.all(6), // Réduire davantage le padding
      decoration: BoxDecoration(
        color: Colors.indigo.shade900,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Évolution des Commandes',
            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Nombre de commandes par mois',
            style: TextStyle(color: Colors.white70, fontSize: 8),
          ),
          const SizedBox(height: 1), // Réduire davantage l'espacement
          Expanded(
            child: FutureBuilder<List<FlSpot>>(
              future: _analyticsService.getLineChartData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }
                
                final spots = snapshot.data ?? [];
                
                if (spots.isEmpty) {
                  return const Center(child: Text('Aucune donnée disponible', style: TextStyle(color: Colors.white)));
                }
                
                return LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: true),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() % 2 == 0 && value.toInt() < 12) {
                              return Text(
                                'M${value.toInt() + 1}',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value % 5 == 0 && value > 0) {
                              return Text(
                                '${value.toInt()}',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [Constants.vertMenthe.withOpacity(0.8), Constants.bleuCanard],
                        ),
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Constants.vertMenthe.withOpacity(0.4),
                              Constants.bleuCanard.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartCard() {
    return Container(
      height: 180, // Réduire encore plus la hauteur
      padding: const EdgeInsets.all(6), // Réduire davantage le padding
      decoration: BoxDecoration(
        color: Colors.indigo.shade900,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chiffre d\'Affaires Mensuel',
            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: _analyticsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                return const SizedBox(height: 16);
              }
              
              final analytics = snapshot.data!;
              
              return Row(
                children: [
                  Text(
                    '${analytics['montantTotal'].toStringAsFixed(2)} €',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 8),
                  ),
                  const SizedBox(width: 2), // Réduire davantage l'espacement
                  Text(
                    'Total des Commandes',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 8),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 1), // Réduire davantage l'espacement
          Expanded(
            child: FutureBuilder<List<BarChartGroupData>>(
              future: _analyticsService.getBarChartData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }
                
                final barGroups = snapshot.data ?? [];
                
                if (barGroups.isEmpty) {
                  return const Center(child: Text('Aucune donnée disponible', style: TextStyle(color: Colors.white)));
                }
                
                // Trouver la valeur maximale pour l'axe Y
                double maxY = 0;
                for (var group in barGroups) {
                  for (var rod in group.barRods) {
                    if (rod.toY > maxY) maxY = rod.toY;
                  }
                }
                
                // Arrondir à la dizaine supérieure pour une meilleure lisibilité
                maxY = ((maxY / 1000).ceil() * 1000).toDouble();
                if (maxY < 1000) maxY = 1000;
                
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() % 2 == 0 && value.toInt() < 12) {
                              return Text(
                                'M${value.toInt() + 1}',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value % (maxY / 5) == 0 && value > 0) {
                              return Text(
                                '${value.toInt()}€',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: barGroups,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double sales, double orders) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: sales,
          color: Constants.vertMenthe,
          width: 12,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
        BarChartRodData(
          toY: orders,
          color: Colors.pinkAccent,
          width: 12,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiLineChartCard() {
    return Container(
      height: 180, // Réduire encore plus la hauteur
      padding: const EdgeInsets.all(6), // Réduire davantage le padding
      decoration: BoxDecoration(
        color: Colors.indigo.shade900,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Sales',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () {},
                iconSize: 12, // Réduire davantage la taille de l'icône
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          Text(
            'Unfold Shop 2018',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 8),
          ),
          const SizedBox(height: 1), // Réduire davantage l'espacement
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: true),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        String text = '';
                        switch (value.toInt()) {
                          case 2:
                            text = 'SEPT';
                            break;
                          case 5:
                            text = 'OCT';
                            break;
                          case 8:
                            text = 'DEC';
                            break;
                        }
                        return Text(
                          text,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        String text = '';
                        if (value == 1) {
                          text = '1m';
                        } else if (value == 2) {
                          text = '2m';
                        } else if (value == 3) {
                          text = '3m';
                        } else if (value == 5) {
                          text = '5m';
                        }
                        return Text(
                          text,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  _buildMultiLineData(Colors.purpleAccent),
                  _buildMultiLineData(Constants.vertMenthe),
                  _buildMultiLineData(Colors.blueAccent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildMultiLineData(Color color) {
    return LineChartBarData(
      spots: [
        const FlSpot(0, 2.5),
        const FlSpot(2, 2),
        const FlSpot(4, 3),
        const FlSpot(6, 2.5),
        const FlSpot(8, 3),
        const FlSpot(10, 2),
      ],
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }

  Widget _buildDashboardCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Première colonne: Graphique circulaire
                Expanded(
                  flex: 2,
                  child: _buildPieChartCard(),
                ),
                const SizedBox(width: 10),
                // Deuxième colonne: Utilisateurs
                Expanded(
                  flex: 1,
                  child: _buildUsersCard(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Première colonne: Tâches
                Expanded(
                  child: _buildTasksCard(),
                ),
                const SizedBox(width: 10),
                // Deuxième colonne: Produits
                Expanded(
                  child: _buildProductsCard(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildPieChartCard() {
    return Container(
      height: 200, // Hauteur ajustée pour la nouvelle disposition
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.indigo.shade900,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribution des Commandes',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 1), // Réduire davantage l'espacement
          Expanded(
            flex: 2,
            child: FutureBuilder<List<PieChartSectionData>>(
              future: _analyticsService.getPieChartData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }
                
                final sections = snapshot.data ?? [];
                
                if (sections.isEmpty) {
                  return const Center(child: Text('Aucune donnée disponible', style: TextStyle(color: Colors.white)));
                }
                
                return PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 30, // Réduit pour économiser de l'espace
                    sections: sections,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            flex: 1,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _analyticsService.getPieChartLegends(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError || !snapshot.hasData) {
                  return const SizedBox();
                }
                
                final legends = snapshot.data ?? [];
                
                return SingleChildScrollView(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: legends.map((legend) => 
                      _buildLegendItem(legend['label'], legend['color'])
                    ).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
          ),
        ],
      ),
    );
  }


  Widget _buildUsersCard() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.indigo.shade900,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clients',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: FutureBuilder<List<UserModel>>(
              future: UserService().getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erreur: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final allUsers = snapshot.data ?? [];
                final clients = allUsers.where((user) => user.role?.toLowerCase() == 'client').toList();

                if (clients.isEmpty) {
                  return const Center(
                    child: Text('Aucun client disponible', style: TextStyle(color: Colors.white)),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    final client = clients[index];
                    final name = client.name?.toString() ?? 'Client sans nom';
                    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
                    final colors = [Colors.amber, Colors.pink, Colors.blue, Colors.orange, Colors.green];
                    final color = colors[index % colors.length];

                    return _buildUserItem(
                      initial,
                      name,
                      color,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(String initial, String name, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: color,
            child: Text(
              initial,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTasksCard() {
    return Container(
      height: 150, // Hauteur ajustée pour la nouvelle disposition
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.indigo.shade900,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Commandes Récentes',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2), // Réduire davantage l'espacement
          Expanded(
            child: FutureBuilder<List<CommandeModel>>(
              future: _commandeService.getAllCommandes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }
                
                final commandes = snapshot.data ?? [];
                
                if (commandes.isEmpty) {
                  return const Center(child: Text('Aucune commande disponible', style: TextStyle(color: Colors.white)));
                }
                
                // Trier par date (plus récentes d'abord)
                commandes.sort((a, b) => b.date.compareTo(a.date));
                
                // Limiter à 3 commandes
                final recentCommandes = commandes.take(3).toList();
                
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: recentCommandes.length,
                  itemBuilder: (context, index) {
                    final commande = recentCommandes[index];
                    return _buildCommandeItem(
                      '${commande.clientName} - ${commande.type}',
                      commande.etat,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandeItem(String commande, String etat) {
    // Couleur en fonction de l'état
    Color statusColor;
    IconData statusIcon;
    
    switch (etat.toLowerCase()) {
      case 'termine':
      case 'terminé':
      case 'terminée':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'annulee':
      case 'annulé':
      case 'annulée':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'en attente':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      default:
        statusColor = Colors.blue;
        statusIcon = Icons.engineering;
        break;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              commande,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(statusIcon, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsCard() {
    return Container(
      height: 150, // Hauteur ajustée pour correspondre à la carte des tâches
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.indigo.shade900,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Commandes par État',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2), // Réduire davantage l'espacement
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _analyticsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }
                
                final analytics = snapshot.data ?? {};
                final Map<String, int> distribution = analytics['distributionEtats'] ?? {};
                
                if (distribution.isEmpty) {
                  return const Center(child: Text('Aucune donnée disponible', style: TextStyle(color: Colors.white)));
                }
                
                // Convertir en liste pour l'affichage
                final List<MapEntry<String, int>> items = distribution.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value)); // Trier par nombre décroissant
                
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: items.length > 3 ? 3 : items.length, // Limiter à 3 états
                  itemBuilder: (context, index) {
                    final item = items[index];
                    String etat = item.key.substring(0, 1).toUpperCase() + item.key.substring(1);
                    
                    // Normaliser les labels pour l'affichage
                    if (item.key == 'terminé' || item.key == 'terminée') {
                      etat = 'Terminé';
                    } else if (item.key == 'annulé' || item.key == 'annulée') {
                      etat = 'Annulé';
                    }
                    
                    final count = item.value;
                    final percentage = (count / analytics['totalCommandes'] * 100).toStringAsFixed(1);
                    
                    return _buildEtatItem('$etat ($count)', '$percentage%');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtatItem(String etat, String percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              etat,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            percentage,
            style: TextStyle(color: Constants.vertMenthe, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

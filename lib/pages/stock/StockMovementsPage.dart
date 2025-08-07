import 'package:flutter/material.dart';
import 'package:keeptex/BaseScaffold.dart';
import 'package:keeptex/Services/StockMovementService.dart';

class StockMovement {
  final String id;
  final String articleName;
  final String type;
  final int quantity;
  final int oldQuantity;
  final int newQuantity;
  final DateTime date;
  final String? user;
  final String? reason;

  StockMovement({
    required this.id,
    required this.articleName,
    required this.type,
    required this.quantity,
    required this.oldQuantity,
    required this.newQuantity,
    required this.date,
    this.user,
    this.reason,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id']?.toString() ?? '',
      articleName: json['Article']?['nom'] ?? json['article']?['nom'] ?? 'Article inconnu',
      type: json['type'] ?? 'unknown',
      quantity: json['quantity'] ?? 0,
      oldQuantity: json['oldQuantity'] ?? json['quantiteAvant'] ?? 0,
      newQuantity: json['newQuantity'] ?? json['quantiteApres'] ?? 0,
      date: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      user: json['User']?['name'] ?? json['User']?['nom'] ?? json['utilisateur'] ?? json['userId'],
      reason: json['reason'] ?? json['raison'],
    );
  }
}

class StockMovementsPage extends StatefulWidget {
  const StockMovementsPage({super.key});

  @override
  State<StockMovementsPage> createState() => _StockMovementsPageState();
}

class _StockMovementsPageState extends State<StockMovementsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StockMovementService _stockMovementService = StockMovementService();
  List<StockMovement> _allMovements = [];
  List<StockMovement> _entrees = [];
  List<StockMovement> _sorties = [];
  List<StockMovement> _filteredAll = [];
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _stats;
  Map<String, dynamic> _countByType = {'success': true, 'data': []};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMovements();
    _loadStats();
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
      _filterMovements();
    });
    
    // Auto-refresh every 30 seconds when page is active
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _refreshMovements();
        _startAutoRefresh();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMovements() async {
    try {
      if (!mounted) return;
      
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final movements = await _stockMovementService.getStockMovements(
        limit: 50,
        page: 1,
      );
      
      if (mounted) {
        setState(() {
          _allMovements = movements;
          _filterMovements();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur lors du chargement des mouvements: ${e.toString()}';
          if (e.toString().contains('404')) {
            _error = 'Aucun mouvement trouvé ou endpoint non accessible';
          }
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadStats() async {
    try {
      // Load both basic stats and count by type
      final stats = await _stockMovementService.getStockMovementStats();
      final countResponse = await _stockMovementService.getCountByType();
      
      if (mounted) {
        setState(() {
          _stats = stats;
          if (countResponse['success'] == true && countResponse['data'] != null) {
            _countByType = {
              'success': true,
              'data': countResponse['data'] is List ? countResponse['data'] : []
            };
          } else {
            _countByType = {
              'success': true,
              'data': []
            };
          }
        });
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des statistiques: $e');
      if (mounted) {
        setState(() {
          _countByType = {
            'success': false,
            'data': []
          };
        });
      }
    }
  }

  void _filterMovements() {
    if (!mounted) return;
    
    final query = _searchQuery.toLowerCase();
    
    final filtered = _allMovements.where((movement) {
      final articleName = movement.articleName.toLowerCase();
      return articleName.contains(query);
    }).toList();

    setState(() {
      _filteredAll = filtered;
      _entrees = filtered.where((m) => m.type.toUpperCase() == 'ENTREE').toList();
      _sorties = filtered.where((m) => m.type.toUpperCase() == 'SORTIE').toList();
    });
  }

  Future<void> _refreshMovements() async {
    await _loadMovements();
    await _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BaseScaffold(
      body: RefreshIndicator(
        onRefresh: _refreshMovements,
        child: CustomScrollView(
          slivers: [
          SliverAppBar(title: const Text('Mouvements de Stock'),
            automaticallyImplyLeading: false, // retire l'icône du menu
          pinned: true,
          floating: true,
          expandedHeight: 120,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white.withOpacity(0.2),
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.list_alt),
                text: 'Tous',
              ),
              Tab(
                icon: Icon(Icons.trending_up),
                text: 'Entrées',
              ),
              Tab(
                icon: Icon(Icons.trending_down),
                text: 'Sorties',
              ),
            ],
          ),
        ),

            
            SliverToBoxAdapter(
              child: Column(
                children: [
                  if (_stats != null) _buildStatsCard(),
                  Container(
                    margin: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Rechercher un article...',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor.withOpacity(0.9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        labelStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [

                        const Spacer(),
                        if (_isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _loadMovements,
                            tooltip: 'Rafraîchir',
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            if (_isLoading && _allMovements.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMovements,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_allMovements.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Aucun mouvement trouvé'),
                    ],
                  ),
                ),
              )
            else
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDynamicMovementsList(_filteredAll, 'Aucun mouvement trouvé'),
                    _buildDynamicMovementsList(_entrees, 'Aucune entrée trouvée'),
                    _buildDynamicMovementsList(_sorties, 'Aucune sortie trouvée'),
                  ],
                ),
              ),
        ],
      ),
    ),
    );
  }

  Widget _buildStatsCard() {
    // Handle both List and Map response formats
    List<dynamic> countData = [];
    if (_countByType['data'] is List) {
      countData = _countByType['data'] as List<dynamic>;
    }
    
    // Get detailed counts from count data
    final entreesData = countData.firstWhere(
      (item) => item is Map && item['type'] == 'ENTREE',
      orElse: () => {'count': 0, 'total_quantite': 0},
    );
    
    final sortiesData = countData.firstWhere(
      (item) => item is Map && item['type'] == 'SORTIE',
      orElse: () => {'count': 0, 'total_quantite': 0},
    );
    
    final entreesCount = int.tryParse((entreesData as Map)['count']?.toString() ?? '0') ?? int.tryParse(_stats?['totalEntrees']?.toString() ?? '0') ?? 0;
    final entreesQuantity = int.tryParse(entreesData['total_quantite']?.toString() ?? '0') ?? 0;
    
    final sortiesCount = int.tryParse((sortiesData as Map)['count']?.toString() ?? '0') ?? int.tryParse(_stats?['totalSorties']?.toString() ?? '0') ?? 0;
    final sortiesQuantity = int.tryParse(sortiesData['total_quantite']?.toString() ?? '0') ?? 0;
    
    final totalMovements = (entreesCount + sortiesCount);

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDetailedStatCard(
                  'Entrées',
                  entreesCount.toString(),
                  '+$entreesQuantity',
                  Colors.green,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailedStatCard(
                  'Sorties',
                  sortiesCount.toString(),
                  '-$sortiesQuantity',
                  Colors.red,
                  Icons.trending_down,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildModernStatCard(
                  'Total Mouvements',
                  totalMovements.toString(),
                  Colors.blue,
                  Icons.analytics,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatCard(String label, String count, String quantity, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'mouvements',
                style: TextStyle(
                  fontSize: 12,
                  color: color.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            quantity,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.8),
            ),
          ),
          Text(
            'quantité totale',
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementsList(List<StockMovement> movements, String emptyMessage) {
    if (movements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(emptyMessage, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMovements,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: movements.length,
        itemBuilder: (context, index) {
          final movement = movements[index];
          return _buildMovementCard(movement);
        },
      ),
    );
  }

  Widget _buildDynamicMovementsList(List<StockMovement> movements, String emptyMessage) {
    if (movements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(emptyMessage, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _refreshMovements,
              icon: const Icon(Icons.refresh),
              label: const Text('Rafraîchir'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshMovements,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: movements.length,
        itemBuilder: (context, index) {
          final movement = movements[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 50)),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 20),
                  child: child,
                ),
              );
            },
            child: _buildMovementCard(movement),
          );
        },
      ),
    );
  }

  Widget _buildMovementCard(StockMovement movement) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[850] : Colors.white;
    final isEntree = movement.type.toUpperCase() == 'ENTREE' || movement.type == 'creation' || movement.type == 'ajout';
    final color = isEntree ? Colors.green : Colors.red;
    final icon = isEntree ? Icons.trending_up : Icons.trending_down;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        color: cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showMovementDetails(movement),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  cardColor!,
                  cardColor.withOpacity(0.95),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'movement-${movement.id}',
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(0.2),
                              color.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movement.articleName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getMovementTypeText(movement.type),
                            style: TextStyle(
                              fontSize: 13,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(movement.date),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        movement.user ?? 'Inconnu',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (movement.reason != null && movement.reason!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notes, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            movement.reason!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMovementDetails(StockMovement movement) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = movement.type.toUpperCase() == 'ENTREE' ? Colors.green : Colors.red;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  (isDark ? Colors.grey[850] : Colors.white)!,
                  (isDark ? Colors.grey[850] : Colors.white)!.withOpacity(0.95),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'movement-${movement.id}',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              typeColor.withOpacity(0.2),
                              typeColor.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          movement.type.toUpperCase() == 'ENTREE' 
                              ? Icons.trending_up 
                              : Icons.trending_down,
                          color: typeColor,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movement.articleName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getMovementTypeText(movement.type),
                            style: TextStyle(
                              fontSize: 14,
                              color: typeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildModernDetailRow('Type', _getMovementTypeText(movement.type), typeColor),
                
                _buildModernDetailRow('Stock avant', movement.oldQuantity.toString(), Colors.grey),
                _buildModernDetailRow('Stock après', movement.newQuantity.toString(), Colors.blue),
                _buildModernDetailRow('Date', _formatDate(movement.date), Colors.grey),
                _buildModernDetailRow('Utilisateur', movement.user ?? 'Inconnu', Colors.grey),
                if (movement.reason != null && movement.reason!.isNotEmpty)
                  _buildModernDetailRow('Motif', movement.reason!, Colors.grey),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Fermer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernDetailRow(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getMovementTypeText(String type) {
    switch (type.toUpperCase()) {
      case 'ENTREE':
        return 'Entrée de stock';
      case 'SORTIE':
        return 'Sortie de stock';
      case 'creation':
        return 'Création d\'article';
      case 'ajout':
        return 'Ajout de stock';
      case 'suppression':
        return 'Suppression d\'article';
      case 'retrait':
        return 'Retrait de stock';
      default:
        return 'Mouvement: $type';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

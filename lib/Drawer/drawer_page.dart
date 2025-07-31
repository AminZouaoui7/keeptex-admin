import 'package:flutter/material.dart';
import 'package:keeptex/responsiveLayout.dart';
import '../constants.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class ButtonsInfo {
  String title;
  IconData icon;
  String? badge;
  List<SubMenuItem>? subItems;

  ButtonsInfo({
    required this.title,
    required this.icon,
    this.badge,
    this.subItems,
  });
}

class SubMenuItem {
  String title;
  IconData icon;
  String route;

  SubMenuItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}

List<ButtonsInfo> _buttonsNames = [
  ButtonsInfo(
    title: "Produits",
    icon: Icons.inventory_2_outlined,
    subItems: [
      SubMenuItem(title: "Liste des produits", icon: Icons.list_alt, route: "/products/list"),
      SubMenuItem(title: "Ajouter produit", icon: Icons.add_box, route: "/products/add"),
    ],
  ),
  ButtonsInfo(
    title: "Commandes",
    icon: Icons.receipt_long_outlined,
    badge: "12",
    subItems: [
      SubMenuItem(title: "Toutes les commandes", icon: Icons.list, route: "/orders/all"),
      SubMenuItem(title: "En attente", icon: Icons.hourglass_empty, route: "/orders/pending"),
      SubMenuItem(title: "En cours", icon: Icons.local_shipping, route: "/orders/processing"),
      SubMenuItem(title: "Livrées", icon: Icons.check_circle, route: "/orders/delivered"),
      SubMenuItem(title: "Annulées", icon: Icons.cancel, route: "/orders/cancelled"),
    ],
  ),
  ButtonsInfo(
    title: "Clients",
    icon: Icons.people_outline,
    subItems: [
      SubMenuItem(title: "Liste des clients", icon: Icons.person_search, route: "/customers/list"),
    ],
  ),
  ButtonsInfo(
    title: "Stocks",
    icon: Icons.warehouse_outlined,
    badge: "!",
    subItems: [
      SubMenuItem(title: "État des stocks", icon: Icons.inventory, route: "/stock/status"),
      SubMenuItem(title: "Alertes rupture", icon: Icons.warning, route: "/stock/alerts"),
      SubMenuItem(title: "Entrées/Sorties", icon: Icons.swap_horiz, route: "/stock/movements"),
    ],
  ),
  ButtonsInfo(
    title: "Production",
    icon: Icons.factory_outlined,
    subItems: [
      SubMenuItem(title: "Objectif fabrication", icon: Icons.track_changes, route: "/production/tracking"),
    ],
  ),
  ButtonsInfo(
    title: "Employés",
    icon: Icons.badge_outlined,
    subItems: [
      SubMenuItem(title: "Liste employés", icon: Icons.people, route: "/employees/list"),
      SubMenuItem(title: "Horaires", icon: Icons.access_time, route: "/employees/schedules"),
      SubMenuItem(title: "Performances", icon: Icons.trending_up, route: "/employees/performance"),
    ],
  ),
  ButtonsInfo(
    title: "Outils",
    icon: Icons.build_outlined,
    subItems: [
      SubMenuItem(title: "Factures", icon: Icons.receipt, route: "/tools/invoices"),
      SubMenuItem(title: "Bons de commande", icon: Icons.local_shipping, route: "/tools/delivery"),
    ],
  ),
  ButtonsInfo(
    title: "Paramètres",
    icon: Icons.settings_outlined,
    subItems: [
      SubMenuItem(title: "Profil utilisateur", icon: Icons.person, route: "/settings/profile"),
      SubMenuItem(title: "Rôles & permissions", icon: Icons.security, route: "/settings/roles"),
    ],
  ),
];

class _DrawerPageState extends State<DrawerPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int? _expandedIndex;
  String? _currentRoute;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _currentRoute = ModalRoute.of(context)?.settings.name;
        for (int i = 0; i < _buttonsNames.length; i++) {
          final subItems = _buttonsNames[i].subItems;
          if (subItems != null && subItems.any((s) => s.route == _currentRoute)) {
            _expandedIndex = i;
            break;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(Constants.KPadding),
          itemCount: _buttonsNames.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                  SizedBox(
                  height: 70, // adjust as needed
                  width: 70,
                  child: ClipOval(
                    child: Image.asset(
                      "assets/521119688_1078649260578555_5364186740130543035_n.jpg",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                    const SizedBox(height: 20),
                    Text(
                      "KEEPTEX",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1500),
                      builder: (context, value, child) {
                        return Container(
                          width: 60 * value,
                          height: 2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1),
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Constants.vertMenthe.withOpacity(value),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            } else {
              return SlideTransition(
                position: _slideAnimation,
                child: _buildMenuItem(index - 1),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem(int index) {
    final item = _buttonsNames[index];
    final isExpanded = _expandedIndex == index;
    final subRoutes = item.subItems?.map((s) => s.route).toList() ?? [];
    final isSubSelected = subRoutes.contains(_currentRoute);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              setState(() {
                _expandedIndex = isExpanded ? null : index;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: isExpanded || isSubSelected
                    ? LinearGradient(colors: [Constants.bleuCanard, Constants.vertMenthe])
                    : null,
              ),
              child: ListTile(
                leading: Icon(item.icon, color: Colors.white),
                title: Text(item.title, style: TextStyle(color: Colors.white)),
                trailing: item.subItems != null
                    ? Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white,
                )
                    : null,
              ),
            ),
          ),
        ),

        // Submenu
        if (item.subItems != null)
          SizedBox(height: 20),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: isExpanded ? item.subItems!.length * 58.0 : 0,
              ),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: item.subItems!.map((subItem) {
                    final isSelected = _currentRoute == subItem.route;
                    return Container(
                      margin: const EdgeInsets.only(left: 32),
                      child: ListTile(
                        selected: isSelected,
                        selectedTileColor: Colors.white24,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        leading: Icon(subItem.icon, color: Colors.white.withOpacity(0.8), size: 18),
                        title: Text(
                          subItem.title,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed(subItem.route);
                          setState(() {
                            _currentRoute = subItem.route;
                            _expandedIndex = index;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

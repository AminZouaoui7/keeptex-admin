import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keeptex/constants.dart';
import 'package:keeptex/responsiveLayout.dart';
import 'package:provider/provider.dart';

import '../Core/Cubit/UserCubit.dart';

class Appbarwidget extends StatefulWidget {
  const Appbarwidget({super.key});

  @override
  State<Appbarwidget> createState() => _AppbarwidgetState();
}

class _AppbarwidgetState extends State<Appbarwidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovering = false;

  final Map<String, String> routeMap = {
    'overview': '/overview',
    'revenue': '/revenue',
    'sales': '/sales',
    'control': '/control',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleNavigation(String value) {
    final route = routeMap[value];
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (route != null && currentRoute != route) {
      Navigator.of(context).pushReplacementNamed(route);
    }
  }

  Widget _buildNavButton(String title, String value) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isSelected = currentRoute == routeMap[value];
    final isComputer = ResponsiveLayout.iscomputer(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isComputer ? 4 : 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _handleNavigation(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isComputer ? 16 : 12,
              vertical: isComputer ? 8 : 6,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
              border: isSelected
                  ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                  : null,
            ),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                fontSize: isComputer ? 14 : 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isComputer = ResponsiveLayout.iscomputer(context);

    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
          ),
        ),
      ),
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.3),
      toolbarHeight: kToolbarHeight + 10,
      title: Row(
        children: [
          MouseRegion(
            onEnter: (_) {
              if (isComputer) {
                setState(() {
                  _isHovering = true;
                  _animationController.reset();
                  _animationController.forward();
                });
              }
            },
            onExit: (_) => setState(() => _isHovering = false),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: const EdgeInsets.all(Constants.KPadding / 2),
                  height: isComputer ? 50 : 40,
                  width: isComputer ? 50 : 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      "assets/521119688_1078649260578555_5364186740130543035_n.jpg",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        color: Colors.white,
                        size: isComputer ? 30 : 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "KEEPTEX",
            style: TextStyle(
              color: Colors.white,
              fontSize: isComputer ? 22 : 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ),
          if (isComputer) ...[
            const SizedBox(width: 30),
            Row(
              children: [
                _buildNavButton('Vue d\'ensemble', 'overview'),
                _buildNavButton('Revenus', 'revenue'),
                _buildNavButton('Ventes', 'sales'),
                _buildNavButton('Contrôle', 'control'),
              ],
            ),
          ],
          const Spacer(),
        ],
      ),
      actions: [
        if (!isComputer)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _handleNavigation,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'overview', child: Text('Vue d\'ensemble')),
              const PopupMenuItem(value: 'revenue', child: Text('Revenus')),
              const PopupMenuItem(value: 'sales', child: Text('Ventes')),
              const PopupMenuItem(value: 'control', child: Text('Contrôle')),
            ],
          ),
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.white, size: isComputer ? 24 : 20),
          onPressed: () {},
          tooltip: 'Notifications',
        ),
        IconButton(
              icon: Icon(Icons.logout, color: Colors.white, size: isComputer ? 24 : 20),
              tooltip: 'Déconnexion',
              onPressed: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                if (shouldLogout == true) {
                  final userCubit = Provider.of<UserCubit>(context, listen: false);
                  await userCubit.logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/LoginDrawerStyle', (route) => false);
                }
              },
            ),
        if (!isComputer) const SizedBox(width: 8),
      ],
      leading: Builder(
        builder: (context) => IconButton(
          iconSize: isComputer ? 24 : 50,
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    );
  }
}

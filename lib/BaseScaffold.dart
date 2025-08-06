import 'package:flutter/material.dart';

import 'Drawer/drawer_page.dart';
import 'appbar/appbarWidget.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;
  final Widget? floatingActionButton;

  const BaseScaffold({Key? key, required this.body, this.floatingActionButton}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 10),
        child: Appbarwidget(),
      ),
      drawer: DrawerPage(), // ✅ Add this line
      // Wrap the body in a SingleChildScrollView to ensure everything is scrollable
      body: SafeArea(
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      // Ensure the scaffold can resize properly
      resizeToAvoidBottomInset: true,
    );
  }
}

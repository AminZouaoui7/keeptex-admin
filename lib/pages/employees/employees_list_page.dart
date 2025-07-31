import 'package:flutter/cupertino.dart';

import '../../BaseScaffold.dart';

class EmployeesListPage extends StatelessWidget {
  const EmployeesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Center(
        child: Text("Page Vue d'ensemble"),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';

import '../../BaseScaffold.dart';

class ProductsListPage extends StatelessWidget {
  const ProductsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Center(
        child: Text("Page Vue d'ensemble"),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:keeptex/pages/orders/CancelledOrdersPage.dart';
import 'package:keeptex/pages/orders/DeliveredOrdersPage.dart';
import 'package:keeptex/pages/orders/PendingOrdersPage.dart';
import 'package:keeptex/pages/orders/ProcessingOrdersPage.dart';
import 'package:keeptex/pages/stock/StockAlertsPage.dart';
import 'package:keeptex/pages/stock/StockMovementsPage.dart';
import 'package:keeptex/pages/tools/commande.dart';
import 'package:keeptex/pages/tools/factures.dart';
import 'package:provider/provider.dart';
import 'Core/utils/cacheHelper.dart';

import 'Services/UserService.dart';
import 'loginpage.dart';
import 'pages/dashboard/overview_page.dart';
import 'pages/dashboard/revenue_page.dart';
import 'pages/dashboard/sales_page.dart';
import 'pages/dashboard/control_page.dart';

import 'pages/products/products_list_page.dart';
import 'pages/products/add_product_page.dart';

import 'pages/orders/all_orders_page.dart';

import 'pages/customers/customers_list_page.dart';

import 'pages/stock/stock_status_page.dart';

import 'pages/production/production_tracking_page.dart';

import 'pages/employees/employees_list_page.dart';
import 'pages/employees/employees_schedules_page.dart';
import 'pages/employees/employees_performance_page.dart';

// Tools
import 'pages/tools/factures.dart';
import 'pages/tools/commande.dart';

// Settings
import 'pages/settings/profile_page.dart';
import 'pages/settings/roles_page.dart';

// Widget tree / home
import 'package:flutter_bloc/flutter_bloc.dart';
import 'widgettree.dart';
import 'Core/Cubit/UserCubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Configuration des providers au niveau de l'application
        Provider<UserService>(
          create: (context) => UserService(),
        ),
        BlocProvider<UserCubit>(
          create: (context) => UserCubit(Provider.of<UserService>(context, listen: false)),
        ),
        // Ajoutez d'autres providers selon vos besoins
      ],
      child: MaterialApp(
        title: 'KeepTex',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/LoginDrawerStyle',
        routes: {
          '/': (context) => const Widgettree(),

          '/LoginDrawerStyle': (context) => LoginDrawerView(),

          // Dashboard
          '/overview': (context) => OverviewPage(),
          '/revenue': (context) => RevenuePage(),
          '/sales': (context) => SalesPage(),
          '/control': (context) => ControlPage(),

          // Products
          '/products/list': (context) => ProductsListPage(),
          '/products/add': (context) => AddProductPage(),

          // Orders
          '/orders/all': (context) => AllOrdersPage(),
          '/orders/pending': (context) => PendingOrdersPage(),
          '/orders/processing': (context) => ProcessingOrdersPage(),
          '/orders/delivered': (context) => DeliveredOrdersPage(),
          '/orders/cancelled': (context) => CancelledOrdersPage(),

          // Customers
          '/customers/list': (context) => CustomersListPage(),

          // Stock
          '/stock/status': (context) => StockStatusPage(),
          '/stock/alerts': (context) => StockAlertsPage(),
          '/stock/movements': (context) => StockMovementsPage(),

          // Production
          '/production/tracking': (context) => ProductionTrackingPage(),

          // Employees
          '/employees/list': (context) => EmployeesListPage(),
          '/employees/schedules': (context) => EmployeesSchedulesPage(),
          '/employees/performance': (context) => EmployeesPerformancePage(),

          // Tools
          '/tools/invoices': (context) => InvoicesPage(),
          '/tools/delivery': (context) => DeliveryPage(),

          // Settings
          '/settings/profile': (context) => ProfilePage(),
          '/settings/roles': (context) => RolesPage(),
        },
      ),
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keeptex/Drawer/drawer_page.dart';
import 'package:keeptex/appbar/appbarWidget.dart';
import 'package:keeptex/responsiveLayout.dart';

class Widgettree extends StatefulWidget {
  const Widgettree({super.key});

  @override
  State<Widgettree> createState() => _WidgettreeState();
}

class _WidgettreeState extends State<Widgettree> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: (ResponsiveLayout.isTinyLimit(context) ||
            ResponsiveLayout.isTinyHeightLimit(context)
            ? Container()
            : Appbarwidget()),
        preferredSize: Size(double.infinity, 100),
      ),
      body: ResponsiveLayout(
          tiny: Container(),
          phone: Container(),
          tablet: Container(),
          Largetablet: Container(),
          computer: Container()
      ),
      drawer: DrawerPage(),
    );
  }
}
import 'package:flutter/cupertino.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key, required this.tiny, required this.phone, required this.tablet, required this.Largetablet, required this.computer});
  final Widget tiny;
  final Widget phone;
  final Widget tablet;
  final Widget Largetablet;
  final Widget computer;

  static final int tinyHeightLimit= 100;
  static final int tinyLimit= 270;
  static final int phoneLimit= 550;
  static final int tabletLimit= 800;
  static final int largetabletLimit= 1100;

  static bool isTinyHeightLimit(BuildContext context )=>MediaQuery.of(context).size.height<tinyHeightLimit;
  static bool isTinyLimit(BuildContext context )=>MediaQuery.of(context).size.width<tinyLimit;
  static bool isphone(BuildContext context )=>MediaQuery.of(context).size.width<phoneLimit && MediaQuery.of(context).size.width>= tinyLimit;
  static bool isTablet(BuildContext context )=>MediaQuery.of(context).size.width<tabletLimit && MediaQuery.of(context).size.width>= phoneLimit;
  static bool islargeTablet(BuildContext context )=>MediaQuery.of(context).size.width<largetabletLimit && MediaQuery.of(context).size.width>= tabletLimit;
  static bool iscomputer(BuildContext context )=>MediaQuery.of(context).size.width>=largetabletLimit;


  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(builder: (BuildContext context , BoxConstraints constraints){
    if(constraints.maxWidth < tinyLimit  || constraints.maxHeight <tinyHeightLimit){
      return tiny;
    }
    if(constraints.maxWidth < phoneLimit ){
      return phone;
    }
    if(constraints.maxWidth < tabletLimit ){
      return tablet;

    }
    if(constraints.maxWidth < largetabletLimit ){
      return Largetablet;

    }
    else{
      return computer;
    }

    },
    );
  }
}

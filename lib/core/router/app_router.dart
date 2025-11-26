import 'package:atomic/core/constants/colors.dart';
import 'package:atomic/core/router/routes_names.dart';
import 'package:atomic/features/home_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings value) {
    String? name = value.name;

    switch (name) {
      case RoutesNames.home:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Error'),
            backgroundColor: Colors.white,
            foregroundColor: CustomColors.blackColor,
          ),
          body: const Center(
            child: Text('no screen found'),
          ),
        );
      },
    );
  }
}

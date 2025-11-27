import 'package:atomic/features/food_feature/presentation/pages/food_screen.dart';
import 'package:atomic/features/habits_feature/presentation/pages/habits_screen.dart';
import 'package:atomic/features/notes_feature/presentation/pages/notes_screen.dart';
import 'package:atomic/features/todos_feature/presentation/pages/todos_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const platform = MethodChannel('com.example.atomic/widget');
  late PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeFromWidget();
    _setupMethodChannelListener();
  }

  Future<void> _initializeFromWidget() async {
    try {
      final int tabIndex = await platform.invokeMethod('getInitialTabIndex');
      print('HomeScreen: Received initial tab index: $tabIndex');
      setState(() {
        _pageIndex = tabIndex;
        _pageController = PageController(initialPage: tabIndex);
      });
    } catch (e) {
      // If widget navigation is not available, start from the first tab
      print('HomeScreen: Error getting initial tab index: $e');
      _pageController = PageController(initialPage: 0);
    }
  }

  void _setupMethodChannelListener() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'navigateToTab') {
        final int tabIndex = call.arguments as int;
        print('HomeScreen: Received navigateToTab request: $tabIndex');
        _navigateToTab(tabIndex);
      }
    });
  }

  void _navigateToTab(int tabIndex) {
    if (tabIndex >= 0 && tabIndex < 4) {
      setState(() {
        _pageIndex = tabIndex;
      });
      _pageController.animateToPage(
        tabIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: const [
          TodosScreen(),
          FoodScreen(),
          HabitsScreen(),
          NotesScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _pageIndex,
        onTap: (value) {
          setState(() {
            _pageIndex = value;
          });
          _pageController.animateToPage(
            value,
            duration: const Duration(milliseconds: 150),
            curve: Curves.bounceIn,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: "Todos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank),
            label: "Food",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Habits",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: "Notes",
          ),
        ],
      ),
    );
  }
}

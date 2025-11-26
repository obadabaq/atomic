import 'package:atomic/features/food_feature/presentation/pages/food_screen.dart';
import 'package:atomic/features/habits_feature/presentation/pages/habits_screen.dart';
import 'package:atomic/features/notes_feature/presentation/pages/notes_screen.dart';
import 'package:atomic/features/todos_feature/presentation/pages/todos_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _pageIndex = 0;

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

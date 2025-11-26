import 'package:atomic/core/constants/colors.dart';
import 'package:atomic/core/dependency_injection/locator.dart';
import 'package:atomic/features/food_feature/domain/usecases/food_use_case.dart';
import 'package:atomic/features/food_feature/presentation/bloc/food_bloc.dart';
import 'package:atomic/features/food_feature/presentation/widgets/my_food_list_tab.dart';
import 'package:atomic/features/food_feature/presentation/widgets/today_tracking_tab.dart';
import 'package:atomic/features/food_feature/presentation/widgets/analytics_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({Key? key}) : super(key: key);

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FoodBloc _foodBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize BLoC with all use cases
    _foodBloc = FoodBloc(
      getFoodsUseCase: sl<GetFoodsUseCase>(),
      addFoodUseCase: sl<AddFoodUseCase>(),
      updateFoodUseCase: sl<UpdateFoodUseCase>(),
      deleteFoodUseCase: sl<DeleteFoodUseCase>(),
      getTodayNutritionUseCase: sl<GetTodayNutritionUseCase>(),
      addMealEntryUseCase: sl<AddMealEntryUseCase>(),
      deleteMealEntryUseCase: sl<DeleteMealEntryUseCase>(),
      getAnalyticsUseCase: sl<GetAnalyticsUseCase>(),
    );

    // Load all data on init
    _foodBloc.add(const RefreshAllDataEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _foodBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FoodBloc>.value(
      value: _foodBloc,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Nutrition Calculator'),
          backgroundColor: Colors.white,
          foregroundColor: CustomColors.blackColor,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: CustomColors.primaryColor,
            labelColor: CustomColors.primaryColor,
            unselectedLabelColor: Colors.black45,
            tabs: const [
              Tab(text: 'Today', icon: Icon(Icons.today)),
              Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
              Tab(text: 'My Foods', icon: Icon(Icons.restaurant_menu)),
            ],
          ),
        ),
        body: BlocListener<FoodBloc, FoodState>(
          listener: (context, state) {
            if (state is FoodErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: CustomColors.redColor,
                ),
              );
            }
          },
          child: TabBarView(
            controller: _tabController,
            children: const [
              TodayTrackingTab(),
              AnalyticsTab(),
              MyFoodListTab(),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:save_ahead/cubit/home_cubit/home_cubit.dart';
import 'package:save_ahead/cubit/home_cubit/home_states.dart';
import 'package:save_ahead/cubit/navigation_cubit/navigation_cubit.dart';
import 'package:save_ahead/cubit/navigation_cubit/navigation_states.dart';
import 'package:save_ahead/layouts/debts_screen.dart';
import 'package:save_ahead/layouts/items_screen.dart';
import 'package:save_ahead/layouts/subscriptions_screen.dart';
import 'package:save_ahead/shared/constants/const_asset_images.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late NavigationCubit _navigationCubit;
  late HomeCubit _homeCubit;

  @override
  Widget build(BuildContext context) {
    _navigationCubit = NavigationCubit.get(context);
    _homeCubit = HomeCubit.get(context);
    return Scaffold(
      bottomNavigationBar: BlocConsumer<NavigationCubit, NavigationStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return bottomNavBarDesign(_navigationCubit.bottomNavBarIndex);
        }
      ),
      appBar: AppBar(
        title: const Text('Save Ahead'),
        centerTitle: true,
      ),
      body: bodyDesign(),
      floatingActionButton: BlocConsumer<NavigationCubit, NavigationStates>(
        listener: (context, state) {},
        builder: (context, state) => (_navigationCubit.screenIndex == _navigationCubit.bottomNavBarIndex)
          ? BlocConsumer<HomeCubit, HomeStates>(
            listener: (context, state) {},
            builder: (context, state) {
              return IconButton(
                onPressed: () => null,
                icon: Icon(Icons.add),
              );
            }
          ) : Container(color: Colors.transparent,),
      )
    );
  }

  Widget bodyDesign() => Stack(
    children: [
      bodyBackground(),
      BlocConsumer<HomeCubit, HomeStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return Column(
            children: [
              bodyCard(),
              BlocConsumer<NavigationCubit, NavigationStates>(
                listener: (context, state) {},
                builder: (context, state) {
                  return IndexedStack(
                    index: _navigationCubit.screenIndex,
                    children: const [
                      SubscriptionsScreen(),
                      DebtsScreen(),
                      ItemsScreen(),
                    ],
                  );
                },
              ),
            ],
          );
        }
      ),
    ],
  );

  Widget bottomNavBarDesign(int bottomNavBarIndex) => BottomNavigationBar(
    onTap: (index) => _navigationCubit.changeBottomNavBarIndex(index),
    currentIndex: bottomNavBarIndex,
    showUnselectedLabels: false,
    useLegacyColorScheme: false,
    items: [
      BottomNavigationBarItem(
        icon: SvgPicture.asset(ConstAssetImages.subscriptionIcon.path, width: 32, height: 32,),
        label: 'Subscriptions',
      ),
      BottomNavigationBarItem(
        icon: SvgPicture.asset(ConstAssetImages.debtIcon.path, width: 32, height: 32,),
        label: 'Debts',
      ),
      BottomNavigationBarItem(
        icon: SvgPicture.asset(ConstAssetImages.itemIcon.path, width: 32, height: 32,),
        label: 'Items',
      ),
    ],
  );

  Widget bodyBackground() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF386485),
          Color(0xFF70A0C4),
        ],
      ),
    ),
  );

  Widget bodyCard() => Card.filled(
    color: Colors.white30,
    margin: EdgeInsets.all(32),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 48.0),
      child: Column(
        children: [
          Text('You need to have', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          SizedBox(height: 8,),
          Text('\$${_homeCubit.totalSaved.toStringAsFixed(2)}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
          SizedBox(height: 8,),
          Text('saved during this month', style: TextStyle(fontSize: 14,),),
        ],
      ),
    )
  );
}

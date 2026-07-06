import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:save_ahead/cubit/bottom_nav_bar_cubit/bottom_nav_bar_cubit.dart';
import 'package:save_ahead/cubit/bottom_nav_bar_cubit/bottom_nav_bar_states.dart';
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

  late BottomNavBarCubit _bottomNavBarCubit;

  @override
  Widget build(BuildContext context) {
    _bottomNavBarCubit = BottomNavBarCubit.get(context);
    return Scaffold(
      bottomNavigationBar: BlocConsumer<BottomNavBarCubit, BottomNavBarStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return BottomNavigationBar(
            onTap: (index) => _bottomNavBarCubit.changeBottomNavBarIndex(index),
            currentIndex: _bottomNavBarCubit.currentIndex,
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
        }
      ),
      appBar: AppBar(
        title: const Text('Save Ahead'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          BlocConsumer<BottomNavBarCubit, BottomNavBarStates>(
            listener: (context, state) {},
            builder: (context, state) {
              return IndexedStack(
                index: _bottomNavBarCubit.currentIndex,
                children: const [
                  SubscriptionsScreen(),
                  DebtsScreen(),
                  ItemsScreen(),
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: IconButton(
        onPressed: () => null,
        icon: Icon(Icons.add),
      ),
    );
  }
}

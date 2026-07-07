import 'package:flutter/material.dart';
import 'package:save_ahead/cubit/navigation_cubit/navigation_cubit.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {

  late NavigationCubit _navigationCubit;

  @override
  Widget build(BuildContext context) {
    _navigationCubit = NavigationCubit.get(context);
    return Center(
      child: Text('Subscriptions Screen'),
    );
  }
}

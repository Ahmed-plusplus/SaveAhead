import 'package:save_ahead/shared/enum/duration_type.dart';

class SubscriptionModel {
  String name;
  double amount;
  DateTime startingDate;
  DurationType durationType;
  double currentSavedAmount;

  SubscriptionModel(this.name, this.amount, this.startingDate,
      this.durationType, this.currentSavedAmount);


}
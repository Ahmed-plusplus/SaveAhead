import 'package:save_ahead/models/debt_model.dart';
import 'package:save_ahead/models/subscription_model.dart';
import 'package:save_ahead/shared/enum/duration_type.dart';
import 'package:save_ahead/shared/extensions/date_time_extension.dart';
import 'package:save_ahead/shared/local/database/db_constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqfliteDB {
  static late Database _database;
  static const String _DATABAS_NAME = 'SaveAhead.db';

  static Future<Database> createDB() async => _database = await openDatabase(
    join(await getDatabasesPath(), _DATABAS_NAME),
    version: 1,
    onCreate: (database, version) async {
      try {
        await database.execute(_createSubscriptionTable());
        await database.execute(_createDebtTable());
      } catch (e) {
        print(e.toString());
      }
    },
    onOpen: (database) {},
    onUpgrade: (database, oldVersion, newVersion) async {
      // try {
      //   if(oldVersion <= 3){
      //     await database.execute('DROP TABLE IF EXISTS ${TransactionConstants.TRANSACTION_TABLE}');
      //     await database.execute(_createOperationTable());
      //   }
      // } catch (e) {
      //   print(e.toString());
      // }
    },
  );

  static String _createSubscriptionTable() {
    return 'CREATE TABLE ${DbConstants.SUBSCRIPTION_TABLE} ('
        '${DbConstants.ID_ATTR} INTEGER PRIMARY KEY AUTOINCREMENT,'
        '${DbConstants.NAME_ATTR} TEXT UNIQUE,'
        '${DbConstants.AMOUNT_ATTR} REAL,'
        '${DbConstants.STARTING_DATE_ATTR} INTEGER,'
        '${DbConstants.ENDING_DATE_ATTR} INTEGER,'
        '${DbConstants.DURATION_TYPE_ATTR} INTEGER,'
        '${DbConstants.CURRENT_SAVED_AMOUNT_ATTR} REAL,'
        '${DbConstants.TWISE_IN_MONTH_ATTR} INTEGER'
        ')';
  }

  static String _createDebtTable() {
    return 'CREATE TABLE ${DbConstants.DEPT_TABLE} ('
        '${DbConstants.ID_ATTR} INTEGER PRIMARY KEY AUTOINCREMENT,'
        '${DbConstants.NAME_ATTR} TEXT UNIQUE,'
        '${DbConstants.AMOUNT_ATTR} REAL,'
        '${DbConstants.ENDING_DATE_ATTR} INTEGER,'
        '${DbConstants.CURRENT_SAVED_AMOUNT_ATTR} REAL'
        ')';
  }

  Future<List<Map<String, dynamic>>> getData(String query, List<Object?> args) async {
    return await _database.rawQuery(query, args);
  }

  Future<int> insertSubscriptionData(SubscriptionModel subscription) async {
    int months = -1;
    if(subscription.durationType.index <= DurationType.thirtyDays.index) {
      Duration duration = Duration(days: (subscription.durationType.index == 0) ? 28 : 30);
      DateTime currRenew = subscription.startingDate;
      DateTime nextRenew = currRenew.add(duration);
      months = 0;
      while (currRenew.month != nextRenew.month) {
        months++;
        currRenew = nextRenew;
        nextRenew = currRenew.add(duration);
      }
    }
    return await _database.transaction((txn) {
      return txn.rawInsert(
        'INSERT INTO ${DbConstants.SUBSCRIPTION_TABLE} ('
            '${DbConstants.NAME_ATTR},'
            '${DbConstants.AMOUNT_ATTR},' //update
            '${DbConstants.STARTING_DATE_ATTR},'
            '${DbConstants.ENDING_DATE_ATTR},'
            '${DbConstants.DURATION_TYPE_ATTR},' //update
            '${DbConstants.CURRENT_SAVED_AMOUNT_ATTR}, '
            '${DbConstants.TWISE_IN_MONTH_ATTR}'
            ') VALUES (?,?,?,?,?,?,?)',
        [
          subscription.name,
          subscription.amount,
          subscription.startingDate.millisecondsSinceEpoch,
          subscription.startingDate.addWRT(subscription.durationType).millisecondsSinceEpoch,
          subscription.durationType.index,
          subscription.currentSavedAmount,
          months
        ],
      );
    });
  }

  Future<int> insertDebtData(DebtModel debt) async {
    return await _database.transaction((txn) {
      return txn.rawInsert(
        'INSERT INTO ${DbConstants.DEPT_TABLE} ('
            '${DbConstants.NAME_ATTR},'
            '${DbConstants.AMOUNT_ATTR},' //update
            '${DbConstants.ENDING_DATE_ATTR},' //update
            '${DbConstants.CURRENT_SAVED_AMOUNT_ATTR}'
            ') VALUES (?,?,?,?)',
        [
          debt.name,
          debt.amount,
          debt.endingDate.millisecondsSinceEpoch,
          debt.currentSavedAmount,
        ],
      );
    });
  }

  String _getMonthsBetween(String startingDate, String endingDate, String isDaysCalculated) {
    return '((strftime(\'%Y\', $endingDate / 1000, \'unixepoch\') - strftime(\'%Y\', $startingDate / 1000, \'unixepoch\')) * 12'
        ' + '
        '(strftime(\'%m\', $endingDate / 1000, \'unixepoch\') - strftime(\'%m\', $startingDate / 1000, \'unixepoch\')))'
        ' - '
        'CASE '
          'WHEN $isDaysCalculated THEN '
            'CASE '
              'WHEN strftime(\'%d\', $endingDate / 1000, \'unixepoch\') < strftime(\'%d\', $startingDate / 1000, \'unixepoch\') '
              'THEN 1 '
              'ELSE 0 '
            'END '
          'ELSE 0 '
        'END'
        ' + 1'; // +1 to include the starting month
  }

  Future<double> _getTotalSavedAmountForSubscriptions() async {
    DateTime today = DateTime.now().dateOnly();
    DateTime firstMonth = today.copyWith(day: 1);
    DateTime nextMonth = firstMonth.copyWith(month: firstMonth.month + 1);
    String query = 'SELECT SUM('
        'CASE WHEN ${DbConstants.STARTING_DATE_ATTR} >= ${firstMonth.millisecondsSinceEpoch}'
        ' AND ${DbConstants.STARTING_DATE_ATTR} < ${nextMonth.millisecondsSinceEpoch}'
        ' THEN '
          '${DbConstants.CURRENT_SAVED_AMOUNT_ATTR}'
        ' ELSE '
          '${DbConstants.CURRENT_SAVED_AMOUNT_ATTR}'
          ' + '
          '((${DbConstants.AMOUNT_ATTR} - ${DbConstants.CURRENT_SAVED_AMOUNT_ATTR})'
          ' / '
          '(${
            _getMonthsBetween(
              today.millisecondsSinceEpoch.toString(),
              DbConstants.ENDING_DATE_ATTR,
              '${DbConstants.DURATION_TYPE_ATTR} <= ${DurationType.threeHundredSixtyFiveDays.index}'
            )
          }))'
          ' + '
          'CASE WHEN ${DbConstants.TWISE_IN_MONTH_ATTR} > 0 THEN '
            '${DbConstants.CURRENT_SAVED_AMOUNT_ATTR}'
            ' + '
            '((${DbConstants.AMOUNT_ATTR} - ${DbConstants.CURRENT_SAVED_AMOUNT_ATTR})'
            ' / '
            '${DbConstants.TWISE_IN_MONTH_ATTR})'
          ' ELSE 0 '
          ' END'
        ' END'
        ') as TOTAL FROM "${DbConstants.SUBSCRIPTION_TABLE}"';
    print(query);
    var result = await getData(
        query,
        []
    );
    return result[0]['TOTAL'] ?? 0.0;
  }

  Future<double> _getTotalSavedAmountForDebts() async {
    DateTime today = DateTime.now().dateOnly();
    String query = 'SELECT SUM('
        '${DbConstants.CURRENT_SAVED_AMOUNT_ATTR}'
        ' + '
        '(${DbConstants.AMOUNT_ATTR} - ${DbConstants.CURRENT_SAVED_AMOUNT_ATTR})'
        ' / '
        '(${_getMonthsBetween(
            today.millisecondsSinceEpoch.toString(),
            DbConstants.ENDING_DATE_ATTR,
            'FALSE')
        })'
        ') as TOTAL FROM "${DbConstants.DEPT_TABLE}"';
    print(query);
    var result = await getData(
        query,
        []
    );
    return result[0]['TOTAL'] ?? 0.0;
  }

  Future<double> getTotalSavedAmount() async {
    double totalSavedAmountForSubscriptions = await _getTotalSavedAmountForSubscriptions();
    double totalSavedAmountForDebts = await _getTotalSavedAmountForDebts();

    return totalSavedAmountForSubscriptions + totalSavedAmountForDebts;
  }

  Future<List<SubscriptionModel>> getAllSubscriptions() async {
    List<Map<String, dynamic>> list = await getData(
      'SELECT * FROM "${DbConstants.SUBSCRIPTION_TABLE}"',
      [],
    );
    return list
        .map(
          (it) => SubscriptionModel(
            it[DbConstants.NAME_ATTR],
            it[DbConstants.AMOUNT_ATTR],
            DateTime.fromMillisecondsSinceEpoch(it[DbConstants.STARTING_DATE_ATTR]),
            DurationType.values[it[DbConstants.DURATION_TYPE_ATTR]],
            it[DbConstants.CURRENT_SAVED_AMOUNT_ATTR],
            DateTime.fromMillisecondsSinceEpoch(it[DbConstants.ENDING_DATE_ATTR])
          ),
        )
        .toList();
  }


  Future<List<SubscriptionModel>> _getAllEndingSubscriptions() async {
    String query = 'SELECT * FROM "${DbConstants.SUBSCRIPTION_TABLE}" '
        'WHERE ${DbConstants.ENDING_DATE_ATTR} <= ?';
    List<Map<String, dynamic>> list = await getData(query, [DateTime.now().dateOnly().millisecondsSinceEpoch]);
    return list.map((it) => SubscriptionModel(
        it[DbConstants.NAME_ATTR],
        it[DbConstants.AMOUNT_ATTR],
        DateTime.fromMillisecondsSinceEpoch(it[DbConstants.STARTING_DATE_ATTR]),
        DurationType.values[it[DbConstants.DURATION_TYPE_ATTR]],
        it[DbConstants.CURRENT_SAVED_AMOUNT_ATTR],
        DateTime.fromMillisecondsSinceEpoch(it[DbConstants.ENDING_DATE_ATTR]
      )
    )).toList();
  }


  Future<List<DebtModel>> getAllDebts() async {
    List<Map<String, dynamic>> list = await getData(
      'SELECT * FROM "${DbConstants.DEPT_TABLE}"',
      [],
    );
    return list
        .map(
          (it) => DebtModel(
            it[DbConstants.NAME_ATTR],
            it[DbConstants.AMOUNT_ATTR],
            DateTime.fromMillisecondsSinceEpoch(it[DbConstants.ENDING_DATE_ATTR]),
            it[DbConstants.CURRENT_SAVED_AMOUNT_ATTR],
          ),
        )
        .toList();
  }

  Future<void> renewSubscription() async {
    List<SubscriptionModel> subscriptions = await _getAllEndingSubscriptions();
    DateTime today = DateTime.now().dateOnly();
    for(SubscriptionModel subscription in subscriptions) {
      while(today.isAfter(subscription.endingDate ?? subscription.startingDate.addWRT(subscription.durationType))) {
        subscription.startingDate = subscription.endingDate ?? subscription.startingDate.addWRT(subscription.durationType);
        subscription.endingDate = subscription.startingDate.addWRT(subscription.durationType);
      }
      await _database.rawUpdate(
        'UPDATE ${DbConstants.SUBSCRIPTION_TABLE} '
            'SET ${DbConstants.STARTING_DATE_ATTR} = ${subscription.startingDate}, '
            '${DbConstants.ENDING_DATE_ATTR} = ${subscription.endingDate}, '
            '${DbConstants.CURRENT_SAVED_AMOUNT_ATTR} = '
            '${DbConstants.CURRENT_SAVED_AMOUNT_ATTR} - ${DbConstants.AMOUNT_ATTR} '
            'WHERE ${DbConstants.NAME_ATTR} = ?',
        [subscription.name],
      );
    }
  }

  Future<void> monthChanged() async {
    DateTime today = DateTime.now().dateOnly();
    String query = 'UPDATE ${DbConstants.SUBSCRIPTION_TABLE} '
        'SET ${DbConstants.CURRENT_SAVED_AMOUNT_ATTR} = '
        '${DbConstants.CURRENT_SAVED_AMOUNT_ATTR}'
        ' + '
        '(${DbConstants.AMOUNT_ATTR} - ${DbConstants.CURRENT_SAVED_AMOUNT_ATTR})'
        ' / '
        '(${
        _getMonthsBetween(
            today.millisecondsSinceEpoch.toString(),
            DbConstants.ENDING_DATE_ATTR,
            '${DbConstants.DURATION_TYPE_ATTR} <= ${DurationType.threeHundredSixtyFiveDays.index}'
        )
        })'
        ' + '
        'CASE WHEN ${DbConstants.TWISE_IN_MONTH_ATTR} > 0 THEN '
          '${DbConstants.CURRENT_SAVED_AMOUNT_ATTR}'
          ' + '
          '((${DbConstants.AMOUNT_ATTR} - ${DbConstants.CURRENT_SAVED_AMOUNT_ATTR})'
          ' / '
          '${DbConstants.TWISE_IN_MONTH_ATTR})'
          ' ELSE 0 '
        ' END, '
        '${DbConstants.TWISE_IN_MONTH_ATTR} = '
        'CASE WHEN ${DbConstants.TWISE_IN_MONTH_ATTR} > 0 THEN '
          '${DbConstants.TWISE_IN_MONTH_ATTR} - 1'
          ' ELSE ${DbConstants.TWISE_IN_MONTH_ATTR}'
        ' END';
    print(query);
    await _database.rawUpdate(
      query,
      [],
    );
    await _database.rawUpdate(
      'UPDATE ${DbConstants.DEPT_TABLE} '
          'SET ${DbConstants.CURRENT_SAVED_AMOUNT_ATTR} = '
          '${DbConstants.CURRENT_SAVED_AMOUNT_ATTR}'
          ' + '
          '(${DbConstants.AMOUNT_ATTR} - ${DbConstants.CURRENT_SAVED_AMOUNT_ATTR})'
          ' / '
          '(${_getMonthsBetween(
              today.millisecondsSinceEpoch.toString(),
              DbConstants.ENDING_DATE_ATTR,
              'FALSE'
          )})',
      [],
    );
  }

  Future<int> updateSubscription(String name, double newAmount, DurationType type) async {
    return await _database.rawUpdate(
      'UPDATE ${DbConstants.SUBSCRIPTION_TABLE} '
          'SET ${DbConstants.AMOUNT_ATTR} = ?, ${DbConstants.DURATION_TYPE_ATTR} = ? '
          'WHERE ${DbConstants.NAME_ATTR} = ?',
      [newAmount, type.index, name],
    );
  }

  Future<int> updateDebt(String name, double newAmount, DateTime endingDate) async {
    return await _database.rawUpdate(
      'UPDATE ${DbConstants.DEPT_TABLE} '
          'SET ${DbConstants.AMOUNT_ATTR} = ?, ${DbConstants.ENDING_DATE_ATTR} = ? '
          'WHERE ${DbConstants.NAME_ATTR} = ?',
      [newAmount, endingDate.millisecondsSinceEpoch, name],
    );
  }

  Future<int> removeSubscription(String name) async {
    return await _database.rawDelete(
      'DELETE FROM ${DbConstants.SUBSCRIPTION_TABLE} WHERE ${DbConstants.NAME_ATTR} = ?',
      [name],
    );
  }

  Future<int> removeDebt(String name) async {
    return await _database.rawDelete(
      'DELETE FROM ${DbConstants.DEPT_TABLE} WHERE ${DbConstants.NAME_ATTR} = ?',
      [name],
    );
  }

}
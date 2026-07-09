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
        '${DbConstants.CURRENT_SAVED_AMOUNT_ATTR} REAL'
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
    return await _database.transaction((txn) {
      return txn.rawInsert(
        'INSERT INTO ${DbConstants.SUBSCRIPTION_TABLE} ('
            '${DbConstants.NAME_ATTR},'
            '${DbConstants.AMOUNT_ATTR},' //update
            '${DbConstants.STARTING_DATE_ATTR},'
            '${DbConstants.ENDING_DATE_ATTR},'
            '${DbConstants.DURATION_TYPE_ATTR},' //update
            '${DbConstants.CURRENT_SAVED_AMOUNT_ATTR}'
            ') VALUES (?,?,?,?,?,?)',
        [
          subscription.name,
          subscription.amount,
          subscription.startingDate.millisecondsSinceEpoch,
          subscription.startingDate.addWRT(subscription.durationType).millisecondsSinceEpoch,
          subscription.durationType.index,
          subscription.currentSavedAmount,
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
    return '((strftime(\'%Y\', $endingDate) - strftime(\'%Y\', $startingDate)) * 12'
        ' + '
        '(strftime(\'%m\', $endingDate) - strftime(\'%m\', $startingDate)))'
        ' - '
        'CASE '
          'WHEN $isDaysCalculated THEN '
            'CASE '
              'WHEN strftime(\'%d\', $endingDate < strftime(\'%d\', $startingDate) '
              'THEN 1 '
              'ELSE 0 '
            'END '
          'ELSE 0 '
        'END'
        ' + 1'; // +1 to include the starting month
  }

  Future<double> _getTotalSavedAmountForSubscriptions() async {
    DateTime today = DateTime.now().dateOnly();
    String query = 'SELECT SUM('
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
    //TODO:: think about if the type 28 or 30 days and the starting date is 1st of the month and today is 28th or 30th of the month, then it will be counted as 1 time, but it should be counted as 2 times. So we need to check if the starting date + duration get a date of this month, then we can count it as 2 months, otherwise we can count it as 1 month.
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
    await _database.rawUpdate(
      'UPDATE ${DbConstants.SUBSCRIPTION_TABLE} '
      //TODO:: change the starting date and ending date
          // 'SET ${DbConstants.STARTING_DATE_ATTR} = ${DbConstants.ENDING_DATE_ATTR}, '
          // 'SET ${DbConstants.ENDING_DATE_ATTR} = ${DbConstants.STARTING_DATE_ATTR} + '
          // '(${DbConstants.DURATION_TYPE_ATTR} * 30 * 24 * 60 * 60 * 1000), '
          'SET ${DbConstants.CURRENT_SAVED_AMOUNT_ATTR} = 0 '
          'WHERE ${DbConstants.ENDING_DATE_ATTR} <= ?',
      [DateTime.now().dateOnly().millisecondsSinceEpoch],
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
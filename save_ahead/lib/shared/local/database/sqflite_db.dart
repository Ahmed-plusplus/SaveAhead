import 'package:save_ahead/models/debt_model.dart';
import 'package:save_ahead/models/subscription_model.dart';
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
            '${DbConstants.AMOUNT_ATTR},'
            '${DbConstants.STARTING_DATE_ATTR},'
            '${DbConstants.DURATION_TYPE_ATTR},'
            '${DbConstants.CURRENT_SAVED_AMOUNT_ATTR}'
            ') VALUES (?,?,?,?,?)',
        [
          subscription.name,
          subscription.amount,
          subscription.startingDate.millisecondsSinceEpoch,
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
            '${DbConstants.AMOUNT_ATTR},'
            '${DbConstants.ENDING_DATE_ATTR},'
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

  Future<double> getTotalSavedAmount() async {
    return Future.value(10.0);
    // var result = await getData(
    //     'SELECT SUM(${TransactionConstants.AMOUNT_ATTR}) FROM "${TransactionConstants.TRANSACTION_TABLE}" WHERE ${TransactionConstants.TYPE_ATTR} == ${TransactionType.customTransaction.index}',
    //     []
    // );
    // return result[0]['SUM(${TransactionConstants.AMOUNT_ATTR})'];
  }
  // Future<List<ChildExpensesChangingModel>> getChildTransactions(String name) async {
  //   List<Map<String, dynamic>> list = await getData(
  //     'SELECT * FROM "${TransactionConstants.TRANSACTION_TABLE}" WHERE ${TransactionConstants.NAME_ATTR} = ?',
  //     [name],
  //   );
  //   return list.reversed
  //       .map(
  //         (map) => ChildExpensesChangingModel(
  //       id: map[TransactionConstants.ID_ATTR],
  //       name: map[TransactionConstants.NAME_ATTR],
  //       expenses: (Currency.values.where((currency) => currency.name == map[TransactionConstants.CURRENCY_ATTR]).first, map[TransactionConstants.AMOUNT_ATTR]),
  //       dateTime: DateTime.fromMillisecondsSinceEpoch(map[TransactionConstants.DATE_ATTR]),
  //       description: map[TransactionConstants.DESCRIPTION_ATTR],
  //       total: (Currency.values.where((currency) => currency.name == map[TransactionConstants.CURRENCY_ATTR]).first, map[TransactionConstants.TOTAL_AMOUNT_ATTR]),
  //     ),
  //   )
  //       .toList();
  // }

  // Future<double> getCustomTransactionValue(String name, DateTime from, Currency curr, bool increaseOnly) async{
  //   var result = await getData(
  //       'SELECT SUM(${TransactionConstants.AMOUNT_ATTR}) FROM "${TransactionConstants.TRANSACTION_TABLE}" WHERE '
  //           '${TransactionConstants.DATE_ATTR} >= ? AND '
  //           '${TransactionConstants.CURRENCY_ATTR} == ? AND '
  //           '${TransactionConstants.NAME_ATTR} == ? AND '
  //           '${(increaseOnly) ? '${TransactionConstants.AMOUNT_ATTR} > 0 AND ' : ''}'
  //           '${TransactionConstants.TYPE_ATTR} == ${TransactionType.customTransaction.index}',
  //       [from.millisecondsSinceEpoch, curr.name, name]
  //   );
  //   return result[0]['SUM(${TransactionConstants.AMOUNT_ATTR})'];
  // }

  // Future<int> updateDescription(int id, String description) async {
  //   return await _database.rawUpdate(
  //     'UPDATE ${TransactionConstants.TRANSACTION_TABLE} SET ${TransactionConstants.DESCRIPTION_ATTR} = ? WHERE ${TransactionConstants.ID_ATTR} = ?',
  //     [description, id],
  //   );
  // }

  // Future<int> removeChild(String name) async {
  //   return await _database.rawDelete(
  //     'DELETE FROM ${TransactionConstants.TRANSACTION_TABLE} WHERE ${TransactionConstants.NAME_ATTR} = ?',
  //     [name],
  //   );
  // }
}
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
        // await database.execute(_createOperationTable());
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

  // static String _createOperationTable() {
  //   return 'CREATE TABLE ${TransactionConstants.TRANSACTION_TABLE} ('
  //       '${TransactionConstants.ID_ATTR} INTEGER PRIMARY KEY AUTOINCREMENT,'
  //       '${TransactionConstants.NAME_ATTR} TEXT,'
  //       '${TransactionConstants.CURRENCY_ATTR} TEXT,'
  //       '${TransactionConstants.AMOUNT_ATTR} REAL,'
  //       '${TransactionConstants.DATE_ATTR} INTEGER,'
  //       '${TransactionConstants.DESCRIPTION_ATTR} TEXT,'
  //       '${TransactionConstants.TOTAL_AMOUNT_ATTR} REAL,'
  //       '${TransactionConstants.TYPE_ATTR} INTEGER'
  //       ')';
  // }

  Future<List<Map<String, dynamic>>> getData(String query, List<Object?> args) async {
    return await _database.rawQuery(query, args);
  }

  // Future<ChildExpensesChangingModel> insertChildData(ChildExpensesChangingModel child, TransactionType type) async {
  //   child.id = await _database.transaction((txn) {
  //     return txn
  //         .rawInsert('INSERT INTO ${TransactionConstants.TRANSACTION_TABLE} ('
  //         '${TransactionConstants.NAME_ATTR},'
  //         '${TransactionConstants.CURRENCY_ATTR},'
  //         '${TransactionConstants.AMOUNT_ATTR},'
  //         '${TransactionConstants.DATE_ATTR},'
  //         '${TransactionConstants.DESCRIPTION_ATTR},'
  //         '${TransactionConstants.TOTAL_AMOUNT_ATTR},'
  //         '${TransactionConstants.TYPE_ATTR}'
  //         ') VALUES ('
  //         '"${child.name}",'
  //         '"${child.expenses.$1.name}",'
  //         '${child.expenses.$2},'
  //         '${child.dateTime!.millisecondsSinceEpoch},'
  //         '"${child.description}",'
  //         '${child.total.$2},'
  //         '${type.index}'
  //         ')');
  //   });
  //   return child;
  // }

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
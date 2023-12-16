import 'package:balance/core/database/database.dart';
import 'package:balance/core/database/tables/transactions.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

part 'transactions_dao.g.dart';

@lazySingleton
@DriftAccessor(tables: [Transactions])
class TransactionsDAO extends DatabaseAccessor<Database>
    with _$TransactionsDAOMixin {
  TransactionsDAO(super.db);

  Future insert(String groupId, String name, int amount) {
    return into(transactions).insert(TransactionsCompanion.insert(
        id: const Uuid().v1(),
        createdAt: DateTime.now(),
        groupId: groupId,
        name: Value(name),
        amount: Value(amount)));
  }

  Future updateAmount(int amount, String transactionId) async {
    final companion = TransactionsCompanion(amount: Value(amount));
    return (update(transactions)..where((tbl) => tbl.id.equals(transactionId)))
        .write(companion);
  }

  Future get(String id) {
    return (select(transactions)..where((tbl) => tbl.id.equals(id)))
        .getSingle();
  }

  Stream<List<Transaction>> watch(String groupId) {
    return (select(transactions)
          ..where((tbl) => tbl.groupId.equals(groupId))
          ..orderBy([
            (tbl) =>
                OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }
}

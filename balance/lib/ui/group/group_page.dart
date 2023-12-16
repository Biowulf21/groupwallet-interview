import 'package:balance/core/database/dao/groups_dao.dart';
import 'package:balance/core/database/dao/transactions_dao.dart';
import 'package:balance/core/database/tables/transactions.dart';
import 'package:balance/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class GroupPage extends StatefulWidget {
  final String groupId;
  const GroupPage(this.groupId, {super.key});

  @override
  State<StatefulWidget> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late final GroupsDao _groupsDao = getIt.get<GroupsDao>();
  late final TransactionsDAO _transactionsDAO = getIt.get<TransactionsDAO>();

  final _incomeController = TextEditingController();
  final _expenseController = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Group details"),
        ),
        body: StreamBuilder(
          stream: _groupsDao.watchGroup(widget.groupId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("Loading...");
            }
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(snapshot.data?.name ?? ""),
                Text(snapshot.data?.balance.toString() ?? ""),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _incomeController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[0-9]"))
                      ],
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        suffixText: "\$",
                      ),
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        final amount = int.parse(_incomeController.text);
                        final balance = snapshot.data?.balance ?? 0;
                        _groupsDao.adjustBalance(
                            balance + amount, widget.groupId);
                        _incomeController.text = "";

                        const name = "Added new income";

                        _transactionsDAO.insert(widget.groupId, name, amount);
                      },
                      child: const Text("Add income")),
                ]),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expenseController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[0-9]"))
                      ],
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        suffixText: "\$",
                      ),
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        final amount = int.parse(_expenseController.text);
                        final balance = snapshot.data?.balance ?? 0;
                        _groupsDao.adjustBalance(
                            balance - amount, widget.groupId);

                        _expenseController.text = "";

                        const name = "Added new expense";

                        _transactionsDAO.insert(
                            widget.groupId, name, amount * -1);
                      },
                      child: const Text("Add expense")),
                ]),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: StreamBuilder(
                            stream: _transactionsDAO.watch(widget.groupId),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Text("No data to load");
                              }

                              if (snapshot.hasError) {
                                return Text(snapshot.error.toString());
                              }

                              if (snapshot.data == null) {
                                return const Text("No transactions");
                              }

                              return ListView.builder(
                                  itemCount: snapshot.requireData.length,
                                  itemBuilder: (context, index) {
                                    final formatter = NumberFormat('#,###');
                                    final formattedAmount = formatter.format(
                                        snapshot.requireData[index].amount);
                                    return GestureDetector(
                                      onTap: () {},
                                      child: ListTile(
                                        title: Text(snapshot
                                            .requireData[index].name
                                            .toString()),
                                        subtitle: Text(formattedAmount),
                                        onTap: () {
                                          print(
                                              "/transactions/edit/${snapshot.requireData[index].id}");

                                          GoRouterHelper(context).push(
                                              "/transactions/edit/${snapshot.requireData[index].id}?groupId=${widget.groupId}");
                                        },
                                      ),
                                    );
                                  });
                            }))),
              ],
            );
          },
        ),
      );
}

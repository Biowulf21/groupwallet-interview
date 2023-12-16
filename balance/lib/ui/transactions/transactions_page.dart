import 'package:balance/core/database/dao/groups_dao.dart';
import 'package:balance/core/database/dao/transactions_dao.dart';
import 'package:balance/core/database/database.dart';
import 'package:balance/main.dart';
import 'package:flutter/material.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage(this.id, this.groupId, {super.key});
  final String id;
  final String groupId;

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late final TransactionsDAO _transactionsDAO = getIt.get<TransactionsDAO>();
  late final GroupsDao _groupsDao = getIt.get<GroupsDao>();

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Transaction'),
        ),
        body: Column(
          children: [
            FutureBuilder(
              future: _transactionsDAO.get(widget.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text("No data to show");
                }

                if (snapshot.hasError) {
                  return const Text("Error");
                }

                // clunky way to check if the transaction is an expense or income
                //  if i wasn't strapped for time, I'd probably use an enum for this instead
                final isIncome = snapshot.data!.name == "Added new income";

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Text(snapshot.data?.name ?? ""),
                        Text(snapshot.data?.amount.toString() ?? ""),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                          controller: _controller,
                          decoration: const InputDecoration(
                              hintText: 'Edit amount',
                              hintStyle: TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              int amount = int.parse(_controller.text);
                              print('isIncome: $isIncome');

                              if (!isIncome) amount *= -1;

                              _transactionsDAO.updateAmount(amount, widget.id);
                              _groupsDao.recalculateTotal(widget.groupId);

                              Navigator.pop(context);
                            },
                            child: const Text('Submit'))
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

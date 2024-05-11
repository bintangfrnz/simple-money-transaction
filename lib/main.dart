import 'package:flutter/material.dart';
import 'package:simple_money_transaction/interface_manager.dart';
import 'package:simple_money_transaction/transaction.dart';
import 'package:simple_money_transaction/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      title: "Simple Money Transaction",
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static InterfaceManager manager = InterfaceManager();
  String errorMessage = manager.getErrorMessage();

  // Declare 2 Users
  static User user1 = User("1", "Bintang", 10000);
  static User user2 = User("2", "Bulan", 20000);
  static User user3 = User("3", "Matahari", 30000);

  User _fromUser = user1;
  User _toUser = user2;

  List<User> users = [user1, user2, user3];
  List<User> fromUsers = [user1, user3];
  List<User> toUsers = [user2, user3];
  TransactionType _transactionType = TransactionType.transfer;

  double? amount;
  bool _loading = false;

  @override
  void dispose() {
    manager.status.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction Simulation"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: StreamBuilder(
          stream: manager.status.stream,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data == InterfaceStatus.idle) {
                _loading = false;
              } else {
                switch (snapshot.data) {
                  case TransactionStatus.running:
                    _loading = true;
                  case TransactionStatus.finished:
                    manager.clearTransactionProgress();
                  case TransactionStatus.error:
                    manager.clearTransactionProgress();
                }

                WidgetsBinding.instance.addPostFrameCallback((_) =>
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            duration: const Duration(seconds: 1),
                            content: Text(manager.updateWithAlertMessage(snapshot.data)),
                        ),
                    ),
                );
              }
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                balanceWidget(users),
                const SizedBox(height: 20),
                // region from user
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text(
                    "From User",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: DropdownButton<User>(
                    value: _fromUser,
                    isExpanded: true,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w400
                    ),
                    onChanged: (User? user) {
                      setState(() {
                        _fromUser = user!;
                        toUsers = List.from(users);
                        toUsers.remove(_fromUser);
                      });
                    },
                    items: fromUsers.map((User user) {
                      return DropdownMenuItem<User>(
                        value: user,
                        child: Text(
                          user.name,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // endregion from user
                const SizedBox(height: 8),
                // region to user
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text(
                    "To User",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: DropdownButton<User>(
                    value: _toUser,
                    isExpanded: true,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w400
                    ),
                    onChanged: (User? user) {
                      setState(() {
                        _toUser = user!;
                        fromUsers = List.from(users);
                        fromUsers.remove(_toUser);
                      });
                    },
                    items: toUsers.map((User user) {
                      return DropdownMenuItem<User>(
                        value: user,
                        child: Text(
                          user.name,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // endregion to user
                const SizedBox(height: 16),
                // region transaction type
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text(
                    "Transaction Type",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: DropdownButton<TransactionType>(
                    value: _transactionType,
                    isExpanded: true,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w400
                    ),
                    onChanged: (TransactionType? typeName) {
                      setState(() {
                        _transactionType = typeName!;
                      });
                    },
                    items: TransactionType.values.map((TransactionType type) {
                      return DropdownMenuItem<TransactionType>(
                        value: type,
                        child: Text(
                            type.name,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w400
                            ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // endregion transaction type
                const SizedBox(height: 4),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _transactionType == TransactionType.transfer
                      ? "Please select BOTH user" : _transactionType == TransactionType.withdrawal
                      ? "Please select FROM user" : "Please select TO user",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // region input
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text(
                    "Input",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                      onChanged: (newAmount) {
                        amount = double.parse(newAmount);
                      },
                      maxLength: 6,
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w600
                      ),
                      decoration: InputDecoration(
                        hintText: "Masukkan nilai",
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 22,
                            fontWeight: FontWeight.w400
                        ),
                      ),
                  ),
                ),
                // endregion input
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    manager.getErrorMessage(),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.red
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: _loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            await manager.createTransaction(
                                _fromUser,
                                _toUser,
                                _transactionType,
                                amount ?? 0
                            );
                          },
                          child: const Text("Process"),
                      ),
                ),
              ],
            );
          },
        ),
      )
    );
  }

  Widget balanceWidget(List<User> users) {
    return Column(
      children: users.map((user) =>
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${user.name}'s Balance",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue
                  ),
                ),
                Text(
                  "Rp${user.getBalance()}",
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue
                  ),
                ),
              ],
            ),
          ),
      ).toList(),
    );
  }
}

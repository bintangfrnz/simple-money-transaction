import 'package:flutter/foundation.dart';
import 'package:simple_money_transaction/transaction.dart';
import 'package:simple_money_transaction/user.dart';
import 'dart:async';


class TransactionManager {
  final List<Transaction> _transactionQueue = <Transaction>[];
  int _transactionCount = 0;

  StreamController streamController =  StreamController();
  TransactionError _error = TransactionError.nothing;

  setError(TransactionError error) {
    _error = error;
  }

  TransactionError getError() {
    return _error;
  }

  Future<bool> createTransaction(
      User from,
      User to,
      TransactionType type,
      double amount
  ) {
    Transaction tr = Transaction(_transactionCount.toString(), from, to, type, amount);
    _transactionCount += 1;
    _transactionQueue.insert(0, tr);

    changeTransactionStatus(tr, TransactionStatus.running);
    return Future.delayed(const Duration(seconds: 2), () {
      tr.setTimeStamp(DateTime.now());
      var error = true;

      if (amount == 0) {
        changeTransactionStatus(tr, TransactionStatus.error, error: TransactionError.emptyAmount);
      } else if (type != TransactionType.topup && from.getBalance() < amount) {
        changeTransactionStatus(tr, TransactionStatus.error, error: TransactionError.insufficientBalance);
      } else {
        switch (type) {
          case TransactionType.topup:
            to.setBalance(to.getBalance() + amount);
          case TransactionType.withdrawal:
            from.setBalance(from.getBalance() - amount);
          case TransactionType.transfer:
            to.setBalance(to.getBalance() + amount);
            from.setBalance(from.getBalance() - amount);
        }
        error = false;
        changeTransactionStatus(tr, TransactionStatus.finished);
      }
      _transactionQueue.removeAt(0);
      return !error;
    });
  }

  Transaction? getCurrentTransaction() {
    return (_transactionQueue.isNotEmpty) ? _transactionQueue.first : null;
  }

  void changeTransactionStatus(
      Transaction tr,
      TransactionStatus status,
      { TransactionError error = TransactionError.nothing }
  ) {
    tr.setStatus(status);
    _error = (status == TransactionStatus.error) ? error : TransactionError.nothing;
    streamController.add(tr.getStatus());
    if (kDebugMode) {
      print("Transaction Status: ${tr.getStatus()}");
    }
  }
}

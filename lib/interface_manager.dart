import 'package:simple_money_transaction/transaction.dart';
import 'package:simple_money_transaction/transaction_manager.dart';
import 'package:simple_money_transaction/user.dart';
import 'dart:async';

enum InterfaceStatus { idle, inProgress }

class InterfaceManager {
  TransactionManager manager = TransactionManager();
  StreamController status =  StreamController();

  String _errorMessage = "";
  late Transaction currentTransaction;

  InterfaceManager() {
    status = manager.streamController;
  }

  String getErrorMessage() {
    return _errorMessage;
  }

  clearErrorMessage() {
    _errorMessage = "";
  }

  clearTransactionProgress() {
    status.add(InterfaceStatus.idle);
  }

  Future<void> createTransaction(
      User from,
      User to,
      TransactionType type,
      double amount
  ) async {
    if (manager.getCurrentTransaction() != null) {
      // Will be executed if we request another transaction while running
      status.add(InterfaceStatus.inProgress);
      return;
    }
    clearErrorMessage();
    await manager.createTransaction(from, to, type, amount);
  }

  updateWithAlertMessage(dynamic event) {
    if (event is InterfaceStatus) {
      switch (event) {
        case InterfaceStatus.inProgress:
          return "A transaction is currently in progress. Please wait";
        case InterfaceStatus.idle:
          return "";
      }
    } else if (event is TransactionStatus) {
      var time = DateTime.now();
      var now = "${time.hour}:${time.minute}:${time.second}";

      switch (event) {
        case TransactionStatus.created:
          return "Transaction created at $now";
        case TransactionStatus.running:
          return "Transaction running at $now";
        case TransactionStatus.finished:
          return "Transaction completed at $now";
        case TransactionStatus.error:
          switch (manager.getError()) {
            case TransactionError.emptyAmount:
              _errorMessage = "Amount should be filled.";
            case TransactionError.insufficientBalance:
              _errorMessage = "Your balance is insufficient.";
            case TransactionError.nothing:
              _errorMessage = "";
          }
          return "Transaction failed at $now";
      }
    }
  }
}
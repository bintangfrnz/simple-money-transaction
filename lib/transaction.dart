import 'package:simple_money_transaction/user.dart';

enum TransactionType { topup, withdrawal, transfer }
enum TransactionStatus { created, running, finished, error }
enum TransactionError { nothing, emptyAmount, insufficientBalance }

class Transaction {
  final String _id;
  final User _from;
  final User _to;
  final TransactionType _type;
  final double _amount;
  late String _timestamp;

  TransactionStatus _status = TransactionStatus.created;
  Transaction(this._id, this._from, this._to, this._type, this._amount);

  String getId() {
    return _id;
  }

  User getFrom() {
    return _from;
  }

  User getTo() {
    return _to;
  }

  TransactionType getType() {
    return _type;
  }

  double getAmount() {
    return _amount;
  }

  String getTimestamp() {
    return _timestamp;
  }

  setTimeStamp(DateTime time) {
    _timestamp = "${time.day} ${time.hour}:${time.minute}:${time.second}";
  }

  TransactionStatus getStatus() {
    return _status;
  }

  setStatus(TransactionStatus status) {
    _status = status;
  }
}

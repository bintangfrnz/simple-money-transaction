class User {
  final String uid;
  final String name;
  double _balance;

  User(this.uid, this.name, this._balance);

  void setBalance(double balance) {
    _balance = balance;
  }

  double getBalance() {
    return _balance;
  }
}

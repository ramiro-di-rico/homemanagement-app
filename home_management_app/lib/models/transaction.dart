class TransactionModel {
  final int id, accountId, categoryId;
  String name;
  double price;
  DateTime date;
  TransactionType transactionType;

  TransactionModel(this.id, this.accountId, this.categoryId, this.name, this.price, this.date, this.transactionType);

  factory TransactionModel.fromJson(dynamic json){
    return TransactionModel(
      json['id'], 
      json['accountId'], 
      json['categoryId'], 
      json['name'], 
      double.parse(json['price'].toString()), 
      DateTime.parse(json['date']),
      parse(json['transactionType']));
  }  

  Map toJson() =>
  {
    'id': this.id,
    'accountId': this.accountId,
    'categoryId': this.categoryId,
    'name': this.name,
    'price': this.price,
    'date': this.date.toIso8601String(),
    'transactionType': this.transactionType == TransactionType.Income ? 0 : 1,
  };

  static TransactionType parse(int value) => value == 0 ? TransactionType.Income : TransactionType.Outcome;

  static TransactionType parseByName(String value) => value == 'Income' ? TransactionType.Income : TransactionType.Outcome;

  static List<String> getTransactionTypes() => ['Income', 'Outcome'];

  String parseTransactionByType() => transactionType == TransactionType.Income ? 'Income' : 'Outcome';
}

enum TransactionType{
  Income, 
  Outcome
}
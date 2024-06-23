class ChargeAmountClass {
  final String partsName;
  final double amount;

  ChargeAmountClass({
    required this.partsName,
    required this.amount,
  });
  Map<String, dynamic> toMap() {
    return {
      'partsName': partsName,
      'amount': amount,
    };
  }
}
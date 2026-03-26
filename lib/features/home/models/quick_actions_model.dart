class QuickActionModel {
  bool? status;
  String? message;
  List<Data>? data;

  QuickActionModel({this.status, this.message, this.data});

  QuickActionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    final rawData = json['data'];
    if (rawData is List) {
      data = rawData
          .whereType<Map<String, dynamic>>()
          .map((v) => Data.fromJson(v))
          .toList();
    } else if (rawData is Map) {
      data = rawData.values
          .whereType<Map<String, dynamic>>()
          .map((v) => Data.fromJson(v))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? paymentType;
  String? billerName;
  String? billerId;
  String? amount;
  String? desc;
  String? nextDue;
  int? daysLeft;
  String? icon;

  Data(
      {this.paymentType,
      this.billerName,
      this.billerId,
      this.amount,
      this.desc,
      this.nextDue,
      this.daysLeft,
      this.icon});

  Data.fromJson(Map<String, dynamic> json) {
    paymentType = json['payment_type'];
    billerName = json['biller_name'];
    billerId = json['biller_id'];
    final rawAmount = json['amount'];
    amount = rawAmount == null ? null : rawAmount.toString();
    desc = json['desc'];
    nextDue = json['next_due'];
    daysLeft = json['days_left'];
    icon = json['icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['payment_type'] = paymentType;
    data['biller_name'] = billerName;
    data['biller_id'] = billerId;
    data['amount'] = amount;
    data['desc'] = desc;
    data['next_due'] = nextDue;
    data['days_left'] = daysLeft;
    data['icon'] = icon;
    return data;
  }
}

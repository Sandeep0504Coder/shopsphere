import 'dart:convert';
class SystemSettings {
  final String id;
  final String settingCategory;
  final String settingUniqueName;
  final String settingName;
  final String settingValue;
  final String entityId;
  final dynamic entityDetails;

  SystemSettings({
    required this.id,
    required this.settingCategory,
    required this.settingUniqueName,
    required this.settingName,
    required this.settingValue,
    required this.entityId,
    this.entityDetails,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'settingCategory': settingCategory,
      'settingUniqueName': settingUniqueName,
      'settingName': settingName,
      'settingValue': settingValue,
      'entityId': entityId,
      'entityDetails': entityDetails,
    };
  }

  factory SystemSettings.fromMap(Map<String, dynamic> map) {
    return SystemSettings(
      id: map['_id'] ?? '',
      settingCategory: map['settingCategory'] ?? '',
      settingUniqueName: map['settingUniqueName'] ?? '',
      settingName: map['settingName'] ?? '',
      settingValue: map['settingValue'] ?? '',
      entityId: map['entityId'] ?? '',
      entityDetails: map['entityDetails'] != null
          ? EntityDetails.fromMap(map['entityDetails'])
          : null,
    );
  }
}

class EntityDetails {
  final String ruleName;
  final num subtotalMinRange;
  final num amount;
  final double percentage;
  final String setDeliveryFeeTo;
  final num? subtotalMaxRange;

  EntityDetails({
    required this.ruleName,
    required this.subtotalMinRange,
    required this.amount,
    required this.percentage,
    required this.setDeliveryFeeTo,
    this.subtotalMaxRange
  });

  factory EntityDetails.fromMap(Map<String, dynamic> map) {
    return EntityDetails(
      ruleName: map['ruleName'] ?? '',
      subtotalMinRange: map['subtotalMinRange'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      percentage: map['percentage']?.toDouble() ?? 0.0,
      setDeliveryFeeTo: map['setDeliveryFeeTo'] ?? '',
      subtotalMaxRange: map['subtotalMaxRange'] != null
          ? map['subtotalMaxRange'].toDouble()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ruleName': ruleName,
      'subtotalMinRange': subtotalMinRange,
      'amount': amount,
      'percentage': percentage,
      'setDeliveryFeeTo': setDeliveryFeeTo,
      'subtotalMaxRange': subtotalMaxRange,
    };
  }
}
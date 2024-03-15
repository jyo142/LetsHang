import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum HangEventRecurringType { weekly, daily, monthly, yearly }

class HangEventRecurringSettings extends Equatable {
  final HangEventRecurringType recurringType;
  final int recurringFrequency;
  const HangEventRecurringSettings({
    required this.recurringType,
    required this.recurringFrequency,
  });

  HangEventRecurringSettings copyWith({
    HangEventRecurringType? recurringType,
    int? recurringFrequency,
  }) {
    return HangEventRecurringSettings(
      recurringType: recurringType ?? this.recurringType,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
    );
  }

  static HangEventRecurringSettings fromSnapshot(DocumentSnapshot snap) {
    return fromMap(snap.data() as Map<String, dynamic>);
  }

  static HangEventRecurringSettings fromMap(Map<String, dynamic> map) {
    HangEventRecurringSettings model = HangEventRecurringSettings(
      recurringType: HangEventRecurringType.values
          .firstWhere((e) => e.name == map["recurringType"]),
      recurringFrequency: map['recurringFrequency'],
    );

    return model;
  }

  Map<String, Object?> toDocument() {
    Map<String, Object?> retVal = {
      'recurringType': recurringType.name,
      'recurringFrequency': recurringFrequency,
    };
    return retVal;
  }

  @override
  List<Object?> get props => [recurringType, recurringFrequency];
}

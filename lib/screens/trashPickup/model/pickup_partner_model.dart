import 'dart:convert';
import 'package:get/get.dart'; 

class PickupPartnerModel {
  final RxString partnerName;
  final RxString partnerContact;

  PickupPartnerModel({
    required String partnerName,
    required String partnerContact,
  })  : partnerName = RxString(partnerName), 
        partnerContact = RxString(partnerContact);

  PickupPartnerModel copyWith({
    String? partnerName,
    String? partnerContact,
  }) {
    return PickupPartnerModel(
      partnerName: partnerName ?? this.partnerName.value,
      partnerContact: partnerContact ?? this.partnerContact.value,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'partner_name': partnerName.value,
      'partner_contact': partnerContact.value,
    };
  }

  factory PickupPartnerModel.fromMap(Map<String, dynamic> map) {
    return PickupPartnerModel(
      partnerName: map['partner_name'] ?? '',
      partnerContact: map['partner_contact'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PickupPartnerModel.fromJson(String source) =>
      PickupPartnerModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'PickupPartnerModel(partner_name: ${partnerName.value}, partner_contact: ${partnerContact.value})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PickupPartnerModel &&
        other.partnerName.value == partnerName.value &&
        other.partnerContact.value == partnerContact.value;
  }

  @override
  int get hashCode => partnerName.hashCode ^ partnerContact.hashCode;
}

class contact {
  String? name;
  String? phone;
  String? checkInDate;

  contact({this.name, this.phone, this.checkInDate});

  String? getName() {
    return name;
  }

  String? getPhone() {
    return phone;
  }

  String? getCheckInDate() {
    return checkInDate;
  }

  factory contact.fromJson(Map<String, dynamic> json) {
    return contact(
      name: json['user'] as String,
      phone: json['phone'] as String,
      checkInDate: json['checkIn'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': name,
      'phone': phone,
      'checkIn': checkInDate,
    };
  }
}

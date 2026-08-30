class DashboardLoginModel {
  final String emailAddress;
  final String password;

  const DashboardLoginModel({
    required this.emailAddress,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {'Email_Adress': emailAddress, 'Password': password};
  }

  factory DashboardLoginModel.fromJson(Map<String, dynamic> json) {
    return DashboardLoginModel(
      emailAddress:
          json['email']?.toString() ?? json['EmailAddress']?.toString() ?? '',
      password:
          json['password']?.toString() ?? json['Password']?.toString() ?? '',
    );
  }
}

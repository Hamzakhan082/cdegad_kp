class EmployeeLoginModel {
  final String emailAddress;
  final String password;

  const EmployeeLoginModel({
    required this.emailAddress,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {'EmailAddress': emailAddress, 'Password': password};
  }

  factory EmployeeLoginModel.fromJson(Map<String, dynamic> json) {
    return EmployeeLoginModel(
      emailAddress:
          json['email']?.toString() ?? json['EmailAddress']?.toString() ?? '',
      password:
          json['password']?.toString() ?? json['Password']?.toString() ?? '',
    );
  }
}

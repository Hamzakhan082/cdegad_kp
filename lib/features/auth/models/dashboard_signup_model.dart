class DashboardSignupModel {
  final String fullName;
  final String emailAddress;
  final String password;
  final String confirmPassword;

  const DashboardSignupModel({
    required this.fullName,
    required this.emailAddress,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': emailAddress,
      'password': password,
    };
  }

  factory DashboardSignupModel.fromJson(Map<String, dynamic> json) {
    return DashboardSignupModel(
      fullName: json['full_name']?.toString() ?? json['FullName']?.toString() ?? '',
      emailAddress: json['email']?.toString() ?? json['EmailAddress']?.toString() ?? '',
      password: json['password']?.toString() ?? json['Password']?.toString() ?? '',
      confirmPassword: json['password']?.toString() ?? json['ConfirmPassword']?.toString() ?? '',
    );
  }
}

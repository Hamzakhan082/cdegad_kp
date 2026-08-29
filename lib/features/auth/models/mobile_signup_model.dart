class MobileSignupModel {
  final String fullName;
  final String emailAddress;
  final String password;
  final String confirmPassword;
  final String mobile;

  const MobileSignupModel({
    required this.fullName,
    required this.emailAddress,
    required this.password,
    required this.confirmPassword,
    required this.mobile,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': emailAddress,
      'password': password,
      'phone': mobile,
    };
  }

  factory MobileSignupModel.fromJson(Map<String, dynamic> json) {
    return MobileSignupModel(
      fullName: json['full_name']?.toString() ?? json['FullName']?.toString() ?? '',
      emailAddress: json['email']?.toString() ?? json['EmailAddress']?.toString() ?? '',
      password: json['password']?.toString() ?? json['Password']?.toString() ?? '',
      confirmPassword: json['password']?.toString() ?? json['ConfirmPassword']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? json['Mobile']?.toString() ?? '',
    );
  }
}

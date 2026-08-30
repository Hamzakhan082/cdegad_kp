import 'dart:io';

class EmployeeSignupModel {
  final String fullName;
  final String emailAddress;
  final String password;
  final String confirmPassword;
  final String cnic;
  final String division;
  final String employeeNo;
  final String mobile;
  final String gender;
  final File? photo;

  const EmployeeSignupModel({
    required this.fullName,
    required this.emailAddress,
    required this.password,
    required this.confirmPassword,
    required this.cnic,
    required this.division,
    required this.employeeNo,
    required this.mobile,
    required this.gender,
    this.photo,
  });

  Map<String, dynamic> toJson() {
    return {
      'FullName': fullName,
      'EmailAddress': emailAddress,
      'Password': password,
      'ConfirmPassword': confirmPassword,
      'CNIC': cnic,
      'Division': division,
      'EmployeeNo': employeeNo,
      'Mobile': mobile,
      'Gender': gender,
    };
  }

  factory EmployeeSignupModel.fromJson(Map<String, dynamic> json) {
    return EmployeeSignupModel(
      fullName:
          json['full_name']?.toString() ?? json['FullName']?.toString() ?? '',
      emailAddress:
          json['email']?.toString() ?? json['EmailAddress']?.toString() ?? '',
      password:
          json['password']?.toString() ?? json['Password']?.toString() ?? '',
      confirmPassword:
          json['password']?.toString() ??
          json['ConfirmPassword']?.toString() ??
          '',
      cnic: json['cnic']?.toString() ?? json['CNIC']?.toString() ?? '',
      division:
          json['division']?.toString() ?? json['Division']?.toString() ?? '',
      employeeNo:
          json['employee_no']?.toString() ??
          json['EmployeeNo']?.toString() ??
          '',
      mobile: json['mobile']?.toString() ?? json['Mobile']?.toString() ?? '',
      gender: json['gender']?.toString() ?? json['Gender']?.toString() ?? '',
      photo: null,
    );
  }

  Map<String, String> toFormData() {
    return {
      'FullName': fullName,
      'EmailAddress': emailAddress,
      'Password': password,
      'ConfirmPassword': confirmPassword,
      'CNIC': cnic,
      'Division': division,
      'EmployeeNo': employeeNo,
      'Mobile': mobile,
      'Gender': gender,
    };
  }
}

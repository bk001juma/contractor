class RegisterModel {
  String name;
  String email;
  String phone;
  String password;
  String confirmPassword;
  bool obscurePassword;
  bool obscureConfirmPassword;

  RegisterModel({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.password = '',
    this.confirmPassword = '',
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
  });

  // Convert to API format
  Map<String, dynamic> toJson() {
    return {
      'fullName': name,
      'email': email,
      'phoneNumber': phone,
      'password': password,
      'userType': 'CLIENT', // Default for now
    };
  }
}

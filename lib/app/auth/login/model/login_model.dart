class LoginModel {
  String email;
  String password;
  bool rememberMe;
  bool obscurePassword;

  LoginModel({
    this.email = '',
    this.password = '',
    this.rememberMe = false,
    this.obscurePassword = true,
  });
}

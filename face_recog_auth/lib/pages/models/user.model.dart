
class User {
  String user;
  String password;
  List modelData;
  String email;

  User({
    this.user,
    this.password,
    this.modelData,
    this.email
  });

  String getUsername() {
    return user;
  }

  static User fromMap(Map<String, dynamic> user) {
    return User(
      user: user['user'],
      password: user['password'],
      modelData: user['modeldata'],
      email: user['email'],
    );
  }

  toMap() {
    return {
      'user': user,
      'password': password,
      'modeldata': modelData,
      'email': email
    };
  }
}

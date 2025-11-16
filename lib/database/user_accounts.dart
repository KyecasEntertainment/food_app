class UserAccounts {
  final String email;
  final String password;

  UserAccounts({
    required this.email,
    required this.password,
  });
}

final List<UserAccounts> accounts = [
  UserAccounts(
    email: "johndoe@example.com",
    password: "12345678",
  ),
];

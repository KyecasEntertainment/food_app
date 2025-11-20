class UserAccounts {
  final String email;
  final String password;
  final String name;
  final String avatar;

  UserAccounts({
    required this.email,
    required this.password,
    required this.name,
    required this.avatar,
  });
}

final List<UserAccounts> accounts = [
  UserAccounts(
    email: "johndoe@example.com",
    password: "12345678",
    name: "John Doe",
    avatar: "assets/avatars/johndoe.jpg",
  ),
  UserAccounts(
    email: "janedoe@example.com",
    password: "87654321",
    name: "Jane Doe",
    avatar: "assets/avatars/janedoe.jpg",
  ),
  UserAccounts(
    email: "bob@example.com",
    password: "password123",
    name: "Bob Smith",
    avatar: "assets/avatars/bob.jpg",
  ),
  UserAccounts(
    email: "alice@example.com",
    password: "alice2025",
    name: "Alice Johnson",
    avatar: "assets/avatars/alice.jpg",
  ),
  UserAccounts(
    email: "michael@example.com",
    password: "mikeSecure1",
    name: "Michael Reyes",
    avatar: "assets/avatars/michael.jpg",
  ),
  UserAccounts(
    email: "sarah@example.com",
    password: "sarahPass99",
    name: "Sarah Williams",
    avatar: "assets/avatars/sarah.jpg",
  ),
  UserAccounts(
    email: "david@example.com",
    password: "davidKey88",
    name: "David Anderson",
    avatar: "assets/avatars/david.jpg",
  ),
  UserAccounts(
    email: "emily@example.com",
    password: "emilySafe00",
    name: "Emily Carter",
    avatar: "assets/avatars/emily.jpg",
  ),
  UserAccounts(
    email: "kevin@example.com",
    password: "kevinLogins22",
    name: "Kevin Thompson",
    avatar: "assets/avatars/kevin.jpg",
  ),
  UserAccounts(
    email: "sophia@example.com",
    password: "sophiaPass33",
    name: "Sophia Martinez",
    avatar: "assets/avatars/sophia.jpg",
  ),
];


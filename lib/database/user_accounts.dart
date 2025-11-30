class UserAccounts {
  final String email;
  final String password;
  final String name;
  final String avatar;
  final String role;

  UserAccounts({
    required this.email,
    required this.password,
    required this.name,
    required this.avatar,
    required this.role,
  });
}

final List<UserAccounts> accounts = [
  UserAccounts(
    email: "johndoe@example.com",
    password: "12345678",
    name: "John Doe",
    avatar: "assets/avatars/johndoe.jpg",
    role: "Admin",

  ),
  UserAccounts(
    email: "janedoe@example.com",
    password: "87654321",
    name: "Jane Doe",
    avatar: "assets/avatars/janedoe.jpg",
    role: "User",
  ),
  UserAccounts(
    email: "bob@example.com",
    password: "password123",
    name: "Bob Smith",
    avatar: "assets/avatars/bob.jpg",
    role: "User",
  ),
  UserAccounts(
    email: "alice@example.com",
    password: "alice2025",
    name: "Alice Johnson",
    avatar: "assets/avatars/alice.jpg",
    role: "User",
  ),
  UserAccounts(
    email: "michael@example.com",
    password: "mikeSecure1",
    name: "Michael Reyes",
    avatar: "assets/avatars/michael.jpg",
    role: "User",
  ),
  UserAccounts(
    email: "sarah@example.com",
    password: "sarahPass99",
    name: "Sarah Williams",
    avatar: "assets/avatars/sarah.jpg",
    role: "User",
  ),
  UserAccounts(
    email: "david@example.com",
    password: "davidKey88",
    name: "David Anderson",
    avatar: "assets/avatars/david.jpg",
    role: "User",
  ),
  UserAccounts(
    email: "emily@example.com",
    password: "emilySafe00",
    name: "Emily Carter",
    avatar: "assets/avatars/emily.jpg",
    role: "User",
  ),
  UserAccounts(
    email: "kevin@example.com",
    password: "kevinLogins22",
    name: "Kevin Thompson",
    avatar: "assets/avatars/kevin.jpg",
    role: "User",
  ),
  UserAccounts(
    email: "sophia@example.com",
    password: "sophiaPass33",
    name: "Sophia Martinez",
    avatar: "assets/avatars/sophia.jpg",
    role: "User",
  ),
];


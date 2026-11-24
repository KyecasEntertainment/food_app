import 'address.dart';

/// A profile row. Authentication credentials belong to Supabase Auth, not here.
class UserAccounts {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String avatar;
  final Address address;

  const UserAccounts({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.avatar,
    this.address = Address.empty,
  });

  String get name => '$firstName $lastName'.trim();

  UserAccounts copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? avatar,
    Address? address,
  }) => UserAccounts(
    id: id,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    email: email ?? this.email,
    avatar: avatar ?? this.avatar,
    address: address ?? this.address,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'avatar': avatar,
    'address': address.toJson(),
  };

  factory UserAccounts.fromJson(Map<String, dynamic> json) => UserAccounts(
    id: json['id'] as String,
    firstName: json['first_name'] as String,
    lastName: json['last_name'] as String,
    email: json['email'] as String? ?? '',
    avatar: json['avatar'] as String? ?? '',
    address: json['address'] == null
        ? Address.empty
        : Address.fromJson(Map<String, dynamic>.from(json['address'] as Map)),
  );
}

// Demo profiles until Supabase Auth supplies real UUIDs. Passwords are isolated
// from profile records and are never serialized with user data.
final List<UserAccounts> accounts = [
  _demo(
    '00000000-0000-4000-8000-000000000001',
    'John',
    'Doe',
    'johndoe@example.com',
    'johndoe.jpg',
  ),
  _demo(
    '00000000-0000-4000-8000-000000000002',
    'Jane',
    'Doe',
    'janedoe@example.com',
    'janedoe.jpg',
  ),
  _demo(
    '00000000-0000-4000-8000-000000000003',
    'Bob',
    'Smith',
    'bob@example.com',
    'bob.jpg',
  ),
  _demo(
    '00000000-0000-4000-8000-000000000004',
    'Alice',
    'Johnson',
    'alice@example.com',
    'alice.jpg',
  ),
  _demo(
    '00000000-0000-4000-8000-000000000005',
    'Michael',
    'Reyes',
    'michael@example.com',
    'michael.jpg',
  ),
  _demo(
    '00000000-0000-4000-8000-000000000006',
    'Sarah',
    'Williams',
    'sarah@example.com',
    'sarah.jpg',
  ),
  _demo(
    '00000000-0000-4000-8000-000000000007',
    'David',
    'Anderson',
    'david@example.com',
    'david.jpg',
  ),
  _demo(
    '00000000-0000-4000-8000-000000000008',
    'Emily',
    'Carter',
    'emily@example.com',
    'emily.jpg',
  ),
  _demo(
    '00000000-0000-4000-8000-000000000009',
    'Kevin',
    'Thompson',
    'kevin@example.com',
    'kevin.jpg',
  ),
  _demo(
    '00000000-0000-4000-8000-000000000010',
    'Sophia',
    'Martinez',
    'sophia@example.com',
    'sophia.jpg',
  ),
];

UserAccounts _demo(
  String id,
  String first,
  String last,
  String email,
  String image,
) => UserAccounts(
  id: id,
  firstName: first,
  lastName: last,
  email: email,
  avatar: 'assets/avatars/$image',
);

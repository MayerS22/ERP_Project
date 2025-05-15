class User {
  final String id;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    role: json['role'],
  );
}

// Mock users for demonstration purposes
List<User> getMockUsers() {
  return [
    User(
      id: 'user1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      role: 'Manager',
    ),
    User(
      id: 'user2',
      name: 'Jane Smith',
      email: 'jane.smith@example.com',
      role: 'Developer',
    ),
    User(
      id: 'user3',
      name: 'Bob Johnson',
      email: 'bob.johnson@example.com',
      role: 'Designer',
    ),
    User(
      id: 'user4',
      name: 'Alice Brown',
      email: 'alice.brown@example.com',
      role: 'Tester',
    ),
    User(
      id: 'user5',
      name: 'Charlie Wilson',
      email: 'charlie.wilson@example.com',
      role: 'Product Owner',
    ),
  ];
} 
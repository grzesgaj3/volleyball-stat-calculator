class Player {
  final String firstName;
  final String lastName;
  final int number;
  final String position;
  
  Player({
    required this.firstName,
    required this.lastName,
    required this.number,
    required this.position,
  });
  
  String get fullName => '$firstName $lastName';
}

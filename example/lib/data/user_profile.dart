class Address {
  final String street;
  final String city;
  final String zip;

  const Address({
    required this.street,
    required this.city,
    required this.zip,
  });

  factory Address.fromMap(Map<String, dynamic> map) => Address(
        street: map['street'] as String? ?? '',
        city: map['city'] as String? ?? '',
        zip: map['zip'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'street': street,
        'city': city,
        'zip': zip,
      };

  @override
  String toString() => 'Address(street: $street, city: $city, zip: $zip)';
}

class UserProfile {
  final String name;
  final String email;
  final int age;
  final DateTime birthDate;
  final String gender;
  final bool agreed;
  final String? licenseNumber;
  final List<String> tags;
  final List<Address> addresses;
  final String firstName;
  final String lastName;

  const UserProfile({
    required this.name,
    required this.email,
    required this.age,
    required this.birthDate,
    required this.gender,
    required this.agreed,
    this.licenseNumber,
    required this.tags,
    required this.addresses,
    required this.firstName,
    required this.lastName,
  });

  /// Constructs a UserProfile from a map — works with both raw JSON
  /// (from an API) and form.values (from the form).
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final info = map['info'] as Map<String, dynamic>?;
    final rawDate = map['birthDate'];
    return UserProfile(
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      age: map['age'] as int? ?? 0,
      birthDate: rawDate is DateTime
          ? rawDate
          : DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime(2000),
      gender: map['gender'] as String? ?? '',
      agreed: map['agreed'] as bool? ?? false,
      licenseNumber: map['licenseNumber'] as String?,
      tags: (map['tags'] as List?)?.whereType<String>().toList() ?? [],
      addresses: (map['addresses'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(Address.fromMap)
              .toList() ??
          [],
      firstName: info?['firstName'] as String? ?? '',
      lastName: info?['lastName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'age': age,
        'birthDate': birthDate,
        'gender': gender,
        'agreed': agreed,
        'licenseNumber': licenseNumber,
        'tags': tags,
        'addresses': addresses.map((a) => a.toMap()).toList(),
        'info': {
          'firstName': firstName,
          'lastName': lastName,
        },
      };

  @override
  String toString() =>
      'UserProfile(name: $name, email: $email, age: $age, '
      'birthDate: ${birthDate.toIso8601String()}, gender: $gender, '
      'agreed: $agreed, licenseNumber: $licenseNumber, '
      'tags: $tags, addresses: $addresses, '
      'firstName: $firstName, lastName: $lastName)';
}

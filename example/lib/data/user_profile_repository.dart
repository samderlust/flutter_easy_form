import 'user_profile.dart';

/// Simulates a repository layer that fetches / saves data from an API.
///
/// In a real app this would call your HTTP client, parse JSON into
/// [UserProfile], and return typed models to the UI layer.
class UserProfileRepository {
  /// Simulated list of taken emails for async validation.
  static const _takenEmails = [
    'taken@email.com',
    'admin@example.com',
    'test@test.com',
  ];

  /// Simulates fetching a user profile from a server.
  /// Returns a typed [UserProfile] — the UI never sees raw JSON.
  Future<UserProfile> fetchProfile() async {
    // Simulate network delay.
    await Future.delayed(const Duration(seconds: 1));

    return UserProfile(
      name: 'Loaded Name',
      email: 'loaded@example.com',
      age: 42,
      birthDate: DateTime(1985, 6, 15),
      gender: 'other',
      agreed: true,
      tags: ['flutter', 'dart', 'mobile'],
      firstName: 'Loaded',
      lastName: 'Server',
    );
  }

  /// Simulates saving a user profile to a server.
  Future<void> saveProfile(UserProfile profile) async {
    await Future.delayed(const Duration(seconds: 1));
    // In a real app: http.post('/api/profile', body: profile.toMap());
  }

  /// Simulates checking if an email is already taken.
  /// Used as an async validator on the email field.
  Future<String?> checkEmailAvailability(String? email) async {
    if (email == null || email.isEmpty) return null;

    // Simulate network delay.
    await Future.delayed(const Duration(milliseconds: 500));

    if (_takenEmails.contains(email.toLowerCase())) {
      return 'this email is already taken';
    }
    return null;
  }
}

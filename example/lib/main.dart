import 'package:flutter/material.dart';

import 'data/user_profile_repository.dart';
import 'presentation/user_profile_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ezy_form example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: UserProfileScreen(repo: UserProfileRepository()),
    );
  }
}

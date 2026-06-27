import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './themes/palette.dart';
import './screens/signin_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aldimi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryBlue),
      ),
      home: const SignInScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/inicio_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FotosMakerApp());
}

class FotosMakerApp extends StatelessWidget {
  const FotosMakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const verde = Color(0xFF217346);
    return MaterialApp(
      title: 'Fotos Maker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: verde,
          primary: verde,
          surface: const Color(0xFFF8FAF8),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAF8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8FAF8),
          foregroundColor: Color(0xFF17251C),
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFE3EAE5)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDCE5DE)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDCE5DE)),
          ),
        ),
      ),
      home: const InicioScreen(),
    );
  }
}

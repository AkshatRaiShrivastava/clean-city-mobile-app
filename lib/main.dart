import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cleancity/screens/splash_screen.dart';
import 'package:cleancity/services/auth_service.dart';
import 'package:cleancity/services/theme_service.dart';
import 'package:cleancity/theme/app_theme.dart';
import 'package:cleancity/firebase_options.dart';
import 'services/theme_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(
          create: (_) => ThemeService(prefs),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'CleanCity',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) {
            // Wrap the entire app with our background
            return WavyBackground(child: child!);
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}

// Add this new class for the wavy background
class WavyBackground extends StatelessWidget {
  final Widget child;
  
  const WavyBackground({Key? key, required this.child}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background layer
        Positioned.fill(
          child: CustomPaint(
            painter: WavyBackgroundPainter(),
            size: Size.infinite,
          ),
        ),
        // Content layer
        child,
      ],
    );
  }
}

class WavyBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Define colors
    final darkNavyBlue = Color(0xFF002233);
    final turquoiseGreen = Color(0xFF00D9A6);
    final orangeCoral = Color(0xFFEE8855);
    
    final width = size.width;
    final height = size.height;
    
    // Paint for filling
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Draw the bottom navy layer (base layer)
    paint.color = darkNavyBlue;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
    
    // Draw the middle turquoise layer with wavy top and bottom
    paint.color = turquoiseGreen;
    
    final turquoisePath = Path();
    
    // Starting point at bottom left
    turquoisePath.moveTo(0, height * 0.7);
    
    // Bottom wavy edge
    turquoisePath.quadraticBezierTo(
      width * 0.2, height * 0.75, 
      width * 0.4, height * 0.7
    );
    turquoisePath.quadraticBezierTo(
      width * 0.7, height * 0.6, 
      width, height * 0.7
    );
    
    // Right edge
    turquoisePath.lineTo(width, height * 0.15);
    
    // Top wavy edge
    turquoisePath.quadraticBezierTo(
      width * 0.8, height * 0.05, 
      width * 0.5, height * 0.15
    );
    turquoisePath.quadraticBezierTo(
      width * 0.3, height * 0.2, 
      width * 0.15, height * 0.15
    );
    turquoisePath.quadraticBezierTo(
      width * 0.05, height * 0.1, 
      0, height * 0.15
    );
    
    // Close the path
    turquoisePath.lineTo(0, height * 0.7);
    turquoisePath.close();
    
    canvas.drawPath(turquoisePath, paint);
    
    // Draw the orange coral layer with wavy edges
    paint.color = orangeCoral;
    
    final orangePath = Path();
    
    // Starting point at bottom left
    orangePath.moveTo(0, height);
    
    // Bottom edge
    orangePath.lineTo(width, height);
    
    // Right edge
    orangePath.lineTo(width, height * 0.85);
    
    // Top wavy edge
    orangePath.quadraticBezierTo(
      width * 0.7, height * 0.75, 
      width * 0.5, height * 0.85
    );
    orangePath.quadraticBezierTo(
      width * 0.3, height * 0.95, 
      width * 0.1, height * 0.9
    );
    orangePath.quadraticBezierTo(
      width * 0.05, height * 0.88, 
      0, height * 0.9
    );
    
    // Close the path
    orangePath.lineTo(0, height);
    orangePath.close();
    
    canvas.drawPath(orangePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
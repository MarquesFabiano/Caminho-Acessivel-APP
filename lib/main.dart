import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Importando o firebase_core
import 'providers/auth_provider.dart';
import 'providers/lugar_provider.dart';
import 'screens/login_screen.dart';
import 'screens/busca_lugares_screen.dart';
import 'screens/favoritos_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/aprovar_lugar_screen.dart';
import 'screens/editar_lugar_screen.dart';
import 'screens/cadastro_screen.dart';
import 'screens/mapa_screen.dart';
import 'screens/adicionar_lugar_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Importando Google Maps

void main() async {
  // Garante que o Firebase seja inicializado antes de rodar o app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializando o Firebase

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LugarProvider()),
      ],
      child: MaterialApp(
        title: 'Caminho Acessível',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/cadastro': (context) => const CadastroScreen(),
          '/home': (context) => const BuscaLugaresScreen(),
          '/favoritos': (context) => const FavoritosScreen(),
          '/perfil': (context) => PerfilScreen(),
          '/aprovar': (context) => const AprovarLugarScreen(),
          '/editar': (context) => EditarLugarScreen(
            latLng: ModalRoute.of(context)?.settings.arguments as LatLng ?? LatLng(0.0, 0.0),
          ),
          '/mapa': (context) => const MapaScreen(),
        },
      ),
    );
  }
}

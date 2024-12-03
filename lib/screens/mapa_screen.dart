import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importando o Firebase Firestore
import 'dart:math' as Math; // Importando a biblioteca math
import 'editar_lugar_screen.dart'; // Importe a tela de edição

class MapaScreen extends StatefulWidget {
  const MapaScreen({Key? key}) : super(key: key);

  @override
  _MapaScreenState createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  late GoogleMapController mapController;
  LatLng _currentLocation = const LatLng(0.0, 0.0);
  Set<Marker> _markers = Set();
  List<Map<String, dynamic>> _lugaresProximos = []; // Lista para armazenar os lugares próximos

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      _buscarLugaresProximos(position.latitude, position.longitude);
      _carregarLugaresNoMapa();
    } else {
      print('Permissão de localização negada');
    }
  }

  // Função para buscar lugares próximos no Firebase
  void _buscarLugaresProximos(double latitude, double longitude) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Calcular a distância e buscar locais dentro de um raio de 10km
    double raio = 10.0; // Raio de busca em quilômetros
    double rad = 0.017453292519943295; // Fator para converter de graus para radianos
    double lat1 = latitude;
    double lon1 = longitude;

    // Query no Firestore para buscar lugares
    QuerySnapshot snapshot = await firestore.collection('lugares').get();
    List<Map<String, dynamic>> lugaresProximos = [];

    for (var doc in snapshot.docs) {
      double lat2 = doc['latitude'];
      double lon2 = doc['longitude'];

      // Calcular a distância entre as duas coordenadas (em km)
      double dlat = (lat2 - lat1) * rad;
      double dlon = (lon2 - lon1) * rad;
      double a = (0.5 - (0.5 * (Math.cos(dlat) - Math.cos(dlon))));
      double c = 2 * Math.asin(Math.sqrt(a));
      double distancia = 6371 * c; // Distância em km

      if (distancia <= raio) {
        lugaresProximos.add(doc.data() as Map<String, dynamic>); // Cast para Map<String, dynamic>
      }
    }

    setState(() {
      _lugaresProximos = lugaresProximos.take(3).toList(); // Pegando apenas 3 lugares próximos
    });
  }

  // Função para carregar os lugares do Firebase e colocar os marcadores
  void _carregarLugaresNoMapa() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('lugares').get();

    for (var doc in snapshot.docs) {
      double lat = doc['latitude'];
      double lon = doc['longitude'];
      String nome = doc['nome'];
      String id = doc.id;

      // Adicionando marcador no mapa
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(id),
          position: LatLng(lat, lon),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), // Usando cor azul para o marcador
          onTap: () async {
            // Passando o latLng para a tela de edição
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditarLugarScreen(latLng: LatLng(lat, lon)),
              ),
            );
          },
        ));
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onTap(LatLng latLng) {
    String markerId = latLng.toString();
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(markerId),
        position: latLng,
        onTap: () async {
          // Passando o latLng para a tela de edição
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditarLugarScreen(latLng: latLng),
            ),
          );
        },
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          _currentLocation.latitude != 0.0 && _currentLocation.longitude != 0.0
              ? Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 14.0,
              ),
              markers: _markers,
              onTap: _onTap, // Permite adicionar marcadores ao clicar no mapa
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          )
              : const Center(child: CircularProgressIndicator()),

          // Card com os lugares mais próximos
          _lugaresProximos.isNotEmpty
              ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                title: const Text('Lugares mais próximos'),
                subtitle: Column(
                  children: _lugaresProximos.map((lugar) {
                    return ListTile(
                      title: Text(
                        lugar['nome'] ?? 'Nome desconhecido',
                      ),
                      subtitle: Text(
                        'Distância: ${lugar['distancia']} km',
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          )
              : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Índice para a tela de mapa
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/mapa');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/perfil');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/favoritos');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }
}

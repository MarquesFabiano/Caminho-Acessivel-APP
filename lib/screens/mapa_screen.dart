import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detalhes_screen.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({Key? key}) : super(key: key);

  @override
  _MapaScreenState createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  late GoogleMapController mapController;
  LatLng _currentLocation = const LatLng(0.0, 0.0);
  Set<Marker> _markers = Set();
  double _radius = 5000.0;

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
      if (position != null) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        _carregarLugaresNoMapa();
      }
    }
  }

  Future<void> _carregarLugaresNoMapa() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('lugares').get();

    for (var doc in snapshot.docs) {
      if (doc['aprovado'] == true) {
        double lat = doc['latitude'];
        double lon = doc['longitude'];
        double distance = _calcularDistancia(_currentLocation.latitude, _currentLocation.longitude, lat, lon);

        if (distance <= _radius) {
          String id = doc.id;

          setState(() {
            _markers.add(Marker(
              markerId: MarkerId(id),
              position: LatLng(lat, lon),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              onTap: () async {
                String telefone = doc['telefone'] ?? 'Não disponível';
                String website = doc['website'] ?? 'Não disponível';

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalhesLugarScreen(
                      nome: doc['nome'],
                      endereco: doc['endereco'],
                      avaliacao: doc['avaliacao'].toDouble(),
                      acessibilidade: List<String>.from(doc['acessibilidade']),
                      telefone: telefone,
                      website: website,
                    ),
                  ),
                );
              },
            ));
          });
        }
      }
    }
  }

  double _calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
    const double pi = 3.1415926535897932;
    const double rad = pi / 180.0;
    double dLat = (lat2 - lat1) * rad;
    double dLon = (lon2 - lon1) * rad;
    double a = (0.5 - (cos(dLat) / 2.0)) + cos(lat1 * rad) * cos(lat2 * rad) * (1 - cos(dLon)) / 2.0;
    return 12742.0 * asin(sqrt(a)) * 1000;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          )
              : const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

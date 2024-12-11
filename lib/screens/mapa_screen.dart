import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as Math;
import 'editar_lugar_screen.dart';
import 'lugares_proximos_screen.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({Key? key}) : super(key: key);

  @override
  _MapaScreenState createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  late GoogleMapController mapController;
  LatLng _currentLocation = const LatLng(0.0, 0.0);
  Set<Marker> _markers = Set();
  List<Map<String, dynamic>> _lugaresProximos = [];

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
        _buscarLugaresProximos(position.latitude, position.longitude);
        _carregarLugaresNoMapa();
      }
    } else {
      print('Permissão de localização negada');
    }
  }

  void _buscarLugaresProximos(double latitude, double longitude) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    double raio = 10.0;
    double rad = 0.017453292519943295;
    double lat1 = latitude;
    double lon1 = longitude;

    QuerySnapshot snapshot = await firestore.collection('lugares').get();
    List<Map<String, dynamic>> lugaresProximos = [];

    for (var doc in snapshot.docs) {
      if (doc['aprovado'] == true) {
        double lat2 = doc['latitude'];
        double lon2 = doc['longitude'];

        double dlat = (lat2 - lat1) * rad;
        double dlon = (lon2 - lon1) * rad;
        double a = (0.5 - (0.5 * (Math.cos(dlat) - Math.cos(dlon))));
        double c = 2 * Math.asin(Math.sqrt(a));
        double distancia = 6371 * c;

        if (distancia <= raio) {
          lugaresProximos.add({
            'nome': doc['nome'],
            'endereco': doc['endereco'],
            'latitude': lat2,
            'longitude': lon2,
            'distancia': distancia,
            'id': doc.id
          });
        }
      }
    }

    setState(() {
      _lugaresProximos = lugaresProximos.take(3).toList();
    });
  }

  void _carregarLugaresNoMapa() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('lugares').get();

    for (var doc in snapshot.docs) {
      if (doc['aprovado'] == true) {
        double lat = doc['latitude'];
        double lon = doc['longitude'];
        String nome = doc['nome'];
        String id = doc.id;

        setState(() {
          _markers.add(Marker(
            markerId: MarkerId(id),
            position: LatLng(lat, lon),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            onTap: () async {
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
        actions: [
          IconButton(
            icon: Icon(Icons.location_searching),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LugaresProximosScreen()),
              );
            },
          ),
        ],
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
              onTap: _onTap,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          )
              : const Center(child: CircularProgressIndicator()),
          _lugaresProximos.isNotEmpty
              ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                title: const Text('Lugares mais próximos'),
                subtitle: Column(
                  children: _lugaresProximos.map((lugar) {
                    return ListTile(
                      title: Text(lugar['nome'] ?? 'Nome desconhecido'),
                      subtitle: Text('Distância: ${lugar['distancia']} km'),
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
        backgroundColor: Colors.white,
      ),
    );
  }
}

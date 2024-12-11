import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LugaresProximosScreen extends StatefulWidget {
  @override
  _LugaresProximosScreenState createState() => _LugaresProximosScreenState();
}

class _LugaresProximosScreenState extends State<LugaresProximosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _acessibilidadeFilter = '';
  List<Map<String, dynamic>> _lugares = [];
  Position? _currentPosition;
  double _radius = 5000; // Raio de busca (5 km)

  @override
  void initState() {
    super.initState();
    _fetchLugares();
    _getCurrentLocation();
  }

  // Função para buscar os lugares no Firestore
  void _fetchLugares() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('lugares').limit(10).get();
    List<Map<String, dynamic>> lugares = snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {
        'nome': data['nome'],
        'endereco': data['endereco'],
        'acessibilidade': data['tiposDeAcessibilidade']?.join(', ') ?? '',
        'latitude': data['latitude'],
        'longitude': data['longitude'],
        'id': doc.id,
      };
    }).toList();
    setState(() {
      _lugares = lugares;
    });
  }

  // Função para obter a localização atual do usuário
  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

  // Função para calcular a distância entre a localização atual e o lugar
  double _calculateDistance(Position position, Map<String, dynamic> lugar) {
    return Geolocator.distanceBetween(position.latitude, position.longitude, lugar['latitude'], lugar['longitude']);
  }

  // Função para filtrar os lugares de acordo com os filtros
  List<Map<String, dynamic>> _filterLugares() {
    if (_currentPosition == null) return [];
    List<Map<String, dynamic>> lugaresFiltrados = _lugares.where((lugar) {
      bool matchesQuery = lugar['nome'].toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesAcessibilidade = _acessibilidadeFilter.isEmpty || lugar['acessibilidade'].toLowerCase().contains(_acessibilidadeFilter.toLowerCase());
      double distance = _calculateDistance(_currentPosition!, lugar);
      bool isWithinRadius = distance <= _radius; // Verifica se o lugar está dentro do raio de busca
      return matchesQuery && matchesAcessibilidade && isWithinRadius;
    }).toList();
    return lugaresFiltrados;
  }

  // Função para exibir a rota no mapa
  void _showRouteOnMap(Map<String, dynamic> lugar) async {
    if (_currentPosition == null) return;
    double originLat = _currentPosition!.latitude;
    double originLng = _currentPosition!.longitude;
    double destinationLat = lugar['latitude'];
    double destinationLng = lugar['longitude'];
    LatLng origin = LatLng(originLat, originLng);
    LatLng destination = LatLng(destinationLat, destinationLng);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          origin: origin,
          destination: destination,
          lugar: lugar,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredLugares = _filterLugares();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lugares Próximos'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Buscar por nome',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _acessibilidadeFilter.isEmpty ? null : _acessibilidadeFilter,
              hint: Text('Filtrar por acessibilidade'),
              isExpanded: true,
              items: [
                'Cadeira de rodas',
                'Entrada acessível',
                'Banheiro adaptado',
                'Outro',
              ].map((acessibilidade) {
                return DropdownMenuItem<String>(
                  value: acessibilidade,
                  child: Text(acessibilidade),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _acessibilidadeFilter = value ?? '';
                });
              },
            ),
            const SizedBox(height: 10),
            filteredLugares.isNotEmpty
                ? Expanded(
              child: ListView.builder(
                itemCount: filteredLugares.length,
                itemBuilder: (context, index) {
                  var lugar = filteredLugares[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(lugar['nome']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Endereço: ${lugar['endereco']}'),
                          Text('Acessibilidade: ${lugar['acessibilidade']}'),
                          Text('Distância: ${(_calculateDistance(_currentPosition!, lugar) / 1000).toStringAsFixed(2)} km'),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () => _showRouteOnMap(lugar),
                    ),
                  );
                },
              ),
            )
                : const Center(child: Text('Nenhum lugar encontrado')),
          ],
        ),
      ),
    );
  }
}

class MapScreen extends StatelessWidget {
  final LatLng origin;
  final LatLng destination;
  final Map<String, dynamic> lugar;

  MapScreen({required this.origin, required this.destination, required this.lugar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lugar['nome'])),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: origin,
          zoom: 12,
        ),
        markers: {
          Marker(
            markerId: MarkerId('origin'),
            position: origin,
            infoWindow: InfoWindow(title: 'Sua Localização'),
          ),
          Marker(
            markerId: MarkerId('destination'),
            position: destination,
            infoWindow: InfoWindow(title: lugar['nome']),
          ),
        },
        polylines: {
          Polyline(
            polylineId: PolylineId('route'),
            points: [origin, destination],
            color: Colors.blue,
            width: 5,
          ),
        },
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../providers/auth_provider.dart';
import 'detalhes_screen.dart';

class BuscaLugaresScreen extends StatefulWidget {
  const BuscaLugaresScreen({super.key});

  @override
  _BuscaLugaresScreenState createState() => _BuscaLugaresScreenState();
}

class _BuscaLugaresScreenState extends State<BuscaLugaresScreen> {
  bool _isLoading = true;
  List<dynamic> _lugares = [];
  String _errorMessage = '';
  TextEditingController _searchController = TextEditingController();

  Future<void> _buscarLugares(double latitude, double longitude, {String? query}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final String url = query == null
        ? 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        : 'https://maps.googleapis.com/maps/api/place/textsearch/json';

    try {
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: query == null
            ? {
          'location': '$latitude,$longitude',
          'radius': '10000',
          'key': 'AIzaSyDEYRZGL1eA_DhKhE6zz_1-jAOCKNtS2oQ'
        }
            : {
          'query': query ?? '',
          'key': 'AIzaSyDEYRZGL1eA_DhKhE6zz_1-jAOCKNtS2oQ'
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _lugares = json.decode(response.body)['results']?.take(10)?.toList() ?? [];
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Erro ao buscar lugares: ${response.statusCode} - ${response.body}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lugares = [];
          _errorMessage = 'Erro ao buscar lugares: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _buscarLugares(position.latitude, position.longitude);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao obter localização: $e';
        });
      }
    }
  }

  void _navegarParaDetalhes(Map<String, dynamic> lugar) {
    Navigator.pushNamed(context, '/detalhes_screen', arguments: lugar);
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lugares Acessíveis Próximos'),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.location_searching),
            onPressed: _getUserLocation,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar por lugar',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              onChanged: (text) {
                if (text.isEmpty) {
                  _getUserLocation();
                } else {
                  _buscarLugares(0.0, 0.0, query: text);
                }
              },
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Buscando um caminho acessível...',
                      style: TextStyle(fontSize: 18, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            if (!_isLoading && _lugares.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _lugares.length,
                  itemBuilder: (context, index) {
                    final lugar = _lugares[index];
                    final acessivel = lugar['wheelchair_accessible_entrance'] ?? false;

                    return Card(
                      elevation: 8,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: lugar['icon'] != null
                                ? Image.network(
                              lugar['icon'],
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                                : Icon(
                              Icons.place,
                              color: Colors.blue[800],
                              size: 40,
                            ),
                            title: Text(
                              lugar['name'] ?? 'Nome não disponível',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              lugar['formatted_address'] ?? 'Endereço não disponível',
                              style: TextStyle(fontSize: 14),
                            ),
                            trailing: Icon(
                              acessivel ? Icons.accessible : Icons.not_accessible,
                              color: acessivel ? Colors.green : Colors.red,
                            ),
                            onTap: () => _navegarParaDetalhes(lugar),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: ElevatedButton(
                              onPressed: () => _navegarParaDetalhes(lugar),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[800],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Ver Detalhes'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            if (!_isLoading && _lugares.isEmpty && _errorMessage.isEmpty)
              const Center(child: Text('Nenhum lugar encontrado.')),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
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
      ),
    );
  }
}

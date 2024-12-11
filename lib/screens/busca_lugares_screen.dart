import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../providers/auth_provider.dart';
import 'detalhes_screen.dart'; // Importe a tela de detalhes

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

  // Método para buscar lugares, agora com os dois tipos de busca
  Future<void> _buscarLugares(double latitude, double longitude, {String? query}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Reseta a mensagem de erro
    });

    final String url = query == null
        ? 'https://maps.googleapis.com/maps/api/place/nearbysearch/json' // Para busca por localização
        : 'https://maps.googleapis.com/maps/api/place/textsearch/json'; // Para busca por texto

    try {
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: query == null
            ? {
          'location': '$latitude,$longitude', // Localização (latitude, longitude)
          'radius': '10000', // Raio de 10 km
          'key': 'AIzaSyDEYRZGL1eA_DhKhE6zz_1-jAOCKNtS2oQ'
        }
            : {
          'query': query ?? '', // Adiciona a query de busca
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

  // Método para obter a localização do usuário
  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _buscarLugares(position.latitude, position.longitude); // Busca locais ao obter a posição
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao obter localização: $e';
        });
      }
    }
  }

  // Navega para a tela de detalhes
  void _navegarParaDetalhes(Map<String, dynamic> lugar) {
    Navigator.pushNamed(context, '/detalhes_screen', arguments: lugar);
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation(); // Pega a localização ao carregar a tela
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
            onPressed: _getUserLocation, // Recarrega os lugares com a localização atual
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de busca por texto
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
                  _getUserLocation(); // Recarrega os lugares próximos se a busca for apagada
                } else {
                  _buscarLugares(0.0, 0.0, query: text); // Busca por texto
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
                      child: ListTile(
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

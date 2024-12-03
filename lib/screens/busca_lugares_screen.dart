import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class BuscaLugaresScreen extends StatefulWidget {
  const BuscaLugaresScreen({super.key});

  @override
  _BuscaLugaresScreenState createState() => _BuscaLugaresScreenState();
}

class _BuscaLugaresScreenState extends State<BuscaLugaresScreen> {
  final TextEditingController _controller = TextEditingController();
  String _termoBusca = '';
  bool _isLoading = false;
  List<dynamic> _lugares = [];
  String _errorMessage = '';
  List<String> favoritos = [];

  Future<void> _buscarLugares() async {
    if (_termoBusca.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um termo de busca.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(
          'https://us-central1-projetomapa-438017.cloudfunctions.net/buscarLugaresAcessiveis?lugar=${Uri.encodeComponent(_termoBusca)}'));

      if (response.statusCode == 200) {
        setState(() {
          _lugares = json.decode(response.body);
        });
      } else {
        setState(() {
          _errorMessage = 'Erro ao buscar lugares: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _lugares = [];
        _errorMessage = 'Erro ao buscar lugares: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _favoritarLugar(
      String placeId, Map<String, dynamic> lugarInfo) async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Você precisa estar logado para favoritar lugares.')),
      );
      return;
    }

    final userId = user.uid;

    try {
      final favoritosRef =
          FirebaseDatabase.instance.ref('users/$userId/favoritos');
      final favoritosSnapshot = await favoritosRef.get();

      List<dynamic> favoritos = favoritosSnapshot.exists
          ? List<dynamic>.from(favoritosSnapshot.value as List)
          : [];

      if (!favoritos.contains(placeId)) {
        favoritos.add(placeId);
        await favoritosRef.set(favoritos);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lugar favoritado com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Este lugar já está nos seus favoritos.')),
        );
      }

      setState(() {
        this.favoritos = List<String>.from(favoritos);
      });

      final lugarRef = FirebaseDatabase.instance.ref('lugares/$placeId');
      final lugarSnapshot = await lugarRef.get();
      if (!lugarSnapshot.exists) {
        await lugarRef.set({
          'place_id': placeId,
          'nome': lugarInfo['nome'],
          'endereco': lugarInfo['endereco'],
          'acessibilidade': lugarInfo['acessibilidade'] ?? 'Indefinido',
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao favoritar o lugar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Lugares Acessíveis'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: (value) {
                setState(() {
                  _termoBusca = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Buscar por nome de lugar',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _buscarLugares,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (!_isLoading && _lugares.isEmpty && _errorMessage.isEmpty)
              const Text('Nenhum lugar encontrado.'),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _lugares.length,
                itemBuilder: (context, index) {
                  final lugar = _lugares[index];
                  final placeId = lugar['place_id'] ?? '';
                  bool isFavorito = favoritos.contains(placeId);
                  final lugarInfo = {
                    'nome': lugar['nome'],
                    'endereco': lugar['endereco'],
                    'acessibilidade': lugar['acessibilidade'],
                  };

                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        lugar['nome'] ?? 'Nome não disponível',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                          Text(lugar['endereco'] ?? 'Endereço não disponível'),
                      trailing: IconButton(
                        icon: Icon(
                          isFavorito ? Icons.favorite : Icons.favorite_border,
                          color: isFavorito ? Colors.red : Colors.black,
                        ),
                        onPressed: () {
                          if (placeId.isNotEmpty) {
                            _favoritarLugar(placeId, lugarInfo);
                            setState(() {});
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Erro: Place ID do lugar não encontrado.')),
                            );
                          }
                        },
                      ),
                      onTap: () {
                        // Lógica de navegação ou edição
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/editar');
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

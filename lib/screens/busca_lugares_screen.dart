import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lugar.dart';
import '../providers/lugar_provider.dart';

class BuscaLugaresScreen extends StatelessWidget {
  const BuscaLugaresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lugarProvider = Provider.of<LugarProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Lugares'),
      ),
      body: FutureBuilder(
        future: lugarProvider.buscarLugares('', ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar lugares'));
          }

          final lugares = snapshot.data ?? [];

          return ListView.builder(
            itemCount: lugares.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(lugares[index].name),
                subtitle: Text(lugares[index].formattedAddress),
              );
            },
          );
        },
      ),
    );
  }
}

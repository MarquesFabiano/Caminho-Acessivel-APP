import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lugar.dart';
import '../providers/lugar_provider.dart';

class EditarLugarScreen extends StatefulWidget {
  final Lugar? lugar; // Torna o parâmetro lugar opcional

  const EditarLugarScreen({super.key, this.lugar}); // Permite null como valor padrão

  @override
  _EditarLugarScreenState createState() => _EditarLugarScreenState();
}

class _EditarLugarScreenState extends State<EditarLugarScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.lugar != null) {
      _nameController.text = widget.lugar!.name;
      _addressController.text = widget.lugar!.formattedAddress;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lugarProvider = Provider.of<LugarProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Lugar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Endereço'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (widget.lugar != null) {
                  final updatedLugar = Lugar(
                    id: widget.lugar!.id,
                    name: _nameController.text,
                    formattedAddress: _addressController.text,
                    tiposDeAcessibilidade: widget.lugar!.tiposDeAcessibilidade,
                    aprovado: widget.lugar!.aprovado,
                    avaliacao: widget.lugar!.avaliacao,
                  );
                  await lugarProvider.editarLugar(widget.lugar!.id, updatedLugar);
                } else {
                  // Caso você queira tratar criação de um novo lugar
                }
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

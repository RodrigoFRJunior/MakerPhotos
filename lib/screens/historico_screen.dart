import 'dart:io';
import 'package:flutter/material.dart';
import '../models/foto.dart';
import '../services/armazenamento_service.dart';
import '../services/foto_service.dart';
import '../widgets/foto_card.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  List<Foto> _fotos = [];
  String _filtro = 'Todas';
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final fotos = await ArmazenamentoService.carregarFotos();
      if (mounted) setState(() { _fotos = fotos; _erro = null; });
    } catch (e) {
      if (mounted) setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _excluir(Foto foto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir foto?'),
        content: Text('Deseja excluir ${foto.nomeArquivo}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await FotoService().excluir(foto);
      await _carregar();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = _filtro == 'Todas'
        ? _fotos
        : _fotos.where((f) => f.modalidade == _filtro).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de fotos')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<String>(
            value: _filtro,
            decoration: const InputDecoration(labelText: 'Filtrar modalidade'),
            items: const [
              DropdownMenuItem(value: 'Todas', child: Text('Todas as modalidades')),
              DropdownMenuItem(value: 'Juniors', child: Text('Juniors')),
              DropdownMenuItem(value: 'OBR', child: Text('OBR')),
              DropdownMenuItem(value: 'Inovacao', child: Text('Inovação')),
            ],
            onChanged: (value) => setState(() => _filtro = value ?? 'Todas'),
          ),
        ),
        Expanded(
          child: _erro != null
            ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_erro!)))
            : filtradas.isEmpty
              ? const Center(child: Text('Nenhuma foto encontrada.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtradas.length,
                  itemBuilder: (_, i) => FotoCard(
                    foto: filtradas[i],
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(title: Text(filtradas[i].nomeArquivo)),
                        body: Center(child: InteractiveViewer(child: Image.file(File(filtradas[i].caminho)))),
                      ),
                    )),
                    onExcluir: () => _excluir(filtradas[i]),
                  ),
                ),
        ),
      ]),
    );
  }
}

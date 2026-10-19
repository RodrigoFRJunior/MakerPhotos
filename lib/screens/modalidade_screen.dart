import 'dart:io';
import 'package:flutter/material.dart';
import '../models/foto.dart';
import '../services/armazenamento_service.dart';
import '../services/foto_service.dart';
import '../widgets/foto_card.dart';

class ModalidadeScreen extends StatefulWidget {
  final String modalidade;
  const ModalidadeScreen({super.key, required this.modalidade});

  @override
  State<ModalidadeScreen> createState() => _ModalidadeScreenState();
}

class _ModalidadeScreenState extends State<ModalidadeScreen> {
  final FotoService _service = FotoService();
  List<Foto> _fotos = [];
  bool _ocupado = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final todas = await ArmazenamentoService.carregarFotos();
      if (mounted) setState(() {
        _fotos = todas.where((f) => f.modalidade == widget.modalidade).toList();
        _erro = null;
      });
    } catch (e) {
      if (mounted) setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  
Future<void> _adicionar(bool camera) async {
  setState(() => _ocupado = true);

  try {
    final List<Foto> adicionadas;

    if (camera) {
      final foto = await _service.capturar(widget.modalidade);
      adicionadas = foto == null ? <Foto>[] : <Foto>[foto];
    } else {
      adicionadas = await _service.importar(widget.modalidade);
    }

    if (adicionadas.isNotEmpty) {
      await _carregar();

      if (mounted) {
        final mensagem = camera
            ? 'Foto salva como ${adicionadas.first.nomeArquivo}'
            : adicionadas.length == 1
                ? '1 foto importada com sucesso.'
                : '${adicionadas.length} fotos importadas com sucesso.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagem)),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível adicionar a foto: '
            '${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
      await _carregar();
    }
  } finally {
    if (mounted) setState(() => _ocupado = false);
  }
}

  Future<void> _excluir(Foto foto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir foto?'),
        content: Text('A foto "${foto.nomeArquivo}" será removida do histórico e do armazenamento do aplicativo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await _service.excluir(foto);
      await _carregar();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
    }
  }

  void _visualizar(Foto foto) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _VisualizarFoto(foto: foto)));
  }

  @override
  Widget build(BuildContext context) {
    final titulo = widget.modalidade == 'Inovacao' ? 'Inovação' : widget.modalidade;
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: _ocupado ? null : () => _adicionar(true),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Tirar foto'),
            )),
            const SizedBox(width: 10),
            Expanded(child: FilledButton.icon(
              onPressed: _ocupado ? null : () => _adicionar(false),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Galeria'),
            )),
          ]),
        ),
        if (_ocupado) const LinearProgressIndicator(),
        Expanded(child: _erro != null
          ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_erro!)))
          : _fotos.isEmpty
            ? const Center(child: Padding(
                padding: EdgeInsets.all(28),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.photo_library_outlined, size: 54, color: Colors.black26),
                  SizedBox(height: 12),
                  Text('Nenhuma foto nesta modalidade', style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 6),
                  Text('Use a câmera ou escolha uma imagem da galeria.', textAlign: TextAlign.center),
                ]),
              ))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                itemCount: _fotos.length,
                itemBuilder: (_, index) => FotoCard(
                  foto: _fotos[index],
                  onTap: () => _visualizar(_fotos[index]),
                  onExcluir: () => _excluir(_fotos[index]),
                ),
              )),
      ]),
    );
  }
}

class _VisualizarFoto extends StatelessWidget {
  final Foto foto;
  const _VisualizarFoto({required this.foto});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(foto.nomeArquivo)),
    body: Center(
      child: InteractiveViewer(
        child: Image.file(File(foto.caminho), errorBuilder: (_, __, ___) =>
          const Padding(padding: EdgeInsets.all(24), child: Text('Não foi possível abrir esta imagem.'))),
      ),
    ),
  );
}

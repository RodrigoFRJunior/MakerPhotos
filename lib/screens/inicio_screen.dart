import 'package:flutter/material.dart';
import '../models/foto.dart';
import '../services/armazenamento_service.dart';
import '../services/exportacao_service.dart';
import 'historico_screen.dart';
import 'horarios_screen.dart';
import 'modalidade_screen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  int _quantidadeFotos = 0;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _atualizar();
  }

  Future<void> _atualizar() async {
    try {
      final fotos = await ArmazenamentoService.carregarFotos();
      if (mounted) setState(() { _quantidadeFotos = fotos.length; _carregando = false; });
    } catch (_) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _exportar() async {
    try {
      final fotos = await ArmazenamentoService.carregarFotos();
      await ExportacaoService().compartilharZip(fotos);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _abrirModalidade(String modalidade) async {
    await Navigator.push(context, MaterialPageRoute(
      builder: (_) => ModalidadeScreen(modalidade: modalidade),
    ));
    _atualizar();
  }

  @override
  Widget build(BuildContext context) {
    final modalidades = [
      ('Juniors', Icons.school_outlined, 'Atividades e registros Juniors'),
      ('OBR', Icons.emoji_events_outlined, 'Olimpíada Brasileira de Robótica'),
      ('Inovacao', Icons.lightbulb_outline, 'Projetos e atividades de inovação'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fotos Maker', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Histórico',
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoricoScreen()));
              _atualizar();
            },
            icon: const Icon(Icons.photo_library_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _atualizar,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFFE2F3E8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.camera_alt_rounded, size: 34, color: Color(0xFF217346)),
                  const SizedBox(height: 14),
                  const Text('Suas atividades, organizadas.',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: Color(0xFF183B27))),
                  const SizedBox(height: 8),
                  const Text('Registre fotos por modalidade e mantenha tudo guardado no aparelho.',
                    style: TextStyle(height: 1.4, color: Color(0xFF365845))),
                  const SizedBox(height: 18),
                  Row(children: [
                    const Icon(Icons.collections_outlined, color: Color(0xFF217346)),
                    const SizedBox(width: 8),
                    Text(_carregando ? 'Contando fotos...' : '$_quantidadeFotos foto(s) armazenada(s)',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF183B27))),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Modalidades', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            for (final item in modalidades)
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE2F3E8),
                    child: Icon(item.$2, color: const Color(0xFF217346)),
                  ),
                  title: Text(item.$1 == 'Inovacao' ? 'Inovação' : item.$1,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(item.$3),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _abrirModalidade(item.$1),
                ),
              ),
            const SizedBox(height: 20),
            const Text('Ferramentas', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _Ferramenta(
                icone: Icons.history, titulo: 'Histórico',
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoricoScreen()));
                  _atualizar();
                },
              )),
              const SizedBox(width: 10),
              Expanded(child: _Ferramenta(
                icone: Icons.schedule, titulo: 'Horários',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HorariosScreen())),
              )),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _exportar,
                icon: const Icon(Icons.folder_zip_outlined),
                label: const Text('Exportar fotos para ZIP'),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Os registros ficam no armazenamento privado do aplicativo. Faça exportações periódicas para manter uma cópia no computador.',
              style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

class _Ferramenta extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final VoidCallback onTap;
  const _Ferramenta({required this.icone, required this.titulo, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(children: [
          Icon(icone, size: 26, color: const Color(0xFF217346)),
          const SizedBox(height: 8),
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import '../models/horario.dart';
import '../services/horario_service.dart';

class HorariosScreen extends StatefulWidget {
  const HorariosScreen({super.key});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  final HorarioService _service = HorarioService();
  List<Horario> _horarios = [];
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final lista = await _service.listar();
      if (mounted) setState(() { _horarios = lista; _erro = null; });
    } catch (e) {
      if (mounted) setState(() => _erro = e.toString());
    }
  }

  Future<void> _formulario({Horario? existente}) async {
    final formKey = GlobalKey<FormState>();
    int dia = existente?.diaSemana ?? DateTime.monday;
    String modalidade = existente?.modalidade ?? 'Juniors';
    final turma = TextEditingController(text: existente?.turma ?? '');
    TimeOfDay inicio = _lerHora(existente?.inicio ?? '08:00');
    TimeOfDay termino = _lerHora(existente?.termino ?? '09:00');

    String formatar(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    final resultado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existente == null ? 'Novo horário' : 'Editar horário'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  DropdownButtonFormField<int>(
                    value: dia,
                    decoration: const InputDecoration(labelText: 'Dia da semana'),
                    items: List.generate(7, (i) => DropdownMenuItem(
                      value: i + 1, child: Text(Horario.dias[i]))),
                    onChanged: (v) { if (v != null) setDialogState(() => dia = v); },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: modalidade,
                    decoration: const InputDecoration(labelText: 'Modalidade'),
                    items: const [
                      DropdownMenuItem(value: 'Juniors', child: Text('Juniors')),
                      DropdownMenuItem(value: 'OBR', child: Text('OBR')),
                      DropdownMenuItem(value: 'Inovacao', child: Text('Inovação')),
                    ],
                    onChanged: (v) { if (v != null) setDialogState(() => modalidade = v); },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: turma,
                    decoration: const InputDecoration(labelText: 'Turma ou classe'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Informe a turma ou classe.' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: OutlinedButton.icon(
                      icon: const Icon(Icons.login),
                      label: Text('Início ${formatar(inicio)}'),
                      onPressed: () async {
                        final t = await showTimePicker(context: context, initialTime: inicio);
                        if (t != null) setDialogState(() => inicio = t);
                      },
                    )),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: Text('Término ${formatar(termino)}'),
                      onPressed: () async {
                        final t = await showTimePicker(context: context, initialTime: termino);
                        if (t != null) setDialogState(() => termino = t);
                      },
                    )),
                  ]),
                ]),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(dialogContext, true);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    if (resultado == true) {
      final novo = Horario(
        id: existente?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        diaSemana: dia,
        inicio: formatar(inicio),
        termino: formatar(termino),
        modalidade: modalidade,
        turma: turma.text.trim(),
      );
      try {
        await _service.salvar(novo);
        await _carregar();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível salvar: $e')));
      }
    }
    turma.dispose();
  }

  TimeOfDay _lerHora(String texto) {
    final partes = texto.split(':');
    return TimeOfDay(hour: int.parse(partes[0]), minute: int.parse(partes[1]));
  }

  Future<void> _excluir(Horario horario) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir horário?'),
        content: Text('${horario.nomeDia}, ${horario.inicio}–${horario.termino} • ${horario.turma}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (ok == true) {
      await _service.excluir(horario.id);
      await _carregar();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Horários e aulas')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _formulario(),
      icon: const Icon(Icons.add),
      label: const Text('Adicionar horário'),
    ),
    body: _erro != null
      ? Center(child: Text(_erro!))
      : _horarios.isEmpty
        ? const Center(child: Padding(
            padding: EdgeInsets.all(28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.calendar_month_outlined, size: 54, color: Colors.black26),
              SizedBox(height: 12),
              Text('Sua grade está vazia', style: TextStyle(fontWeight: FontWeight.w700)),
              SizedBox(height: 6),
              Text('Toque em “Adicionar horário” para cadastrar seus dias e turmas.', textAlign: TextAlign.center),
            ]),
          ))
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
            itemCount: _horarios.length,
            itemBuilder: (_, i) {
              final h = _horarios[i];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.schedule)),
                  title: Text('${h.nomeDia} • ${h.inicio}–${h.termino}'),
                  subtitle: Text('${h.modalidade == 'Inovacao' ? 'Inovação' : h.modalidade} • ${h.turma}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'editar') _formulario(existente: h);
                      if (v == 'excluir') _excluir(h);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'editar', child: Text('Editar')),
                      PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                    ],
                  ),
                ),
              );
            },
          ),
  );
}

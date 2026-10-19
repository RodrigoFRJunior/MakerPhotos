import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/foto.dart';
import '../models/horario.dart';

class ArmazenamentoService {
  static Future<Directory> get diretorioBase async {
    final appDir = await getApplicationDocumentsDirectory();
    final fotosDir = Directory('${appDir.path}/fotos');
    if (!await fotosDir.exists()) {
      await fotosDir.create(recursive: true);
    }
    return appDir;
  }

  static Future<File> _arquivo(String nome) async {
    final base = await diretorioBase;
    return File('${base.path}/$nome');
  }

  static Future<List<Foto>> carregarFotos() async {
    final file = await _arquivo('fotos.json');
    if (!await file.exists()) return [];
    try {
      final decoded = jsonDecode(await file.readAsString()) as List<dynamic>;
      return decoded
          .map((item) => Foto.fromJson(Map<String, dynamic>.from(item as Map)))
          .where((foto) => File(foto.caminho).existsSync())
          .toList()
        ..sort((a, b) => b.dataRegistro.compareTo(a.dataRegistro));
    } catch (_) {
      throw Exception('Não foi possível ler o histórico de fotos salvo.');
    }
  }

  static Future<void> salvarFotos(List<Foto> fotos) async {
    final file = await _arquivo('fotos.json');
    await file.writeAsString(
      jsonEncode(fotos.map((foto) => foto.toJson()).toList()),
      flush: true,
    );
  }

  static Future<List<Horario>> carregarHorarios() async {
    final file = await _arquivo('horarios.json');
    if (!await file.exists()) return [];
    try {
      final decoded = jsonDecode(await file.readAsString()) as List<dynamic>;
      return decoded
          .map((item) => Horario.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      throw Exception('Não foi possível ler os horários salvos.');
    }
  }

  static Future<void> salvarHorarios(List<Horario> horarios) async {
    final file = await _arquivo('horarios.json');
    await file.writeAsString(
      jsonEncode(horarios.map((horario) => horario.toJson()).toList()),
      flush: true,
    );
  }

  // O contador é persistido separadamente: excluir uma foto não reutiliza seu número.
  static Future<int> proximoNumero(String modalidade, String data) async {
    final file = await _arquivo('contadores.json');
    Map<String, dynamic> contadores = {};
    if (await file.exists()) {
      try {
        contadores = Map<String, dynamic>.from(jsonDecode(await file.readAsString()) as Map);
      } catch (_) {
        contadores = {};
      }
    }
    final chave = '${modalidade}_$data';
    final proximo = ((contadores[chave] as num?)?.toInt() ?? 0) + 1;
    contadores[chave] = proximo;
    await file.writeAsString(jsonEncode(contadores), flush: true);
    return proximo;
  }
}

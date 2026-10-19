import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/foto.dart';
import 'armazenamento_service.dart';

class FotoService {
  static const modalidades = ['Juniors', 'OBR', 'Inovacao'];
  final ImagePicker _picker = ImagePicker();

  Future<Foto?> capturar(String modalidade, {String? turma}) async {
    final imagem = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    if (imagem == null) return null;
    return _guardar(imagem, modalidade, turma);
  }

  Future<Foto?> importar(String modalidade, {String? turma}) async {
    final imagem = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (imagem == null) return null;
    return _guardar(imagem, modalidade, turma);
  }

  Future<Foto> _guardar(XFile imagem, String modalidade, String? turma) async {
    final agora = DateTime.now();
    final data = '${agora.year.toString().padLeft(4, '0')}-'
        '${agora.month.toString().padLeft(2, '0')}-'
        '${agora.day.toString().padLeft(2, '0')}';
    final numero = await ArmazenamentoService.proximoNumero(modalidade, data);
    final nome = '${modalidade}_${data}_${numero.toString().padLeft(3, '0')}.jpg';

    final base = await getApplicationDocumentsDirectory();
    final pasta = Directory('${base.path}/fotos');
    await pasta.create(recursive: true);
    final destino = File('${pasta.path}/$nome');
    if (await destino.exists()) {
      throw Exception('O arquivo $nome já existe. Nenhuma imagem foi sobrescrita.');
    }

    // Mantém os bytes originais fornecidos pelo seletor, evitando recompressão adicional.
    await File(imagem.path).copy(destino.path);
    final foto = Foto(
      id: '${agora.microsecondsSinceEpoch}_$numero',
      modalidade: modalidade,
      nomeArquivo: nome,
      caminho: destino.path,
      dataRegistro: agora,
      turma: turma,
    );
    final fotos = await ArmazenamentoService.carregarFotos();
    fotos.add(foto);
    await ArmazenamentoService.salvarFotos(fotos);
    return foto;
  }

  Future<void> excluir(Foto foto) async {
    final fotos = await ArmazenamentoService.carregarFotos();
    fotos.removeWhere((item) => item.id == foto.id);
    await ArmazenamentoService.salvarFotos(fotos);
    final arquivo = File(foto.caminho);
    if (await arquivo.exists()) await arquivo.delete();
  }
}

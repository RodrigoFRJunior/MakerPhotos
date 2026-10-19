import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/foto.dart';

class ExportacaoService {
  Future<void> compartilharZip(List<Foto> fotos) async {
    if (fotos.isEmpty) {
      throw Exception('Ainda não há fotos para exportar.');
    }

    final arquivoZip = Archive();
    for (final foto in fotos) {
      final imagem = File(foto.caminho);
      if (!await imagem.exists()) continue;
      final caminhoNoZip = foto.modalidade == 'OBR'
          ? 'OBR/${foto.nomeArquivo}'
          : foto.nomeArquivo;
      final bytes = await imagem.readAsBytes();
      arquivoZip.addFile(ArchiveFile(caminhoNoZip, bytes.length, bytes));
    }

    if (arquivoZip.files.isEmpty) {
      throw Exception('Nenhuma imagem disponível foi encontrada para exportação.');
    }

    final bytesZip = ZipEncoder().encode(arquivoZip);
    if (bytesZip == null) throw Exception('Não foi possível criar o arquivo ZIP.');

    final agora = DateTime.now();
    final data = '${agora.year.toString().padLeft(4, '0')}-'
        '${agora.month.toString().padLeft(2, '0')}-'
        '${agora.day.toString().padLeft(2, '0')}';
    final temp = await getTemporaryDirectory();
    final arquivo = File('${temp.path}/FotosMaker_$data.zip');
    await arquivo.writeAsBytes(bytesZip, flush: true);

    await Share.shareXFiles(
      [XFile(arquivo.path, mimeType: 'application/zip')],
      text: 'Exportação de fotos do Fotos Maker',
      subject: 'Fotos Maker $data',
    );
  }
}

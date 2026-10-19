import 'dart:io';
import 'package:flutter/material.dart';
import '../models/foto.dart';

class FotoCard extends StatelessWidget {
  final Foto foto;
  final VoidCallback onTap;
  final VoidCallback onExcluir;

  const FotoCard({
    super.key,
    required this.foto,
    required this.onTap,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final data = foto.dataRegistro;
    final dataTexto = '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/${data.year} '
        '${data.hour.toString().padLeft(2, '0')}:'
        '${data.minute.toString().padLeft(2, '0')}';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(foto.caminho),
            width: 68,
            height: 68,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(
              width: 68,
              height: 68,
              child: Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
        title: Text(foto.nomeArquivo, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text('${foto.modalidade} • $dataTexto'),
        onTap: onTap,
        trailing: IconButton(
          tooltip: 'Excluir foto',
          icon: const Icon(Icons.delete_outline),
          onPressed: onExcluir,
        ),
      ),
    );
  }
}

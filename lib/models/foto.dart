class Foto {
  final String id;
  final String modalidade;
  final String nomeArquivo;
  final String caminho;
  final DateTime dataRegistro;
  final String? turma;

  const Foto({
    required this.id,
    required this.modalidade,
    required this.nomeArquivo,
    required this.caminho,
    required this.dataRegistro,
    this.turma,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'modalidade': modalidade,
        'nomeArquivo': nomeArquivo,
        'caminho': caminho,
        'dataRegistro': dataRegistro.toIso8601String(),
        'turma': turma,
      };

  factory Foto.fromJson(Map<String, dynamic> json) => Foto(
        id: json['id'] as String,
        modalidade: json['modalidade'] as String,
        nomeArquivo: json['nomeArquivo'] as String,
        caminho: json['caminho'] as String,
        dataRegistro: DateTime.parse(json['dataRegistro'] as String),
        turma: json['turma'] as String?,
      );
}

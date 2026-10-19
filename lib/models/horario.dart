class Horario {
  final String id;
  final int diaSemana; // DateTime.monday = 1 ... DateTime.sunday = 7
  final String inicio;
  final String termino;
  final String modalidade;
  final String turma;

  const Horario({
    required this.id,
    required this.diaSemana,
    required this.inicio,
    required this.termino,
    required this.modalidade,
    required this.turma,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'diaSemana': diaSemana,
        'inicio': inicio,
        'termino': termino,
        'modalidade': modalidade,
        'turma': turma,
      };

  factory Horario.fromJson(Map<String, dynamic> json) => Horario(
        id: json['id'] as String,
        diaSemana: json['diaSemana'] as int,
        inicio: json['inicio'] as String,
        termino: json['termino'] as String,
        modalidade: json['modalidade'] as String,
        turma: json['turma'] as String,
      );

  static const dias = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];

  String get nomeDia => dias[diaSemana - 1];
}

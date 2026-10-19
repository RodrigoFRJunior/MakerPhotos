import '../models/horario.dart';
import 'armazenamento_service.dart';

class HorarioService {
  Future<List<Horario>> listar() => ArmazenamentoService.carregarHorarios();

  Future<void> salvar(Horario horario) async {
    final lista = await listar();
    final indice = lista.indexWhere((item) => item.id == horario.id);
    if (indice >= 0) {
      lista[indice] = horario;
    } else {
      lista.add(horario);
    }
    lista.sort((a, b) {
      final dia = a.diaSemana.compareTo(b.diaSemana);
      return dia != 0 ? dia : a.inicio.compareTo(b.inicio);
    });
    await ArmazenamentoService.salvarHorarios(lista);
  }

  Future<void> excluir(String id) async {
    final lista = await listar();
    lista.removeWhere((item) => item.id == id);
    await ArmazenamentoService.salvarHorarios(lista);
  }
}

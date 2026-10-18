import '../data/almacen_local.dart';
import '../model/incidencia.dart';

class GestorIncidencias {
  final AlmacenLocal datos = AlmacenLocal();
  List<Incidencia> incidencias = [];
  int cantidadPendientes = 0;

  Future<void> iniciar() async {
    incidencias = await datos.leer();
    cantidadPendientes =
        incidencias.where((x) => x.estado == 'Pendiente').length;
  }

  List<Incidencia> buscar(String texto, {String? estado, String? prioridad}) {
    final consulta = texto.trim().toLowerCase();

    return incidencias.where((x) {
      final coincideTexto = consulta.isEmpty ||
          x.titulo.toLowerCase().contains(consulta) ||
          x.descripcion.toLowerCase().contains(consulta);
      final coincideEstado = estado == null || x.estado == estado;
      final coincidePrioridad = prioridad == null || x.prioridad == prioridad;

      return coincideTexto && coincideEstado && coincidePrioridad;
    }).toList();
  }

  Incidencia? porId(String id) {
    for (var x in incidencias) {
      if (x.id == id) return x;
    }
    return null;
  }

  int contar(String estado) {
    if (estado == 'Pendiente') return cantidadPendientes;
    return incidencias.where((x) => x.estado == estado).length;
  }

  Future<void> cambiarEstado(String id, String estado) async {
    var huboCambios = false;

    for (var i = 0; i < incidencias.length; i++) {
      if (incidencias[i].id == id) {
        final anterior = incidencias[i].estado;
        if (anterior != estado) {
          incidencias[i].estado = estado;
          
          if (anterior == 'Pendiente') cantidadPendientes--;
          if (estado == 'Pendiente') cantidadPendientes++;

          huboCambios = true;
        }
        break;
      }
    }

    if (huboCambios) {
      await datos.guardar(incidencias);
    }
  }

  cambiarPrioridad(String id, String prioridad) async {
    var huboCambios = false;

    for (var i = 0; i < incidencias.length; i++) {
      if (incidencias[i].id == id) {
        final anterior = incidencias[i].prioridad;
        if (anterior != prioridad) {
          incidencias[i].prioridad = prioridad;
          huboCambios = true;
        }
        break;
      }
    }

    if (huboCambios) {
      await datos.guardar(incidencias);
    }
  }

  Future<void> crear(String titulo, String descripcion, String cliente,
      String categoria) async {
    final nuevo = Incidencia(
      id: 'INC-${DateTime.now().microsecondsSinceEpoch}',
      titulo: titulo,
      descripcion: descripcion,
      cliente: cliente,
      categoria: categoria,
      estado: 'Pendiente',
      prioridad: 'Media',
      fecha: DateTime.now().toIso8601String().split('T').first,
    );
    incidencias.insert(0, nuevo);
    cantidadPendientes++;
    await datos.guardar(incidencias);
  }

  Future<void> reiniciarDemo() async {
    await datos.restaurarDatosDeEjemplo();
    await iniciar();
  }
}

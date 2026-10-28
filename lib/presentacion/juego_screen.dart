import 'package:flutter/material.dart';
import '../logica/direccion.dart';
import '../logica/estado_juego.dart';
import '../logica/motor_juego.dart';

class Ficha extends StatelessWidget {
  final int? valor;
  const Ficha({super.key, required this.valor});

  static const Map<int, List<Color>> _gradientes = {
    2: [Color(0xFFFFFDE7), Color(0xFFFFF9C4)],
    4: [Color(0xFFF8BBD0), Color(0xFFF48FB1)],
    8: [Color(0xFFD7CCC8), Color(0xFFA1887F)],
    16: [Color(0xFFFFE0B2), Color(0xFFFFB74D)],
    32: [Color(0xFFC8E6C9), Color(0xFF81C784)],
    64: [Color(0xFFE1BEE7), Color(0xFFBA68C8)],
    128: [Color(0xFF8D6E63), Color(0xFF4E342E)],
    256: [Color(0xFFFFE082), Color(0xFFFFC107)],
    512: [Color(0xFF6D4C41), Color(0xFF3E2723)],
    1024: [Color(0xFFFFF3E0), Color(0xFFFFCC80)],
    2048: [Color(0xFF006341), Color(0xFFFFFFFF)],
  };

  static const Map<int, String> _nombres = {
    2: 'Vainilla', 4: 'Fresa', 8: 'Chocolate', 16: 'Mango',
    32: 'Limon', 64: 'Uva', 128: 'Mole', 256: 'Tequila',
    512: 'Cafe', 1024: 'Rompope', 2048: 'Independencia',
  };

  @override
  Widget build(BuildContext context) {
    final colores = _gradientes[valor] ?? [Colors.grey.shade200, Colors.grey.shade300];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animacion) => ScaleTransition(scale: animacion, child: child),
      child: Container(
        key: ValueKey(valor),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colores, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(12),
          boxShadow: valor == null
              ? []
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        alignment: Alignment.center,
        child: valor == null
            ? null
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    valor.toString(),
                    style: TextStyle(
                      fontSize: valor! >= 128 ? 18 : 22,
                      fontWeight: FontWeight.bold,
                      color: valor! >= 128 ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    _nombres[valor] ?? '',
                    style: TextStyle(fontSize: 10, color: valor! >= 128 ? Colors.white70 : Colors.black54),
                  ),
                ],
              ),
      ),
    );
  }
}

class JuegoScreen extends StatefulWidget {
  const JuegoScreen({super.key});

  @override
  State<JuegoScreen> createState() => _JuegoScreenState();
}

// AQUÍ ESTÁ EL STATE (_JuegoScreenState) con la animación agregada:
class _JuegoScreenState extends State<JuegoScreen>
    with SingleTickerProviderStateMixin {
  late MotorJuego _motor;

  // Variables para la animación de temblor (shake)
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _motor = MotorJuego();

    // Inicializamos el controlador del temblor
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _mover(Direccion direccion) {
    // Copiamos el grid antes del movimiento para comparar si cambió
    final antes = _motor.grid.celdas.map((f) => List<int?>.from(f)).toList();

    setState(() {
      _motor.mover(direccion);
    });

    // Verificamos si el tablero se quedó igual tras intentar mover
    final tableroIgual = _gridsIguales(antes, _motor.grid.celdas);

    if (tableroIgual || !_motor.grid.hayMovimientosPosibles()) {
      // Si no hubo cambios, activamos el temblor
      _shakeController.forward(from: 0.0);
    }

    if (_motor.estado != EstadoJuego.jugando) {
      _mostrarResultado();
    }
  }

  bool _gridsIguales(List<List<int?>> a, List<List<int?>> b) {
    for (var f = 0; f < a.length; f++) {
      for (var c = 0; c < a[f].length; c++) {
        if (a[f][c] != b[f][c]) return false;
      }
    }
    return true;
  }

  void _mostrarResultado() {
    final gano = _motor.estado == EstadoJuego.ganado;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'resultado',
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: FadeTransition(
            opacity: anim1,
            child: AlertDialog(
              title: Text(gano ? '¡Independencia lograda!' : 'Se acabaron los movimientos'),
              content: Text('Puntaje final: ${_motor.puntaje}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => _motor = MotorJuego());
                  },
                  child: const Text('Jugar de nuevo'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nieves 2048 - Dolores Hidalgo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: _motor.puntaje),
              duration: const Duration(milliseconds: 400),
              builder: (context, valor, _) => Text(
                'Puntaje: $valor',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (detalle) {
                final v = detalle.primaryVelocity ?? 0;
                if (v > 0) _mover(Direccion.derecha);
                if (v < 0) _mover(Direccion.izquierda);
              },
              onVerticalDragEnd: (detalle) {
                final v = detalle.primaryVelocity ?? 0;
                if (v > 0) _mover(Direccion.abajo);
                if (v < 0) _mover(Direccion.arriba);
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                // Aquí aplicamos el AnimatedBuilder para que la cuadrícula tiemble
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: child,
                    );
                  },
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 16,
                    itemBuilder: (context, i) {
                      final valor = _motor.grid.celdas[i ~/ 4][i % 4];
                      return Ficha(valor: valor);
                    },
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Desliza en cualquier dirección para mover las nieves'),
          ),
        ],
      ),
    );
  }
}
# nieves_once_sabores

# Ángel Nahúm Camarillo Solano
* GTID244
* Universidad Tecnológica del Norte de Guanajuato (UTNG)
* Desarrollo de Software Multiplataforma

# Descripción del Proyecto
**Nieves 2048** es una variante temática del clásico juego de 2048, adaptada culturalmente a los sabores tradicionales de Dolores Hidalgo (desde el nivel inicial de *Vainilla* hasta la ficha máxima de *Independencia* con un valor de 2048). 

El proyecto fue construido siguiendo estrictamente la metodología **TDD (Test-Driven Development)** bajo el ciclo **Rojo ➔ Verde ➔ Refactor**, garantizando la robustez de la lógica central, el manejo del motor del juego y la experiencia visual con gradientes de color dinámicos y animaciones fluidas.

# Arquitectura y Estructura del Proyecto
El proyecto está estructurado separando claramente las reglas del negocio de la interfaz gráfica y el motor lógico:
nieves_once_sabores/
├── lib/
│   ├── logica/           <- Motor del juego y reglas puras (Dart)
│   │   ├── motor_2048.dart
│   │   ├── grid.dart
│   │   ├── motor_juego.dart
│   │   ├── direccion.dart
│   │   └── estado_juego.dart
│   ├── presentacion/     <- Interfaz de usuario y widgets animados
│   │   └── juego_screen.dart
│   └── main.dart         <- Punto de entrada de la aplicación
├── test/                 <- Pruebas unitarias e de integración
│   ├── motor_2048_test.dart
│   ├── grid_test.dart
│   └── motor_juego_test.dart
└── pubspec.yaml

# Miaugoritmos: restauración del proyecto original

Base actual: Miaugoritmos_Distribucion_visual.zip.
Referencia anterior: ProyectoJuego-SEI-main(2).zip.

## Nivel 3 conservado
Se verificó la igualdad byte por byte de los 265 archivos actuales bajo
scripts/nivel_3, scenes/Nivel_3, scenes/ExamenNivel3 y assets/nivel_3.
No se cambiaron sus ejercicios, respuestas, examen, recompensas, insignias,
interfaces, NPC, diálogos, escenas ni recursos.

## Restaurados directamente desde el proyecto anterior
Los siguientes 20 archivos son copias exactas de la versión anterior:

- dialogs/nivel_1/exams/exam_e1.json
- scenes/common/ui/MainMenu.tscn
- scripts/common/puzzle/puzzleManager.gd
- scripts/common/ui/mainMenu.gd
- assets/audio/sfx/5-correct-answers.mp3
- assets/audio/sfx/5-correct-answers.mp3.import
- assets/audio/sfx/completed-lesson.mp3
- assets/audio/sfx/completed-lesson.mp3.import
- assets/audio/sfx/correct.mp3
- assets/audio/sfx/correct.mp3.import
- assets/audio/sfx/wrong.mp3
- assets/audio/sfx/wrong.mp3.import
- scripts/common/ui/catTitle.gd
- scripts/common/ui/catTitle.gd.uid
- scripts/common/ui/devPanel.gd
- scripts/common/ui/devPanel.gd.uid
- scripts/common/ui/menuBackground.gd
- scripts/common/ui/menuBackground.gd.uid
- scripts/common/ui/menuButton.gd
- scripts/common/ui/menuButton.gd.uid

Los demás archivos originales de los niveles anteriores ya eran idénticos a la versión actual y se conservaron.

## Conflictos compartidos resueltos fuera del Nivel 3
- scripts/common/systems/DJManager.gd: adaptador que conserva el motor actual para el Nivel 3 y utiliza el motor original para los niveles anteriores y los menús. Recupera los efectos de respuestas correctas, errores, rachas, celebraciones y los bleeps originales, sin sustituir el audio del Nivel 3.
- scripts/common/ui/manualUI.gd: conserva el manual actual del Nivel 3 y muestra el manual original en el resto del proyecto. Mantiene la ruta pública del botón que usa el encabezado del Nivel 3.
- project.godot: únicamente se ajustó la ruta del autoload PuntajesNivel3 al adaptador de protección de progreso; su nombre público no cambió.

Nuevos módulos en scripts/common/compat (con sus archivos .uid):
- AudioOriginal.gd: copia exacta del gestor de audio antiguo.
- AudioNivel3Actual.gd: copia exacta del gestor de audio actual.
- ManualOriginal.gd: copia exacta del manual antiguo.
- ManualNivel3Actual.gd: copia exacta del manual actual.
- ProgresoCompatible.gd: hereda del gestor del Nivel 3 sin editar ese archivo. Conserva el ID guardado, utiliza su carga de progreso existente y evita el reinicio automático al entrar al menú o a la introducción. El reinicio explícito mediante Jugar de nuevo conserva su implementación actual.

## Guardado
No se borraron ni sustituyeron los archivos user:// del usuario. No se incluyeron datos de prueba en el proyecto. Se mantienen el nombre de la aplicación y las rutas de guardado, registro JSON, ranking, perfiles e insignias. Las pruebas usaron una carpeta de usuario temporal independiente.

## Comprobaciones
Motor: Godot 4.7 estable, de acuerdo con project.godot.
- Importación del proyecto sin errores de scripts o escenas.
- Carga y transiciones reales entre menú, Intro, Intro2, Main, Villa1, Villa2, Panaderia y Escuela.
- Apertura del diálogo original del alcalde.
- Carga de E3.1 a E3.10 y de Final.tscn.
- Validación de las soluciones existentes de los diez ejercicios del Nivel 3 sin cambiar sus respuestas ni entregar recompensas de prueba.
- Carga de las nueve escenas del examen actual.
- Activación del manual original fuera del Nivel 3 y del manual actual dentro del Nivel 3.
- Disponibilidad de los sonidos originales y selección del audio actual al entrar al Nivel 3.
- Conservación de un ID, puntos, insignias y registros previamente guardados durante las transiciones y al regresar al menú.
- Comparación de los archivos originales y de los 265 archivos protegidos del Nivel 3.

Las pruebas fueron automáticas; no constituyen una partida manual completa de todos los ejercicios anteriores. En algunos cierres anticipados del motor de pruebas aparece un aviso de recurso todavía en uso al salir (también presente al probar el menú original). No se detectaron errores de scripts ni rutas durante la última secuencia de navegación. No se editaron archivos del Nivel 3 para ocultar ese aviso.

## Abrir
Descomprimir el ZIP y abrir ProyectoJuego-SEI-mainO/project.godot en Godot 4.7. La carpeta conserva el nombre de la entrega actual. No hay que copiar la versión antigua encima del resultado.

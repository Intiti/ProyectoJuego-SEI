# Miaugoritmos (MGTS) 

**Videojuego educativo para reforzar conocimientos de programación en Python** mediante una aventura interactiva desarrollada en **Godot Engine**.

**Asignatura:** OII-433 — Sistemas Educativos Inteligentes  
**Integrantes:** Benjamín Leiva, Inti Liberona y Eliana García  

## Descripción

En Miaugoritmos, el jugador recorre distintos escenarios para encontrar a **Panko**, un gato perdido. Para avanzar debe interactuar con personajes y resolver desafíos seleccionando y ordenando bloques de código con instrucciones basadas en Python.

El juego está pensado para personas que **ya conocen las bases de Python** y quieren reforzar contenidos mediante la práctica; no es un curso desde cero.

## Contenido del juego

| Nivel | Escenario | Contenidos principales |
|---|---|---|
| 1 | Aldea del Valle | Variables, operaciones, entrada/salida y condiciones |
| 2 | Bosque Profundo y Ancestral | Ciclos, contadores, acumuladores y condiciones |
| 3 | Complejo Subterráneo | Combinación de ciclos, condiciones y lógica |

El proyecto incluye **30 ejercicios de práctica** (10 por nivel), evaluaciones, retroalimentación y elementos de gamificación, como puntajes, insignias y clasificaciones.

## Cómo ejecutar el proyecto desde el código fuente

1. Instalar **Godot Engine 4.x**. El archivo `project.godot` de esta entrega declara compatibilidad con la característica **4.7**; se recomienda abrirlo con esa versión o una versión compatible.
2. Descargar o clonar el repositorio y descomprimirlo si corresponde.
3. Abrir Godot y seleccionar **Importar**.
4. Seleccionar el archivo `project.godot` de la carpeta principal del proyecto.
5. Abrir el proyecto y presionar **F5 (Ejecutar proyecto)** para iniciar el juego desde el menú principal.

> **Ejecutable de Windows:** si la entrega incluye un archivo `.exe` independiente, se puede abrir directamente en Windows sin instalar el editor de Godot. **El ZIP del código fuente revisado no contiene ese `.exe`; debe adjuntarse o enlazarse por separado.**

## Controles básicos

| Acción | Tecla |
|---|---|
| Moverse | Flechas izquierda/derecha o **A / D** |
| Saltar | **Espacio**, **Enter** o **W** |
| Interactuar | **E** |
| Abrir el menú de pausa | **Esc** |
| Resolver desafíos | Seleccionar y organizar los bloques en pantalla |

Algunas pantallas ofrecen botones para consultar el manual, continuar o regresar.

## Cómo iniciar una partida

1. En el menú principal, seleccionar la opción para jugar.
2. El juego genera un **alias de jugador**. Copiarlo o anotarlo.
3. Abrir y responder el formulario de **pretest** que aparece antes de comenzar, utilizando el mismo alias.
4. Iniciar el juego, explorar los niveles y completar los desafíos.
5. Al finalizar la experiencia, responder el **postest** con el mismo alias.

El uso del mismo alias permite relacionar las respuestas de los formularios con la partida sin utilizar el nombre personal como identificador principal.

## Registros y datos del juego

El proyecto genera archivos de información en la carpeta de usuario de Godot (`user://`). Entre los archivos definidos en el código se encuentran:

- `reporte_jugador.json`: resumen del desempeño de la partida.
- `reportes/`: copias de reportes por sesión.
- `log_interacciones_mgts.json` y `log_interacciones_mgts.jsonl`: registros detallados de interacción del nivel 3.
- `log_examen_nivel3.jsonl`: registros asociados al examen del nivel 3.
- `progreso_nivel3_mgts.json` y `ranking_nivel3_mgts.json`: progreso y clasificación del nivel 3.

Desde el menú principal se puede usar el botón **CARPETA JSON** para abrir la carpeta local donde se guardan estos archivos. No todos los registros se generan necesariamente al iniciar: dependen de las acciones realizadas durante la partida.

**Importante:** los registros de interacción detallados están implementados específicamente en el nivel 3; los tres niveles también disponen de reportes de desempeño.

## Estructura del repositorio

```text
ProyectoJuego-SEI-main/
├── addons/              # Complementos de Godot (incluye Talo)
├── assets/              # Imágenes, sonidos, tipografías y otros recursos
├── dialogs/             # Diálogos y datos de actividades
├── scenes/              # Escenas y niveles del videojuego
├── scripts/             # Lógica en GDScript
├── project.godot        # Archivo principal para abrir el proyecto
└── export_presets.cfg   # Configuración de exportación
```

## Tecnologías utilizadas

- **Godot Engine** y **GDScript** para la implementación del juego.
- **JSON / JSONL** para diálogos y registros locales.
- **Talo** como complemento integrado para funcionalidades de clasificación y servicios relacionados. Algunas funciones en línea pueden depender de conectividad y configuración externa.


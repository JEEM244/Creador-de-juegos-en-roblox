# Guía de uso — Norteño Studio AI

## 1. Iniciar
Usa Node.js 20 o superior. En Windows, ejecuta `start.bat` con doble clic: crea `.env` si falta, inicia el servidor y abre el navegador. Para utilizar chat y planificador, edita `.env`, configura una clave API compatible y reinicia el servidor. También puedes ejecutar `npm start` y abrir `http://127.0.0.1:4173` manualmente.

Sin clave API puedes gestionar proyectos, tareas y archivos manualmente. El chat y el planificador requieren la API; el botón especializado **Construir festival en Studio** usa Codex CLI/MCP y no necesita `AI_API_KEY`. No pongas claves en el navegador. La API puede generar costes independientes de la suscripción de ChatGPT/Codex.

## 2. Crear un proyecto
Pulsa **+ Proyecto**, escribe un nombre y una descripción. Selecciona el proyecto desde el menú superior para filtrar la cola y la biblioteca. Los datos se guardan en la carpeta local `data/`.

## 3. Planificar una idea
Abre **Planificador**, escribe una meta concreta y pulsa **Crear plan**. La IA prepara subtareas, sugiere herramientas y propone criterios de aceptación. El sistema guarda las tareas como **Planificadas**; esto no significa que ya se ejecutaron.

Actualiza el estado al trabajar. Las tareas con dependencias no pueden pasar a **En progreso** ni **Terminada** hasta que las tareas previas estén terminadas.

## 4. Chat
Usa el chat para diseñar sistemas, resolver preguntas y redactar código. Cada respuesta se puede copiar o guardar como nota en **Recursos**. Si contiene un bloque de código Lua/Luau, puedes guardar ese bloque como archivo Luau. El chat no ejecuta scripts en Roblox Studio.

## 5. Recursos
En **Recursos**, puedes subir archivos admitidos o escribir un script Luau. Los archivos se almacenan en `data/assets/` y se descargan desde la biblioteca. El límite es 8 MB por recurso.

La app no ejecuta ni valida código Luau ni importa modelos automáticamente. Descarga el archivo, revisa su contenido y úsalo manualmente en Roblox Studio. Comprueba el formato, la procedencia y la licencia antes de incorporar un recurso a un juego publicado.

## 6. Enviar una tarea a Codex
Primero configura el MCP con [la guía de Roblox Studio](ROBLOX-STUDIO-MCP.md). En **Conexiones**, pulsa **Comprobar Codex**. La app revisa que el CLI esté instalado y que Roblox_Studio figure en `codex mcp list`; esto todavía no demuestra que Studio tenga una sesión conectada.

En el chat, escribe una instrucción y pulsa **Enviar a Codex**. También puedes enviarlo desde una tarea guardada. La app pide confirmación y ejecuta `codex exec` con el sandbox `workspace-write`, aprobación `on-request` y límite de diez minutos. El proceso muestra su salida en el panel y permite cancelar. Se permite una sola ejecución a la vez.

Antes de iniciar, asegúrate de que Studio está abierto en la experiencia correcta y guarda una copia. Si el MCP no devuelve una sesión real, Codex debe informar del bloqueo. La app no marca tareas como terminadas automáticamente. Revisa el resultado dentro de Studio antes de actualizar el estado.

El puente utiliza la autenticación/configuración local de Codex CLI, no la clave `AI_API_KEY` del chat. El uso sigue sujeto a la disponibilidad y los límites de tu cuenta de Codex.

## 7. Construir el Festival Norteño
1. Abre una copia de la experiencia correcta en Roblox Studio y guarda una copia de seguridad.
2. Confirma en Studio que el servidor MCP está habilitado y que Codex aparece conectado en esa sesión.
3. En Norteño Studio AI, pulsa **Construir festival en Studio** y acepta el aviso. El botón carga el brief local y lo envía a Codex con las reglas del constructor.
4. Codex debe leer `templates/norteno-festival/BuildFestival.lua`, ejecutar el constructor en contexto de edición, crear la escena y añadir `LightingShow.server.luau` y `RodeoRide.server.luau` a `ServerScriptService`.
5. Deja que Codex inspeccione la jerarquía, corrija errores y haga Playtest si el MCP lo permite. Revisa las luces, pasillos, pantallas, puestos y controles. No publiques automáticamente.

El constructor crea piezas nativas, pantallas gráficas y público estilizado; no descarga modelos externos ni incluye música real. La escena procedural es una base jugable inicial, no una producción AAA. Si el MCP no puede ejecutar el constructor o editar scripts, revisa el bloqueo concreto en la salida de Codex y la guía `templates/norteno-festival/README.md`.

## 8. Exportar para Codex
En **Conexiones**, puedes descargar el brief Markdown, JSON o exportación de tareas; son archivos de referencia y no ejecutan acciones por sí mismos.

## 9. Exportar y hacer copias de seguridad
Los botones **Exportar Markdown** y **Exportar JSON** descargan proyectos, tareas y metadatos de recursos; no incluyen los archivos binarios. Para conservar todo, cierra la app y copia la carpeta `data/` a una ubicación segura, incluyendo `state.json`, `activity.jsonl` y `assets/`.

## 10. Pruebas
Ejecuta `npm test`. GitHub Actions ejecuta pruebas del servidor en Node.js 20 y 22. Las pruebas no requieren una clave de API y utilizan un proveedor simulado para verificar el planificador.

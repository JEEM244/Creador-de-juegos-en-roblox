# Guía de uso — Norteño Studio AI

## 1. Iniciar
Usa Node.js 20 o superior. En Windows, ejecuta `start.bat` con doble clic: crea `.env` si falta, inicia el servidor y abre el navegador. Para utilizar chat y planificador, edita `.env`, configura una clave API compatible y reinicia el servidor. También puedes ejecutar `npm start` y abrir `http://127.0.0.1:4173` manualmente.

Sin clave API puedes gestionar proyectos, tareas y archivos manualmente, pero el chat y el planificador no pueden completar peticiones de IA. No pongas claves en el navegador. La API puede generar costes independientes de la suscripción de ChatGPT/Codex.

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

## 7. Exportar para Codex
En **Conexiones**, puedes descargar el brief Markdown, JSON o exportación de tareas; son archivos de referencia y no ejecutan acciones por sí mismos.

## 8. Exportar y hacer copias de seguridad
Los botones **Exportar Markdown** y **Exportar JSON** descargan proyectos, tareas y metadatos de recursos; no incluyen los archivos binarios. Para conservar todo, cierra la app y copia la carpeta `data/` a una ubicación segura, incluyendo `state.json`, `activity.jsonl` y `assets/`.

## 9. Pruebas
Ejecuta `npm test`. GitHub Actions ejecuta pruebas del servidor en Node.js 20 y 22. Las pruebas no requieren una clave de API y utilizan un proveedor simulado para verificar el planificador.

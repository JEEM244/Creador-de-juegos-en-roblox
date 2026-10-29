# Norteño Studio AI — Roblox Game Creator

Estudio local en español para organizar y ejecutar la construcción de juegos de Roblox: proyectos persistentes, tareas, biblioteca de recursos, puente con Codex CLI y un flujo de construcción de festival norteño mediante Roblox Studio MCP.

## Requisitos
- Node.js 20 o superior.
- Una clave API de un proveedor compatible con Chat Completions para utilizar el chat y el planificador con IA.
- Opcional: Roblox Studio y Codex CLI para aplicar y comprobar cambios en la experiencia.

## Ejecutar en Windows
1. Clona o descarga el repositorio.
2. Ejecuta `start.bat` con doble clic. El lanzador crea `.env` desde `.env.example` si todavía no existe, inicia el servidor y abre el navegador.
3. Para usar el chat y el planificador, edita `.env` y añade tu clave en `AI_API_KEY`. Reinicia el servidor después de editarlo.

También puedes iniciarlo desde una terminal: copia `.env.example` como `.env`, configura la clave si la necesitas, ejecuta `npm start` y abre `http://127.0.0.1:4173`.

No requiere dependencias de npm. Para desarrollo puedes usar `npm run dev`; para pruebas, `npm test`. **No subas el archivo `.env` a GitHub.**

## Funciones disponibles
- **Chat de creación:** conversación con un modelo configurado mediante `AI_BASE_URL`, `AI_MODEL` y `AI_API_KEY`.
- **Construir festival en Studio:** botón especializado que carga un brief y lo entrega a Codex CLI para construir en la sesión de Roblox Studio abierta. Incluye un constructor procedural de escenario y plantillas Luau para el control de iluminación y una atracción arcade. Funciona sin `AI_API_KEY`, siempre que Codex/MCP estén conectados.
- **Ejecución con Codex CLI:** envía una instrucción o tarea guardada al Codex instalado en Windows; consulta instalación y configuración MCP, enseña la salida y permite cancelar. Usa el sandbox `workspace-write` y aprobación `on-request`.
- **Planificador:** envía una idea al modelo, solicita un plan estructurado y guarda las subtareas en la cola.
- **Proyectos:** crea, filtra, renombra y elimina proyectos.
- **Cola de tareas:** guarda tareas en disco, cambia su estado, edita detalles y elimina tareas.
- **Biblioteca de recursos:** guarda y descarga scripts Luau, texto/Markdown/JSON, imágenes, audio, modelos Roblox y formatos 3D admitidos. Límite por archivo: 8 MB.
- **Registro local:** las modificaciones se anotan en `data/activity.jsonl`; el estado y los metadatos se guardan en `data/state.json`, y los archivos en `data/assets/`.
- **Pruebas automáticas:** GitHub Actions ejecuta las pruebas con Node.js 20 y 22.

## IA del chat
Configuración por defecto en `.env.example`:
- `AI_BASE_URL=https://api.openai.com/v1`
- `AI_MODEL=gpt-6-luna` (modelo de menor coste para tareas enfocadas; revisa la documentación vigente)
- `AI_REASONING_EFFORT=none` (parámetro pensado para usar el modelo con baja latencia y permitir `temperature` en Chat Completions)
- `CODEX_EXECUTABLE=codex` (opcional; comando o ruta al CLI)
- `CODEX_WORKDIR=` (opcional; carpeta de trabajo existente para Codex)
- `AI_API_KEY=` (se debe completar localmente)

Puedes utilizar otro proveedor que implemente `/chat/completions`, pero algunas funciones como el modo JSON del planificador dependen de la compatibilidad del proveedor. Una suscripción a ChatGPT o Codex no implica que tengas créditos de API; revisa los costes y límites antes de enviar peticiones.

La comprobación de configuración solo indica si existe una clave. No demuestra que la clave sea válida; la primera solicitud al modelo verifica la conexión de uso real.

## Conectar Codex CLI con Roblox Studio
La vía recomendada es el servidor MCP integrado en Studio. Consulta [la guía de configuración de Windows](docs/ROBLOX-STUDIO-MCP.md).

La app puede lanzar Codex CLI con la configuración local existente mediante el botón **Enviar a Codex**. Antes de iniciar, confirma la acción; el puente verifica que `Roblox_Studio` esté en `codex mcp list` y muestra la salida de Codex. La ejecución real aún debe probarse en la computadora con Studio abierto. La app no controla por sí misma el protocolo MCP. Los recursos guardados en la biblioteca se descargan para importarlos o revisarlos en Studio.

## API local
- `GET /api/health`: versión, contadores y estado de configuración.
- `GET /api/codex/status`: comprueba si el CLI está instalado y si `Roblox_Studio` figura en la configuración MCP.
- `POST /api/codex/runs`: inicia una ejecución con Codex, tras verificar la configuración.
- `GET /api/codex/runs` y `GET /api/codex/runs/:id`: consulta la salida y el estado.
- `POST /api/codex/runs/:id/cancel`: solicita cancelar una ejecución activa.
- `GET/POST /api/projects`, `PATCH/DELETE /api/projects/:id`: proyectos.
- `GET/POST /api/jobs`, `PATCH/DELETE /api/jobs/:id`: tareas.
- `POST /api/plan`: genera un plan con IA y guarda las tareas.
- `GET/POST /api/assets`, `GET /api/assets/:id/download`, `DELETE /api/assets/:id`: biblioteca.
- `POST /api/chat`: chat con IA.
- `GET /api/export/codex`: brief para Codex con tareas, criterios y pasos de verificación.

Las rutas son para uso local; la aplicación escucha por defecto solo en `127.0.0.1`.

## Seguridad y límites
- Las claves API solo viven en el entorno local del servidor, nunca en el navegador ni en commits.
- Los archivos se guardan en la carpeta local `data`, ignorada por Git.
- Se aceptan únicamente extensiones conocidas; no se extraen archivos comprimidos ni se ejecutan scripts de la biblioteca.
- El código Luau se almacena y descarga como archivo; la aplicación no afirma haberlo ejecutado en Roblox Studio.
- El diagnóstico confirma que Codex CLI y la entrada MCP están configurados, pero no demuestra que exista una sesión real de Studio conectada. La propia ejecución debe comprobarlo.
- El puente de Codex usa sandbox `workspace-write`, aprobaciones `on-request`, límite de 10 minutos, una ejecución simultánea y un botón de cancelación. El proceso puede modificar el juego abierto si el MCP está disponible; revisa la ejecución y Studio antes de marcar la tarea como terminada.
- El constructor procedural crea una escena estilizada con piezas nativas; no genera modelos 3D externos ni música. La construcción automatizada depende de las herramientas de la sesión MCP y no está verificada todavía en la computadora del usuario. La app no publica juegos.
- Mantén copias de seguridad del proyecto Roblox y revisa cada cambio antes de publicarlo.

## Constructor de Festival Norteño
Abre Roblox Studio con una copia de tu experiencia, confirma que Codex puede leer la sesión MCP abierta y pulsa **Construir festival en Studio**. La app lee `templates/norteno-festival/BUILD-BRIEF.md` y manda el flujo a Codex. El brief incluye `BuildFestival.lua`, `LightingShow.server.luau` y `RodeoRide.server.luau`; Codex debe ejecutar el constructor en modo de edición, instalar los scripts y comprobar el resultado. No marques como completado nada que Codex no haya verificado realmente. Mira [la guía del paquete](templates/norteno-festival/README.md) para límites y criterios.

## Guía de uso
Consulta [docs/USER-GUIDE.md](docs/USER-GUIDE.md) para el flujo recomendado desde una idea hasta tareas y recursos revisables.

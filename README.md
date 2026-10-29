# Norteño Studio AI — Roblox Game Creator

Estudio local en español para organizar el desarrollo de juegos de Roblox: chat con IA, planificación en tareas, proyectos persistentes, biblioteca local y exportación de scripts Luau.

## Requisitos
- Node.js 20 o superior.
- Una clave API de un proveedor compatible con Chat Completions para utilizar el chat y el planificador con IA.
- Opcional: Roblox Studio y Codex CLI para aplicar y comprobar cambios en la experiencia.

## Ejecutar
1. Clona el repositorio.
2. Copia `.env.example` como `.env`.
3. Añade tu clave privada en `AI_API_KEY` si quieres activar el chat/planificador con IA.
4. Ejecuta `npm start`.
5. Abre `http://127.0.0.1:4173`.

No requiere dependencias de npm. Para desarrollo puedes usar `npm run dev`; para pruebas, `npm test`. **No subas el archivo `.env` a GitHub.**

## Funciones disponibles
- **Chat de creación:** conversación con un modelo configurado mediante `AI_BASE_URL`, `AI_MODEL` y `AI_API_KEY`.
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
- `AI_API_KEY=` (se debe completar localmente)

Puedes utilizar otro proveedor que implemente `/chat/completions`, pero algunas funciones como el modo JSON del planificador dependen de la compatibilidad del proveedor. Una suscripción a ChatGPT o Codex no implica que tengas créditos de API; revisa los costes y límites antes de enviar peticiones.

La comprobación de configuración solo indica si existe una clave. No demuestra que la clave sea válida; la primera solicitud al modelo verifica la conexión de uso real.

## Conectar Codex CLI con Roblox Studio
La vía recomendada es el servidor MCP integrado en Studio. Consulta [la guía de configuración de Windows](docs/ROBLOX-STUDIO-MCP.md).

La app web **no se conecta directamente al MCP ni ejecuta cambios dentro de Studio**. Codex CLI y Roblox Studio deben configurarse por separado, y la conexión real debe probarse allí. Los recursos guardados en la biblioteca se descargan para luego importarlos o revisarlos en Studio.

## API local
- `GET /api/health`: versión, contadores y estado de configuración.
- `GET/POST /api/projects`, `PATCH/DELETE /api/projects/:id`: proyectos.
- `GET/POST /api/jobs`, `PATCH/DELETE /api/jobs/:id`: tareas.
- `POST /api/plan`: genera un plan con IA y guarda las tareas.
- `GET/POST /api/assets`, `GET /api/assets/:id/download`, `DELETE /api/assets/:id`: biblioteca.
- `POST /api/chat`: chat con IA.

Las rutas son para uso local; la aplicación escucha por defecto solo en `127.0.0.1`.

## Seguridad y límites
- Las claves API solo viven en el entorno local del servidor, nunca en el navegador ni en commits.
- Los archivos se guardan en la carpeta local `data`, ignorada por Git.
- Se aceptan únicamente extensiones conocidas; no se extraen archivos comprimidos ni se ejecutan scripts de la biblioteca.
- El código Luau se almacena y descarga como archivo; la aplicación no afirma haberlo ejecutado en Roblox Studio.
- La app no comprueba de forma automática la conexión MCP, no genera modelos por sí misma y no publica juegos.
- Mantén copias de seguridad del proyecto Roblox y revisa cada cambio antes de publicarlo.

## Guía de uso
Consulta [docs/USER-GUIDE.md](docs/USER-GUIDE.md) para el flujo recomendado desde una idea hasta tareas y recursos revisables.

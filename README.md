# Norteño Studio AI — Roblox Game Creator

Aplicación local en español para centralizar el chat de creación, organizar tareas y preparar integraciones con Roblox Studio, Codex y proveedores de recursos.

## Requisitos
- Node.js 20 o superior.
- Una clave API de un proveedor de IA compatible con el endpoint Chat Completions.
- Opcional: Roblox Studio y su servidor MCP habilitado.
- Opcional: credenciales de servicios de generación de imágenes/modelos 3D.

## Ejecutar
1. Clona el repositorio.
2. Copia `.env.example` como `.env`.
3. Abre `.env` y añade tu clave API en `AI_API_KEY`.
4. Ejecuta `npm start`.
5. Abre `http://localhost:4173`.

No requiere dependencias de npm. El servidor carga las variables de `.env` directamente. **No subas el archivo `.env` a GitHub.**

## Configurar el proveedor de IA en la nube
Configuración por defecto:
- `AI_BASE_URL=https://api.openai.com/v1`
- `AI_MODEL=gpt-4.1-mini`
- `AI_API_KEY=` (añade tu clave privada)

Puedes cambiar la URL y el modelo para otro proveedor compatible con `/chat/completions`. Una suscripción de ChatGPT no incluye necesariamente créditos de API; revisa la facturación y límites del proveedor que elijas.

## Integraciones
- Chat con proveedor de IA en la nube: implementado; requiere clave y conexión válida.
- Cola inicial de tareas: implementada, con registro local de actividad.
- Roblox Studio/MCP: pendiente de conectar y probar.
- Generación de modelos 3D e imágenes: requiere adaptadores y credenciales del proveedor.
- Ejecución de tareas y publicación de juegos: no implementadas todavía.

## Seguridad
- Las claves API se guardan únicamente en el servidor, en `.env`; nunca en el navegador ni en commits.
- El servidor escucha por defecto en `127.0.0.1`.
- Revisa las acciones antes de ejecutar scripts o cambios en Roblox Studio.
- Las llamadas a modelos en la nube pueden generar costes según el proveedor.

## Próximos pasos
1. Conectar y validar Roblox Studio por MCP.
2. Añadir acciones permitidas con vista previa y confirmación.
3. Añadir proveedores de generación de modelos 3D e imágenes.
4. Persistir proyectos y tareas, y añadir pruebas automatizadas.

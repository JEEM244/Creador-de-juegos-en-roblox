# Hoja de ruta

## Fase 0 — Base local
- [x] Interfaz en español con navegación de chat, planificación, tareas, recursos y conexiones.
- [x] Servidor local sin dependencias npm.
- [x] Proxy de chat con proveedor compatible con Chat Completions.
- [x] Proyectos persistentes con creación, edición y eliminación.
- [x] Tareas persistentes con edición, estados, filtros y eliminación.
- [x] Planificador con IA que convierte una idea en un conjunto de tareas vinculadas.
- [x] Biblioteca local para scripts Luau, documentos, imágenes, audio y formatos de modelos admitidos.
- [x] Descarga de recursos y límite de 8 MB por archivo.
- [x] Registro de actividad y almacenamiento local ignorado por Git.
- [x] Pruebas automáticas de API y persistencia; CI para Node.js 20 y 22.
- [ ] Pruebas automatizadas de navegador para la interfaz.

## Fase 1 — Codex y Roblox Studio
- [x] Documentar la conexión del servidor MCP integrado de Roblox Studio con Codex CLI en Windows.
- [x] Aclarar en la interfaz que la app no verifica ni controla el MCP directamente.
- [ ] Validar una sesión real con Codex CLI + Roblox Studio en la computadora del usuario.
- [ ] Crear un flujo de aprobación y comprobación para cambios hechos con Codex/Studio.
- [ ] Investigar un puente local seguro para que la app pueda mostrar un estado de conexión real, sin fingir conectividad.

## Fase 2 — Flujos de producción
- [ ] Ejecutar una tarea aprobada con el cliente configurado, manteniendo revisión humana.
- [ ] Añadir exportación/importación de un paquete de proyecto con metadatos.
- [ ] Añadir búsqueda, etiquetas y vista previa de recursos en la biblioteca.
- [ ] Añadir exportación de planes y tareas a JSON/Markdown.
- [ ] Añadir operaciones de recuperación y copia de seguridad desde la interfaz.

## Fase 3 — Recursos y generación
- [ ] Comprobar las herramientas de generación/búsqueda de recursos disponibles en la versión instalada de Studio.
- [ ] Evaluar proveedores externos de imagen/modelos 3D solo cuando exista una necesidad concreta.
- [ ] Mostrar licencias, origen y formatos de los recursos antes de usarlos.
- [ ] Validar importaciones y resultados dentro de Roblox Studio.

## Fase 4 — Calidad y distribución
- [ ] Añadir pruebas de navegador y pruebas de seguridad.
- [ ] Validar scripts y probar un juego de muestra dentro de Studio.
- [ ] Medir rendimiento con luces, audio, público y objetos interactivos.
- [ ] Añadir un flujo explícito y confirmado de publicación.
- [ ] Empaquetar la aplicación local para Windows.

## Criterio de éxito
La app conserva proyectos, tareas y recursos, convierte ideas en planes revisables y deja claro qué acciones realizó realmente. Las conexiones con herramientas externas solo se marcan como activas después de verificarlas.

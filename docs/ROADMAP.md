# Hoja de ruta

## Fase 0 — Base local
- [x] Interfaz en español con chat y panel de integraciones.
- [x] Servidor local sin dependencias npm.
- [x] Proxy de chat para proveedores compatibles con Chat Completions.
- [x] Comprobación local del estado de configuración de IA.
- [x] Cola inicial de tareas y registro de actividad.
- [x] Añadir pruebas automatizadas para rutas principales del servidor y comprobarlas con CI en Node.js 20 y 22.
- [ ] Añadir pruebas automatizadas de navegador para la interfaz.
- [ ] Persistir proyectos y estados de tareas tras reiniciar.

## Fase 1 — Flujo de trabajo con Codex y Roblox Studio
- [x] Identificar el servidor MCP integrado de Roblox Studio como integración recomendada.
- [x] Documentar la conexión de Roblox Studio con Codex CLI en Windows.
- [ ] Probar una sesión real de Codex CLI conectada a Roblox Studio en la máquina del usuario.
- [ ] Crear un procedimiento repetible: inspeccionar escena, proponer cambio, revisar aprobación, ejecutar y verificar resultado.
- [ ] Mostrar en la app el estado real de conexión; no inferir conexión a partir de que la configuración exista.
- [ ] Añadir una vista previa de tareas y confirmación explícita para acciones importantes.

## Fase 2 — Planificación y tareas
- [ ] Convertir una petición en un plan estructurado con objetivo, subtareas, dependencias y criterios de aceptación.
- [ ] Permitir aprobar, pausar, reintentar, cancelar y marcar tareas terminadas.
- [ ] Guardar proyectos y tareas en almacenamiento local persistente.
- [ ] Exportar scripts Luau y archivos de diseño para revisión antes de usarlos.

## Fase 3 — Recursos de juego
- [ ] Evaluar primero las funciones de generación y búsqueda de recursos disponibles en Roblox Studio MCP.
- [ ] Añadir proveedores externos de imagen/modelos solo cuando aporten algo que Studio no resuelva.
- [ ] Guardar metadatos de origen, licencia, formato y estado de importación.
- [ ] Permitir previsualizar y organizar recursos antes de integrarlos.

## Fase 4 — Pruebas y publicación
- [ ] Validar scripts y probar el juego en Roblox Studio.
- [ ] Registrar errores y resultados de las pruebas.
- [ ] Diagnosticar rendimiento en escenas con luces, público, audio y objetos interactivos.
- [ ] Añadir flujo explícito de publicación con confirmación final.
- [ ] Empaquetar la app local para Windows.

## Criterio de éxito
Una instrucción produce un plan revisable; cada tarea muestra su estado y herramienta requerida. Las conexiones se verifican de verdad, las modificaciones importantes requieren revisión y no se presentan como completadas acciones que no se ejecutaron.

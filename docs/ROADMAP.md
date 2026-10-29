# Hoja de ruta

## Fase 0 — Base local (actual)
- [x] Interfaz única con chat y panel de integraciones.
- [x] Servidor local sin dependencias npm.
- [x] Proxy de chat con Ollama y comprobación de estado.
- [x] Cola temporal de tareas y registro local de actividad.
- [ ] Pruebas automatizadas del servidor y la interfaz.
- [ ] Persistencia de proyectos y tareas tras reiniciar.

## Fase 1 — Roblox Studio
- [ ] Documentar la configuración del servidor MCP de Roblox Studio en Windows.
- [ ] Añadir comprobación de conectividad MCP real.
- [ ] Añadir un catálogo de acciones permitidas: inspeccionar escena, crear carpeta, insertar pieza, modificar propiedades seguras.
- [ ] Presentar una vista previa de acciones y solicitar aprobación antes de ejecutarlas.
- [ ] Registrar resultados, errores y opción de deshacer cuando el protocolo lo permita.

## Fase 2 — Generación de recursos
- [ ] Definir interfaz común de proveedores para imagen, modelo 3D y textura.
- [ ] Añadir un proveedor por vez, con claves almacenadas exclusivamente en el servidor.
- [ ] Guardar metadatos de licencia, origen, formato, dimensiones y estado de importación.
- [ ] Permitir previsualizar, descargar y organizar recursos antes de importarlos.

## Fase 3 — Flujo de creación
- [ ] Convertir peticiones del chat en planes estructurados con dependencias.
- [ ] Permitir aprobar, pausar, reintentar y cancelar tareas.
- [ ] Añadir archivos de proyecto y exportación de scripts Luau revisables.
- [ ] Añadir pruebas de regresión y validación en Roblox Studio.

## Fase 4 — Calidad y publicación
- [ ] Diagnóstico de rendimiento y límites de memoria.
- [ ] Revisión de seguridad y permisos.
- [ ] Flujo explícito de publicación con confirmación final.
- [ ] Empaquetado sencillo para Windows.

## Criterio de éxito
Una sola instrucción produce un plan verificable; cada tarea muestra qué herramienta necesita, qué se ha hecho realmente y qué falta. No se simulan integraciones inexistentes ni se ejecutan cambios destructivos sin aprobación.

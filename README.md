# Norteño Studio AI — Roblox Game Creator

Un espacio de trabajo local para describir juegos en un chat, convertir las ideas en tareas y preparar recursos para Roblox Studio. La meta es coordinar herramientas desde una sola interfaz, no fingir que un chat por sí solo puede generar y montar un juego completo.

## Requisitos
- Node.js 20 o superior.
- Opcional: Ollama para chat local.
- Opcional: Roblox Studio y su servidor MCP habilitado.
- Opcional: credenciales de proveedores de generación de recursos; se conectarán mediante adaptadores seguros cuando se configure cada proveedor.

## Ejecutar
1. Descarga/clona este repositorio.
2. En la carpeta del proyecto ejecuta `npm start`.
3. Abre `http://localhost:4173`.
4. Para desarrollo con reinicio automático: `npm run dev`.

No necesita dependencias de npm: utiliza módulos integrados de Node.js.

## Conectar Ollama
1. Instala y abre Ollama.
2. Descarga el modelo sugerido: `ollama pull qwen2.5-coder:3b`.
3. Confirma que Ollama responda en `http://127.0.0.1:11434`.
4. Reinicia la aplicación si cambiaste `.env`.

La interfaz detecta el chat local y envía allí las solicitudes. Sin Ollama, el modo de demostración permite explorar la planificación, pero no genera respuestas reales de un modelo.

## Roblox Studio
El diseño contempla una integración local con Roblox Studio/MCP para que un agente autorizado pueda crear y modificar objetos dentro de Studio. La primera versión **no se conecta automáticamente a MCP ni ejecuta cambios en Roblox**: primero se debe configurar y validar ese puente, y luego añadir una capa de acciones con confirmación del usuario.

## Estado de las funciones
- Chat local con Ollama: implementado.
- Planificador inicial de tareas: implementado en la interfaz.
- Panel de integraciones y estado del servidor: base inicial.
- Generación real de modelos 3D: requiere conectar un proveedor y su API.
- Escritura de scripts/edición de mapas en Roblox Studio: requiere integrar y probar el MCP de Studio.
- Exportar/publicar juegos: no implementado todavía.

## Seguridad
- Las claves de servicios externos nunca deben ir en el navegador ni en el repositorio.
- El servidor escucha por defecto en localhost.
- Revisa los cambios antes de ejecutar scripts o acciones destructivas en Studio.
- Usa únicamente recursos, modelos, música y texturas con permisos de uso adecuados.

## Siguiente etapa
1. Conectar MCP de Roblox Studio.
2. Añadir adaptadores de proveedores de modelos 3D y generación de imágenes.
3. Hacer que el planificador ejecute tareas aprobadas y guarde resultados en un registro.
4. Añadir importación/exportación de recursos y pruebas automáticas.

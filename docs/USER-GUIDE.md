# Guía de uso — Norteño Studio AI

## 1. Iniciar
Usa Node.js 20 o superior. Copia `.env.example` a `.env`; para usar chat y planificador, configura una clave de API compatible. Ejecuta `npm start` y abre `http://127.0.0.1:4173`.

Si no tienes una clave API, puedes usar la cola manual de tareas y la biblioteca, pero el chat y el planificador de IA no podrán completar peticiones. No hay que poner la clave en el navegador.

## 2. Crear un proyecto
Pulsa **+ Proyecto**, escribe un nombre y una descripción. Selecciona el proyecto desde el menú superior para filtrar la cola y los recursos. Proyectos y tareas se guardan en el almacenamiento local de la app.

## 3. Planificar una idea
Abre **Planificador**, escribe una meta concreta y pulsa **Crear plan**. La IA convierte la idea en subtareas, asigna una herramienta sugerida y propone criterios de aceptación. El sistema guarda las tareas con estado **Planificada**; esto no significa que se ejecutaron.

Puedes cambiar cada tarea a aprobada, en progreso, bloqueada, terminada o cancelada. Marca una tarea como terminada solo después de comprobar su resultado.

## 4. Chat
El chat es para diseño, preguntas y planificación. No puede ejecutar acciones dentro de Roblox Studio por sí solo. Para generar y seguir tareas de forma estructurada, usa la pestaña **Planificador**.

## 5. Guardar scripts y recursos
En **Recursos**, puedes subir un archivo admitido o escribir un script Luau. Los archivos se almacenan bajo `data/assets/` y se pueden descargar desde la biblioteca. El límite es 8 MB por recurso.

La app no ejecuta ni valida el código Luau y no importa un modelo automáticamente a Studio. Descarga el archivo, revisa su contenido y úsalo manualmente en Roblox Studio. Comprueba el formato y la licencia del recurso antes de incorporarlo a un juego publicado.

## 6. Conectar Codex y Roblox Studio
Sigue [la guía MCP para Windows](ROBLOX-STUDIO-MCP.md). La conexión ocurre en el cliente Codex y Roblox Studio. Esta app no la comprueba directamente y no debe mostrarla como conectada sin pruebas.

## 7. Copia de seguridad
Cierra la app y copia la carpeta `data/` a una ubicación segura. Incluye `state.json`, `activity.jsonl` y `assets/`. Esta carpeta está ignorada por Git para evitar subir datos y archivos del usuario.

## 8. Pruebas
Ejecuta `npm test`. GitHub Actions ejecuta las pruebas de servidor en Node.js 20 y 22. No se envían solicitudes a un modelo durante las pruebas y estas no requieren clave API.

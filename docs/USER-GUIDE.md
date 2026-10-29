# Guía de uso — Norteño Studio AI

## 1. Iniciar
Usa Node.js 20 o superior. Copia `.env.example` a `.env`; para utilizar chat y planificador configura una clave API compatible. Ejecuta `npm start` y abre `http://127.0.0.1:4173`.

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

## 6. Exportar para Codex
En **Conexiones**, usa **Brief para Codex** para descargar un archivo Markdown con los proyectos y tareas, los criterios de aceptación y una lista de comprobaciones para Roblox Studio MCP. Ábrelo o pásalo a Codex CLI cuando trabajes en el proyecto.

El brief no ejecuta las tareas. Codex debe comprobar que el servidor MCP está conectado, revisar cambios importantes y comunicar qué ha probado.

## 7. Conectar Codex y Roblox Studio
Sigue [la guía MCP para Windows](ROBLOX-STUDIO-MCP.md). La conexión ocurre en Codex y Roblox Studio, por separado de esta app. No se muestra como activa hasta que se verifique dentro de Studio y mediante herramientas que devuelvan datos reales.

## 8. Exportar y hacer copias de seguridad
Los botones **Exportar Markdown** y **Exportar JSON** descargan proyectos, tareas y metadatos de recursos; no incluyen los archivos binarios. Para conservar todo, cierra la app y copia la carpeta `data/` a una ubicación segura, incluyendo `state.json`, `activity.jsonl` y `assets/`.

## 9. Pruebas
Ejecuta `npm test`. GitHub Actions ejecuta pruebas del servidor en Node.js 20 y 22. Las pruebas no requieren una clave de API y utilizan un proveedor simulado para verificar el planificador.

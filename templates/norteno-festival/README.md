# Plantillas del Festival Norteño

Este paquete es la base reproducible para el botón **Construir festival en Studio** de Norteño Studio AI.

## Archivos
- `BuildFestival.lua`: constructor de escenario, truss, pantallas LED gráficas, pilas de bocinas, siluetas de banda norteña con acordeón, bajo sexto, micrófonos y batería, gradas, público estilizado, entrada, puestos abiertos, backstage y arena arcade.
- `LightingShow.server.luau`: controlador de luces en servidor con apertura, looks de color y final.
- `RodeoRide.server.luau`: minijuego arcade de 12 segundos; la puntuación se calcula en el servidor.
- `CrowdAnimation.client.luau`: anima un máximo de 42 brazos del público localmente con tweens ligeros.
- `BUILD-BRIEF.md`: instrucciones de implementación, fases y criterios de aceptación para Codex.

## Flujo previsto
1. Abre Roblox Studio con una copia de tu experiencia.
2. Asegúrate de que el cliente Codex esté conectado al servidor MCP de la sesión actual.
3. Inicia Norteño Studio AI y selecciona **Construir festival en Studio**.
4. La herramienta lee el brief, después Codex debe inspeccionar la sesión real antes de cambiarla.
5. El constructor se ejecuta en contexto de edición si la herramienta de Studio lo permite. Nunca lo ejecutes en Play mode para hacer una construcción que debas guardar: los cambios de una sesión de prueba pueden revertirse al salir.
6. Codex instala los dos scripts de servidor, ejecuta las pruebas disponibles y muestra el resultado real.

El constructor marca su salida con el atributo `GeneratedByNortenoStudioAI`. No reemplaza escenas automáticamente: si detecta una escena ya generada, se detiene para evitar una duplicación y Codex debe inspeccionar la escena existente y mejorarla con cuidado. Si encuentra un modelo `NortenoFestival` sin marca, lo conserva y el constructor crea otro con sufijo. No publiques el lugar automáticamente.

## Límites conocidos
- La escena usa piezas nativas para que no dependa de IDs de activos externos. Es una base procedural estilizada, no modelos escaneados ni geometría AAA.
- Las pantallas son composición gráfica con `SurfaceGui`; no reproducen vídeo ni música por sí solas.
- La banda y el público son siluetas/props estáticos para controlar el coste. No equivalen a músicos animados, una multitud de NPC con comportamiento ni una simulación musical.
- La luz del show cambia colores y estados. La sincronización real con audio requiere música autorizada y una capa adicional de análisis/tiempo.
- El minijuego es una atracción arcade no gráfica; las puntuaciones se calculan en el servidor, pero todavía debe probarse con varios jugadores.
- El código fuente de esta carpeta no demuestra una ejecución exitosa en Roblox Studio. Revisa los resultados y los errores de salida antes de guardar/publicar.

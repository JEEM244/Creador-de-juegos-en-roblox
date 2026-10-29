# Conectar Codex CLI con Roblox Studio MCP en Windows

Roblox Studio tiene un servidor MCP integrado. La aplicación Norteño Studio AI no se conecta directamente a ese servidor todavía; Codex CLI puede ser el cliente MCP que interactúa con tu sesión de Studio.

## Preparación
- Actualiza Roblox Studio.
- Instala Codex CLI y comprueba que puedes abrirlo desde tu entorno de trabajo.
- Abre en Studio una copia del proyecto que puedas modificar sin poner en riesgo tu versión principal.

## Configuración recomendada: conexión rápida
1. Abre Roblox Studio y carga tu experiencia.
2. Abre **Assistant** en Studio.
3. Pulsa el menú **…** y selecciona **Manage MCP Servers**.
4. Activa **Enable Studio as MCP server**.
5. Abre la opción **Quick connect** y habilita **Codex CLI**.
6. Si Codex CLI estaba abierto durante la instalación/configuración, reinícialo.
7. En caso de que tu versión muestre una configuración distinta, sigue el texto que proporciona la propia interfaz de Studio para ese cliente.

Si Codex CLI no aparece en Quick connect, confirma primero que está instalado y reinicia Roblox Studio. No pegues archivos de configuración de un cliente distinto sin revisar el formato que espera Codex.

## Comprobación
Pide a Codex CLI que:
1. Detecte/lista las sesiones de Roblox Studio disponibles.
2. Identifique la sesión correcta por nombre y, cuando corresponda, por ID de lugar.
3. Lea la jerarquía del juego y resuma los objetos de Workspace.
4. No modifique nada hasta que apruebes una primera operación pequeña.

En Studio, vuelve a **Assistant → … → Manage MCP Servers** y revisa el indicador de conexión. Una instrucción de Codex por sí sola no demuestra que el MCP esté conectado: confirma que las herramientas realmente devuelvan datos del proyecto abierto.

## Qué puede hacer el MCP de Studio
Según la versión disponible, las herramientas pueden cubrir lectura y edición de scripts, búsqueda en la jerarquía, ejecución de Luau, entrada de usuario de prueba, modo Playtest, captura de pantalla y algunas funciones de generación/búsqueda de recursos. La lista exacta puede cambiar con las actualizaciones de Studio.

## Seguridad
- El cliente conectado puede leer y modificar el contenido de las experiencias abiertas en Studio; conecta solo clientes de confianza.
- Guarda una copia del proyecto antes de operaciones amplias.
- Revisa las solicitudes de aprobación; no autorices acciones que no entiendas.
- Prueba primero cambios pequeños y verifica el resultado en Studio.
- Nunca compartas claves API, tokens ni archivos privados en los mensajes.

## Límites actuales de Norteño Studio AI
La app local solo mantiene un panel de estado informativo para MCP; todavía no lanza Codex CLI, no habla directamente con el servidor MCP y no puede verificar su estado por sí misma. Esta guía configura la conexión en Codex/Studio, de forma separada del chat de IA en la app.

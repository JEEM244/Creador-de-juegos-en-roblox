# Conectar Codex CLI con Roblox Studio MCP en Windows

Roblox Studio incluye un servidor MCP. Norteño Studio AI no se conecta directamente a ese servidor: Codex CLI es el cliente que puede interactuar con la sesión abierta de Studio. Consulta también la [documentación oficial de Roblox](https://create.roblox.com/docs/studio/mcp).

## Preparación
- Actualiza Roblox Studio.
- Instala Codex CLI y verifica que abre correctamente.
- Abre en Studio una copia del proyecto que puedas modificar sin poner en riesgo la versión principal.

## Método recomendado: conexión rápida
1. Abre Roblox Studio y carga tu experiencia.
2. Abre **Assistant** → menú **…** → **Manage MCP Servers**.
3. Activa **Enable Studio as MCP server**.
4. En **Quick connect**, habilita **Codex CLI** (en algunas versiones puede aparecer bajo el nombre ChatGPT/codex).
5. Reinicia Codex CLI si estaba abierto durante la configuración.

Si el cliente no aparece en la lista, confirma que Codex CLI esté instalado y reinicia Studio. Sigue las instrucciones que muestre tu versión de Studio.

## Método alternativo desde PowerShell
Usa esta alternativa solo si la conexión rápida no aparece. En PowerShell ejecuta:

```powershell
codex mcp add Roblox_Studio '--' cmd.exe /c 'cd /d %LOCALAPPDATA%\Roblox && .\mcp.bat'
codex mcp list
```

El primer comando registra el servidor MCP de Studio en Codex. Si Codex indica que ya existe `Roblox_Studio`, no lo registres por segunda vez; revisa la configuración existente y vuelve a consultar `codex mcp list`. Consulta la [guía técnica de conexión de Roblox Studio](https://github.com/Roblox/roblox-studio-agent-plugin/blob/main/skills/roblox-get-started/references/connect.md) si la sintaxis cambia.

## Comprobar que funciona
1. Confirma en Studio que **Manage MCP Servers** muestra el indicador verde de cliente conectado.
2. En Codex, pide que liste las sesiones de Studio disponibles y que identifique la sesión por nombre/ID de lugar.
3. Pide leer la jerarquía de Workspace y resumir algunos objetos, sin modificar nada.
4. Después de confirmar que la lectura funciona, autoriza un cambio pequeño y reversible.
5. Verifica el resultado dentro de Studio y revisa la salida de errores.

No basta con que Codex conteste que está conectado: las herramientas deben devolver datos de la experiencia que tienes abierta.

## Qué puede hacer el MCP
Según la versión de Studio, las herramientas pueden permitir leer/editar scripts, buscar objetos, ejecutar Luau, controlar Playtest, simular entrada del jugador, capturar pantalla y acceder a funciones de generación de recursos como mallas. La lista exacta depende de la versión instalada; consulta la [documentación oficial de MCP](https://create.roblox.com/docs/studio/mcp).

## Seguridad
- Un cliente conectado puede leer y modificar el contenido de los lugares abiertos en Studio; conecta solo clientes de confianza.
- Guarda una copia del proyecto antes de cambios grandes.
- Revisa las aprobaciones y no autorices operaciones que no entiendas.
- Prueba primero cambios pequeños.
- No compartas claves API, tokens ni archivos privados.

## Límites actuales de Norteño Studio AI
La app no lanza Codex CLI, no se comunica directamente con el servidor MCP y no verifica el estado de la conexión. El chat de la app, la configuración MCP y Codex CLI son componentes separados. Puedes exportar un **brief para Codex** desde **Conexiones** para pasarle al agente las tareas guardadas y los criterios de aceptación.

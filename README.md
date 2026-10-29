# Norteño Studio AI — Roblox Game Creator

Aplicación local en español para centralizar ideas, organizar tareas y preparar un flujo de creación de juegos con Codex y Roblox Studio.

## Requisitos
- Node.js 20 o superior.
- Una clave API de un proveedor compatible con Chat Completions para usar el chat integrado de la aplicación.
- Roblox Studio actualizado y Codex CLI para trabajar directamente en la escena mediante el MCP integrado de Studio.

## Ejecutar la aplicación
1. Clona el repositorio.
2. Copia `.env.example` como `.env`.
3. Abre `.env` y añade tu clave privada en `AI_API_KEY` si quieres usar el chat integrado.
4. Ejecuta `npm start`.
5. Abre `http://localhost:4173`.

No requiere dependencias de npm. El servidor carga las variables de `.env` directamente. **No subas el archivo `.env` a GitHub.**

## IA del chat integrado
Configuración por defecto:
- `AI_BASE_URL=https://api.openai.com/v1`
- `AI_MODEL=gpt-4.1-mini`
- `AI_API_KEY=` (añade tu clave privada)

Puedes cambiar la URL y el modelo para otro proveedor compatible con `/chat/completions`. La clave permanece en el backend. Una suscripción de ChatGPT/Codex no implica que tengas créditos de API; comprueba la facturación y los límites antes de usarla.

**Importante:** este chat de la aplicación y Codex son partes distintas. La API key sirve para el chat integrado; la conexión de Codex CLI con Roblox Studio se configura en Codex/Studio por separado.

## Conectar Codex CLI con Roblox Studio (Windows)
La vía recomendada es el servidor MCP integrado en Roblox Studio, no instalar un servidor MCP externo por separado.

1. Instala o actualiza Roblox Studio y comprueba que Codex CLI funciona en tu PC.
2. Abre Roblox Studio y el proyecto que vas a editar.
3. Abre **Assistant** → menú de tres puntos (**…**) → **Manage MCP Servers**.
4. Activa **Enable Studio as MCP server**.
5. En **Quick connect**, habilita **Codex CLI**. Si no aparece, reinicia Studio después de instalar Codex y vuelve a revisar.
6. Sigue las instrucciones de configuración que muestra Studio para el cliente elegido.
7. Reinicia Codex CLI cuando lo solicite.
8. Pídele a Codex que liste las instancias de Studio y lea la jerarquía del proyecto. Verifica en Studio el indicador de conexión y revisa las aprobaciones antes de permitir cambios.

Guía paso a paso: [docs/ROBLOX-STUDIO-MCP.md](docs/ROBLOX-STUDIO-MCP.md).

El MCP de Studio utiliza transporte local `stdio`. Esta aplicación web **todavía no se conecta directamente al MCP ni puede afirmar si Codex está conectado**. La conexión directa desde la app es una tarea pendiente.

## Estado de las integraciones
- Chat con IA en la nube: implementado, pero requiere API key y conectividad válidas.
- Cola inicial de tareas: implementada; todavía requiere mejoras de persistencia y estados.
- Roblox Studio MCP: disponible en Studio; la guía está preparada, pero la conexión debe configurarse y probarse en tu PC.
- Generación de mallas, modelos y materiales: algunas funciones forman parte de las herramientas de Studio MCP; comprueba su disponibilidad en tu versión de Studio.
- Publicación automática del juego: no implementada.

## Seguridad
- No guardes claves en el frontend, el repositorio ni capturas públicas.
- El servidor local escucha por defecto en `127.0.0.1`.
- Conectar un cliente MCP le permite leer y modificar contenido del proyecto abierto. Conecta solo clientes de confianza y conserva una copia antes de cambios grandes.
- Revisa las acciones y aprobaciones antes de ejecutar código en Studio.
- Las llamadas a modelos en la nube pueden tener costes según el proveedor.

## Próximas prioridades
1. Probar Codex CLI + Roblox Studio MCP en una sesión real.
2. Convertir ideas en planes estructurados y tareas persistentes.
3. Mostrar el estado real de las conexiones.
4. Ampliar las pruebas con navegador y validar el flujo completo en Studio.

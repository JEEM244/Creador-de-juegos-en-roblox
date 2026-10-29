# Build brief: Festival Norteño (Roblox Studio)

## Mission
Build a polished, playable first version of a large-scale Mexican norteño concert festival inside the currently open Roblox Studio experience. Work through the live Roblox Studio MCP session. Do not just write a plan or return code for the user to paste: create the scene and scripts in Studio, verify the result, and report what was actually completed.

## Hard rules
- First prove the Studio MCP session is live by reading the current place/session and Workspace hierarchy. A configured server in `codex mcp list` alone is not proof.
- Work only inside a clearly named `Workspace/NortenoFestival` model and purpose-created folders/scripts. Do not remove, rename, or overwrite unrelated user objects. If a marked generated scene already exists, inspect and improve it instead of rerunning the one-time constructor. Avoid duplicate builds.
- Do not publish the experience. Do not add external packages or use arbitrary Toolbox assets without checking their source. Avoid guessed asset IDs. Use native Parts, Materials, SurfaceGui, PointLight, SpotLight, Attachments, Beams, ProximityPrompts, and scripts when possible.
- Make changes in small phases, verify after each phase, and keep the existing place intact. If the MCP cannot perform a needed action, state the limitation and continue with a safe fallback.
- Prioritize a visually composed, detailed scene over an enormous empty map. Use a consistent art direction and real scale, layered depth, intentional silhouettes, signage, trim, cables/truss details, and believable lighting.
- Do not describe features as tested unless the live tool session actually ran/observed them. Do not make up test results.
- Keep performance reasonable for a modest PC: reuse materials, avoid hundreds of active lights, use anchored static parts, and cap audience props. Keep dynamic effects limited and toggleable.

## Visual direction
A premium nighttime regional Mexican / norteño festival. Palette: matte charcoal and black steel, warm amber and brass, deep red accents, warm white work lights, and controlled magenta/cyan LED highlights. Use dark sky and ground to make the stage lights readable. No default gray-box look: add layered materials, sign lettering, banners, cable runs, truss crossbars, speaker stacks, screen borders, edge lighting, road cases, backstage details, safety rails, floor markings, and coordinated signage. Keep the environment readable and navigable.

## Phase 1 — Make the first real Studio change immediately
1. Call `list_roblox_studios`, `get_studio_state`, and `search_game_tree` only long enough to select the live Studio instance, confirm Edit mode, and check whether a generated festival already exists. The connection check has already served its purpose once these return valid live data.
2. **Do not spend the next turn only narrating, planning, reading every template, or listing tools.** The user's request is to build the game, not only connect MCP.
3. Read `templates/norteno-festival/BuildFestival.lua`, then immediately execute its Luau source through the Roblox Studio MCP `execute_luau` tool with `datamodel_type="Edit"` if no marked festival exists. This constructor is specifically designed for Edit mode. Do not use Play mode for the build because edits can revert when play stops.
4. If a generated festival already exists, do not rerun the constructor. Inspect it and improve the existing marked model using `execute_luau` or `multi_edit`. Never delete or overwrite unrelated objects.
5. If running the local source through `execute_luau` fails, capture the exact error and use Studio MCP editing tools (`execute_luau`, `multi_edit`, `script_read`, and `search_game_tree`) to build the scene in smaller, verifiable batches. Do not stop with just a plan or instructions for the user to paste.
6. **Verify a real modification before proceeding:** call `search_game_tree` again and confirm a marked model under `Workspace` plus the expected children such as `MainStage`, `MainLEDWall`, `Audience`/bleachers, `Concessions`, and `RodeoArena`. Report the actual paths/counts. If the tree is unchanged, do not claim that construction succeeded; continue with a different MCP editing method or report the precise blocking error.
7. After the environment exists, read `LightingShow.server.luau` and `RodeoRide.server.luau` and install them as scripts in `ServerScriptService` using Studio MCP `multi_edit`. Install `CrowdAnimation.client.luau` as a `LocalScript` in `StarterPlayer/StarterPlayerScripts`. Verify their paths with `search_game_tree` and read back the source with `script_read`.
8. The builder applies a named Atmosphere effect and sets global Lighting values for the night scene. Do not delete or modify unrelated effects; report those intentional environment changes so the user can review them.
9. Use helper functions for any additional parts, signs, lights, and props. Set anchored/collision/query properties deliberately.

## Phase 2 — Build the main stage
Create a concert space with visual hierarchy:
- A raised multi-layer stage deck with dark fascia, metallic edges, stairs/ramps and safe player access.
- A large roof/truss rig with believable vertical towers, horizontal spans, cross-bracing and hanging fixtures.
- A central LED wall and two side screens with dark frames, patterned animated/color-cycle content made with SurfaceGui if supported; avoid pretending it is real video.
- Stacks of line-array speaker cabinets on both sides, subwoofer blocks, monitor wedges and backstage road cases.
- Several rows of truss-mounted lighting fixtures, visible lens/fixture geometry, beams/cones where possible, and SpotLight/PointLight instances kept to a reasonable count.
- A branded sign reading “FESTIVAL NORTEÑO” and supporting directional signs. Use readable built-in fonts, contrast, and sensible text sizes.
- Cable runs, barriers, front-of-stage security lane, side-fill speakers, stage edge marks, and a small backstage area.
- Create a compact audience/bleacher area with rows, handrails, aisle gaps and a limited number of stylized audience silhouettes. Do not spawn an unbounded number of characters or physics objects.

## Phase 3 — Environment and side activities
- Add a designed entrance gate, ticket/check-in booths, food stands, string lights, bins, benches, first-aid/help point, toilets signage and clear paths.
- Add a separate fenced dirt rodeo/jaripeo-style arena as an optional side attraction. Make it an arcade-style, non-graphic mechanical ride/minigame space with safe spectator distance, seating, lights, score display and an obvious exit. Do not depict injury.
- Ensure the main concert remains the focal point; side activities must not block paths or sightlines.

## Phase 4 — Make it playable
Create maintainable scripts in appropriate services (use MCP script editing/creation tools):
- A server-authoritative show controller in ServerScriptService. It owns show state and cycles a small number of lighting looks (warm opening, red/amber pulse, finale) with safe cleanup and a stop/reset.
- A server-side ProximityPrompt or button near backstage that starts/stops the light show. Add a short cooldown so multiple users cannot spam it.
- An interactive attraction prompt and simple server-validated score/time loop for the arcade ride. Keep the mechanic optional and non-graphic.
- A lightweight client script only if needed for local UI feedback. Validate RemoteEvent inputs on the server; never trust a client to set scores or arbitrary lighting.
- Avoid hard-coded references that break if objects are renamed; use a consistent folder/attribute scheme and nil checks.

## Companion templates
- `templates/norteno-festival/BuildFestival.lua`: one-time procedural builder intended for Studio EDIT context; it creates a marked, self-contained scene.
- `templates/norteno-festival/LightingShow.server.luau`: server-authoritative show toggle and lighting looks.
- `templates/norteno-festival/RodeoRide.server.luau`: optional 12-second arcade ride challenge with server-side score checks.
- `templates/norteno-festival/CrowdAnimation.client.luau`: client-local tweening of a limited number of audience arms for a livelier but lightweight crowd.

## Phase 5 — Quality pass
1. Inspect the generated hierarchy and check for duplicate builds, floating objects, unanchored static geometry, blocked paths, malformed text and excessive light instances.
2. Run Luau syntax checks or Studio playtest/tool diagnostics if supported by MCP.
3. Start Playtest only if the MCP supports it and the user has not indicated a live session must remain untouched. If errors appear, fix them and rerun the relevant check.
4. Verify that the show control toggles the lighting state and that the optional attraction can be entered/started/stopped without soft-locking a player.
5. Check visual composition from at least a visitor entrance view and the center of the audience if screenshot/camera tools exist.
6. Provide a concise, truthful final report: objects created/updated, scripts created, tests that really ran, known limitations, and any manual Studio step remaining.

## Acceptance criteria
- A clearly branded, non-empty main stage with layered rigging, LED panels, speaker arrays, barriers and stage access.
- A coherent night environment with entry, crowd/bleachers, wayfinding and food stands.
- A separate optional arena attraction with no graphic injury content.
- At least one interactive show control with server-side state.
- No unrelated existing objects deleted or overwritten; repeated run does not create a second copy of the festival.
- Honest verification report, with no claims of real assets, live music, performance, or playtest unless those were actually confirmed.

## Working strategy
Execute phases in order. Keep the place playable after each phase. Prefer fewer well-composed details over random clutter. If a phase exceeds the available tool capabilities, implement the best native-Parts fallback and document the gap instead of stopping after a plan.

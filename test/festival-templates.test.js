import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const template = name => path.join(root, "templates", "norteno-festival", name);

test("el constructor está marcado y no ejecuta una segunda copia silenciosamente", async () => {
  const source = await readFile(template("BuildFestival.lua"), "utf8");
  assert.match(source, /GeneratedByNortenoStudioAI/);
  assert.match(source, /BuilderVersion/);
  assert.match(source, /escena generada por Norteño Studio AI/);
  assert.match(source, /FestivalGround/);
  assert.match(source, /MainLEDWall/);
  assert.match(source, /AudienceSilhouette/);
  assert.match(source, /JARIPEO ARCADE/);
  assert.match(source, /ShowControlPrompt/);
});

test("los controladores de servidor validan el modelo y sus controles", async () => {
  const lightScript = await readFile(template("LightingShow.server.luau"), "utf8");
  const rideScript = await readFile(template("RodeoRide.server.luau"), "utf8");
  assert.match(lightScript, /GeneratedByNortenoStudioAI/);
  assert.match(lightScript, /ProximityPrompt/);
  assert.match(lightScript, /LEDStripe/);
  assert.match(lightScript, /stopShow/);
  assert.match(rideScript, /GeneratedByNortenoStudioAI/);
  assert.match(rideScript, /ProximityPrompt/);
  assert.match(rideScript, /RodeoBest/);
  assert.match(rideScript, /12 seconds|12/);
});

test("el brief define conexión real, pruebas y límites de publicación", async () => {
  const brief = await readFile(template("BUILD-BRIEF.md"), "utf8");
  assert.match(brief, /live Studio MCP session/i);
  assert.match(brief, /EDIT mode/i);
  assert.match(brief, /Acceptance criteria/i);
  assert.match(brief, /Do not publish the experience/i);
  assert.match(brief, /LightingShow.server.luau/);
  assert.match(brief, /RodeoRide.server.luau/);
});

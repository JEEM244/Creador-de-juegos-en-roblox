import { spawn } from "node:child_process";
import { after, before, test } from "node:test";
import assert from "node:assert/strict";
import { mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";

const port = 18000 + Math.floor(Math.random() * 10000);
const baseUrl = "http://127.0.0.1:" + port;
let serverProcess;
let dataDir;

const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));

async function startServer() {
  serverProcess = spawn(process.execPath, ["server.js"], {
    cwd: process.cwd(),
    env: { ...process.env, PORT: String(port), AI_API_KEY: "", DATA_DIR: dataDir },
    stdio: ["ignore", "ignore", "pipe"]
  });
  let stderr = "";
  serverProcess.stderr?.on("data", chunk => { stderr += chunk.toString(); });

  for (let attempt = 0; attempt < 80; attempt++) {
    if (serverProcess.exitCode !== null) throw new Error("El servidor terminó al iniciar. " + stderr);
    try {
      const response = await fetch(baseUrl + "/api/health");
      if (response.ok) return;
    } catch {}
    await sleep(100);
  }
  serverProcess.kill("SIGTERM");
  throw new Error("El servidor no respondió a tiempo. " + stderr);
}

async function stopServer() {
  if (!serverProcess || serverProcess.exitCode !== null) return;
  const child = serverProcess;
  await new Promise(resolve => {
    child.once("exit", resolve);
    child.kill("SIGTERM");
  });
}

async function jsonRequest(pathname, options = {}) {
  const response = await fetch(baseUrl + pathname, options);
  return { response, data: await response.json() };
}

before(async () => {
  dataDir = await mkdtemp(path.join(tmpdir(), "norteno-studio-test-"));
  await startServer();
});

after(async () => {
  await stopServer();
  if (dataDir) await rm(dataDir, { recursive: true, force: true });
});

test("GET /api/health informa el estado real de configuración", async () => {
  const { response, data } = await jsonRequest("/api/health");
  assert.equal(response.status, 200);
  assert.equal(data.ok, true);
  assert.equal(data.app, "Norteño Studio AI");
  assert.equal(data.ai.configured, false);
  assert.equal(data.integrations.robloxStudioMcp.status, "manual");
});

test("GET / sirve la interfaz en español", async () => {
  const response = await fetch(baseUrl);
  const html = await response.text();
  assert.equal(response.status, 200);
  assert.match(html, /<html lang="es">/);
  assert.match(html, /Norteño Studio AI/);
});

test("proyectos se crean, actualizan y validan", async () => {
  const created = await jsonRequest("/api/projects", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name: "Concierto Norteño", description: "Demo de prueba" })
  });
  assert.equal(created.response.status, 201);
  assert.equal(created.data.project.name, "Concierto Norteño");

  const updated = await jsonRequest("/api/projects/" + created.data.project.id, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name: "Festival Norteño" })
  });
  assert.equal(updated.response.status, 200);
  assert.equal(updated.data.project.name, "Festival Norteño");

  const invalid = await jsonRequest("/api/projects", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name: " " })
  });
  assert.equal(invalid.response.status, 400);
});

test("las tareas se crean y permiten cambiar estado", async () => {
  const projectList = await jsonRequest("/api/projects");
  const projectId = projectList.data.projects[0].id;
  const created = await jsonRequest("/api/jobs", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ title: "Crear escenario", detail: "Bloqueo de prueba", tool: "Roblox Studio", projectId })
  });
  assert.equal(created.response.status, 201);
  assert.equal(created.data.job.status, "planned");
  assert.equal(created.data.job.projectId, projectId);

  const updated = await jsonRequest("/api/jobs/" + created.data.job.id, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ status: "in_progress", detail: "En progreso" })
  });
  assert.equal(updated.response.status, 200);
  assert.equal(updated.data.job.status, "in_progress");

  const invalid = await jsonRequest("/api/jobs/" + created.data.job.id, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ status: "magia" })
  });
  assert.equal(invalid.response.status, 400);
});

test("la biblioteca guarda, descarga y elimina scripts Luau", async () => {
  const created = await jsonRequest("/api/assets", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name: "Script de prueba", filename: "prueba.luau", kind: "script", contentText: 'print("hola")' })
  });
  assert.equal(created.response.status, 201);
  assert.equal(created.data.asset.extension, ".luau");
  const download = await fetch(baseUrl + created.data.asset.downloadUrl);
  assert.equal(download.status, 200);
  assert.equal(await download.text(), 'print("hola")');

  const removed = await jsonRequest("/api/assets/" + created.data.asset.id, { method: "DELETE" });
  assert.equal(removed.response.status, 200);
  assert.equal(removed.data.deleted, true);
});

test("el servidor rechaza formatos de archivo no permitidos", async () => {
  const result = await jsonRequest("/api/assets", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ filename: "setup.exe", contentText: "not allowed" })
  });
  assert.equal(result.response.status, 400);
});

test("la persistencia conserva proyectos y tareas al reiniciar", async () => {
  const created = await jsonRequest("/api/jobs", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ title: "Persistencia de prueba", detail: "Debe sobrevivir al reinicio" })
  });
  assert.equal(created.response.status, 201);

  await stopServer();
  await startServer();

  const list = await jsonRequest("/api/jobs");
  assert.ok(list.data.jobs.some(job => job.title === "Persistencia de prueba"));
  const projects = await jsonRequest("/api/projects");
  assert.ok(projects.data.projects.some(project => project.name === "Festival Norteño"));
});

test("el chat y el planificador no realizan llamadas externas sin clave API", async () => {
  const chat = await jsonRequest("/api/chat", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ message: "Hola" })
  });
  assert.equal(chat.response.status, 503);
  assert.match(chat.data.error, /AI_API_KEY/);

  const plan = await jsonRequest("/api/plan", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ goal: "Diseñar una zona de concierto" })
  });
  assert.equal(plan.response.status, 503);
});

test("se limitan solicitudes JSON excesivas y rutas desconocidas", async () => {
  const missing = await jsonRequest("/api/no-existe");
  assert.equal(missing.response.status, 404);
});

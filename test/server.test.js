import { spawn } from "node:child_process";
import { after, before, test } from "node:test";
import assert from "node:assert/strict";

const port = 18000 + Math.floor(Math.random() * 10000);
const baseUrl = `http://127.0.0.1:${port}`;
let serverProcess;

const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));

before(async () => {
  serverProcess = spawn(process.execPath, ["server.js"], {
    cwd: process.cwd(),
    env: { ...process.env, PORT: String(port), AI_API_KEY: "" },
    stdio: ["ignore", "ignore", "pipe"]
  });

  let lastError = "";
  serverProcess.stderr?.on("data", chunk => { lastError += chunk.toString(); });

  for (let attempt = 0; attempt < 60; attempt++) {
    if (serverProcess.exitCode !== null) {
      throw new Error(`El servidor terminó al iniciar. ${lastError}`);
    }
    try {
      const response = await fetch(`${baseUrl}/api/health`);
      if (response.ok) return;
    } catch {
      // El proceso puede necesitar unos milisegundos para abrir el puerto.
    }
    await sleep(100);
  }

  serverProcess.kill("SIGTERM");
  throw new Error(`El servidor no respondió a tiempo. ${lastError}`);
});

after(() => {
  if (serverProcess && serverProcess.exitCode === null) serverProcess.kill("SIGTERM");
});

test("GET /api/health informa la app y que la API key está ausente", async () => {
  const response = await fetch(`${baseUrl}/api/health`);
  const data = await response.json();

  assert.equal(response.status, 200);
  assert.equal(data.ok, true);
  assert.equal(data.app, "Norteño Studio AI");
  assert.equal(data.ai.configured, false);
  assert.equal(data.integrations.robloxStudioMcp, "not_configured");
});

test("GET / sirve la interfaz en español", async () => {
  const response = await fetch(baseUrl);
  const html = await response.text();

  assert.equal(response.status, 200);
  assert.match(html, /<html lang="es">/);
  assert.match(html, /Norteño Studio AI/);
});

test("POST /api/jobs crea una tarea y GET /api/jobs la devuelve", async () => {
  const create = await fetch(`${baseUrl}/api/jobs`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      title: "Prueba automática",
      detail: "Validar la cola",
      tool: "Test"
    })
  });
  const created = await create.json();

  assert.equal(create.status, 201);
  assert.equal(created.job.title, "Prueba automática");
  assert.equal(created.job.status, "planned");

  const listResponse = await fetch(`${baseUrl}/api/jobs`);
  const list = await listResponse.json();
  assert.ok(list.jobs.some(job => job.id === created.job.id));
});

test("POST /api/jobs rechaza una tarea sin título", async () => {
  const response = await fetch(`${baseUrl}/api/jobs`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ detail: "Sin título" })
  });
  const data = await response.json();

  assert.equal(response.status, 400);
  assert.match(data.error, /título/i);
});

test("POST /api/chat no realiza llamadas externas si no hay clave API", async () => {
  const response = await fetch(`${baseUrl}/api/chat`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ message: "Hola" })
  });
  const data = await response.json();

  assert.equal(response.status, 503);
  assert.match(data.error, /AI_API_KEY/);
});

test("POST /api/chat rechaza mensajes vacíos", async () => {
  const response = await fetch(`${baseUrl}/api/chat`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ message: "   " })
  });
  const data = await response.json();

  assert.equal(response.status, 400);
  assert.match(data.error, /instrucción/i);
});

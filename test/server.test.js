import { spawn } from "node:child_process";
import { createServer } from "node:http";
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

async function startServer(options = {}) {
  serverProcess = spawn(process.execPath, ["server.js"], {
    cwd: process.cwd(),
    env: { ...process.env, PORT: String(port), AI_API_KEY: options.apiKey ?? "", AI_BASE_URL: options.aiBaseUrl || "https://api.openai.com/v1", CODEX_EXECUTABLE: options.codexExecutable || "codex-command-missing-in-tests", CODEX_WORKDIR: options.codexWorkdir || process.cwd(), DATA_DIR: dataDir },
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

test("GET /api/build-brief entrega el flujo de construcción sin exigir API key", async () => {
  const response = await fetch(baseUrl + "/api/build-brief");
  const brief = await response.text();
  assert.equal(response.status, 200);
  assert.match(response.headers.get("content-type") || "", /text\/markdown/i);
  assert.match(brief, /Phase 2 — Build the main stage/);
  assert.match(brief, /Acceptance criteria/);
  assert.equal((await jsonRequest("/api/health")).data.ai.configured, false);
});

test("el puente Codex informa cuando CLI no está instalada y no ejecuta tareas", async () => {
  const status = await jsonRequest("/api/codex/status");
  assert.equal(status.response.status, 200);
  assert.equal(status.data.installed, false);

  const result = await jsonRequest("/api/codex/runs", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ prompt: "Crear una estructura en Roblox Studio" })
  });
  assert.equal(result.response.status, 503);
  assert.match(result.data.error, /Codex CLI/i);
});

test("las rutas de escritura rechazan orígenes remotos", async () => {
  const response = await fetch(baseUrl + "/api/projects", {
    method: "POST",
    headers: { "Content-Type": "application/json", "Origin": "https://example.invalid" },
    body: JSON.stringify({ name: "No debe crearse" })
  });
  const data = await response.json();
  assert.equal(response.status, 403);
  assert.match(data.error, /Origen no permitido/i);
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

  const dependent = await jsonRequest("/api/jobs", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ title: "Instalar luces", projectId, dependsOn: [created.data.job.id] })
  });
  assert.equal(dependent.response.status, 201);
  const blocked = await jsonRequest("/api/jobs/" + dependent.data.job.id, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ status: "in_progress" })
  });
  assert.equal(blocked.response.status, 409);

  const finishDependency = await jsonRequest("/api/jobs/" + created.data.job.id, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ status: "done" })
  });
  assert.equal(finishDependency.response.status, 200);
  const nowAllowed = await jsonRequest("/api/jobs/" + dependent.data.job.id, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ status: "in_progress" })
  });
  assert.equal(nowAllowed.response.status, 200);
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


test("el planificador convierte una respuesta del proveedor en tareas con dependencias", async () => {
  const aiPort = 19000 + Math.floor(Math.random() * 9000);
  const planPayload = {
    projectName: "Plan de prueba",
    summary: "Plan devuelto por un proveedor de prueba local.",
    tasks: [
      { title: "Crear escenario", detail: "Construir el bloque inicial.", tool: "Roblox Studio", dependsOn: [], acceptanceCriteria: "Escenario visible." },
      { title: "Añadir luces", detail: "Añadir luces después del escenario.", tool: "Codex", dependsOn: [0], acceptanceCriteria: "Luces verificables." }
    ]
  };
  let authHeader = "";
  const mockAi = createServer(async (request, response) => {
    let raw = "";
    for await (const chunk of request) raw += chunk.toString();
    authHeader = request.headers.authorization || "";
    response.writeHead(200, { "Content-Type": "application/json" });
    response.end(JSON.stringify({ choices: [{ message: { content: JSON.stringify(planPayload) } }] }));
  });
  await new Promise(resolve => mockAi.listen(aiPort, "127.0.0.1", resolve));
  try {
    await stopServer();
    await startServer({ apiKey: "test-key", aiBaseUrl: "http://127.0.0.1:" + aiPort + "/v1" });
    const projects = await jsonRequest("/api/projects");
    const project = projects.data.projects[0];
    const result = await jsonRequest("/api/plan", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ goal: "Crear un escenario con iluminación", projectId: project.id })
    });
    assert.equal(result.response.status, 201);
    assert.equal(authHeader, "Bearer test-key");
    assert.equal(result.data.jobs.length, 2);
    assert.deepEqual(result.data.jobs[1].dependsOn, [result.data.jobs[0].id]);
    assert.equal(result.data.jobs[1].projectId, project.id);
  } finally {
    await stopServer();
    await new Promise(resolve => mockAi.close(resolve));
    await startServer();
  }
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

test("las exportaciones JSON y Markdown incluyen el estado del estudio", async () => {
  const jsonResponse = await fetch(baseUrl + "/api/export/json");
  const exported = await jsonResponse.json();
  assert.equal(jsonResponse.status, 200);
  assert.equal(exported.format, "norteno-studio-export");
  assert.ok(exported.projects.some(project => project.name === "Festival Norteño"));
  assert.ok(exported.jobs.some(job => job.title === "Persistencia de prueba"));

  const markdownResponse = await fetch(baseUrl + "/api/export/markdown");
  const markdown = await markdownResponse.text();
  assert.equal(markdownResponse.status, 200);
  assert.match(markdown, /## Proyectos/);
  assert.match(markdown, /## Tareas/);
  assert.match(markdown, /Persistencia de prueba/);

  const codexResponse = await fetch(baseUrl + "/api/export/codex");
  const codexBrief = await codexResponse.text();
  assert.equal(codexResponse.status, 200);
  assert.match(codexBrief, /Brief de trabajo para Codex/);
  assert.match(codexBrief, /servidor MCP Roblox_Studio/);
  assert.match(codexBrief, /Persistencia de prueba/);
});

test("la exportación por proyecto filtra tareas y metadatos", async () => {
  const projectList = await jsonRequest("/api/projects");
  const project = projectList.data.projects.find(item => item.name === "Festival Norteño");
  assert.ok(project);
  const response = await fetch(baseUrl + "/api/export/json?projectId=" + project.id);
  const exported = await response.json();
  assert.equal(response.status, 200);
  assert.equal(exported.projects.length, 1);
  assert.equal(exported.projects[0].id, project.id);
  assert.ok(exported.jobs.every(job => job.projectId === project.id));
});

test("el puente Codex lanza una ejecución aislada y captura su salida", { skip: process.platform === "win32" ? "el ejecutable de prueba usa un shim POSIX" : false }, async () => {
  const { writeFile, chmod } = await import("node:fs/promises");
  const fakeCodex = path.join(dataDir, "codex-fake");
  await writeFile(fakeCodex, `#!/bin/sh
case "$1" in
  --version) echo "codex-test 1.0"; exit 0 ;;
  mcp) echo "Roblox_Studio enabled"; exit 0 ;;
  exec) echo "FAKE CODEX STARTED"; cat; exit 0 ;;
  *) echo "unexpected command"; exit 2 ;;
esac
`, "utf8");
  await chmod(fakeCodex, 0o755);
  await stopServer();
  await startServer({ codexExecutable: fakeCodex, codexWorkdir: process.cwd() });
  try {
    const status = await jsonRequest("/api/codex/status");
    assert.equal(status.data.installed, true);
    assert.equal(status.data.mcpServerRegistered, true);

    const started = await jsonRequest("/api/codex/runs", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title: "Prueba de puente", prompt: "Lee la escena y no cambies nada." })
    });
    assert.equal(started.response.status, 202);
    const id = started.data.run.id;
    let result;
    for (let attempt = 0; attempt < 50; attempt++) {
      result = await jsonRequest("/api/codex/runs/" + id);
      if (result.data.run.status !== "running") break;
      await sleep(100);
    }
    assert.equal(result.data.run.status, "completed");
    assert.match(result.data.run.output, /FAKE CODEX STARTED/);
    assert.match(result.data.run.output, /Lee la escena y no cambies nada/);
  } finally {
    await stopServer();
    await startServer();
  }
});

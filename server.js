import http from "node:http";
import { readFile, mkdir, appendFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PORT = Number(process.env.PORT || 4173);
const OLLAMA_URL = (process.env.OLLAMA_URL || "http://127.0.0.1:11434").replace(/\/$/, "");
const OLLAMA_MODEL = process.env.OLLAMA_MODEL || "qwen2.5-coder:3b";
const dataDir = path.join(__dirname, "data");
const jobs = [];
let jobId = 1;

const mime = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml"
};
const send = (res, status, data) => {
  res.writeHead(status, { "Content-Type": "application/json; charset=utf-8", "Cache-Control": "no-store" });
  res.end(JSON.stringify(data));
};
async function bodyJson(req) {
  let raw = "";
  for await (const chunk of req) {
    raw += chunk;
    if (raw.length > 1_000_000) throw new Error("La solicitud supera 1 MB.");
  }
  return raw ? JSON.parse(raw) : {};
}
async function ollamaStatus() {
  try {
    const response = await fetch(`${OLLAMA_URL}/api/tags`, { signal: AbortSignal.timeout(1800) });
    if (!response.ok) return { connected: false, model: OLLAMA_MODEL, error: "Ollama respondió con un error." };
    const payload = await response.json();
    const models = (payload.models || []).map((m) => m.name);
    return { connected: true, model: OLLAMA_MODEL, models, modelAvailable: models.some((m) => m === OLLAMA_MODEL || m.startsWith(OLLAMA_MODEL + ":")) };
  } catch {
    return { connected: false, model: OLLAMA_MODEL, models: [], error: "No se detectó Ollama en la dirección configurada." };
  }
}
const systemPrompt = `Eres el copiloto de Norteño Studio AI, un estudio para crear juegos de Roblox. Habla español claro y directo. Convierte las ideas en planes concretos y realistas para Roblox Studio/Luau. Distingue lo que puedes hacer ahora de las integraciones que todavía requieren configuración. No afirmes que has creado archivos, modelos ni cambiado Roblox Studio si no se ejecutó una herramienta real. Cuando convenga, propone una lista breve de tareas con nombre, objetivo y herramienta requerida. Prioriza una demo pequeña y funcional antes de ampliar el alcance.`;

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url || "/", `http://127.0.0.1:${PORT}`);
  try {
    if (req.method === "GET" && url.pathname === "/api/health") {
      const ollama = await ollamaStatus();
      return send(res, 200, { ok: true, app: "Norteño Studio AI", version: "0.1.0", ollama, jobs: jobs.length, integrations: { robloxStudioMcp: "not_configured", assetGeneration: "not_configured" } });
    }
    if (req.method === "GET" && url.pathname === "/api/jobs") return send(res, 200, { jobs });
    if (req.method === "POST" && url.pathname === "/api/jobs") {
      const input = await bodyJson(req);
      if (!input.title || typeof input.title !== "string") return send(res, 400, { error: "Falta el título de la tarea." });
      const job = { id: jobId++, title: input.title.slice(0, 180), detail: String(input.detail || "").slice(0, 1200), tool: input.tool || "Planificador", status: "planned", createdAt: new Date().toISOString() };
      jobs.unshift(job);
      await mkdir(dataDir, { recursive: true });
      await appendFile(path.join(dataDir, "activity.jsonl"), JSON.stringify({ type: "job-created", ...job }) + "\n");
      return send(res, 201, { job });
    }
    if (req.method === "POST" && url.pathname === "/api/chat") {
      const input = await bodyJson(req);
      const message = String(input.message || "").trim();
      if (!message) return send(res, 400, { error: "Escribe una instrucción." });
      if (message.length > 12000) return send(res, 413, { error: "El mensaje supera el límite de 12,000 caracteres." });
      const status = await ollamaStatus();
      if (!status.connected) return send(res, 503, { error: "Ollama no está disponible. Puedes usar el planificador, o iniciar Ollama para habilitar el chat con IA local.", ollama: status });
      if (!status.modelAvailable) return send(res, 503, { error: `Ollama está activo, pero no se encontró el modelo ${OLLAMA_MODEL}. Descárgalo con: ollama pull ${OLLAMA_MODEL}`, ollama: status });
      const response = await fetch(`${OLLAMA_URL}/api/chat`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ model: OLLAMA_MODEL, stream: false, messages: [{ role: "system", content: systemPrompt }, ...(Array.isArray(input.history) ? input.history.slice(-10).map(m => ({ role: m.role === "assistant" ? "assistant" : "user", content: String(m.content || "").slice(0, 5000) })) : []), { role: "user", content: message }], options: { temperature: 0.35 } }),
        signal: AbortSignal.timeout(120000)
      });
      if (!response.ok) return send(res, 502, { error: "Ollama no pudo completar la respuesta." });
      const payload = await response.json();
      return send(res, 200, { reply: payload.message?.content || "El modelo no devolvió texto.", model: OLLAMA_MODEL });
    }
    if (req.method === "GET" && url.pathname === "/") {
      const html = await readFile(path.join(__dirname, "public", "index.html"));
      res.writeHead(200, { "Content-Type": "text/html; charset=utf-8", "X-Content-Type-Options": "nosniff" });
      return res.end(html);
    }
    if (req.method === "GET" && url.pathname.startsWith("/")) {
      const relative = decodeURIComponent(url.pathname.slice(1));
      if (!relative || relative.includes("..") || relative.includes("\\") || relative.startsWith(".")) return send(res, 400, { error: "Ruta no válida." });
      const fullPath = path.resolve(__dirname, "public", relative);
      if (!fullPath.startsWith(path.join(__dirname, "public") + path.sep)) return send(res, 403, { error: "Acceso denegado." });
      try {
        const file = await readFile(fullPath);
        res.writeHead(200, { "Content-Type": mime[path.extname(fullPath)] || "application/octet-stream", "X-Content-Type-Options": "nosniff" });
        return res.end(file);
      } catch { return send(res, 404, { error: "No se encontró el recurso." }); }
    }
    return send(res, 404, { error: "Ruta no encontrada." });
  } catch (error) {
    console.error(error);
    return send(res, 500, { error: error instanceof SyntaxError ? "JSON inválido." : "Error interno del servidor." });
  }
});
server.listen(PORT, "127.0.0.1", () => console.log(`Norteño Studio AI listo en http://127.0.0.1:${PORT}`));

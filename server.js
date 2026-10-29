import http from "node:http";
import { readFile, mkdir, appendFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
try {
  const envText = await readFile(path.join(__dirname, ".env"), "utf8");
  for (const line of envText.split(/\r?\n/)) {
    const match = line.match(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*$/);
    if (match && process.env[match[1]] === undefined) process.env[match[1]] = match[2].replace(/^(['"])(.*)\1$/, "$2");
  }
} catch {}
const PORT = Number(process.env.PORT || 4173);
const AI_BASE_URL = (process.env.AI_BASE_URL || "https://api.openai.com/v1").replace(/\/$/, "");
const AI_API_KEY = process.env.AI_API_KEY || "";
const AI_MODEL = process.env.AI_MODEL || "gpt-4.1-mini";
const dataDir = path.join(__dirname, "data");
const jobs = [];
let jobId = 1;

const mime = { ".html": "text/html; charset=utf-8", ".css": "text/css; charset=utf-8", ".js": "text/javascript; charset=utf-8", ".json": "application/json; charset=utf-8", ".svg": "image/svg+xml" };
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
function aiStatus() {
  return { configured: Boolean(AI_API_KEY), provider: AI_BASE_URL.includes("api.openai.com") ? "OpenAI API" : "API compatible", model: AI_MODEL, baseUrl: AI_BASE_URL };
}
const systemPrompt = `Eres el copiloto de Norteño Studio AI, un estudio para crear juegos de Roblox. Habla español claro y directo. Convierte ideas en planes concretos y realistas para Roblox Studio/Luau. Distingue lo que puedes hacer ahora de las integraciones que requieren configuración. No afirmes que has creado archivos, modelos ni cambiado Roblox Studio si no se ejecutó una herramienta real. Cuando convenga, propone tareas breves con nombre, objetivo y herramienta requerida. Prioriza una demo pequeña y funcional antes de ampliar el alcance.`;

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url || "/", `http://127.0.0.1:${PORT}`);
  try {
    if (req.method === "GET" && url.pathname === "/api/health") {
      return send(res, 200, { ok: true, app: "Norteño Studio AI", version: "0.2.0", ai: aiStatus(), jobs: jobs.length, integrations: { robloxStudioMcp: "not_configured", assetGeneration: "not_configured" } });
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
      if (!AI_API_KEY) return send(res, 503, { error: "Falta configurar AI_API_KEY en el archivo .env. No necesitas IA local; configura una clave del proveedor de IA en la nube." });
      const history = Array.isArray(input.history) ? input.history.slice(-10).map(m => ({ role: m.role === "assistant" ? "assistant" : "user", content: String(m.content || "").slice(0, 5000) })) : [];
      let response;
      try {
        response = await fetch(`${AI_BASE_URL}/chat/completions`, {
          method: "POST",
          headers: { "Content-Type": "application/json", "Authorization": `Bearer ${AI_API_KEY}` },
          body: JSON.stringify({ model: AI_MODEL, messages: [{ role: "system", content: systemPrompt }, ...history, { role: "user", content: message }], temperature: 0.35 }),
          signal: AbortSignal.timeout(120000)
        });
      } catch {
        return send(res, 502, { error: "No se pudo conectar con el proveedor de IA. Revisa tu conexión y AI_BASE_URL." });
      }
      const payload = await response.json().catch(() => ({}));
      if (!response.ok) return send(res, response.status === 401 ? 502 : 502, { error: payload.error?.message || "El proveedor de IA rechazó la solicitud. Revisa la clave, el modelo y el saldo/cuota de la API." });
      const reply = payload.choices?.[0]?.message?.content;
      return send(res, 200, { reply: typeof reply === "string" ? reply : "El modelo no devolvió texto.", model: AI_MODEL, provider: aiStatus().provider });
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

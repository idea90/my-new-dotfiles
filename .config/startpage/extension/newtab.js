// Kaleido start page: colors and wallpaper come from the local server (server.py), which reads
// matugen's output. The last colors are cached so the page paints right the first time.
const SERVER = "http://127.0.0.1:7391";
const $ = id => document.getElementById(id);
const root = document.documentElement;

const ENGINES = [
  { name: "Google", url: "https://www.google.com/search?q=" },
  { name: "DuckDuckGo", url: "https://duckduckgo.com/?q=" },
  { name: "Brave", url: "https://search.brave.com/search?q=" },
  { name: "YouTube", url: "https://www.youtube.com/results?search_query=" },
  { name: "GitHub", url: "https://github.com/search?q=" },
];
const DEFAULT_LINKS = [
  { name: "YouTube", url: "https://www.youtube.com" },
  { name: "GitHub", url: "https://github.com" },
  { name: "Reddit", url: "https://www.reddit.com" },
  { name: "Gmail", url: "https://mail.google.com" },
  { name: "ArchWiki", url: "https://wiki.archlinux.org" },
  { name: "Hyprland", url: "https://wiki.hypr.land" },
];

function load(key, fallback) {
  try { const v = localStorage.getItem(key); return v === null ? fallback : JSON.parse(v); } catch { return fallback; }
}
function save(key, value) { try { localStorage.setItem(key, JSON.stringify(value)); } catch {} }

const state = {
  engine: load("engine", 0), links: load("links", DEFAULT_LINKS), blur: load("blur", 16), dim: load("dim", 25),
  h24: load("h24", false), lite: load("lite", false), wall: load("wall", true), name: load("name", ""),
};

// ---- colors -------------------------------------------------------------
function applyColors(c) {
  for (const k in c) root.style.setProperty("--" + k, c[k]);
}
const cached = load("colors", null);
if (cached) applyColors(cached);

let lastColors = JSON.stringify(cached), lastWall = load("wallVersion", 0);
async function sync() {
  try {
    const [colors, meta] = await Promise.all([
      fetch(SERVER + "/colors.json", { cache: "no-store" }).then(r => r.json()),
      fetch(SERVER + "/meta.json", { cache: "no-store" }).then(r => r.json()),
    ]);
    $("offline").hidden = true;
    const s = JSON.stringify(colors);
    if (s !== lastColors && Object.keys(colors).length) { lastColors = s; applyColors(colors); save("colors", colors); }
    setGreeting(meta.user);
    if (state.wall) setWallpaper(meta.wallpaper); else $("bg").classList.add("plain");
  } catch {
    $("offline").hidden = false;
    $("bg").classList.add("plain");
  }
}
function setWallpaper(version) {
  const bg = $("bg");
  if (!version) { bg.classList.add("plain"); return; }
  if (version === lastWall && bg.dataset.loaded) { bg.classList.add("ready"); return; }
  const img = new Image();
  img.onload = () => {
    bg.style.backgroundImage = `url(${img.src})`;
    bg.dataset.loaded = "1";
    bg.classList.remove("plain");
    bg.classList.add("ready");
    lastWall = version; save("wallVersion", version);
  };
  img.onerror = () => bg.classList.add("plain");
  img.src = SERVER + "/wallpaper?v=" + version;
}

// ---- clock, greeting ------------------------------------------------------
let sysUser = load("user", "");
function setGreeting(user) {
  if (user) { sysUser = user; save("user", user); }
  const h = new Date().getHours();
  const part = h >= 5 && h < 12 ? "Good morning" : h >= 12 && h < 18 ? "Good afternoon" : h >= 18 && h < 22 ? "Good evening" : "Good night";
  const who = state.name || sysUser;
  $("greet").textContent = who ? `${part}, ${who}` : part;
}
function tick() {
  const d = new Date();
  let h = d.getHours();
  const pm = h >= 12;
  if (!state.h24) h = h % 12 || 12;
  $("hh").textContent = state.h24 ? String(h).padStart(2, "0") : String(h);
  $("mm").textContent = String(d.getMinutes()).padStart(2, "0");
  $("ap").textContent = state.h24 ? "" : (pm ? "PM" : "AM");
  $("date").textContent = d.toLocaleDateString(undefined, { weekday: "long", day: "numeric", month: "long" });
  setGreeting();
}
tick(); setInterval(tick, 1000);

// ---- search -------------------------------------------------------------------
function paintEngine() { $("engine").textContent = ENGINES[state.engine % ENGINES.length].name; }
$("engine").onclick = () => { state.engine = (state.engine + 1) % ENGINES.length; save("engine", state.engine); paintEngine(); $("q").focus(); };
$("search").onsubmit = e => {
  e.preventDefault();
  const q = $("q").value.trim();
  if (!q) return;
  // a URL or a bare domain opens directly
  if (/^https?:\/\//i.test(q)) location.href = q;
  else if (/^[\w-]+(\.[\w-]+)+(\/\S*)?$/.test(q)) location.href = "https://" + q;
  else location.href = ENGINES[state.engine % ENGINES.length].url + encodeURIComponent(q);
};
paintEngine();

// ---- quick links ------------------------------------------------------------------
function renderLinks() {
  const box = $("links");
  box.textContent = "";
  state.links.forEach((l, i) => {
    const a = document.createElement("a");
    a.className = "link"; a.href = l.url;
    const ic = document.createElement("div"); ic.className = "ic";
    ic.textContent = (l.name || "?").charAt(0).toUpperCase();
    const n = document.createElement("span"); n.className = "n"; n.textContent = l.name;
    const x = document.createElement("span"); x.className = "x"; x.textContent = "✕"; x.title = "Remove";
    x.onclick = e => { e.preventDefault(); state.links.splice(i, 1); save("links", state.links); renderLinks(); };
    a.append(ic, n, x);
    box.append(a);
  });
  const add = document.createElement("a");
  add.className = "link add";
  add.innerHTML = '<div class="ic">+</div><span class="n">Add</span>';
  add.onclick = () => {
    let url = prompt("Address (e.g. github.com)");
    if (!url) return;
    if (!/^https?:\/\//i.test(url)) url = "https://" + url;
    const name = prompt("Name", new URL(url).hostname.replace(/^www\./, "").split(".")[0]) || url;
    state.links.push({ name, url }); save("links", state.links); renderLinks();
  };
  box.append(add);
}
renderLinks();

// ---- settings --------------------------------------------------------------------
function paintLook() {
  document.body.classList.toggle("lite", state.lite);
  root.style.setProperty("--blur", state.blur + "px");
  root.style.setProperty("--dim", state.dim / 100);
}
paintLook();
$("gear").onclick = () => { $("panel").hidden = !$("panel").hidden; };
$("s-blur").value = state.blur; $("s-dim").value = state.dim; $("s-24h").checked = state.h24;
$("s-wall").checked = state.wall; $("s-lite").checked = state.lite; $("s-name").value = state.name;
$("s-blur").oninput = e => { state.blur = +e.target.value; save("blur", state.blur); paintLook(); };
$("s-dim").oninput = e => { state.dim = +e.target.value; save("dim", state.dim); paintLook(); };
$("s-lite").onchange = e => { state.lite = e.target.checked; save("lite", state.lite); paintLook(); };
$("s-24h").onchange = e => { state.h24 = e.target.checked; save("h24", state.h24); tick(); };
$("s-wall").onchange = e => { state.wall = e.target.checked; save("wall", state.wall); if (state.wall) sync(); else $("bg").classList.replace("ready", "plain"); };
$("s-name").oninput = e => { state.name = e.target.value.trim(); save("name", state.name); setGreeting(); };
$("s-reset").onclick = () => { state.links = DEFAULT_LINKS.slice(); save("links", state.links); renderLinks(); };
document.addEventListener("click", e => { if (!$("panel").hidden && !e.target.closest("#panel, #gear")) $("panel").hidden = true; });

sync(); setInterval(sync, 5000);

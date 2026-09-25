# Arreglar LSPs de Neovim (Astro, JS/TS, ESLint, Prisma) + diagnósticos visibles

## Context

Editando `~/Dev/DevMatch` (Astro + TypeScript, monorepo bun), Neovim tira errores en cada
archivo y no muestra ningún diagnóstico útil. Los síntomas reportados fueron:

- `eslint: Request textDocument/diagnostic failed with message: pLimit is not a function`
- `Request initialize failed ... Can't find typescript.js or tsserverlibrary.js`
- No hay servidor de Prisma y se necesita.
- Cuando hay un error o warning real, no se ve en pantalla.

**No es un problema, son cinco causas independientes** — y las dos más graves viven en el
proyecto DevMatch, no en la config de Neovim. Todas fueron confirmadas empíricamente:

| # | Causa raíz | Evidencia | Dónde se arregla |
|---|---|---|---|
| 1 | No existe ninguna llamada a `vim.diagnostic.config()` | Neovim 0.12 trae `virtual_text=false` por defecto (verificado) → solo se ven signos y subrayado, nunca el mensaje | myNixos |
| 2 | No hay LSP de Prisma | `prisma-language-server` ausente del PATH | myNixos |
| 3 | `typescript@7.0.2` en `frontend` | TS 7 es el compilador Go; su `lib/` no trae `typescript.js` ni `tsserverlibrary.js` → `astro-ls` muere al iniciar | DevMatch |
| 4 | `node_modules` mal materializado por bun | `p-limit@3.1.0` está en el store pero **no enlazado** dentro de `locate-path@6.0.0/node_modules/`, donde `p-locate@5.0.0` hace `require('p-limit')` | DevMatch |
| 5 | `eslint-plugin-astro` importado pero no instalado | `frontend/eslint.config.js` lo importa; ausente de `node_modules` y de `bun.lock` | DevMatch |

**Hallazgo clave sobre ESLint (#4):** ESLint no está roto "en Neovim" — está roto a nivel de
instalación. Falla idéntico desde la terminal, sin Neovim de por medio, en `frontend/` *y* en
`backend/`, antes siquiera de leer un archivo de config:

```
TypeError: pLimit is not a function
    at pLocate (.../locate-path@6.0.0/node_modules/p-locate/index.js:31:16)
    at ConfigLoader.locateConfigFileToUse (.../eslint/lib/config/config-loader.js:541:27)
```

El `bun.lock` **sí declara la resolución correcta** (`p-locate/p-limit` → `p-limit@3.1.0`);
lo que está mal es el árbol en disco. Por eso basta reinstalar sin tirar el lockfile.

Resultado esperado: diagnósticos visibles con un bind para cambiar de modo, Prisma LSP listo,
y Astro/TS/ESLint funcionando en DevMatch.

---

## Parte A — Diagnósticos visibles + bind para togglear

Archivo **nuevo**: `dotfiles/nvim/lua/config/diagnostics.lua`.

**Por qué en `config/` y no en `lsp.lua`:** `lsp.lua` es un plugin lazy que solo carga en
`BufReadPre`/`BufNewFile`. La config de diagnósticos debe existir desde el arranque y aplica
también a fuentes que no son LSP. `init.lua` lo cargará siempre.

El namespace `<leader>d` está **completamente libre** (verificado contra todos los binds
existentes: `w q e f rn ca tf tg tb th`), así que no hay colisiones.

```lua
-- dotfiles/nvim/lua/config/diagnostics.lua
-- Neovim 0.12 trae virtual_text = false por defecto: sin esto no se ve ningún
-- mensaje de error/warning, solo el signo en la columna izquierda.
local signs = {
  [vim.diagnostic.severity.ERROR] = " ",
  [vim.diagnostic.severity.WARN] = " ",
  [vim.diagnostic.severity.INFO] = " ",
  [vim.diagnostic.severity.HINT] = "󰌵 ",
}

vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "■", source = "if_many" },
  virtual_lines = false,
  signs = { text = signs },
  underline = true,
  severity_sort = true,
  update_in_insert = false,
  float = { border = "rounded", source = "if_many", header = "", prefix = "" },
})

-- <leader>dl alterna entre el mensaje al final de la línea (virtual_text) y el
-- mensaje completo en una línea aparte (virtual_lines), útil cuando se trunca.
local function toggle_modo()
  local cfg = vim.diagnostic.config()
  local a_lineas = not cfg.virtual_lines
  vim.diagnostic.config({
    virtual_lines = a_lineas and { current_line = false } or false,
    virtual_text = (not a_lineas) and { spacing = 2, prefix = "■", source = "if_many" } or false,
  })
  vim.notify("Diagnósticos: " .. (a_lineas and "líneas completas" or "texto en línea"))
end

local function toggle_encendido()
  local on = vim.diagnostic.is_enabled()
  vim.diagnostic.enable(not on)
  vim.notify("Diagnósticos " .. (on and "desactivados" or "activados"))
end

local map = vim.keymap.set
map("n", "<leader>dl", toggle_modo, { desc = "Diagnósticos: cambiar modo de vista" })
map("n", "<leader>dt", toggle_encendido, { desc = "Diagnósticos: activar/desactivar" })
map("n", "<leader>df", vim.diagnostic.open_float, { desc = "Diagnósticos: ver mensaje completo" })
map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Diagnósticos: listar en loclist" })
```

Y en `dotfiles/nvim/init.lua`, agregar la línea antes de `config.lazy`:

```lua
require("config.options")
require("config.keymaps")
require("config.diagnostics")   -- nuevo
require("config.lazy")
```

**API verificada en vivo:** `vim.diagnostic.config()` sin argumentos actúa de getter y con
tabla muta en runtime; `virtual_lines` existe en 0.12.4; `is_enabled`/`enable` funcionan.

En `lsp.lua`, migrar los dos binds deprecados (`goto_prev`/`goto_next` siguen existiendo pero
están deprecados) a la forma moderna, que además abre el float al saltar:

```lua
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Diagnóstico anterior")
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Diagnóstico siguiente")
```

---

## Parte B — LSP de Prisma

Tres ediciones. **Ojo:** en nvim-lspconfig el servidor se llama `prismals`, no `prisma`.
El paquete de nixpkgs es `prisma-language-server` y provee un binario con exactamente ese
nombre (verificado construyéndolo), que es justo lo que `lsp/prismals.lua` invoca.

1. `modules/nvim.nix` → agregar `prisma-language-server` a `home.packages`.
2. `dotfiles/nvim/lua/plugins/lsp.lua` → agregar `"prismals"` a la lista de `vim.lsp.enable`.
3. `dotfiles/nvim/lua/plugins/treesitter.lua` → agregar `"prisma"` a `ensure_installed`
   (hoy no está y el parser no existe).

DevMatch todavía no usa Prisma (no hay `schema.prisma` ni dependencias), así que esto deja el
servidor listo para cuando se agregue. **No** se va a scaffoldear Prisma en el proyecto.

---

## Parte C — Blindar astro-ls contra TypeScript roto

`lsp/astro.lua` resuelve el tsdk con `util.get_typescript_server_path(root_dir)`, que busca
hacia arriba el primer `node_modules` con un directorio `typescript` y le añade `/lib`. Con
TS 7 eso apunta a un directorio sin `tsserverlibrary.js` y el servidor muere.

Arreglar la versión en DevMatch (Parte D) resuelve el caso concreto, pero esto vuelve a pasar
en **cualquier** proyecto con TS roto. Esta parte lo hace robusto de forma permanente.

**Detalle de implementación verificado:** `vim.lsp.config` fusiona con
`vim.tbl_deep_extend('force', ...)`, y `force` **reemplaza** valores que no son tabla. Un
`before_init` propio por lo tanto **sustituye** al de lspconfig — hay que reimplementar la
búsqueda local, no solo añadir el fallback.

Para no clavar una ruta del Nix store, se declara el tsdk global desde Nix y se lee en Lua:

```nix
# modules/nvim.nix
home.sessionVariables.NVIM_TSDK = "${pkgs.typescript}/lib/node_modules/typescript/lib";
```

```lua
-- dotfiles/nvim/lua/plugins/lsp.lua
-- astro-ls necesita la API clásica de TypeScript (tsserverlibrary.js). Si el
-- proyecto trae un TS que no la incluye (ej. TS 7, el compilador en Go), se cae
-- al TypeScript global de Nix en vez de morir al iniciar.
local function tsdk_valido(dir)
  return dir and dir ~= "" and vim.fn.filereadable(dir .. "/tsserverlibrary.js") == 1
end

vim.lsp.config("astro", {
  before_init = function(_, config)
    local tsdk = require("lspconfig.util").get_typescript_server_path(config.root_dir)
    if not tsdk_valido(tsdk) then
      tsdk = vim.env.NVIM_TSDK
    end
    config.init_options = vim.tbl_deep_extend("force", config.init_options or {}, {
      typescript = { tsdk = tsdk },
    })
  end,
})
```

El TypeScript de Nix (5.9.3) sí trae `typescript.js` y `tsserverlibrary.js` — verificado en
disco. `ts_ls` no necesita el mismo parche: su `root_dir` se ancla en lockfiles, así que en
DevMatch cae en la raíz del workspace y toma el TS 6.0.3 correcto.

---

## Parte D — Reparar el proyecto DevMatch

### D1. `frontend/package.json`

- `typescript`: `7.0.2` → **`6.0.3`** (decisión tomada; alinea con la raíz del workspace y
  satisface el peer de `typescript-eslint`, que exige `>=4.8.4 <6.1.0` — 7.0.2 lo violaba).
- Agregar `eslint-plugin-astro` (lo importa `eslint.config.js`).
- Agregar sus peers, que hoy **tampoco están instalados**: `eslint-plugin-jsx-a11y` y
  `@typescript-eslint/parser`. `eslint-plugin-astro@3.1.0` declara:
  ```json
  { "eslint": ">=10.0.0", "typescript-eslint": ">=8.61.0",
    "eslint-plugin-jsx-a11y": ">=6.10.2", "@typescript-eslint/parser": ">=8.61.0" }
  ```
  ESLint 10 sí está soportado, y Node 24.18.1 cumple `engines`.
- Unificar `eslint` con la raíz (frontend `10.9.1` vs raíz `10.6.0`). Dos copias de ESLint en
  un workspace hacen que el servidor cargue una u otra según el archivo; conviene una sola.

### D2. Limpiar el lockfile huérfano

`backend/bun.lock` (1.2 KB) es un resto de `bun init` que declara `typescript@5.9.3` y no
corresponde al workspace. El lock real es el de la raíz (99 KB). Borrarlo.

### D3. Reinstalación limpia

El `bun.lock` de la raíz ya declara la resolución correcta, así que **se conserva**; lo que
hay que rehacer es el árbol en disco:

```bash
cd ~/Dev/DevMatch
rm -f backend/bun.lock
rm -rf node_modules frontend/node_modules backend/node_modules
bun install
```

### D4. Verificación (esto es lo que prueba que #4 quedó resuelto)

```bash
cd ~/Dev/DevMatch/frontend
./node_modules/.bin/eslint --version          # debe imprimir la versión, sin traza
./node_modules/.bin/eslint src/pages/index.astro   # debe linteear de verdad
ls node_modules/typescript/lib/tsserverlibrary.js  # debe existir ahora
```

Si `eslint --version` vuelve a lanzar `pLimit is not a function`, la reinstalación no corrigió
el enlace y el siguiente paso sería regenerar el lock (`rm bun.lock && bun install`).

---

## Orden de ejecución

Los cambios Lua aplican al instante (`~/.config/nvim` es symlink al repo); los de Nix
necesitan tu rebuild. Por eso:

1. **Yo**: Partes A, B y C — edito `modules/nvim.nix`, `lua/config/diagnostics.lua` (nuevo),
   `init.lua`, `lua/plugins/lsp.lua`, `lua/plugins/treesitter.lua`.
2. **Tú**: corres tu `rebuild` (yo no ejecuto `nixos-rebuild` ni `sudo`). Esto instala
   `prisma-language-server` y expone `NVIM_TSDK`. `NVIM_TSDK` viene de `sessionVariables`, así
   que requiere cerrar y volver a abrir sesión (o exportarla a mano para probar antes).
3. **Yo**: Parte D — edito los `package.json`, borro el lock huérfano y corro `bun install`
   (esto no es `sudo` ni toca Nix ni git).
4. **Ambos**: verificación final.

## Verificación final

En `nvim ~/Dev/DevMatch/frontend/src/pages/index.astro`:

- `:checkhealth vim.lsp` → `astro` y `eslint` adjuntos, sin errores de init.
- No debe aparecer ya el popup de `pLimit is not a function`.
- Introducir un error a propósito (ej. `const x: number = "hola"`) debe mostrar el mensaje
  **en línea** — esto es lo que hoy no pasa.
- `<leader>dl` cambia entre texto en línea y líneas completas; `<leader>df` abre el mensaje
  completo; `<leader>dt` apaga/enciende.
- `nvim archivo.prisma` → `:checkhealth vim.lsp` muestra `prismals` adjunto.

## Fuera de alcance

- No se instala Mason (ni se instalará).
- No se ejecuta `nixos-rebuild`/`rebuild` ni nada con `sudo`.
- No se hace `git add`/`commit` en ningún repo.
- No se agrega Prisma como dependencia de DevMatch — solo queda el LSP listo.

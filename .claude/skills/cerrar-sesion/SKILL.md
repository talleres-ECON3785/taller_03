---
name: cerrar-sesion
description: Cierra una sesión de trabajo del Taller 3 a nivel de repositorio — hace commit y push de los cambios a la rama del integrante (nunca a main) y copia el registro crudo (.jsonl) de la conversación actual a 09_Conversaciones/ (carpeta ignorada por git). Es mecánica; la bitácora y el handoff los escribe antes bitacora-sesion. Usar cuando el usuario pida "cerrar sesión", "hacer el commit", "subir los cambios", "push" o "guardar la conversación".
model: haiku
---

# Cerrar sesión de trabajo

Último paso de una sesión: versiona lo hecho y guarda la conversación. Va
**después** de `bitacora-sesion` (que escribe la bitácora y actualiza
`HANDOFF.md`), para que el commit incluya ambos. Hace dos cosas en este orden:

1. Hacer commit y push de la sesión a la rama del integrante (nunca a `main`).
2. Copiar el registro crudo (`.jsonl`) de la conversación a `09_Conversaciones/`.

Antes de empezar, confirma que existe la bitácora de hoy en `06_Bitacoras/` y que
`HANDOFF.md` aparece modificado en `git status`. Si falta alguno, avisa al
usuario y sugiere correr primero `bitacora-sesion`; no la escribas aquí. Si algo
no es inferible con certeza (quién trabajó, qué archivos son de la sesión),
pregunta en vez de adivinar. Si el usuario pide solo una de las partes, haz solo
esa.

## Paso 1: commit y push a la rama del integrante

Sigue la sección "Flujo de versiones" de `CLAUDE.md`, donde está la tabla
integrante → rama. Cada integrante tiene su rama (p. ej. `SantiagoMunozM`), y
los cambios de la sesión se suben **solo** a esa rama. Nunca a `main`.

1. **Identificar la rama del integrante.** Compara `git branch --show-current`
   y `git config user.name` con la tabla de `CLAUDE.md`.
   - Si la rama actual es la del integrante, continúa.
   - Si la rama actual es `main`, **no hagas commit**. Si los cambios están sin
     commitear, cambia a la rama del integrante con `git switch <rama>` (los
     cambios sin commitear se trasladan) y continúa ahí. Si ya hay commits
     locales en `main` que no están en `origin/main`, detente y pregunta al
     usuario cómo moverlos.
   - Si la rama actual es la de otro integrante, o no es inferible quién
     trabajó, pregunta antes de seguir.
2. **Revisar qué entra al commit.** Muestra `git status --short` y
   `git diff --stat`. Agrega los archivos de la sesión por nombre (no
   `git add -A` a ciegas):
   - Sí se versionan: la bitácora, `HANDOFF.md`, los scripts, `CLAUDE.md`, el README, los
     recursos de `07_Recursos/` y los datos y resultados que generan los
     scripts (p. ej. los `.Rds` de `01_Datos/02_Procesados/` y `03_Listos/`, y
     las tablas y figuras de `03_Resultados/`), y las notas de `05_Notas/`.
     Revisa en `git status` que no
     haya archivos de datos o resultados sin seguimiento.
   - No se versionan: nada de `09_Conversaciones/` (está en `.gitignore`; no
     uses `git add -f`), ni archivos temporales o de sesión de RStudio. Los
     datos crudos de `01_Datos/01_Crudos/` nunca se modifican.
   - Si aparecen archivos modificados que no son de esta sesión, o archivos
     pesados o sensibles, pregunta antes de incluirlos.
3. **Commit.** Mensaje en español, en imperativo, que resuma la sesión (p. ej.
   "Crear 00_main.R con pacman y verificación de carpetas"), con el cuerpo
   apuntando a la bitácora (`Bitácora: 06_Bitacoras/<archivo>.md`).
4. **Push a la rama del integrante:** `git push origin <rama>`; usa
   `git push -u origin <rama>` si la rama local no sigue todavía a la remota.
   - Si el push es rechazado porque la rama remota avanzó, haz
     `git pull --no-rebase origin <rama>`, resuelve con el usuario cualquier
     conflicto y vuelve a intentar. Nunca uses `--force`.
   - **Nunca** `git push origin main`, ni push de la rama del integrante hacia
     `main` (`<rama>:main`), ni merge a `main`. Llevar los cambios a `main` es
     decisión del integrante y se hace aparte, solo si lo pide.
5. Si el usuario pidió explícitamente no versionar, omite este paso y dilo en
   el cierre.

## Paso 2: copiar el `.jsonl` de la conversación

Claude Code guarda cada sesión como un `.jsonl` en
`~/.claude/projects/<slug>/`, donde `<slug>` es la ruta del directorio de
trabajo con todo carácter no alfanumérico reemplazado por `-`. Si la sesión
corrió desde un worktree, el directorio de trabajo es el del worktree, así que
basta con usar la raíz del directorio actual (`git rev-parse --show-toplevel`).

Esta skill se invoca **sin argumentos**: Claude Code sustituye los marcadores
`$1`, `$2`... del texto de la skill por los argumentos, y por eso el bloque no
los usa.

```bash
# Raíz del directorio de trabajo actual (repo principal o worktree)
TOPLEVEL=$(git rev-parse --show-toplevel)

# Carpeta de proyecto de Claude: la ruta con lo no alfanumérico cambiado por "-"
CARPETA="$HOME/.claude/projects/$(printf '%s' "$TOPLEVEL" | sed -E 's/[^A-Za-z0-9]/-/g')"

# Sesión actual = .jsonl modificado más recientemente en esa carpeta
SESSION_FILE=$(ls -t "$CARPETA"/*.jsonl 2>/dev/null | head -1)

if [ -z "$SESSION_FILE" ]; then
  echo "No se encontró ningún .jsonl en: $CARPETA"; exit 1
fi

# Destino dentro del repo (relativo a la raíz donde se ejecuta la sesión)
mkdir -p "$TOPLEVEL/09_Conversaciones"
DEST="$TOPLEVEL/09_Conversaciones/$(date +%Y-%m-%d)_$(basename "$SESSION_FILE")"
cp "$SESSION_FILE" "$DEST"
echo "Copiado: $SESSION_FILE -> $DEST"
```

Reglas:

- Es una copia: el original en `~/.claude/projects/...` no se toca.
- Antes de copiar, muestra al usuario qué archivo se eligió (nombre y fecha de
  modificación). Si hay varios `.jsonl` con fechas cercanas y hay duda de cuál
  es la sesión actual, pregunta.
- `09_Conversaciones/` está en `.gitignore`: el `.jsonl` copiado **no se
  versiona** ni se sube a GitHub. No lo agregues con `git add -f`.
- Copia el `.jsonl` al final de la sesión, para que incluya lo más reciente de
  la conversación.
- Si no existe la carpeta de proyecto o no hay `.jsonl`, informa al usuario en
  vez de improvisar otra ruta.

## Cierre

Termina con un reporte corto: ruta del `.jsonl` copiado, el hash y mensaje del
commit, la rama a la que se hizo push (o por qué no se hizo) y los siguientes
objetivos que dejó `HANDOFF.md`. Si el integrante quiere llevar los cambios a
`main`, recuérdale que se hace aparte, con un pull request desde su rama.

@echo off
setlocal EnableDelayedExpansion

REM === Configuración ===
set "REPO_URL=https://github.com/Alberthoma/Contable.git"
set "COMMIT_MSG=Publicacion inicial de la app contable"

echo ================================
echo   Publicar Contable en GitHub
echo   Repo: %REPO_URL%
echo ================================
echo.

REM --- 1) Verificar Git instalado ---
git --version >nul 2>&1
if errorlevel 1 (
  echo [ERROR] No se encontro Git. Instala Git (https://git-scm.com/) y vuelve a intentar.
  pause
  exit /b 1
)

REM --- 2) Verificar que index.html exista ---
if not exist "index.html" (
  echo [ADVERTENCIA] No se encontro index.html en esta carpeta.
  echo Asegurate de ejecutar este .bat dentro de la carpeta del proyecto.
  pause
  REM No salimos por si quiere subir otros archivos, pero lo recomendamos.
)

REM --- 3) Inicializar repo local (si no lo está) ---
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  echo Inicializando repositorio local...
  git init
)

REM --- 4) Preparar commit inicial/actualizacion ---
echo Agregando archivos...
git add -A

REM Si no hay nada que commitear, lo avisamos, pero intentamos seguir
git diff --cached --quiet
if errorlevel 1 (
  echo Realizando commit...
  git commit -m "%COMMIT_MSG%"
) else (
  echo No hay cambios nuevos para commit. Continuando...
)

REM --- 5) Forzar rama main local ---
git branch -M main

REM --- 6) Configurar remoto origin al repo correcto ---
for /f "tokens=*" %%r in ('git remote') do set HASREMOTE=1
if not defined HASREMOTE (
  git remote add origin "%REPO_URL%"
) else (
  git remote set-url origin "%REPO_URL%"
)

REM --- 7) Detectar si el remoto esta vacio (sin ramas) ---
for /f %%A in ('git ls-remote --heads origin ^| find /c /v ""') do set HEADCOUNT=%%A
if "%HEADCOUNT%"=="0" (
  echo Remoto vacio: empujando main por primera vez...
  git push -u origin main
  if errorlevel 1 (
    echo [ERROR] Fallo el push inicial al remoto vacio.
    echo Verifica tu acceso al repo %REPO_URL% y vuelve a intentar.
    pause
    exit /b 1
  )
) else (
  echo Remoto con historial: alineando y subiendo...
  git fetch origin

  REM Intentar rebase con main; si no existe, probar master
  git ls-remote --heads origin refs/heads/main >nul 2>&1
  if errorlevel 1 (
    echo No se detecto rama remota main, probando con master...
    git pull --rebase origin master || (
      echo [ADVERTENCIA] No se pudo rebasear con master. Intentando continuar...
    )
  ) else (
    git pull --rebase origin main || (
      echo [ADVERTENCIA] No se pudo rebasear con main. Intentando continuar...
    )
  )

  git push -u origin main
  if errorlevel 1 (
    echo [ERROR] Fallo el push a origin/main.
    echo Sugerencia: si ves "unrelated histories", ejecuta manualmente:
    echo   git pull --rebase --allow-unrelated-histories origin main
    echo y luego vuelve a ejecutar este .bat
    pause
    exit /b 1
  )
)

echo.
echo ✅ Listo. Revisa tu repo: %REPO_URL%
echo.
echo Para publicar en GitHub Pages:
echo 1) Entra a Settings -> Pages.
echo 2) Source: "Deploy from a branch".
echo 3) Branch: main y "/" (root). Save.
echo 4) Abre la URL que aparecera (ej.: https://alberthoma.github.io/Contable/).
echo.
pause

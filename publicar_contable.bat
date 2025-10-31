@echo off
setlocal EnableDelayedExpansion
title Publicar cambios de Contable

echo ================================
echo    PUBLICAR CAMBIOS EN GITHUB
echo ================================

REM --- Configuración ---
set "REPO_URL=https://github.com/Alberthoma/Contable.git"
set "BRANCH=main"
set "MENSAJE=Actualizacion automatica %date% %time%"

REM --- 1. Verificar Git ---
git --version >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Git no esta instalado o no se reconoce el comando.
  echo Descargalo desde https://git-scm.com/
  pause
  exit /b
)

REM --- 2. Asegurar que estas en el repo correcto ---
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  echo No hay repositorio Git en esta carpeta. Inicializando...
  git init
  git branch -M %BRANCH%
  git remote add origin %REPO_URL%
)

REM --- 3. Agregar todos los cambios ---
echo.
echo Agregando archivos modificados...
git add -A

REM --- 4. Crear commit ---
git diff --cached --quiet
if %errorlevel%==1 (
  echo Creando commit: %MENSAJE%
  git commit -m "%MENSAJE%"
) else (
  echo No hay cambios nuevos para guardar.
)

REM --- 5. Subir al remoto ---
echo.
echo Subiendo cambios a GitHub...
git push origin %BRANCH%
if errorlevel 1 (
  echo [ERROR] No se pudo subir. Verifica tu conexion o token.
  pause
  exit /b
)

echo.
echo ✅ Cambios publicados correctamente.
echo Si ya activaste GitHub Pages, se actualizara en pocos minutos.
echo URL: https://alberthoma.github.io/Contable/
echo.
pause


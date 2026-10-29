@echo off
setlocal
cd /d "%~dp0"

where node >nul 2>&1
if errorlevel 1 (
  echo ERROR: No se encontro Node.js.
  echo Instala Node.js 20 o superior y vuelve a intentarlo.
  pause
  exit /b 1
)

if not exist ".env" (
  copy ".env.example" ".env" >nul
  echo Se creo .env a partir de .env.example.
  echo Para usar el chat de IA, edita .env y configura AI_API_KEY.
  echo No compartas ese archivo ni lo subas a GitHub.
)

echo.
echo Iniciando Norteño Studio AI...
echo Se abrira el navegador en http://127.0.0.1:4173
echo Para detener el servidor, cierra la ventana del servidor.
echo.

start "Norteño Studio AI - Servidor" cmd /k "cd /d ""%~dp0"" && npm start"
timeout /t 3 /nobreak >nul
start "" "http://127.0.0.1:4173"
endlocal

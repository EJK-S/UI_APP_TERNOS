Guía para Colaboradores
¡Bienvenido al proyecto! Para mantener un flujo de trabajo ordenado, sigue estos pasos para subir tus avances.

1. Clonar el Repositorio (Solo la primera vez)
Si es la primera vez que trabajas en el proyecto, necesitas descargar (clonar) el repositorio a tu computadora.

# Reemplaza la URL por la URL HTTPS de este repositorio (la encuentras en el botón verde "Code")
git clone https:https://github.com/EJK-S/Aplicaci-n_Venta_Alquiler_Ternos.git

# Una vez clonado, entra a la carpeta del proyecto
cd nombre-del-repo
nota: No hay problema si usas VSCode, puedes usar la opción New Terminal en la pestaña Terminal y allí ya tendrás la dirección de tu carpeta.

# Instala todas las dependencias de Flutter
flutter pub get
¡Listo! Ya tienes el proyecto y puedes empezar a trabajar.

2. Flujo de Trabajo Diario para Subir Cambios
Cada vez que termines una tarea o quieras guardar tu progreso en la nube, sigue estos 4 pasos.

Paso A: Sincronizar con el Repositorio Remoto
¡Importante! Antes de subir tus cambios, siempre trae la versión más reciente del proyecto desde GitHub. Esto evita conflictos.

# Trae los últimos cambios de la rama principal (main)
git pull origin main
Si hay conflictos (Git te avisará), resuélvelos en tu editor (ej. VS Code) antes de continuar.

Paso B: Añadir tus Cambios
Prepara los archivos que modificaste para "tomarles la foto" (commit).

# El "." significa "añadir todos los archivos que he cambiado"
git add .
Paso C: Crear un "Commit"
Crea un punto de guardado con un mensaje que describa qué hiciste.

# ¡Cambia el mensaje por uno descriptivo!
git commit -m "Ej: Añadido el botón de login en la pantalla de inicio"
Paso D: Subir tus Cambios a GitHub
Finalmente, envía tu "commit" a la nube para que todos puedan verlo.

# Sube tus cambios a la rama principal (main)
git push origin main
Resumen Rápido (El "Cheatsheet")
Una vez que ya tienes el proyecto clonado, tu día a día será este ciclo:

# 1. Trae los últimos cambios
git pull origin main

# 2. (Trabajas en tu código...)

# 3. Añades tus archivos
git add .

# 4. Creas el commit
git commit -m "Mi mensaje descriptivo"

# 5. Subes tus cambios
git push origin main
Este flujo de trabajo asume que todos trabajan directamente sobre la rama main.

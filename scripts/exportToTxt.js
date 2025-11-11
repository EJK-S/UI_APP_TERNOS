// scripts/exportToTxt.js

const fs = require("fs");
const path = require("path");

// Validar argumentos
if (process.argv.length < 3) {
  console.error("❌ Error: no se proporcionó el archivo de entrada.");
  process.exit(1);
}

const inputFile = process.argv[2];
const outputFile = inputFile.replace(/\.[^/.]+$/, ".txt");

try {
  // Leer archivo original
  const content = fs.readFileSync(inputFile, "utf8");

  // Guardar en nuevo archivo .txt
  fs.writeFileSync(outputFile, content);

  console.log(`✅ Archivo exportado correctamente a:\n${outputFile}`);
} catch (err) {
  console.error("❌ Error al exportar el archivo:", err.message);
  process.exit(1);
}

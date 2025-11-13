// prisma.config.ts
import dotenv from "dotenv";
dotenv.config({ path: ".env", override: true }); // ← fuerza usar tu .env

import { defineConfig } from "@prisma/config";

export default defineConfig({
  schema: "./prisma/schema.prisma",
});

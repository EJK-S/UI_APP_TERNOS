import express from "express";
import cors from "cors";
import morgan from "morgan";
import helmet from "helmet";
import rateLimit from "express-rate-limit";
import clientesRouter from "./routes/clientes.routes.js";
import citaRouter from "./routes/cita.routes.js";
import { errorHandler, notFound } from "./middlewares/error.js";
import swaggerUi from "swagger-ui-express";
import swaggerSpec from "./docs/swagger.js";

const app = express();

const allowed = (process.env.CORS_ORIGIN || "").split(",").map(s => s.trim()).filter(Boolean);
app.use(cors({
  origin: (origin, cb) => {
    if (!origin || allowed.length === 0 || allowed.includes(origin)) return cb(null, true);
    return cb(new Error("CORS not allowed"), false);
  },
  credentials: true
}));

app.use(helmet());
app.use(morgan("dev"));
app.use(express.json());

const limiter = rateLimit({
  windowMs: Number(process.env.RATE_LIMIT_WINDOW_MS || 60000),
  max: Number(process.env.RATE_LIMIT_MAX || 100)
});
app.use(limiter);

app.set('json replacer', (_, v) => (typeof v === 'bigint' ? v.toString() : v));

app.get("/api/health", (_req, res) => {
  res.json({ ok: true, service: "api_ternos", ts: new Date().toISOString() });
});

app.use("/api/clientes", clientesRouter);
app.use("/api/citas", citaRouter);

app.use("/api/docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.use(notFound);
app.use(errorHandler);

export default app;

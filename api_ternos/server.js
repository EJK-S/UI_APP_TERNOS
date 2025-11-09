import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import clienteRoutes from './src/routes/cliente.routes.js';

dotenv.config();
const app = express();

/**
 * CORS: permite localhost en cualquier puerto (Flutter Web usa 51xxx/52xxx)
 * y 127.0.0.1. Ajusta/añade dominios reales cuando despliegues.
 */
const allowedOrigins = [
  /^http:\/\/localhost:\d+$/,
  /^http:\/\/127\.0\.0\.1:\d+$/,
];
const corsOptions = {
  origin(origin, callback) {
    // peticiones sin origin (Postman/cURL) -> permitir
    if (!origin) return callback(null, true);
    if (allowedOrigins.some((rx) => rx.test(origin))) return callback(null, true);
    return callback(new Error(`CORS: Origin no permitido -> ${origin}`), false);
  },
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: false,
};

app.use(cors(corsOptions));
// Preflight global (recomendado para PUT/PATCH/DELETE desde navegador)
app.options('*', cors(corsOptions));

// Body parser JSON
app.use(express.json({ limit: '1mb' }));

// Healthcheck
app.get('/api/health', (_req, res) => res.json({ ok: true }));

// Rutas
app.use('/api/clientes', clienteRoutes);

// 404: ruta no encontrada
app.use((req, res, _next) => {
  res.status(404).json({ error: 'Recurso no encontrado', path: req.originalUrl });
});

// Handler de errores (incluye errores de CORS)
app.use((err, _req, res, _next) => {
  const status = err.status || 500;
  res.status(status).json({
    error: err.message || 'Error interno del servidor',
  });
});

// Arranque
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`API escuchando en http://localhost:${PORT}`);
});


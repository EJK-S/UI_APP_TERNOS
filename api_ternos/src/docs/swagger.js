import swaggerJSDoc from "swagger-jsdoc";

const servers = (process.env.SWAGGER_SERVERS || "http://localhost:3000/api")
  .split(",")
  .map(s => ({ url: s.trim() }))
  .filter(s => !!s.url);

const options = {
  definition: {
    openapi: "3.0.3",
    info: { title: "API Ternos — Clientes", version: "1.0.0" },
    servers, // 👈 dinámico por env
  },
  apis: [],
};

export default swaggerJSDoc(options);

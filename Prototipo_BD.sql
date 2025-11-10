-- =========================================================
-- CREACIÓN DEL ESQUEMA BASE
-- =========================================================

-- 1️⃣ Crea el esquema (puedes cambiar el nombre si deseas)
CREATE DATABASE IF NOT EXISTS db_ternos
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

-- 2️⃣ Usa el esquema
USE db_ternos;

/* =========================================================
   GESTIÓN DE TERNOS – ESQUEMA MEJORADO (MySQL 8+)
   - Catálogos (no ENUM)
   - Auditoría created_by/updated_by/updated_at
   - Pagos con FK estricta (por tipo)
   - Tipos de cambio + snapshot al calcular montos
   - Triggers de negocio y Vistas de consulta
   ========================================================= */

SET NAMES utf8mb4;

-- =========================
-- MAESTROS / CATÁLOGOS
-- =========================
CREATE TABLE cat_moneda (
  id TINYINT PRIMARY KEY,
  codigo CHAR(3) NOT NULL UNIQUE  -- 'PEN','USD'
) ENGINE=InnoDB;
INSERT INTO cat_moneda (id, codigo) VALUES
(1,'PEN'),(2,'USD');

CREATE TABLE cat_metodo_pago (
  id TINYINT PRIMARY KEY,
  nombre VARCHAR(20) UNIQUE
) ENGINE=InnoDB;
INSERT INTO cat_metodo_pago (id,nombre) VALUES
(1,'EFECTIVO'),(2,'YAPE'),(3,'PLIN'),(4,'TARJETA'),(5,'TRANSFERENCIA');

-- consultar para su edición
CREATE TABLE cat_tipo_prenda (
  id TINYINT PRIMARY KEY,
  nombre VARCHAR(20) UNIQUE
) ENGINE=InnoDB;
INSERT INTO cat_tipo_prenda VALUES
(1,'TERNO'),(2,'SACO'),(3,'PANTALON'),(4,'CAMISA'),(5,'ACCESORIO'),(6,'OTRO');

/*
-- consultar para saber si se implementa o no
CREATE TABLE cat_tipo_evento (
  id TINYINT PRIMARY KEY,
  nombre VARCHAR(20) UNIQUE
) ENGINE=InnoDB;
INSERT INTO cat_tipo_evento VALUES
(1,'BODA'),(2,'PROM'),(3,'GALA'),(4,'OTRO');*/

CREATE TABLE cat_condicion_articulo (
  id TINYINT PRIMARY KEY,
  nombre VARCHAR(20) UNIQUE
) ENGINE=InnoDB;
INSERT INTO cat_condicion_articulo VALUES
(1,'NUEVO'),(2,'USADO'),(3,'REACONDICIONADO');

CREATE TABLE cat_estado_articulo (
  id TINYINT PRIMARY KEY,
  nombre VARCHAR(20) UNIQUE
) ENGINE=InnoDB;
INSERT INTO cat_estado_articulo VALUES
(1,'DISPONIBLE'),(2,'RESERVADO'),(3,'ALQUILADO'),(4,'VENDIDO'),(5,'INACTIVO');

CREATE TABLE cat_proposito_cita (
  id TINYINT PRIMARY KEY,
  nombre VARCHAR(20) UNIQUE
) ENGINE=InnoDB;
INSERT INTO cat_proposito_cita VALUES
(1,'PRUEBA'),(2,'MEDIDAS'),(3,'ASESORIA'),(4,'OTRO');

CREATE TABLE cat_estado_cita (
  id TINYINT PRIMARY KEY,
  nombre VARCHAR(20) UNIQUE
) ENGINE=InnoDB;
INSERT INTO cat_estado_cita VALUES
(1,'PENDIENTE'),(2,'ASISTIO'),(3,'CANCELADA'),(4,'NO_ASISTIO');

CREATE TABLE cat_estado_alquiler (
  id TINYINT PRIMARY KEY,
  nombre VARCHAR(20) UNIQUE
) ENGINE=InnoDB;
INSERT INTO cat_estado_alquiler VALUES
(1,'ACTIVO'),(2,'FINALIZADO'),(3,'CANCELADO'),(4,'INCUMPLIDO');

CREATE TABLE cat_estado_devolucion (
  id TINYINT PRIMARY KEY,
  nombre VARCHAR(20) UNIQUE
) ENGINE=InnoDB;
INSERT INTO cat_estado_devolucion VALUES
(1,'COMPLETA'),(2,'INCOMPLETA'),(3,'DANIADO'),(4,'PERDIDO');

-- =========================
-- USUARIOS APP (auditoría)
-- =========================
CREATE TABLE app_user (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  nombre   VARCHAR(80) NOT NULL,
  username VARCHAR(40) NOT NULL UNIQUE,
  pin_hash VARCHAR(125) NOT NULL,
  activo   TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- hasta acá llegué

-- =========================
-- PARAMETROS & TIPO CAMBIO
-- =========================
CREATE TABLE parametros (
  id               TINYINT PRIMARY KEY,
  garantia_pen     DECIMAL(10,2) NOT NULL DEFAULT 150.00,
  mora_diaria_usd  DECIMAL(10,2) NOT NULL DEFAULT 10.00,
  mora_tope_pen    DECIMAL(10,2) NOT NULL DEFAULT 150.00,
  prolong_sem_usd  DECIMAL(10,2) NOT NULL DEFAULT 25.00,
  updated_at       TIMESTAMP NOT NULL
     DEFAULT CURRENT_TIMESTAMP
     ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT ck_param_single CHECK (id=1)
) ENGINE=InnoDB;
INSERT INTO parametros (id) VALUES (1)
ON DUPLICATE KEY UPDATE id=id;

CREATE TABLE tipo_cambio (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  fecha DATE NOT NULL,
  base_moneda_id TINYINT NOT NULL,
  contra_moneda_id TINYINT NOT NULL,
  tasa DECIMAL(18,6) NOT NULL, -- ej: USD->PEN
  UNIQUE KEY uq_tc (fecha, base_moneda_id, contra_moneda_id),
  CONSTRAINT fk_tc_base  FOREIGN KEY (base_moneda_id)  REFERENCES cat_moneda(id),
  CONSTRAINT fk_tc_quote FOREIGN KEY (contra_moneda_id) REFERENCES cat_moneda(id)
) ENGINE=InnoDB;

-- =========================
-- CLIENTE & CITA
-- =========================
CREATE TABLE cliente (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  nombres   VARCHAR(60) NOT NULL,
  apellidos VARCHAR(60) NOT NULL,
  celular   VARCHAR(20),
  direccion VARCHAR(120),
  dni       VARCHAR(15),
  correo    VARCHAR(100),
  fecha_nac DATE,
  vetado    TINYINT(1) NOT NULL DEFAULT 0,
  motivo_veto VARCHAR(200),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_cliente_dni (dni)
) ENGINE=InnoDB;

CREATE TABLE cita (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  cliente_id BIGINT NOT NULL,
  fecha_hora DATETIME NOT NULL,
  proposito_id TINYINT NOT NULL,
  estado_id TINYINT NOT NULL,
  notas VARCHAR(200),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_cita_cliente (cliente_id),
  CONSTRAINT fk_cita_cliente FOREIGN KEY (cliente_id) REFERENCES cliente(id),
  CONSTRAINT fk_cita_proposito FOREIGN KEY (proposito_id) REFERENCES cat_proposito_cita(id),
  CONSTRAINT fk_cita_estado FOREIGN KEY (estado_id) REFERENCES cat_estado_cita(id)
) ENGINE=InnoDB;

-- =========================
-- INVENTARIO
-- =========================
CREATE TABLE articulo (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  codigo VARCHAR(50) NOT NULL UNIQUE,
  tipo_prenda_id TINYINT NOT NULL,
  modelo VARCHAR(40),
  color  VARCHAR(40),
  talla  VARCHAR(20),
  tipo_evento_id TINYINT NOT NULL,
  condicion_id   TINYINT NOT NULL,
  estado_id      TINYINT NOT NULL,
  publicado      TINYINT(1) NOT NULL DEFAULT 1,
  precio_referencial DECIMAL(10,2),
  moneda_id      TINYINT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL,
  created_by BIGINT NULL,
  updated_by BIGINT NULL,
  CONSTRAINT fk_art_prenda  FOREIGN KEY (tipo_prenda_id) REFERENCES cat_tipo_prenda(id),
  CONSTRAINT fk_art_evento  FOREIGN KEY (tipo_evento_id) REFERENCES cat_tipo_evento(id),
  CONSTRAINT fk_art_cond    FOREIGN KEY (condicion_id)   REFERENCES cat_condicion_articulo(id),
  CONSTRAINT fk_art_estado  FOREIGN KEY (estado_id)      REFERENCES cat_estado_articulo(id),
  CONSTRAINT fk_art_moneda  FOREIGN KEY (moneda_id)      REFERENCES cat_moneda(id),
  CONSTRAINT fk_art_cby     FOREIGN KEY (created_by)     REFERENCES app_user(id),
  CONSTRAINT fk_art_uby     FOREIGN KEY (updated_by)     REFERENCES app_user(id)
) ENGINE=InnoDB;

-- =========================
-- ALQUILERES
-- =========================
CREATE TABLE alquiler (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  cliente_id BIGINT NOT NULL,
  fecha_alquiler DATE NOT NULL,
  fecha_prev_devolucion DATE NOT NULL,
  garantia_monto DECIMAL(10,2) NOT NULL,
  garantia_moneda_id TINYINT NOT NULL,
  garantia_estado ENUM('PENDIENTE','DEVUELTA','RETENIDA','APLICADA') NOT NULL DEFAULT 'PENDIENTE',
  metodo_pago_garantia_id TINYINT NOT NULL,
  estado_id TINYINT NOT NULL,
  observaciones VARCHAR(250),
  monto_total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  moneda_id TINYINT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL,
  created_by BIGINT NULL,
  updated_by BIGINT NULL,
  KEY idx_alq_cliente (cliente_id),
  KEY idx_alq_estado (estado_id),
  CONSTRAINT fk_alq_cliente  FOREIGN KEY (cliente_id) REFERENCES cliente(id),
  CONSTRAINT fk_alq_moneda   FOREIGN KEY (moneda_id) REFERENCES cat_moneda(id),
  CONSTRAINT fk_alq_gmoneda  FOREIGN KEY (garantia_moneda_id) REFERENCES cat_moneda(id),
  CONSTRAINT fk_alq_metpg    FOREIGN KEY (metodo_pago_garantia_id) REFERENCES cat_metodo_pago(id),
  CONSTRAINT fk_alq_estado   FOREIGN KEY (estado_id) REFERENCES cat_estado_alquiler(id),
  CONSTRAINT fk_alq_cby      FOREIGN KEY (created_by) REFERENCES app_user(id),
  CONSTRAINT fk_alq_uby      FOREIGN KEY (updated_by) REFERENCES app_user(id)
) ENGINE=InnoDB;

CREATE TABLE alquiler_item (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  alquiler_id BIGINT NOT NULL,
  articulo_id BIGINT NOT NULL,
  precio_alq DECIMAL(10,2) NOT NULL,
  moneda_id TINYINT NOT NULL,
  entregado TINYINT(1) NOT NULL DEFAULT 0,
  devuelto  TINYINT(1) NOT NULL DEFAULT 0,
  UNIQUE KEY uq_ai (alquiler_id, articulo_id),
  KEY idx_ai_art (articulo_id),
  CONSTRAINT fk_ai_alq FOREIGN KEY (alquiler_id) REFERENCES alquiler(id) ON DELETE CASCADE,
  CONSTRAINT fk_ai_art FOREIGN KEY (articulo_id) REFERENCES articulo(id),
  CONSTRAINT fk_ai_mon FOREIGN KEY (moneda_id)   REFERENCES cat_moneda(id)
) ENGINE=InnoDB;

CREATE TABLE devolucion (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  alquiler_id BIGINT NOT NULL,
  articulo_id BIGINT NOT NULL,
  fecha_recep DATE NOT NULL,
  estado_id TINYINT NOT NULL,
  notas VARCHAR(200),
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_dev (alquiler_id, articulo_id),
  KEY idx_dev_art (articulo_id),
  CONSTRAINT fk_dev_alq FOREIGN KEY (alquiler_id) REFERENCES alquiler(id) ON DELETE CASCADE,
  CONSTRAINT fk_dev_art FOREIGN KEY (articulo_id) REFERENCES articulo(id),
  CONSTRAINT fk_dev_estado FOREIGN KEY (estado_id) REFERENCES cat_estado_devolucion(id)
) ENGINE=InnoDB;

CREATE TABLE mora (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  alquiler_id BIGINT NOT NULL,
  dia_mora INT NOT NULL,
  monto_usd DECIMAL(10,2) NOT NULL,
  fx_usd_pen DECIMAL(18,6) NOT NULL,
  monto_pen_aplicado DECIMAL(10,2) NOT NULL,
  generado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_mora (alquiler_id, dia_mora),
  CONSTRAINT fk_mora_alq FOREIGN KEY (alquiler_id) REFERENCES alquiler(id) ON DELETE CASCADE,
  CONSTRAINT ck_mora_dia CHECK (dia_mora >= 1)
) ENGINE=InnoDB;

CREATE TABLE prolongacion (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  alquiler_id BIGINT NOT NULL,
  semanas INT NOT NULL,
  monto_usd DECIMAL(10,2) NOT NULL,
  fx_usd_pen DECIMAL(18,6) NOT NULL,
  monto_pen DECIMAL(10,2) NOT NULL,
  fecha DATE NOT NULL,
  CONSTRAINT fk_prol_alq FOREIGN KEY (alquiler_id) REFERENCES alquiler(id) ON DELETE CASCADE,
  CONSTRAINT ck_prol_sem CHECK (semanas >= 1)
) ENGINE=InnoDB;

-- =========================
-- VENTAS
-- =========================
CREATE TABLE venta (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  cliente_id BIGINT NULL,
  alquiler_id BIGINT NULL,                 -- venta ligada a alquiler (opcional)
  fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  metodo_pago_id TINYINT NOT NULL,
  desc_por_comp_de_alquiler TINYINT(1) NOT NULL DEFAULT 0,
  monto_descuento DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  moneda_descuento_id TINYINT NOT NULL,
  observaciones VARCHAR(200),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL,
  created_by BIGINT NULL,
  updated_by BIGINT NULL,
  KEY idx_vta_cli (cliente_id),
  KEY idx_vta_alq (alquiler_id),
  CONSTRAINT fk_vta_cli FOREIGN KEY (cliente_id) REFERENCES cliente(id) ON DELETE SET NULL,
  CONSTRAINT fk_vta_alq FOREIGN KEY (alquiler_id) REFERENCES alquiler(id) ON DELETE SET NULL,
  CONSTRAINT fk_vta_met FOREIGN KEY (metodo_pago_id) REFERENCES cat_metodo_pago(id),
  CONSTRAINT fk_vta_mon FOREIGN KEY (moneda_descuento_id) REFERENCES cat_moneda(id),
  CONSTRAINT fk_vta_cby FOREIGN KEY (created_by) REFERENCES app_user(id),
  CONSTRAINT fk_vta_uby FOREIGN KEY (updated_by) REFERENCES app_user(id)
) ENGINE=InnoDB;

CREATE TABLE venta_item (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  venta_id BIGINT NOT NULL,
  articulo_id BIGINT NOT NULL,
  precio_unit DECIMAL(10,2) NOT NULL,
  moneda_id TINYINT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_vi (venta_id, articulo_id),
  KEY idx_vi_art (articulo_id),
  CONSTRAINT fk_vi_vta FOREIGN KEY (venta_id) REFERENCES venta(id) ON DELETE CASCADE,
  CONSTRAINT fk_vi_art FOREIGN KEY (articulo_id) REFERENCES articulo(id),
  CONSTRAINT fk_vi_mon FOREIGN KEY (moneda_id) REFERENCES cat_moneda(id)
) ENGINE=InnoDB;

-- =========================
-- PAGOS (con FK estricta)
-- =========================
CREATE TABLE pago_venta (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  venta_id BIGINT NOT NULL,
  metodo_pago_id TINYINT NOT NULL,
  monto DECIMAL(10,2) NOT NULL,
  moneda_id TINYINT NOT NULL,
  fecha_pago DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  notas VARCHAR(200),
  CONSTRAINT fk_pvt_vta FOREIGN KEY (venta_id) REFERENCES venta(id) ON DELETE CASCADE,
  CONSTRAINT fk_pvt_met FOREIGN KEY (metodo_pago_id) REFERENCES cat_metodo_pago(id),
  CONSTRAINT fk_pvt_mon FOREIGN KEY (moneda_id) REFERENCES cat_moneda(id)
) ENGINE=InnoDB;

CREATE TABLE pago_alquiler (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  alquiler_id BIGINT NOT NULL,
  metodo_pago_id TINYINT NOT NULL,
  monto DECIMAL(10,2) NOT NULL,
  moneda_id TINYINT NOT NULL,
  fecha_pago DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  notas VARCHAR(200),
  CONSTRAINT fk_pal_alq FOREIGN KEY (alquiler_id) REFERENCES alquiler(id) ON DELETE CASCADE,
  CONSTRAINT fk_pal_met FOREIGN KEY (metodo_pago_id) REFERENCES cat_metodo_pago(id),
  CONSTRAINT fk_pal_mon FOREIGN KEY (moneda_id) REFERENCES cat_moneda(id)
) ENGINE=InnoDB;

CREATE TABLE pago_garantia (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  alquiler_id BIGINT NOT NULL,
  metodo_pago_id TINYINT NOT NULL,
  monto DECIMAL(10,2) NOT NULL,
  moneda_id TINYINT NOT NULL,
  fecha_pago DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  notas VARCHAR(200),
  CONSTRAINT fk_pga_alq FOREIGN KEY (alquiler_id) REFERENCES alquiler(id) ON DELETE CASCADE,
  CONSTRAINT fk_pga_met FOREIGN KEY (metodo_pago_id) REFERENCES cat_metodo_pago(id),
  CONSTRAINT fk_pga_mon FOREIGN KEY (moneda_id) REFERENCES cat_moneda(id)
) ENGINE=InnoDB;

CREATE TABLE pago_mora (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  mora_id BIGINT NOT NULL,
  metodo_pago_id TINYINT NOT NULL,
  monto DECIMAL(10,2) NOT NULL,
  moneda_id TINYINT NOT NULL,
  fecha_pago DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  notas VARCHAR(200),
  CONSTRAINT fk_pmo_mora FOREIGN KEY (mora_id) REFERENCES mora(id) ON DELETE CASCADE,
  CONSTRAINT fk_pmo_met  FOREIGN KEY (metodo_pago_id) REFERENCES cat_metodo_pago(id),
  CONSTRAINT fk_pmo_mon  FOREIGN KEY (moneda_id) REFERENCES cat_moneda(id)
) ENGINE=InnoDB;

CREATE TABLE pago_prolongacion (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  prolongacion_id BIGINT NOT NULL,
  metodo_pago_id TINYINT NOT NULL,
  monto DECIMAL(10,2) NOT NULL,
  moneda_id TINYINT NOT NULL,
  fecha_pago DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  notas VARCHAR(200),
  CONSTRAINT fk_ppr_prol FOREIGN KEY (prolongacion_id) REFERENCES prolongacion(id) ON DELETE CASCADE,
  CONSTRAINT fk_ppr_met  FOREIGN KEY (metodo_pago_id) REFERENCES cat_metodo_pago(id),
  CONSTRAINT fk_ppr_mon  FOREIGN KEY (moneda_id) REFERENCES cat_moneda(id)
) ENGINE=InnoDB;

-- =========================
-- TRIGGERS DE NEGOCIO
-- =========================

/* 1) Al añadir un alquiler_item (primera vez para ese artículo no vendido),
      marcar el artículo como RESERVADO (2) o ALQUILADO (3) al entregarse.
*/
DELIMITER $$
CREATE TRIGGER trg_ai_after_insert
AFTER INSERT ON alquiler_item
FOR EACH ROW
BEGIN
  -- Si aún no está vendido, pasar a RESERVADO
  UPDATE articulo
     SET estado_id = 2, updated_at = NOW()
   WHERE id = NEW.articulo_id AND estado_id <> 4;
END$$

CREATE TRIGGER trg_ai_after_update_entrega
AFTER UPDATE ON alquiler_item
FOR EACH ROW
BEGIN
  IF NEW.entregado = 1 AND OLD.entregado = 0 THEN
    UPDATE articulo
       SET estado_id = 3, updated_at = NOW()
     WHERE id = NEW.articulo_id AND estado_id <> 4;
  END IF;
END$$

/* 2) Al registrar una devolución completa, marcar devuelto=1 y, si no hay
      otras rentas abiertas del mismo artículo, volver a DISPONIBLE (1). */
CREATE TRIGGER trg_devolucion_after_insert
AFTER INSERT ON devolucion
FOR EACH ROW
BEGIN
  UPDATE alquiler_item
     SET devuelto = 1
   WHERE alquiler_id = NEW.alquiler_id
     AND articulo_id = NEW.articulo_id;

  -- ¿Quedan alquileres activos (no devueltos) para el artículo?
  IF NOT EXISTS (
      SELECT 1 FROM alquiler_item ai
      JOIN alquiler al ON al.id = ai.alquiler_id
      WHERE ai.articulo_id = NEW.articulo_id
        AND ai.devuelto = 0
        AND al.estado_id = 1  -- ACTIVO
    )
  THEN
    UPDATE articulo
       SET estado_id = 1, updated_at = NOW() -- DISPONIBLE
     WHERE id = NEW.articulo_id AND estado_id <> 4;
  END IF;
END$$

/* 3) Al insertar un venta_item, marcar artículo como VENDIDO (4) y publicado=0 */
CREATE TRIGGER trg_vi_after_insert
AFTER INSERT ON venta_item
FOR EACH ROW
BEGIN
  UPDATE articulo
     SET estado_id = 4, publicado = 0, updated_at = NOW()
   WHERE id = NEW.articulo_id;
END$$

/* 4) MORA: antes de insertar, calcular monto_usd (param), tasa usd->pen del día
      y aplicar tope acumulado (param.mora_tope_pen) */
CREATE TRIGGER trg_mora_before_insert
BEFORE INSERT ON mora
FOR EACH ROW
BEGIN
  DECLARE v_mora_usd DECIMAL(10,2);
  DECLARE v_fx DECIMAL(18,6);
  DECLARE v_tope DECIMAL(10,2);
  DECLARE v_acum DECIMAL(10,2);

  -- parámetros
  SELECT mora_diaria_usd, mora_tope_pen INTO v_mora_usd, v_tope FROM parametros WHERE id=1;

  -- tasa del día; si falta, usa la última disponible
  SELECT tasa INTO v_fx
    FROM tipo_cambio
   WHERE fecha = CURDATE() AND base_moneda_id = 2 AND contra_moneda_id = 1
   ORDER BY id DESC LIMIT 1;

  IF v_fx IS NULL THEN
    SELECT tasa INTO v_fx
      FROM tipo_cambio
     WHERE base_moneda_id = 2 AND contra_moneda_id = 1
     ORDER BY fecha DESC, id DESC LIMIT 1;
  END IF;

  IF v_fx IS NULL THEN SET v_fx = 3.80; END IF; -- fallback seguro

  -- snapshot
  SET NEW.monto_usd = v_mora_usd;
  SET NEW.fx_usd_pen = v_fx;

  -- acumulado previo en PEN
  SELECT IFNULL(SUM(monto_pen_aplicado),0) INTO v_acum
    FROM mora WHERE alquiler_id = NEW.alquiler_id;

  -- aplicar tope
  SET NEW.monto_pen_aplicado = LEAST( (v_mora_usd * v_fx), GREATEST(v_tope - v_acum, 0) );
END$$

/* 5) PROLONGACION: calcular monto por semanas con snapshot de TC */
CREATE TRIGGER trg_prol_before_insert
BEFORE INSERT ON prolongacion
FOR EACH ROW
BEGIN
  DECLARE v_sem DECIMAL(10,2);
  DECLARE v_fx DECIMAL(18,6);

  SELECT prolong_sem_usd INTO v_sem FROM parametros WHERE id=1;

  SELECT tasa INTO v_fx
    FROM tipo_cambio
   WHERE fecha = CURDATE() AND base_moneda_id = 2 AND contra_moneda_id = 1
   ORDER BY id DESC LIMIT 1;

  IF v_fx IS NULL THEN
    SELECT tasa INTO v_fx
      FROM tipo_cambio
     WHERE base_moneda_id = 2 AND contra_moneda_id = 1
     ORDER BY fecha DESC, id DESC LIMIT 1;
  END IF;

  IF v_fx IS NULL THEN SET v_fx = 3.80; END IF;

  SET NEW.monto_usd = (NEW.semanas * v_sem);
  SET NEW.fx_usd_pen = v_fx;
  SET NEW.monto_pen = NEW.monto_usd * v_fx;
END$$
DELIMITER ;

-- =========================
-- VISTAS
-- =========================

/* Alquileres activos con totales de mora/prolongaciones (PEN) */
CREATE OR REPLACE VIEW vw_alquileres_activos AS
SELECT
  al.id,
  al.cliente_id,
  al.fecha_alquiler,
  al.fecha_prev_devolucion,
  al.monto_total,
  SUM(IFNULL(m.monto_pen_aplicado,0)) AS total_mora_pen,
  SUM(IFNULL(p.monto_pen,0)) AS total_prolong_pen
FROM alquiler al
LEFT JOIN mora m ON m.alquiler_id = al.id
LEFT JOIN prolongacion p ON p.alquiler_id = al.id
WHERE al.estado_id = 1  -- ACTIVO
GROUP BY al.id;

/* Disponibilidad: 1 si no está vendido y no tiene alquiler activo pendiente */
CREATE OR REPLACE VIEW vw_disponibilidad_articulo AS
SELECT
  a.*,
  CASE
    WHEN a.estado_id = 4 THEN 0
    WHEN EXISTS (
      SELECT 1
      FROM alquiler_item ai
      JOIN alquiler al ON al.id = ai.alquiler_id
      WHERE ai.articulo_id = a.id
        AND al.estado_id = 1   -- ACTIVO
        AND ai.devuelto = 0
    ) THEN 0
    ELSE 1
  END AS disponible
FROM articulo a;

-- ==========================================
-- ÍNDICES SUGERIDOS ADICIONALES (consultas)
-- ==========================================
CREATE INDEX idx_alq_fecha ON alquiler(fecha_alquiler, fecha_prev_devolucion);
CREATE INDEX idx_mora_alq_dia ON mora(alquiler_id, dia_mora);
CREATE INDEX idx_prol_alq_fecha ON prolongacion(alquiler_id, fecha);
CREATE INDEX idx_vta_fecha ON venta(fecha);

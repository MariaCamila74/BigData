-- =========================================
-- SCRIPT DE INSERCIONES
-- ========================================= 
-- 1 Productos
INSERT INTO productos (nombre_producto, descripcion)
VALUES
('Benceno', 'Producto que emite benceno durante su proceso de producción (alto riesgo)'),
('Producto X', 'Producto secundario de ejemplo');
-- 2 Fábricas (A, B, C) con ubicación ejemplo (lon, lat)
INSERT INTO fabricas (codigo_fabrica, nombre_fabrica, direccion, ciudad, pais, geom, contacto)
VALUES
('A', 'Fábrica A', 'Carrera 1 #100', 'Medellín', 'Colombia', ST_SetSRID(ST_MakePoint(-75.5636, 6.2442),4326), 'gerenciaA@slocas.com'),
('B', 'Fábrica B', 'Calle 50 #20', 'Envigado', 'Colombia', ST_SetSRID(ST_MakePoint(-75.5730, 6.2000),4326), 'gerenciaB@slocas.com'),
('C', 'Fábrica C', 'Via 45 km 3', 'Bello', 'Colombia', ST_SetSRID(ST_MakePoint(-75.5500, 6.3000),4326), 'gerenciaC@slocas.com');
-- 3 Turnos
INSERT INTO turnos (nombre_turno, hora_inicio, hora_fin, descripcion)
VALUES
('Turno 08-16', '08:00:00', '16:00:00', 'Turno diurno 8am-4pm'),
('Turno 16-00', '16:00:00', '00:00:00', 'Turno vespertino 4pm-12am'),
('Turno 00-08', '00:00:00', '08:00:00', 'Turno nocturno 12am-8am');
-- 4 Empleados y Supervisores
INSERT INTO empleados (nombre_completo, cedula, celular, email, fecha_ingreso, cargo)
VALUES
('Ana Rodríguez', '1001001001', '3001001001', 'ana.rodriguez@slocas.com', '2022-02-01', 'Supervisor de Planta'),
('Luis Martínez', '1002002002', '3002002002', 'luis.martinez@slocas.com', '2021-11-10', 'Supervisor de Planta'),
('María Fernández', '1003003003', '3003003003', 'maria.fernandez@slocas.com', '2020-06-20', 'Supervisor de Planta'),
('Diego Torres', '1004004004', '3004004004', 'diego.torres@slocas.com', '2024-01-15', 'Operario');
-- Mapear algunos empleados a supervisores (usamos IDs de empleados insertados)
INSERT INTO supervisores (id_empleado, id_turno, certificaciones)
VALUES
((SELECT id_empleado FROM empleados WHERE nombre_completo='Ana Rodríguez'), 10, 'Seguridad Industrial I'),
((SELECT id_empleado FROM empleados WHERE nombre_completo='Luis Martínez'), 11, 'Gestión Ambiental'),
((SELECT id_empleado FROM empleados WHERE nombre_completo='María Fernández'),12, 'Operación de Planta');
-- 5 Crear las 4 líneas por cada fábrica y asociarlas al producto "Benceno"
WITH p AS (SELECT id_producto FROM productos WHERE nombre_producto='Benceno' LIMIT 1)
INSERT INTO lineas_produccion (id_fabrica, id_producto, nombre_linea, fecha_instalacion, ubicacion_planta)
SELECT f.id_fabrica, p.id_producto,
       CASE WHEN f.codigo_fabrica = 'A' THEN concat('A', i, ' - Benceno')
            WHEN f.codigo_fabrica = 'B' THEN concat('B', i, ' - Benceno')
            WHEN f.codigo_fabrica = 'C' THEN concat('C', i, ' - Benceno') END,
       -- fechas de instalacion ejemplo:
       CASE WHEN i = 1 THEN DATE '2019/05/10' WHEN i = 2 THEN '2019/06/15' WHEN i = 3 THEN '2020/01/20' ELSE '2020/04/05' END,
       CASE WHEN f.codigo_fabrica = 'A' THEN 'Sector A' WHEN f.codigo_fabrica = 'B' THEN 'Sector B' ELSE 'Sector C' END
FROM (SELECT id_fabrica, codigo_fabrica FROM fabricas) f
CROSS JOIN (SELECT 1 AS i UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) seq
CROSS JOIN p;
--6 Tipos de filtro 
INSERT INTO tipos_filtro (nombre_tipo, vida_estimada_dias, costo_usd)
VALUES
('Filtro Carbón Activo - Estándar', 15, 300.00),
('Filtro HEPA - Industrial', 20, 450.00);
-- 7 Instalar 1 filtro por línea
INSERT INTO filtros (id_linea, id_tipo_filtro, codigo_filtro, fecha_instalacion, fecha_vencimiento, dias_uso_recomendado, proveedor)
SELECT l.id_linea, (SELECT id_tipo_filtro FROM tipos_filtro WHERE nombre_tipo LIKE 'Filtro Carbón Activo%'), 
       concat('FILT-', l.id_linea, '-', to_char(CURRENT_DATE,'YYYYMMDD')),
       CURRENT_DATE - INTERVAL '10 day', (CURRENT_DATE - INTERVAL '10 day') + INTERVAL '7 day', 15, 'ProveedorFiltros S.A.'
FROM lineas_produccion l;
-- 8 Niveles de peligrosidad
INSERT INTO niveles_peligrosidad (nombre_nivel, ppm_minimo, ppm_maximo, color_led, codigo_color_hex, nivel_criticidad, descripcion, protocolo_accion)
VALUES
('Bajo', 0.00, 1.00, 'Verde', '#00FF00', 1, 'Dentro de tolerancia OSHA/NIOSH', 'Continuar operación. Monitorizar.'),
('Moderado', 1.01, 10.00, 'Amarillo', '#FFFF00', 2, 'Precaución', 'Aumentar ventilación; revisar filtros y sensores.'),
('Alto', 10.01, 100.00, 'Naranja', '#FFA500', 3, 'Riesgo alto', 'Notificar supervisor; preparar detención de línea.'),
('Crítico', 100.01, 2000.00, 'Rojo', '#FF0000', 5, 'Riesgo crítico', 'Evacuar área; detener línea/fábrica; notificar bomberos.');
-- 9 Tipos de alarma
INSERT INTO tipos_alarma (nombre_tipo, nivel_prioridad, requiere_detencion_linea, requiere_detencion_fabrica, requiere_llamada_bomberos, protocolo_detallado, tiempo_max_respuesta)
VALUES
('Alarma Precaución', 2, FALSE, FALSE, FALSE, 'Aumentar ventilación; revisar filtros y sensores; notificar supervisor.', 30),
('Alarma Alto', 4, TRUE, FALSE, FALSE, 'Notificar supervisor; detener línea si no baja en 5 min; inspección técnica.', 15),
('Alarma Crítica', 5, TRUE, TRUE, TRUE, 'Evacuar sector; detener fábrica; llamar bomberos y defensa civil; activar plan de emergencia.', 5);
-- 10 CREAR microcontroladores y sensores MASIVAMENTE (240 MC y 240 sensores)
-- Estructura: fábrica A,B,C; líneas i=1..4 por fabrica; microcontroladores por línea m=1..20
-- Codigo MC ex: A1M01, sensor: A1S01
-- Insert microcontroladores
DO $$
DECLARE
    fab RECORD;
    line RECORD;
    m INT;
    cod_mc TEXT;
BEGIN
  FOR fab IN SELECT codigo_fabrica, id_fabrica FROM fabricas LOOP
    FOR line IN SELECT id_linea, nombre_linea FROM lineas_produccion WHERE id_fabrica = fab.id_fabrica LOOP
      FOR m IN 1..20 LOOP
        cod_mc := fab.codigo_fabrica || substring(line.nombre_linea from 1 for 2) || 'M' || lpad(m::text,2,'0');
        INSERT INTO microcontroladores (id_linea, codigo_mc, firmware_version)
        VALUES (line.id_linea, cod_mc, 'v1.0')
        ON CONFLICT (codigo_mc) DO NOTHING;
      END LOOP;
    END LOOP;
  END LOOP;
END$$;
-- Insert sensores vinculados a microcontroladores
DO $$
DECLARE
  mc RECORD;
  cod_sens TEXT;
BEGIN
  FOR mc IN SELECT id_mc, codigo_mc, id_linea FROM microcontroladores LOOP
    cod_sens := replace(mc.codigo_mc,'M','S'); -- ejemplo: A1M01 -> A1S01
    INSERT INTO sensores (id_mc, id_linea, codigo_sensor, tipo_sensor, fecha_instalacion, precision, estado)
    VALUES (mc.id_mc, mc.id_linea, cod_sens, 'MQ-135 (calibrado para Benceno)', CURRENT_DATE - INTERVAL '400 day', 0.05, 'OPERATIVO')
    ON CONFLICT (codigo_sensor) DO NOTHING;
  END LOOP;
END$$;
-- 11 POBLAR lecturas de ejemplo 
-- Insertaremos lecturas de 5 sensores distribuidos con distintos niveles.
INSERT INTO lecturas (
    id_sensor, id_mc, id_linea, id_fabrica, id_turno, id_nivel,
    fecha_hora, concentracion_ppm, temperatura, humedad, presion_atmosferica,
    latitud, longitud, geom, payload
)
VALUES
-- SENSOR BAJO – AA1M01 → AA1S01 → TURNO 10
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'AA1S01'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'AA1M01'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'AA1M01'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='AA1M01')),
 10, 1,
 '2024-10-08 08:30:00', 0.25, 24.5, 55.0, 1012.0,
 6.2442, -75.5636, ST_SetSRID(ST_MakePoint(-75.5636,6.2442),4326),
 '{"raw":"example","sensor":"AA1S01"}'::jsonb
),
-- SENSOR MODERADO – BB2M05 → BB2S05 → TURNO 11
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'BB2S05'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'BB2M05'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'BB2M05'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='BB2M05')),
 11, 2,
 '2024-10-08 17:45:00', 5.75, 28.0, 50.0, 1009.5,
 6.2000, -75.5730, ST_SetSRID(ST_MakePoint(-75.5730,6.2000),4326),
 '{"raw":"example","sensor":"BB2S05"}'::jsonb
),
-- SENSOR ALTO – CC3M10 → CC3S10 → TURNO 10
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'CC3S10'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'CC3M10'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'CC3M10'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='CC3M10')),
 10, 3,
 '2024-10-09 15:20:00', 25.125, 30.2, 48.0, 1008.3,
 6.3000, -75.5500, ST_SetSRID(ST_MakePoint(-75.5500,6.3000),4326),
 '{"raw":"example","sensor":"CC3S10"}'::jsonb
),
-- SENSOR CRÍTICO – AA4M20 → AA4S20 → TURNO 12
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'AA4S20'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'AA4M20'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'AA4M20'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='AA4M20')),
 12, 4,
 '2024-10-10 02:10:00', 420.900, 36.0, 60.0, 1005.0,
 6.2442, -75.5636, ST_SetSRID(ST_MakePoint(-75.5636,6.2442),4326),
 '{"raw":"example","sensor":"AA4S20"}'::jsonb
);
-- ADD
INSERT INTO lecturas (
    id_sensor, id_mc, id_linea, id_fabrica, id_turno, id_nivel,
    fecha_hora, concentracion_ppm, temperatura, humedad, presion_atmosferica,
    latitud, longitud, geom, payload
)
VALUES
-- =====================================================================
--  LECTURAS 1–5  → SENSOR BAJO (AA1S01 / AA1M01)  → NIVEL 1  → TURNO 10
-- =====================================================================
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'AA1S01'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'AA1M01'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'AA1M01'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='AA1M01')),
 10, 1,
 '2024-10-08 08:30', 0.25, 24.5, 55, 1012,
 6.2442, -75.5636, ST_SetSRID(ST_MakePoint(-75.5636,6.2442),4326),
 '{"sensor":"AA1S01"}'
),
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'AA1S01'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'AA1M01'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'AA1M01'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='AA1M01')),
 10, 1,
 '2024-10-08 08:31', 0.30, 24.6, 55.2, 1011.8,
 6.2442, -75.5636, ST_SetSRID(ST_MakePoint(-75.5636,6.2442),4326),
 '{"sensor":"AA1S01"}'
),
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'AA1S01'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'AA1M01'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'AA1M01'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='AA1M01')),
 10, 1,
 '2024-10-08 08:32', 0.28, 24.5, 55.1, 1011.9,
 6.2442, -75.5636, ST_SetSRID(ST_MakePoint(-75.5636,6.2442),4326),
 '{"sensor":"AA1S01"}'
),
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'AA1S01'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'AA1M01'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'AA1M01'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='AA1M01')),
 10, 1,
 '2024-10-08 08:33', 0.32, 24.7, 55.3, 1011.7,
 6.2442, -75.5636, ST_SetSRID(ST_MakePoint(-75.5636,6.2442),4326),
 '{"sensor":"AA1S01"}'
),
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'AA1S01'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'AA1M01'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'AA1M01'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='AA1M01')),
 10, 1,
 '2024-10-08 08:34', 0.40, 24.8, 55.5, 1011.6,
 6.2442, -75.5636, ST_SetSRID(ST_MakePoint(-75.5636,6.2442),4326),
 '{"sensor":"AA1S01"}'
),
-- =====================================================================
--  LECTURAS 6–10  → SENSOR MODERADO (BB2S05 / BB2M05) → NIVEL 2 → TURNO 11
-- =====================================================================
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'BB2S05'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'BB2M05'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'BB2M05'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='BB2M05')),
 11, 2,
 '2024-10-08 09:00', 5.75, 28, 50, 1009.5,
 6.20, -75.5730, ST_SetSRID(ST_MakePoint(-75.5730,6.2000),4326),
 '{"sensor":"BB2S05"}'
),
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'BB2S05'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'BB2M05'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'BB2M05'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='BB2M05')),
 11, 2,
 '2024-10-08 09:01', 5.90, 28.1, 50.2, 1009.4,
 6.20, -75.5730, ST_SetSRID(ST_MakePoint(-75.5730,6.2000),4326),
 '{"sensor":"BB2S05"}'
),
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'BB2S05'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'BB2M05'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'BB2M05'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='BB2M05')),
 11, 2,
 '2024-10-08 09:02', 6.10, 28.2, 50.3, 1009.3,
 6.20, -75.5730, ST_SetSRID(ST_MakePoint(-75.5730,6.2000),4326),
 '{"sensor":"BB2S05"}'
),
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'BB2S05'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'BB2M05'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'BB2M05'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='BB2M05')),
 11, 2,
 '2024-10-08 09:03', 6.00, 28.2, 50.4, 1009.2,
 6.20, -75.5730, ST_SetSRID(ST_MakePoint(-75.5730,6.2000),4326),
 '{"sensor":"BB2S05"}'
),
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'BB2S05'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'BB2M05'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'BB2M05'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='BB2M05')),
 11, 2,
 '2024-10-08 09:04', 5.85, 28.1, 50.6, 1009.1,
 6.20, -75.5730, ST_SetSRID(ST_MakePoint(-75.5730,6.2000),4326),
 '{"sensor":"BB2S05"}'
),
-- =====================================================================
--  LECTURAS 11–15  → SENSOR ALTO (CC3S10 / CC3M10)  → NIVEL 3 → TURNO 10
-- =====================================================================
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'CC3S10'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'CC3M10'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'CC3M10'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='CC3M10')),
 10, 3,
 '2024-10-09 15:20', 25.12, 30.2, 48, 1008.3,
 6.30, -75.5500, ST_SetSRID(ST_MakePoint(-75.5500,6.3000),4326),
 '{"sensor":"CC3S10"}'
),
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'CC3S10'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'CC3M10'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'CC3M10'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='CC3M10')),
 10, 3,
 '2024-10-09 15:21', 26.05, 30.3, 48.1, 1008.2,
 6.30, -75.5500, ST_SetSRID(ST_MakePoint(-75.5500,6.3000),4326),
 '{"sensor":"CC3S10"}'
),
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'CC3S10'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'CC3M10'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'CC3M10'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='CC3M10')),
 10, 3,
 '2024-10-09 15:22', 24.95, 30.4, 48.2, 1008.1,
 6.30, -75.5500, ST_SetSRID(ST_MakePoint(-75.5500,6.3000),4326),
 '{"sensor":"CC3S10"}'
),
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'CC3S10'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'CC3M10'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'CC3M10'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='CC3M10')),
 10, 3,
 '2024-10-09 15:23', 25.50, 30.4, 48.3, 1008.0,
 6.30, -75.5500, ST_SetSRID(ST_MakePoint(-75.5500,6.3000),4326),
 '{"sensor":"CC3S10"}'
),
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'CC3S10'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'CC3M10'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'CC3M10'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='CC3M10')),
 10, 3,
 '2024-10-09 15:24', 27.10, 30.5, 48.5, 1007.9,
 6.30, -75.5500, ST_SetSRID(ST_MakePoint(-75.5500,6.3000),4326),
 '{"sensor":"CC3S10"}'
),
-- =====================================================================
--  LECTURAS 16–20  → SENSOR CRÍTICO (AA4S20 / AA4M20)  → NIVEL 4 → TURNO 12
-- =====================================================================
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'AA4S20'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'AA4M20'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'AA4M20'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='AA4M20')),
 12, 4,
 '2024-10-10 02:10', 420.9, 36, 60, 1005,
 6.2442, -75.5636, ST_SetSRID(ST_MakePoint(-75.5636,6.2442),4326),
 '{"sensor":"AA4S20"}'
),
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'AA4S20'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'AA4M20'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'AA4M20'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='AA4M20')),
 12, 4,
 '2024-10-10 02:11', 415.8, 36.1, 60.3, 1004.9,
 6.2442, -75.5636, ST_SetSRID(ST_MakePoint(-75.5636,6.2442),4326),
 '{"sensor":"AA4S20"}'
),
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'AA4S20'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'AA4M20'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'AA4M20'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='AA4M20')),
 12, 4,
 '2024-10-10 02:12', 430.1, 36.3, 60.5, 1004.8,
 6.2442, -75.5636, ST_SetSRID(ST_MakePoint(-75.5636,6.2442),4326),
 '{"sensor":"AA4S20"}'
),
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'AA4S20'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'AA4M20'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'AA4M20'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='AA4M20')),
 12, 4,
 '2024-10-10 02:13', 440.55, 36.5, 60.8, 1004.7,
 6.2442, -75.5636, ST_SetSRID(ST_MakePoint(-75.5636,6.2442),4326),
 '{"sensor":"AA4S20"}'
),
(
 (SELECT id_sensor FROM sensores WHERE codigo_sensor = 'AA4S20'),
 (SELECT id_mc FROM microcontroladores WHERE codigo_mc = 'AA4M20'),
 (SELECT id_linea FROM microcontroladores WHERE codigo_mc = 'AA4M20'),
 (SELECT id_fabrica FROM lineas_produccion WHERE id_linea = (SELECT id_linea FROM microcontroladores WHERE codigo_mc='AA4M20')),
 12, 4,
 '2024-10-10 02:14', 450.0, 36.6, 61, 1004.6,
 6.2442, -75.5636, ST_SetSRID(ST_MakePoint(-75.5636,6.2442),4326),
 '{"sensor":"AA4S20"}'
);
-- 12 Insertar alarmas asociadas a lecturas críticas/altas (usando subqueries)
INSERT INTO alarmas (id_lectura, id_tipo_alarma, id_supervisor, fecha_hora_alarma, estado_alarma, acciones_tomadas, tiempo_respuesta)
VALUES
(
  (SELECT id_lectura FROM lecturas WHERE concentracion_ppm >= 100 ORDER BY fecha_hora LIMIT 1),
  (SELECT id_tipo_alarma FROM tipos_alarma WHERE nombre_tipo = 'Alarma Crítica' LIMIT 1),
  (SELECT id_supervisor FROM supervisores LIMIT 1),
  NOW(),
  'ACTIVA',
  'Evacuación iniciada; notificado bomberos.',
  NULL
),
(
  (SELECT id_lectura FROM lecturas WHERE concentracion_ppm BETWEEN 10 AND 100 ORDER BY fecha_hora LIMIT 1),
  (SELECT id_tipo_alarma FROM tipos_alarma WHERE nombre_tipo = 'Alarma Alto' LIMIT 1),
  (SELECT id_supervisor FROM supervisores LIMIT 1),
  NOW(),
  'ATENDIDA',
  'Detención temporal de línea y revisión de filtro.',
  12
); 

--13 inserción registros en la tabla empleado_turno

INSERT INTO empleado_turno (
    id_empleado, id_turno, fecha, id_linea
)
VALUES
(13, 10, '2024-10-01', 1),
(16, 11, '2024-10-01', 6),
(13, 12, '2024-10-01', 11),
(15, 10, '2024-10-02', 1),
(14, 10, '2024-10-03', 5),
(15, 11, '2024-10-03', 12),
(14, 11, '2024-10-04', 6),
(16, 12, '2024-10-04', 3),
(13, 10, '2024-10-05', 11),
(16, 10, '2024-10-06', 8);

--14 inserción registros en la tabla historial_filtros

INSERT INTO historial_filtros (
    id_filtro, fecha_cambio, dias_uso_real, motivo_cambio, id_supervisor, observaciones
)
VALUES
(1, '2024-09-15 10:30:00', 15, 'Vencimiento del filtro', 13, 'El filtro llegó a su vida útil recomendada.'),
(2, '2024-09-20 14:10:00', 12, 'Lecturas fuera de rango', 14, 'El sensor reportó aumento de partículas, se realizó cambio preventivo.'),
(3, '2024-10-01 09:00:00', 15, 'Mantenimiento preventivo', 15, 'Cambio programado dentro del plan mensual.'),
(4, '2024-10-05 11:45:00', 10, 'Obstrucción parcial', 13, 'Se detectó obstrucción en el flujo; se reemplazó inmediatamente.'),
(5, '2024-10-08 08:20:00', 5, 'Daño estructural', 15, 'El filtro presentó deformaciones por impacto en la línea.'),
(1, '2024-10-12 07:50:00', 13, 'Lecturas inestables', 13, 'Se verificó el filtro y se encontró saturado.'),
(2, '2024-10-15 16:40:00', 15, 'Actualización de componente', 13, 'Se instaló un filtro de mayor capacidad.'),
(3, '2024-10-18 10:25:00', 14, 'Auditoría interna', 14, 'Se recomendó cambio tras revisión de calidad.'),
(4, '2024-10-20 13:00:00', 9, 'Exceso de humedad', 14, 'El material absorbente superó los niveles tolerables.'),
(5, '2024-10-22 06:55:00', 15, 'Cambio rutinario fin de turno', 13, 'Cambio ejecutado durante el cierre del turno nocturno.');
-- FIN DEL SCRIPT DE INSERCIÓN


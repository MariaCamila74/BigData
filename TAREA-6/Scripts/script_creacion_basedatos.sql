
-- TABLA: FABRICAS
CREATE TABLE fabricas (
    id_fabrica SERIAL PRIMARY KEY,
    codigo_fabrica VARCHAR(10) NOT NULL UNIQUE,
    nombre_fabrica VARCHAR(100) NOT NULL,
    direccion TEXT,
    ciudad VARCHAR(100),
    pais VARCHAR(100),
    geom geometry(Point,4326), -- ubicación (long, lat) en EPSG:4326
    contacto TEXT
);

-- TABLA: PRODUCTOS
CREATE TABLE productos (
    id_producto SERIAL PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);

-- TABLA: LINEAS_PRODUCCION
CREATE TABLE lineas_produccion (
    id_linea SERIAL PRIMARY KEY,
    id_fabrica INTEGER NOT NULL REFERENCES fabricas(id_fabrica) ON DELETE CASCADE,
    id_producto INTEGER NOT NULL REFERENCES productos(id_producto) ON UPDATE CASCADE,
    nombre_linea VARCHAR(50) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVA' CHECK (estado IN ('ACTIVA','INACTIVA','MANTENIMIENTO')),
    fecha_instalacion DATE NOT NULL CHECK (fecha_instalacion <= CURRENT_DATE),
    ubicacion_planta VARCHAR(100),
    UNIQUE (id_fabrica, nombre_linea)
);

-- TABLA: MICROCONTROLADORES
CREATE TABLE microcontroladores (
    id_mc SERIAL PRIMARY KEY,
    id_linea INTEGER NOT NULL REFERENCES lineas_produccion(id_linea) ON DELETE CASCADE,
    codigo_mc VARCHAR(30) NOT NULL UNIQUE, -- ex: A1M01
    modelo VARCHAR(50) DEFAULT 'ESP8266',
    firmware_version VARCHAR(50),
    geom geometry(Point,4326), -- ubicación del microcontrolador (opcional)
    comentarios TEXT
);

-- TABLA: SENSORES 
CREATE TABLE sensores (
    id_sensor SERIAL PRIMARY KEY,
    id_mc INTEGER NOT NULL REFERENCES microcontroladores(id_mc) ON DELETE CASCADE,
    id_linea INTEGER NOT NULL REFERENCES lineas_produccion(id_linea) ON DELETE CASCADE,
    codigo_sensor VARCHAR(50) NOT NULL UNIQUE, -- ex: A1S01
    tipo_sensor VARCHAR(100) NOT NULL, -- ex: MQ-135 calibrado para benceno
    fecha_instalacion DATE NOT NULL CHECK (fecha_instalacion <= CURRENT_DATE),
    fecha_calibracion TIMESTAMP,
    estado VARCHAR(20) NOT NULL DEFAULT 'OPERATIVO' CHECK (estado IN ('OPERATIVO','FALLA','CALIBRANDO')),
    precision DECIMAL(5,2) NOT NULL CHECK (precision > 0),
    latitud DOUBLE PRECISION,
    longitud DOUBLE PRECISION,
    geom geometry(Point,4326),
    observaciones TEXT
);

-- TABLA: TURNOS
CREATE TABLE turnos (
    id_turno SERIAL PRIMARY KEY,
    nombre_turno VARCHAR(50) NOT NULL UNIQUE,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    descripcion VARCHAR(100),
    CONSTRAINT chk_turno_horas CHECK (hora_inicio <> hora_fin)
);

–TURNO: EMPLEADOS
CREATE TABLE empleados (
    id_empleado SERIAL PRIMARY KEY,
    nombre_completo VARCHAR(100) NOT NULL,
    cedula VARCHAR(30) UNIQUE,
    celular VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    fecha_ingreso DATE,
    estado VARCHAR(20) DEFAULT 'ACTIVO' CHECK (estado IN ('ACTIVO','INACTIVO','SUSPENDIDO')),
    cargo VARCHAR(100)
);

 -- TABLA: EMPLEADO_TURNO 
CREATE TABLE empleado_turno (
    id_empleadoturno SERIAL PRIMARY KEY,
    id_empleado INTEGER NOT NULL REFERENCES empleados(id_empleado) ON DELETE CASCADE,
    id_turno INTEGER NOT NULL REFERENCES turnos(id_turno) ON UPDATE CASCADE,
    fecha DATE NOT NULL,
    id_linea INTEGER REFERENCES lineas_produccion(id_linea),
    UNIQUE (id_empleado, id_turno, fecha)
);

-- TABLA: SUPERVISORES
CREATE TABLE supervisores (
    id_supervisor SERIAL PRIMARY KEY,
    id_empleado INTEGER NOT NULL UNIQUE REFERENCES empleados(id_empleado) ON DELETE CASCADE,
    id_turno INTEGER NOT NULL REFERENCES turnos(id_turno) ON UPDATE CASCADE,
    certificaciones TEXT
);

-- TABLA: TIPOS_FILTRO
CREATE TABLE tipos_filtro (
    id_tipo_filtro SERIAL PRIMARY KEY,
    nombre_tipo VARCHAR(100) NOT NULL UNIQUE,
    vida_estimada_dias INTEGER NOT NULL DEFAULT 15,
    costo_usd NUMERIC(10,2)
);

-- TABLA: FILTROS
CREATE TABLE filtros (
    id_filtro SERIAL PRIMARY KEY,
    id_linea INTEGER NOT NULL REFERENCES lineas_produccion(id_linea) ON DELETE CASCADE,
    id_tipo_filtro INTEGER NOT NULL REFERENCES tipos_filtro(id_tipo_filtro),
    codigo_filtro VARCHAR(50) NOT NULL UNIQUE,
    fecha_instalacion DATE NOT NULL CHECK (fecha_instalacion <= CURRENT_DATE),
    fecha_vencimiento DATE NOT NULL,
    dias_uso_recomendado INTEGER NOT NULL DEFAULT 15,
    estado VARCHAR(20) NOT NULL DEFAULT 'ACTIVO' CHECK (estado IN ('ACTIVO','INACTIVO','VENCIDO')),
    proveedor VARCHAR(100),
    observaciones TEXT
);

-- TABLA: HISTORIAL_FILTROS
CREATE TABLE historial_filtros (
    id_historial SERIAL PRIMARY KEY,
    id_filtro INTEGER NOT NULL REFERENCES filtros(id_filtro) ON DELETE CASCADE,
    fecha_cambio TIMESTAMP NOT NULL CHECK (fecha_cambio <= NOW()),
    dias_uso_real INTEGER NOT NULL DEFAULT 15,
    motivo_cambio VARCHAR(200),
    id_supervisor INTEGER NOT NULL REFERENCES supervisores(id_supervisor) ON UPDATE CASCADE,
    observaciones TEXT
);

-- TABLA: NIVELES_PELIGROSIDAD
CREATE TABLE niveles_peligrosidad (
    id_nivel SERIAL PRIMARY KEY,
    nombre_nivel VARCHAR(50) NOT NULL UNIQUE,
    ppm_minimo DECIMAL(8,2) NOT NULL CHECK (ppm_minimo >= 0),
    ppm_maximo DECIMAL(8,2) NOT NULL CHECK (ppm_maximo > ppm_minimo),
    color_led VARCHAR(20) NOT NULL,
    codigo_color_hex VARCHAR(7) NOT NULL CHECK (codigo_color_hex ~ '^#[0-9A-Fa-f]{6}$'),
    nivel_criticidad INTEGER NOT NULL CHECK (nivel_criticidad BETWEEN 1 AND 5),
    descripcion TEXT,
    protocolo_accion TEXT
);

--TABLA: TIPOS_ALARMA
CREATE TABLE tipos_alarma (
    id_tipo_alarma SERIAL PRIMARY KEY,
    nombre_tipo VARCHAR(100) NOT NULL UNIQUE,
    nivel_prioridad INTEGER NOT NULL CHECK (nivel_prioridad BETWEEN 1 AND 5),
    requiere_detencion_linea BOOLEAN NOT NULL DEFAULT FALSE,
    requiere_detencion_fabrica BOOLEAN NOT NULL DEFAULT FALSE,
    requiere_llamada_bomberos BOOLEAN NOT NULL DEFAULT FALSE,
    protocolo_detallado TEXT,
    tiempo_max_respuesta INTEGER NOT NULL
);

--TABLA: LECTURAS 
CREATE TABLE lecturas (
    id_lectura BIGSERIAL PRIMARY KEY,
    id_sensor INTEGER NOT NULL REFERENCES sensores(id_sensor) ON DELETE CASCADE,
    id_mc INTEGER NOT NULL REFERENCES microcontroladores(id_mc) ON DELETE CASCADE,
    id_linea INTEGER NOT NULL REFERENCES lineas_produccion(id_linea) ON DELETE CASCADE,
    id_fabrica INTEGER NOT NULL REFERENCES fabricas(id_fabrica) ON DELETE CASCADE,
    id_turno INTEGER NOT NULL REFERENCES turnos(id_turno) ON UPDATE CASCADE,
    id_nivel INTEGER REFERENCES niveles_peligrosidad(id_nivel),
    fecha_hora TIMESTAMP NOT NULL DEFAULT NOW(),
    concentracion_ppm DECIMAL(10,3) NOT NULL CHECK (concentracion_ppm >= 0),
    temperatura DECIMAL(5,2),
    humedad DECIMAL(5,2),
    presion_atmosferica DECIMAL(7,2),
    latitud DOUBLE PRECISION,
    longitud DOUBLE PRECISION,
    geom geometry(Point,4326),
    payload jsonb -- para guardar metadatos originales (raw JSON del microcontrolador)
);

-- TABLA: ALARMAS
CREATE TABLE alarmas (
    id_alarma BIGSERIAL PRIMARY KEY,
    id_lectura BIGINT NOT NULL REFERENCES lecturas(id_lectura) ON DELETE CASCADE,
    id_tipo_alarma INTEGER NOT NULL REFERENCES tipos_alarma(id_tipo_alarma),
    id_supervisor INTEGER REFERENCES supervisores(id_supervisor) ON UPDATE CASCADE,
    fecha_hora_alarma TIMESTAMP NOT NULL DEFAULT NOW(),
    fecha_hora_atencion TIMESTAMP,
    estado_alarma VARCHAR(20) NOT NULL DEFAULT 'ACTIVA' CHECK (estado_alarma IN ('ACTIVA','ATENDIDA','RESUELTA')),
    acciones_tomadas TEXT,
    tiempo_respuesta INTEGER
);

-- ÍNDICES OPTIMIZACIÓN
CREATE INDEX idx_lecturas_fecha ON lecturas (fecha_hora DESC);
CREATE INDEX idx_lecturas_sensor ON lecturas (id_sensor);
CREATE INDEX idx_lecturas_fabrica_fecha ON lecturas (id_fabrica, fecha_hora DESC);
CREATE INDEX idx_alarmas_estado ON alarmas (estado_alarma);
CREATE INDEX idx_sensores_codigo ON sensores (codigo_sensor);

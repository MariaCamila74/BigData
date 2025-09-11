<<<<<<< HEAD:TAREA-2/Archivos_Profesor/script-base-datos-valida-fecha.sql


-- Consulta SQL
-- Formato de fecha válido = "AAAA-MM-DD"
-- Seleccionar los registros con fechas DIFERENTES al formato
SELECT * FROM operaciones WHERE fecha !~ '^\d{4}-\d{2}-\d{2}$';

-- Consulta SQL
-- Formato de fecha válido = "AAAA-MM-DD"
-- Seleccionar los registros con fechas IGUALES al formato
SELECT * FROM operaciones WHERE fecha ~ '^\d{4}-\d{2}-\d{2}$';
=======


-- Consulta SQL
-- Formato de fecha válido = "AAAA-MM-DD"
-- Seleccionar los registros con fechas DIFERENTES al formato
SELECT * FROM operaciones WHERE fecha !~ '^\d{4}-\d{2}-\d{2}$';

-- Consulta SQL
-- Formato de fecha válido = "AAAA-MM-DD"
-- Seleccionar los registros con fechas IGUALES al formato
SELECT * FROM operaciones WHERE fecha ~ '^\d{4}-\d{2}-\d{2}$';
>>>>>>> 1b7bb061541c7fd4355a4bd7d37a54bff4e26974:script-base-datos-valida-fecha.sql

--Imputa datos de id_municipio a Id_departamento

UPDATE operaciones
SET id_departamento = CAST(SUBSTRING(CAST(id_municipio AS VARCHAR), 1, 4) AS INTEGER)
WHERE id_departamento = 0;

--Hallar el promedio de catidades y imputar los datos en 0
WITH promedios AS (
    SELECT id_municipio, AVG(cantidad)::int AS prom
    FROM operaciones
    WHERE cantidad > 0
    GROUP BY id_municipio
)
UPDATE operaciones o
SET cantidad = p.prom,
FROM promedios p
WHERE o.id_municipio = p.id_municipio
  AND o.cantidad = 0;

UPDATE public.operaciones
SET fecha = 
    CASE 
        WHEN fecha ~ ''

-- 
UPDATE public.operaciones
SET id_producto = 4 
WHERE id_municipio = 5705108
AND id_departamento = 5705;
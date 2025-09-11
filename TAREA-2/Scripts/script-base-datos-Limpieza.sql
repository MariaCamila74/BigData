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

--Fecha en fomato corto se pasa a formato largo
UPDATE public.operaciones
SET fecha =  TO_DATE(fecha,'YY-MM-DD' )
WHERE fecha  ~  '^\d{2}-\d{2}-\d{2}$';

--Fecha con error de un dato faltante en el año
UPDATE public.operaciones
SET fecha =  TO_DATE('2' ||fecha,'YYYY-MM-DD' )
WHERE fecha  ~  '^\d{3}-\d{2}-\d{2}$'
AND ('2' || substring(fecha FROM 1 FOR 3))::int BETWEEN 2000 AND 2099;

--Fecha con el formato correcto pero en el orden incorrecto
UPDATE public.operaciones
SET fecha = TO_CHAR(TO_DATE('13-12-2024', 'DD-MM-YYYY'), 'YYYY-MM-DD')
WHERE id_registro = 13945;

UPDATE public.operaciones
SET fecha = TO_CHAR(TO_DATE('11-23-2024', 'MM-DD-YYYY'), 'YYYY-MM-DD')
WHERE id_registro = 19680;

--Fecha en formato corto y con el dia y mes en posiciones incorrectas
UPDATE public.operaciones
SET fecha =  TO_DATE(fecha,'YY-DD-MM' )
WHERE fecha  ~  '^\d{2}-\d{2}-\d{2}$';

--Fecha en formato corto y con el año en posicion incorrecta
UPDATE public.operaciones
SET fecha =  TO_DATE('20' || SUBSTRING(fecha FROM 7 for 2) || '-'  || SUBSTRING(fecha FROM 4 FOR 2) || '-'  || SUBSTRING(fecha FROM 1 FOR 2),'YYYY-MM-DD' )
WHERE fecha  ~  '^\d{2}-\d{2}-\d{2}$';

--Fecha con formato diferente en la posicion del año
UPDATE public.operaciones
SET fecha =  TO_DATE(SUBSTRING(fecha FROM 7 FOR 4) || '-' || SUBSTRING(fecha FROM 4 FOR 2) || '-' || SUBSTRING(fecha FROM 1 FOR 2), 'YYYY-MM-DD' )
WHERE fecha  ~  '^\d{2}-\d{2}-\d{4}$';

--Id_departamento con campos en 0, se llena con datos de id_municipio

UPDATE operaciones
SET id_departamento = CAST(SUBSTRING(CAST(id_municipio AS VARCHAR), 1, 4) AS INTEGER)
WHERE id_departamento = 0;

--error en campo cantidad con registros en 0, se soluciona con el promedio de ventas por municipio
WITH promedios AS (
    SELECT 
        id_municipio, 
        COALESCE(AVG(NULLIF(cantidad, 0)), 0)::int AS prom
    FROM operaciones
    WHERE cantidad IS NOT NULL
    GROUP BY id_municipio
)
UPDATE operaciones o
SET cantidad = p.prom
FROM promedios p
WHERE o.id_municipio = p.id_municipio
  AND o.cantidad = 0 ;

--Error cantidades en numeros negativos
UPDATE public.operaciones
SET cantidad = ABS(cantidad)
WHERE cantidad < 0;

--Error id_producto en 0
UPDATE public.operaciones
SET id_producto = 4 
WHERE id_municipio = 5705108
AND id_departamento = 5705;



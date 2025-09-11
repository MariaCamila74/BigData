--CONSULTAS SQL

--7.1 

--Consulta sin usar la vista
/*
SELECT 
    D.nombre AS departamento,
    SUM(O.cantidad * P.precio) AS monto_total
FROM operaciones O, departamentos D, municipios M, Productos p
WHERE D.id_departamento = O.id_departamento
AND O.id_municipio = M.id_municipio
AND O.id_producto = P.id_producto
GROUP BY D.nombre
ORDER BY monto_total DESC LIMIT 8;
*/

--Consulta usando la vista

SELECT departamento, SUM(venta) AS monto_total
FROM vista_operaciones
GROUP BY departamento
ORDER BY monto_total DESC LIMIT 8;

--7.2

--Consulta sin usar la vista
/*
SELECT 
    M.nombre AS municipio,
    SUM(O.cantidad) AS total_vendidos
FROM operaciones O, departamentos D, municipios M, productos P
WHERE D.id_departamento = O.id_departamento
AND M.id_municipio = O.id_municipio
AND O.id_producto = P.id_producto
AND D.nombre = 'Antioquia'
GROUP BY M.nombre
ORDER BY total_vendidos DESC
LIMIT 15;
*/

--Consulta usando la vista

SELECT 
    municipio,
    SUM(cantidad) AS total_vendidos
FROM vista_operaciones
WHERE departamento = 'Antioquia'
GROUP BY municipio
ORDER BY total_vendidos DESC
LIMIT 15;

--7.3

--Consulta sin usar la vista
/*
SELECT 
    D.nombre AS departamento,
    SUM(O.cantidad) AS total_vendidas
FROM operaciones O, departamentos D, municipios M, Productos p
WHERE D.id_departamento = O.id_departamento
AND M.id_municipio = O.id_municipio
AND P.id_producto = O.id_producto
AND P.nombre = 'MANZALOCA'
GROUP BY D.nombre
ORDER BY total_vendidas DESC
LIMIT 5;
*/

--Consulta usando la vista

SELECT 
    departamento,
    SUM(cantidad) AS total_vendidas
FROM vista_operaciones
WHERE producto = 'MANZALOCA'
GROUP BY departamento
ORDER BY total_vendidas DESC
LIMIT 5;

--7.4

--Consulta sin usar la vista

/*
SELECT 
    D.nombre AS departamento,
    M.nombre AS municipio,
    SUM(O.cantidad * P.precio) AS monto_total
FROM operaciones O, departamentos D, municipios M, productos P
WHERE D.id_departamento = O.id_departamento
AND M.id_municipio = O.id_municipio
AND P.id_producto = O.id_producto
AND P.nombre = 'MANZALOCA'   
GROUP BY D.nombre, M.nombre
ORDER BY monto_total ASC
LIMIT 5;
*/

--Consulta usando la vista

SELECT 
    departamento,
    municipio,
    SUM(venta) AS monto_total
FROM vista_operaciones
WHERE producto = 'MANZALOCA'
GROUP BY departamento, municipio
ORDER BY monto_total ASC
LIMIT 5;

--7.5

--Consulta sin usar la vista
/*
SELECT R.nombre_region, P.nombre, SUM(O.cantidad) AS total_vendido
FROM operaciones O, productos P, regiones R
WHERE P.id_producto = O.id_producto
AND R.id_region = O.id_region
GROUP BY R.nombre_region, P.nombre
ORDER BY total_vendido DESC;
*/

--Consulta usando la vista

SELECT
    region,
    producto,
    SUM(cantidad) AS total_vendido
FROM vista_operaciones
GROUP BY region, producto
ORDER BY total_vendido DESC;

--7.6

--Consulta sin usar la vista

/*
SELECT P.nombre, SUM(O.cantidad * P.precio) AS total_ventas
FROM operaciones O, productos P, departamentos D
WHERE P.id_producto = O.id_producto
AND D.id_departamento = O.id_departamento
AND D.nombre = 'Antioquia'
GROUP BY P.nombre
ORDER BY total_ventas DESC;
*/

--Consulta usando la vista

SELECT 
    producto,
    SUM(venta) AS total_ventas
FROM vista_operaciones
WHERE departamento = 'Antioquia'
GROUP BY producto
ORDER BY total_ventas DESC;
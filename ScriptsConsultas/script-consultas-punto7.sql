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
AND M.id_producto = P.id_producto
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
    SUM(ope.cantidad) AS total_vendidos
FROM operaciones O, departamentos D, municipios M, productos P
WHERE D.id_departamento = O.id_departamento
AND M.id_municipio = O.id_municipio
AND M.id_producto = P.id_producto
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
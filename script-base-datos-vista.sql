
--
-- ESTA VISTA  ES UNA HERRAMIENTA ESPECIAL PARA REALIZAR CONSULTAS
-- 
-- Operaciones completas
-- Nombres de region, departamento, municipio, producto, cantidad, precio y monto 
-- DROP VIEW vista_operaciones
CREATE VIEW vista_operaciones AS
SELECT 	ope.id_registro,
        dep.nombre as departamento, ope.id_departamento, 
       	mun.nombre as municipio,    ope.id_municipio,
       	pro.nombre as producto,     ope.id_producto,
		reg.nombre_region as region, ope.id_region,
   		ope.fecha,
        ope.cantidad, 
		pro.precio,
	   	ope.cantidad * pro.precio as venta,
		ope.estado
FROM operaciones ope
JOIN departamentos dep on dep.id_departamento = ope.id_departamento
JOIN municipios    mun on mun.id_municipio    = ope.id_municipio
JOIN productos     pro on pro.id_producto     = ope.id_producto
JOIN regiones	   reg on reg.id_region       = ope.id_region
ORDER BY dep.nombre, mun.nombre, pro.nombre,reg.nombre_region
CREATE OR REPLACE VIEW public.vista_operaciones_new
 AS
 SELECT ope.id_registro,
    dep.nombre AS departamento,
    ope.id_departamento,
    mun.nombre AS municipio,
    ope.id_municipio,
    pro.nombre AS producto,
    ope.id_producto,
    ope.fecha,
    date_part('month'::text, to_date((ope.fecha)::text, 'YYYY-MM-DD'::text)) AS mes,
    date_part('year'::text, to_date((ope.fecha)::text, 'YYYY-MM-DD'::text)) AS anio,
    ope.cantidad,
    pro.precio,
    (ope.cantidad * pro.precio) AS venta,
    ope.estado,
    reg.id_region,
    reg.nombre_region
   FROM (((operaciones ope
     JOIN departamentos dep ON ((dep.id_departamento = ope.id_departamento)))
     JOIN municipios mun ON ((mun.id_municipio = ope.id_municipio)))
     JOIN productos pro ON ((pro.id_producto = ope.id_producto)))
     JOIN regiones reg ON ((reg.id_region = ope.id_region))
  ORDER BY dep.nombre, mun.nombre, pro.nombre, reg.nombre_region;
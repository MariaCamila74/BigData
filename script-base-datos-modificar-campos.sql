
--Agregar el campo id_region a public.operaciones

ALTER TABLE public.operaciones
ADD id_region INT REFERENCES regiones(id_region);

--Agregar el campo modificado a public.operaciones

ALTER TABLE operaciones
ADD COLUMN IF NOT EXISTS modificado boolean DEFAULT false;

--Agregar el campo causa a public.operaciones

ALTER TABLE operaciones
ADD COLUMN IF NOT EXISTS causa text DEFAULT 'Valido';
-- TRIGGER INSTEAD:

CREATE trigger tr_INSTEAD_envases
on ENVASES INSTEAD OF insert  
as 
begin transaction

	select 
		'TABLA INSERTED',
		*
	from Inserted 

	insert into Envases (enva_codigo, enva_detalle)
	select 
		enva_codigo, LTRIM(RTRIM(enva_detalle)) + 'MODIFICO COMPORTAMIENTO TR'
	from inserted 
	
commit


insert into Envases (enva_codigo, enva_detalle)
	values(18, 'envase 18' )


SELECT * FROM ENVASES


-- Ej 1

-- 10. Crear el/los objetos de base de datos que ante el intento de borrar un artículo verifique que no exista stock y si es así lo borre, en caso contrario que emita un mensaje de error.

-- Ej 2

-- EJERCICIO:
-- 	Crear el/los objetos de base de datos que ante la venta 
-- 	del producto '00000030' registre en una estructura adicional
-- 	el mes, anio y la cantidad de ese producto que se esta 
-- 	comprando por mes y anio.
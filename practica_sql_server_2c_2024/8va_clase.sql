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
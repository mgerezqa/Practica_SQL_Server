-- TSQL Intro

BEGIN
    declare @var1 char(100)
    declare @var2 int 

    set @var1 = 'Hola mundo'
    set @var2 = 10 + 10

    print @var1
    print @var2
END


-- 2do ejemplo

-- Resumen:
-- Este código SQL realiza los siguientes pasos:

-- Declara dos variables: @v_cod y @v_nombre.
-- Asigna el valor '00000' a la variable @v_cod.
-- Realiza una consulta en la tabla cliente para obtener el valor de clie_razon_social correspondiente al clie_codigo '00000' y asigna este valor a la variable @v_nombre.
-- Imprime el valor de la variable @v_nombre

	declare @v_cod char(5)
	declare @v_nombre char(100) 
	
	set @v_cod = '00000'
	
	select 
		 @v_nombre = clie_razon_social 
	from cliente 
	where 
		clie_codigo =  @v_cod
		
	print @v_nombre

-- 2do ejemplo query en SQL

Select clie_razon_social from Cliente where clie_codigo = '00000'

-- 3er ejemplo
-- Interactuando con clausulas if/else

BEGIN
	
	declare @var int 
    set @var = 1000
		
	IF (SELECT COUNT(*) FROM CLIENTE) > @var 
        begin
            
            print 'hay mas de 1000 clientes'
            
        end
	else
        begin
            
            print 'hay menos de 1000 clientes'
            
        end
    
END

--4to ejemplo
-- Clausula while
BEGIN
	
	declare @var3 int 
		
	set @var3 = 1 
	
	while @var3 <= 100
	begin
		print @var3 
		set @var3 = @var3 + 1 
	end 


	
END


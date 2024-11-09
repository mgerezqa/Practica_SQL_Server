-- DEFINICION DE CURSOR
--UN CURSOR ES UN OBJETO QUE PERMITE RECORRER LOS REGISTROS DE UNA TABLA O UNA VISTA
--LOS CURSORES SON UTILIZADOS PARA REALIZAR OPERACIONES DE PROCESAMIENTO DE FILAS UNA A UNA
--


DECLARE @cod char(5)
	DECLARE @nombre char(100)
	
	DECLARE mi_cursor CURSOR FOR 
		SELECT 
			clie_codigo ,
			clie_razon_social 
		FROM Cliente c 
		ORDER BY
			clie_codigo DESC 
			
	OPEN mi_cursor 
	fetch mi_cursor into @cod, @nombre
	
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		PRINT @NOMBRE
		fetch mi_cursor into @cod, @nombre
	END 
	CLOSE mi_cursor 
	DEALLOCATE mi_cursor

-- declaración del cursor   

-- DECLARE mi_cursor CURSOR FOR 
-- SELECT 
-- clie_codigo ,
-- clie_razon_social 
-- FROM Cliente c 
-- ORDER BY
-- clie_codigo DESC 

-- DECLARE mi_cursor CURSOR FOR: Declara un cursor llamado mi_cursor.
-- SELECT clie_codigo, clie_razon_social 
-- FROM Cliente c 
-- ORDER BY clie_codigo DESC:

--  Define la consulta que el cursor recorrerá. Selecciona las columnas clie_codigo y clie_razon_social de la tabla Cliente, ordenando los resultados por clie_codigo en orden descendente.

-- OPEN mi_cursor 

-- OPEN mi_cursor: Abre el cursor mi_cursor para que pueda ser utilizado.

--  Recuperación Inicial de Datos

-- fetch mi_cursor into @cod, @nombre: Recupera la primera fila del conjunto de resultados del cursor y asigna los valores de clie_codigo y clie_razon_social a las variables @cod y @nombre, respectivamente.


-- WHILE @@FETCH_STATUS = 0 
-- BEGIN
-- PRINT @NOMBRE
-- fetch mi_cursor into @cod, @nombre
-- END 


-- WHILE @@FETCH_STATUS = 0: 
-- Inicia un bucle que continuará mientras @@FETCH_STATUS sea igual a 0. @@FETCH_STATUS es una función del sistema que devuelve el estado de la última operación de FETCH. Un valor de 0 indica que la operación fue exitosa.
-- BEGIN ... END: Define el bloque de código que se ejecutará en cada iteración del bucle.
-- PRINT @NOMBRE: Imprime el valor de la variable @nombre.
-- fetch mi_cursor into @cod, @nombre: Recupera la siguiente fila del conjunto de resultados del cursor y asigna los valores a las variables @cod y @nombre.

-- CLOSE mi_cursor 
-- DEALLOCATE mi_cursor

-- CLOSE mi_cursor: Cierra el cursor mi_cursor una vez que se ha terminado de utilizar.
-- DEALLOCATE mi_cursor: Libera los recursos asociados con el cursor mi_cursor.


-- Resumen
-- Este código SQL utiliza un cursor para recorrer todas las filas de la tabla Cliente, seleccionando las columnas clie_codigo y clie_razon_social y ordenándolas por clie_codigo en orden descendente. En cada iteración del bucle, imprime el valor de clie_razon_social.



DECLARE @cod char(5)
	DECLARE @nombre char(100)
	
	DECLARE mi_cursor CURSOR  FOR 
		SELECT 
			clie_codigo ,
			clie_razon_social 
		FROM Cliente c 
		ORDER BY
			clie_codigo DESC 
	FOR UPDATE OF 
		clie_razon_social 
			
	OPEN mi_cursor 
	fetch mi_cursor into @cod, @nombre
	
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		IF @cod = '00000'
		BEGIN 
			UPDATE CLIENTE 
				SET clie_razon_social = 'CAMBIADO FOR UDPATE CURSOR'
			WHERE 
				CURRENT OF MI_CURSOR 
		END 	
		fetch mi_cursor into @cod, @nombre
	END 
	CLOSE mi_cursor 
	DEALLOCATE mi_cursor


-- UPDATE CLIENTE SET clie_razon_social = 'CAMBIADO FOR UDPATE CURSOR' WHERE CURRENT OF MI_CURSOR: Actualiza la columna clie_razon_social de la fila actual del cursor a 'CAMBIADO FOR UDPATE CURSOR'.

--     Resumen
-- Este código SQL utiliza un cursor para recorrer todas las filas de la tabla Cliente, seleccionando las columnas clie_codigo y clie_razon_social y ordenándolas por clie_codigo en orden descendente. En cada iteración del bucle, si el valor de clie_codigo es '00000', actualiza la columna clie_razon_social de esa fila a 'CAMBIADO FOR UDPATE CURSOR'.
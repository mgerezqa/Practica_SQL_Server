-- BEGIN TRANSACTION: Esta sentencia inicia una transacción. Una transacción es un conjunto de operaciones SQL que se ejecutan como una unidad. Si alguna de las operaciones falla, se puede deshacer todo el conjunto de operaciones para mantener la integridad de la base de datos.
-- INSERT INTO Envases (enva_codigo, enva_detalle) VALUES (5, ‘env 5’): Esta sentencia inserta un nuevo registro en la tabla Envases. El nuevo registro tendrá enva_codigo igual a 5 y enva_detalle igual a ‘env 5’.
-- INSERT INTO Envases (enva_codigo, enva_detalle) VALUES (6, ‘env 6’): Similar a la anterior, esta sentencia inserta otro nuevo registro en la tabla Envases con enva_codigo igual a 6 y enva_detalle igual a ‘env 6’.
-- En resumen, estas sentencias están añadiendo dos nuevos registros a la tabla Envases dentro de una transacción. Si todo se ejecuta correctamente, los dos registros se añadirán a la tabla. Si ocurre algún error, la transacción puede ser revertida para que la base de datos vuelva a su estado original antes de la transacción.


BEGIN TRANSACTION
	INSERT INTO Envases ( enva_codigo, enva_detalle)
		values(5, 'env 5')
		
	INSERT INTO Envases ( enva_codigo, enva_detalle)
			values(6, 'env 6')

    COMMIT TRANSACTION

    -- ROLLBACK ME SIRVE PARA ANULAR CAMBIOS PARCIALES , ES DECIR CUANDO NO FUERON COMITEADOS


SELECT * FROM Envases


-- COMO HAGO PARA DESHACER UN COMMIT????

-- Una vez que has hecho un COMMIT en una transacción, los cambios se vuelven permanentes en la base de datos y no se pueden deshacer directamente con una sentencia SQL. Sin embargo, hay algunas estrategias que puedes considerar para revertir los cambios:

-- Realizar un Backup y Restore: Si tienes un respaldo de la base de datos antes de la transacción, puedes restaurar la base de datos a ese punto. Esto puede ser una solución drástica y no siempre práctica.
-- Transacciones Compensatorias: Puedes escribir una nueva transacción que revierta los cambios realizados. Por ejemplo, si insertaste registros, puedes eliminarlos con una nueva transacción:
-- SQL

BEGIN TRANSACTION
    DELETE FROM Envases WHERE enva_codigo IN (5, 6)
COMMIT

-- Utilizar el Log de Transacciones: En SQL Server, puedes usar el log de transacciones para restaurar la base de datos a un punto en el tiempo antes del COMMIT. Esto requiere que tengas configurado el modo de recuperación completa y que realices backups del log de transacciones regularmente.
-- Herramientas de Terceros: Existen herramientas de terceros que pueden ayudarte a revertir cambios en la base de datos utilizando el log de transacciones.


BEGIN TRANSACTION
    UPDATE Envases SET enva_detalle = 'Nuevo'
    WHERE enva_codigo = 1

ROLLBACK TRANSACTION


SELECT @@TRANCOUNT

    -- ROLLBACK ME SIRVE PARA ANULAR CAMBIOS PARCIALES , ES DECIR CUANDO NO FUERON COMITEADOS

-- EJEMPLO DE TRANSACCIÓN REPETIBLE

SET TRANSACTION ISOLATION LEVEL  REPEATABLE READ 

BEGIN TRANSACTION
	
	SELECT * FROM Envases e 
	WHERE 
		enva_codigo = 1 
		

	
	
	SELECT * FROM Envases e 
	WHERE 
		enva_codigo = 1 

COMMIT

-- EJEMPLO DE SERIALIZACIÓN

-- SERIALIZABLE

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE 

BEGIN TRANSACTION
	
	SELECT *  FROM Envases e  WHERE enva_codigo = 1 

	UPDATE Envases SET enva_detalle = 'MODIF' WHERE enva_codigo = 1

COMMIT
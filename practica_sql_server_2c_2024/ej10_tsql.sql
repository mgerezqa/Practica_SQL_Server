-- 10. Crear el/los objetos de base de datos que ante el intento de borrar un artículo verifique que no exista stock y si es así lo borre, en caso contrario que emita un mensaje de error.

ALTER TRIGGER trg_borrar_producto
ON [dbo].[Producto]
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM [dbo].[STOCK] WHERE stoc_producto IN (SELECT prod_codigo FROM DELETED) AND stoc_cantidad > 0)
    BEGIN
        RAISERROR ('No se puede borrar el artículo porque existe stock.', 16, 1);
    END
    ELSE
    BEGIN
                -- Eliminar registros de la tabla STOCK con cantidad cero
        DELETE FROM [dbo].[STOCK] WHERE stoc_producto IN (SELECT prod_codigo FROM DELETED) AND stoc_cantidad = 0;
        
        -- Eliminar el producto de la tabla Producto
        DELETE FROM [dbo].[Producto] WHERE prod_codigo IN (SELECT prod_codigo FROM DELETED);
    END
END
GO


-- Claro, aquí tienes una explicación detallada de la nueva versión del trigger trg_borrar_producto:

-- Explicación paso a paso:
-- Definición del Trigger:

-- El trigger se llama trg_borrar_producto y está asociado a la tabla [dbo].[Producto].
-- Se define como un trigger INSTEAD OF DELETE, lo que significa que se ejecutará en lugar de la operación de eliminación estándar.
-- Inicio del Trigger:

-- El bloque BEGIN ... END define el cuerpo del trigger.
-- Verificación de Existencia de Stock Mayor a Cero:

-- La instrucción IF EXISTS (SELECT 1 FROM [dbo].[STOCK] WHERE stoc_producto IN (SELECT prod_codigo FROM DELETED) AND stoc_cantidad > 0) verifica si hay registros en la tabla [dbo].[STOCK] que correspondan a los productos que se están intentando eliminar y que tengan una cantidad mayor a 0.
-- DELETED es una tabla mágica que contiene las filas que se están eliminando.
-- Emisión de Mensaje de Error:

-- Si la condición del IF es verdadera (es decir, si existe stock mayor a cero para el producto que se intenta eliminar), se ejecuta el bloque BEGIN ... END dentro del IF.
-- RAISERROR ('No se puede borrar el artículo porque existe stock.', 16, 1); emite un mensaje de error y detiene la operación de eliminación.
-- Eliminación de Registros en STOCK con Cantidad Cero:

-- Si no existe stock mayor a cero para el producto que se intenta eliminar, se ejecuta el bloque BEGIN ... END dentro del ELSE.
-- DELETE FROM [dbo].[STOCK] WHERE stoc_producto IN (SELECT prod_codigo FROM DELETED) AND stoc_cantidad = 0; elimina los registros correspondientes en la tabla STOCK donde la cantidad es cero.
-- Eliminación del Producto:

-- Después de eliminar los registros en STOCK con cantidad cero, se procede a eliminar el producto de la tabla Producto.
-- DELETE FROM [dbo].[Producto] WHERE prod_codigo IN (SELECT prod_codigo FROM DELETED); elimina el producto de la tabla Producto.
-- Resumen:
-- Este trigger asegura que un producto solo se pueda eliminar si no tiene stock mayor a cero. Si hay stock mayor a cero, se emite un mensaje de error y se impide la eliminación. Si no hay stock o el stock es cero, se eliminan primero los registros correspondientes en la tabla STOCK y luego el producto en la tabla Producto.



SELECT * FROM [dbo].[Producto];
SELECT * FROM [dbo].[STOCK];


-- Crear registros de prueba en la tabla Producto
INSERT INTO [dbo].[Producto] (prod_codigo, prod_detalle) VALUES ('TEST0001', 'Producto de Prueba 1');
INSERT INTO [dbo].[Producto] (prod_codigo, prod_detalle) VALUES ('TEST0002', 'Producto de Prueba 2');

-- Crear registros de prueba en la tabla STOCK
-- PRODUCTO QUE TIENE STOCK
INSERT INTO [dbo].[STOCK] (stoc_producto, stoc_deposito, stoc_cantidad) VALUES ('TEST0001', '00', 100);
-- PRODUCTO QUE NO TIENE STOCK
INSERT INTO [dbo].[STOCK] (stoc_producto, stoc_deposito, stoc_cantidad) VALUES ('TEST0002', '00', 0 );

-- Intentar borrar el producto con stock
PRINT 'Intentando borrar Producto 1 (con stock)...';
BEGIN TRY
    DELETE FROM [dbo].[Producto] WHERE prod_codigo = 'TEST0001';
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH

-- Intentar borrar el producto sin stock
PRINT 'Intentando borrar Producto 2 (sin stock)...';
BEGIN TRY
    DELETE FROM [dbo].[Producto] WHERE prod_codigo = 'TEST0002';
    PRINT 'Producto 2 borrado exitosamente.';
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH

-- Verificar el estado final de las tablas
SELECT * FROM [dbo].[Producto];
SELECT * FROM [dbo].[STOCK];


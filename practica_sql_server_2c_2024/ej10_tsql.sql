-- 10. Crear el/los objetos de base de datos que ante el intento de borrar un artículo verifique que no exista stock y si es así lo borre en caso contrario que emita un mensaje de error.

USE GD2015C1;
GO

CREATE PROCEDURE DeleteArticulo
    @articuloID CHAR(8)
AS
BEGIN
    DECLARE @stockCount INT;

    -- Verificar si existe stock para el artículo
    SELECT @stockCount = COUNT(*)
    FROM STOCK
    WHERE stoc_producto = @articuloID;

    -- Si no hay stock, borrar el artículo
    IF @stockCount = 0
    BEGIN
        DELETE FROM Producto
        WHERE prod_codigo = @articuloID;
        PRINT 'Artículo borrado exitosamente.';
    END
    ELSE
    BEGIN
        -- Si hay stock, emitir un mensaje de error
        PRINT 'No se puede borrar el artículo porque aún hay stock.';
    END
END;
GO


/*

APROBADO.

Implementar los objetos necesarios para registrar, en tiempo real,
los 10 productos más vendidos por año en una tabla específica.
Esta tabla debe contener exclusivamente la información requerida,
sin incluir filas adicionales.
Los "más vendidos" se definen como aquellos productos con el mayor número de unidades vendidas.
*/

DROP TABLE IF EXISTS Top_10_Productos_Vendidos;

CREATE TABLE Top_10_Productos_Vendidos (
    Año INT,
    Producto CHAR(8),
    Total_Vendido DECIMAL(12, 2),
    CONSTRAINT PK_Top10 PRIMARY KEY (Año, Producto)
);
GO


CREATE OR ALTER TRIGGER tr_actualizar_top_10 
ON dbo.Item_Factura
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

    DECLARE @año_actual INT;

    DECLARE cursor_años CURSOR FOR
        SELECT DISTINCT YEAR(f.fact_fecha)
        FROM Factura AS f
        JOIN Item_Factura AS i
          ON f.fact_tipo + f.fact_sucursal + f.fact_numero = i.item_tipo + i.item_sucursal + i.item_numero;

    OPEN cursor_años;
    FETCH NEXT FROM cursor_años INTO @año_actual;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DELETE FROM Top_10_Productos_Vendidos WHERE Año = @año_actual;

        INSERT INTO Top_10_Productos_Vendidos (Año, Producto, Total_Vendido)
        SELECT TOP 10 
               @año_actual AS Año,
               i.item_producto AS Producto,
               SUM(i.item_cantidad) AS [Total Vendido]
        FROM Factura AS f
        JOIN Item_Factura AS i
          ON f.fact_tipo + f.fact_sucursal + f.fact_numero = i.item_tipo + i.item_sucursal + i.item_numero
        WHERE YEAR(f.fact_fecha) = @año_actual
        GROUP BY i.item_producto
        ORDER BY SUM(i.item_cantidad) DESC;

        FETCH NEXT FROM cursor_años INTO @año_actual;
    END;

    CLOSE cursor_años;
    DEALLOCATE cursor_años;
END;
GO

-- TESTING


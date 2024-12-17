-- Realizar una función que dado un artículo y una fecha, retorne el stock que
-- existía a esa fecha


-- version 1

CREATE FUNCTION dbo.ej2_tsql_stock_art_fecha (@articulo CHAR(8), @fecha DATE)
RETURNS DECIMAL(12,2) --STOCK
AS
BEGIN
    DECLARE @stock DECIMAL(12,2)

    SELECT @stock = SUM(s.stoc_cantidad) - ISNULL(SUM(ifa.item_cantidad), 0)
    FROM Stock s
    LEFT JOIN Item_Factura ifa ON s.stoc_producto = ifa.item_producto
    LEFT JOIN Factura f ON f.fact_tipo = ifa.item_tipo 
                      AND f.fact_sucursal = ifa.item_sucursal   
                      AND f.fact_numero = ifa.item_numero
                      AND f.fact_fecha <= @fecha
    WHERE s.stoc_producto = @articulo
    GROUP BY s.stoc_producto

    RETURN ISNULL(@stock, 0)
END

-- version 2

ALTER FUNCTION dbo.ej2_tsql_stock_art_fecha_v2 (@articulo CHAR(8), @fecha DATE)
RETURNS DECIMAL(12,2) --STOCK
AS
BEGIN
    DECLARE @stock_actual DECIMAL(12,2)
    DECLARE @stock_a_fecha DECIMAL(12,2)
    DECLARE @ventas_a_fecha DECIMAL(12,2)

    --Obtener stock actual de todos los depositos para ese producto
    SELECT @stock_actual = ISNULL(SUM(stoc_cantidad), 0)
    FROM Stock s
    WHERE s.stoc_producto = @articulo

    --Obtener ventas hasta la fecha
    SELECT @ventas_a_fecha = ISNULL(SUM(ifa.item_cantidad),0)
    FROM Item_Factura ifa
    LEFT JOIN Factura f ON f.fact_tipo = ifa.item_tipo 
                      AND f.fact_sucursal = ifa.item_sucursal   
                      AND f.fact_numero = ifa.item_numero
    WHERE ifa.item_producto = @articulo AND f.fact_fecha <= @fecha
    
    -- Calcular stock a la fecha
    SET @stock_a_fecha = ISNULL(@stock_actual - @ventas_a_fecha,0)

    RETURN @stock_a_fecha
END

SELECT * FROM STOCK

SELECT dbo.ej2_tsql_stock_art_fecha('TEST001', '2012-01-01') as 'Stock a fecha'
SELECT dbo.ej2_tsql_stock_art_fecha_v2('TEST001', '2012-01-01') as 'Stock a fecha'
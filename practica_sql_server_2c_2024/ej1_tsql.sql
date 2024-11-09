-- 1. 
-- Hacer una función que dado un artículo y un deposito devuelva un string que indique el estado del depósito según el artículo.
--  Si la cantidad almacenada es menor al límite retornar “OCUPACION DEL DEPOSITO XX %” siendo XX el % de ocupación. 
-- Si la cantidad almacenada es mayor o igual al límite retornar “DEPOSITO COMPLETO”.

-- 1. 
-- Hacer una función que dado un artículo y un deposito devuelva un string que indique el estado del depósito según el artículo.
--  Si la cantidad almacenada es menor al límite retornar “OCUPACION DEL DEPOSITO XX %” siendo XX el % de ocupación. 
-- Si la cantidad almacenada es mayor o igual al límite retornar “DEPOSITO COMPLETO”.
ALTER FUNCTION fn_estado_deposito (
    @articulo CHAR(8), 
    @deposito CHAR(2)
)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @stock_actual DECIMAL(12, 2);
    DECLARE @stock_maximo DECIMAL(12, 2);
    DECLARE @ocupacion_porcentaje DECIMAL(5, 2);
    DECLARE @resultado VARCHAR(50);
    -- Obtener el stock actual y el stock máximo del depósito
    SELECT 
        @stock_actual = stoc_cantidad, 
        @stock_maximo = stoc_stock_maximo
    FROM stock
    WHERE stoc_producto = @articulo
    AND stoc_deposito = @deposito;
    -- Calcular el porcentaje de ocupación del depósito
    IF @stock_maximo > 0
    BEGIN
        SET @ocupacion_porcentaje = (@stock_actual / @stock_maximo) * 100;
    END
    -- Verificar si el depósito está completo o no
    IF @stock_actual >= @stock_maximo
    BEGIN
        SET @resultado = 'DEPOSITO COMPLETO';
    END
    ELSE
    BEGIN
        SET @resultado = 'OCUPACION DEL DEPOSITO ' + CAST(@ocupacion_porcentaje AS VARCHAR(5)) + ' %';
    END
    RETURN @resultado;
END;
GO
-- Probar la función

SELECT dbo.fn_estado_deposito('00000102', '07')


-- OTRA SOLUCION

SELECT STOC_PRODUCTO,stoc_cantidad,stoc_deposito
FROM STOCK
WHERE STOC_PRODUCTO = '00000102'

SELECT STOC_PRODUCTO AS COD_PRODUCTO, STOC_DEPOSITO AS DEPOSITO ,SUM(stoc_cantidad) AS STOCK_ACTUAL,stoc_stock_maximo 
FROM STOCK 
GROUP BY STOC_PRODUCTO, stoc_stock_maximo,STOC_DEPOSITO
ORDER BY STOC_PRODUCTO

-- MODIFICAR PRODUCTO Y STOCK_ACTUAL

UPDATE STOCK
SET stoc_cantidad = 100
WHERE stoc_producto = '00000030' 

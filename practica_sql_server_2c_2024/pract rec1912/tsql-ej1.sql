-- Hacer una función que dado un artículo y un deposito devuelva un string que
-- indique el estado del depósito según el artículo. Si la cantidad almacenada es
-- menor al límite retornar “OCUPACION DEL DEPOSITO XX %” siendo XX el
-- % de ocupación. Si la cantidad almacenada es mayor o igual al límite retornar
-- “DEPOSITO COMPLETO”.

CREATE FUNCTION dbo.ej1_tsql_estado_deposito
    (@articulo CHAR(8), @deposito CHAR(2))
RETURNS VARCHAR(50)
AS 
BEGIN
    DECLARE @cantidad DECIMAL(12,2)
    DECLARE @maximo DECIMAL(12,2)
    DECLARE @resultado VARCHAR(50)

    -- Obtener cantidad y máximo del stock
    SELECT @cantidad = stoc_cantidad,
           @maximo = stoc_stock_maximo
    FROM STOCK 
    WHERE stoc_producto = @articulo  AND stoc_deposito = @deposito

    -- Verificar si existe el stock
    IF @cantidad IS NULL OR @maximo IS NULL
        RETURN 'NO EXISTE STOCK PARA EL ARTÍCULO/DEPÓSITO'

    -- Si el depósito está lleno entonces retornar "DEPOSITO COMPLETO"
    IF @cantidad >= @maximo
        SET @resultado = 'DEPOSITO COMPLETO'
    ELSE
        -- Si el depósito no está lleno entonces retornar "OCUPACION DEL DEPOSITO XX %"
        SET @resultado = 'OCUPACION DEL DEPOSITO ' + 
            CAST(CAST((@cantidad / @maximo * 100) AS DECIMAL(5,2)) AS VARCHAR(5)) + ' %'

    RETURN @resultado
END


-- HELPER
-- SELECT 
--       s.stoc_producto 'Producto',
--       s.stoc_deposito 'Deposito',
--       s.stoc_stock_maximo 'Stock Maximo',
--       SUM(s.stoc_cantidad) 'Cantidad almacenada'
-- FROM 
--     Stock s
-- -- STOCK >0
-- -- WHERE 
-- --     s.stoc_cantidad > 0
-- GROUP BY 
--     s.stoc_producto,
--     s.stoc_stock_maximo,
--     s.stoc_deposito
-- -- HAVING 
-- --     SUM(s.stoc_cantidad) > s.stoc_stock_maximo

-- -- Insertar datos de prueba
-- INSERT INTO STOCK (stoc_producto, stoc_deposito, stoc_cantidad, stoc_stock_maximo)
-- VALUES ('TEST001', '99', 100, 200)  -- 50% ocupado

-- -- EJECUTAR HELPER Y VERIFICAR CANTIDAD DEL STOCK PARA EL PRODUCTO 'TEST001' Y DEPOSITO '99'


-- -- Probar función
-- SELECT dbo.ej1_tsql_estado_deposito('TEST001', '99') as Estado


-- -- MODIFICAR DATOS DE PRUEBA
-- UPDATE STOCK
-- SET stoc_cantidad = 200 -- 100% ocupado
-- WHERE stoc_producto = 'TEST001' AND stoc_deposito = '99'

-- -- EJECUTAR HELPER Y VERIFICAR CANTIDAD DEL STOCK PARA EL PRODUCTO 'TEST001' Y DEPOSITO '99'

-- -- Probar función
-- SELECT dbo.ej1_tsql_estado_deposito('TEST001', '99') as Estado


-- SELECT * FROM Producto
-- SELECT * FROM Deposito

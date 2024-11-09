-- 3. Realizar una consulta que muestre 
-- código de producto, nombre de producto y el stock total,
--  sin importar en que deposito se encuentre, 
-- los datos deben ser ordenados por nombre del artículo de menor a mayor.

-- Version 1
-- MUESTRO INCLUSO EL DEPOSITO Y EL STOCK 
-- HASTA LOS STOCKS EN 0

SELECT 
    Producto.prod_codigo,
    Producto.prod_detalle,
    Deposito.depo_detalle as deposito,
    SUM(Stock.stoc_cantidad) as stock_total
FROM 
    dbo.Producto
INNER JOIN 
    dbo.Stock
    ON Producto.prod_codigo = Stock.stoc_producto
INNER JOIN 
    dbo.Deposito 
    ON Stock.stoc_deposito = Deposito.depo_codigo
GROUP BY
    Producto.prod_codigo,
    Producto.prod_detalle,
    Deposito.depo_detalle
-- HAVING 
--     SUM(Stock.stoc_cantidad) > 0
ORDER BY
    Producto.prod_detalle ASC;

-- Version 2

SELECT 
    Producto.prod_codigo, 
    Producto.prod_detalle, 
    SUM(Stock.stoc_cantidad) AS stock_total
FROM 
    dbo.Producto
INNER JOIN 
    dbo.Stock 
    ON Producto.prod_codigo = Stock.stoc_producto
GROUP BY 
    Producto.prod_codigo, 
    Producto.prod_detalle
HAVING 
    SUM(Stock.stoc_cantidad) > 0
ORDER BY 
    Producto.prod_detalle ASC;

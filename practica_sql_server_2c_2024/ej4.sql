-- 4. Realizar una consulta que muestre para todos los artículos 
-- código, detalle y cantidad de artículos que lo componen.
--  Mostrar solo aquellos artículos para los cuales el
-- stock promedio por depósito sea mayor a 100.

SELECT 
    Producto.prod_codigo,
    Producto.prod_detalle,
    SUM(Composicion.comp_cantidad) AS cantidad_total
FROM
    dbo.Producto
INNER JOIN
    dbo.Composicion
    ON Producto.prod_codigo = Composicion.comp_producto
INNER JOIN
    dbo.Stock
    ON Producto.prod_codigo = Stock.stoc_producto
GROUP BY
    Producto.prod_codigo,
    Producto.prod_detalle
HAVING
    AVG(Stock.stoc_cantidad) > 100
ORDER BY
    Producto.prod_codigo;
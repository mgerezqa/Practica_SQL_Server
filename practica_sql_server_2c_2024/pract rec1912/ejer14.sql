-- 14. Escriba una consulta que retorne una estadística de ventas por cliente. Los campos que
-- debe retornar son:
-- Código del cliente
-- Cantidad de veces que compro en el último año
-- Promedio por compra en el último año
-- Cantidad de productos diferentes que compro en el último año
-- Monto de la mayor compra que realizo en el último año
-- Se deberán retornar todos los clientes ordenados por la cantidad de veces que compro en
-- el último año.
-- No se deberán visualizar NULLs en ninguna columna


SELECT
    f.fact_cliente AS 'Codigo Cliente',
    COUNT(DISTINCT f.fact_numero) AS 'Compras realizadas',
    AVG(f.fact_total) AS 'Promedio por compra',
    COUNT(DISTINCT ifa.item_producto) AS 'Cantidad productos',
    MAX(f.fact_total) AS 'Mayor Compra $'
FROM
    Factura f
JOIN
    Item_Factura ifa
    ON f.fact_tipo = ifa.item_tipo 
    AND f.fact_sucursal = ifa.item_sucursal   
    AND f.fact_numero = ifa.item_numero 
-- obtener un año especifico WHERE  YEAR(f.fact_fecha) = 2012 
-- obtener el año anterior al año actual WHERE YEAR(GETDATE()) - 1
WHERE YEAR(fact_fecha) = (SELECT MAX(YEAR(fact_fecha)) FROM Factura)

GROUP BY
    f.fact_cliente
ORDER BY
    COUNT(f.fact_numero) DESC;

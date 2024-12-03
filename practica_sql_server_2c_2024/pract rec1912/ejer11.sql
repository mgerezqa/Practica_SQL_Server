-- Realizar una consulta que retorne el detalle de la familia, la cantidad de diferentes 
-- productos vendidos y el monto de dichas ventas sin impuestos. Los datos se deberán
-- ordenar de mayor a menor, por la familia que más productos diferentes vendidos tenga,
-- solo se deberán mostrar las familias que tengan una venta superior a 20000 pesos para
-- el año 2012.

SELECT
    fam.fami_detalle 'Detalle de familia',
    COUNT(DISTINCT ifa.item_producto) 'Cantidad de productos distintos vendidos',
    SUM(ISNULL(f.fact_total,0)) - SUM(ISNULL(f.fact_total_impuestos,0)) 'Venta sin impuestos'
FROM
    Factura f
JOIN Item_Factura ifa 			
    ON f.fact_tipo = ifa.item_tipo
    AND f.fact_sucursal = ifa.item_sucursal 
    AND f.fact_numero = ifa.item_numero
JOIN
    Producto p
    ON ifa.item_producto = p.prod_codigo
JOIN
    Familia fam
    ON p.prod_familia = fam.fami_id

WHERE YEAR(F.fact_fecha) = 2012 

GROUP BY
    ifa.item_producto,
    fam.fami_detalle,
    fam.fami_id --limita la consulta, buena idea.
HAVING
    (SUM(ISNULL(f.fact_total,0)) - SUM(ISNULL(f.fact_total_impuestos,0)))>20000
ORDER BY COUNT(DISTINCT P.prod_codigo) DESC


-- HELPERS ---
SELECT * FROM Familia
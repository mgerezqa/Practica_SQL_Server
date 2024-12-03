-- Ejer12
-- Mostrar nombre de producto, 
-- Cantidad de clientes distintos que lo compraron 
-- Importe promedio pagado por el producto, 
-- Stock actual del producto en todos los depósitos.
-- Cantidad de depósitos en los cuales hay stock del producto 
-- Se deberán mostrar aquellos productos que hayan tenido operaciones en el año 2012 y los datos deberán
-- ordenarse de mayor a menor por monto vendido del producto.


SELECT
p.prod_detalle 'Nombre del producto',
COUNT(DISTINCT fact_cliente) 'Cantidad de compradores',
AVG(ifa.item_precio) 'Precio promedio',
SUM(s.stoc_cantidad) 'Stock Total en todos los depósitos',
COUNT(DISTINCT s.stoc_deposito) 'Cantidad de depositos con stock'
FROM
    Producto p
JOIN
    Item_Factura ifa 		
    on p.prod_codigo = ifa.item_producto
JOIN Factura f
    ON  ifa.item_tipo = f.fact_tipo
    AND ifa.item_sucursal = f.fact_sucursal  
    AND  ifa.item_numero = f.fact_numero
JOIN
    Stock s
    ON  prod_codigo = s.stoc_producto
JOIN
    Cliente C
    ON fact_cliente = clie_codigo

WHERE YEAR(fact_fecha) = 2012

GROUP BY prod_codigo,
         p.prod_detalle
HAVING
        SUM(s.stoc_cantidad) > 0
ORDER BY (AVG(ifa.item_precio)) DESC
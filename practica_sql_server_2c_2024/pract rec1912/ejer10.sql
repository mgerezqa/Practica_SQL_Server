-- Mostrar los 10 productos más vendidos en la historia y también los 10 productos menos
-- vendidos en la historia y quien fue el cliente que más los compro.


SELECT
       p.prod_detalle as Detalle_producto,
    -- (Subquery para pedir el cliente que mas compro)
       (SELECT TOP 1 fact_cliente
        FROM Factura f
        JOIN Item_Factura ifa 			
        ON f.fact_tipo = ifa.item_tipo
        AND f.fact_sucursal = ifa.item_sucursal 
        AND f.fact_numero = ifa.item_numero
        WHERE ifa.item_producto = p.prod_codigo
        GROUP BY fact_cliente
        ORDER BY SUM(ifa.item_cantidad) ASC) AS Cliente_que_mas_compro

FROM 
     Producto p
WHERE
    p.prod_codigo IN(
        SELECT TOP 10 
        ifa.item_producto
        FROM Item_Factura ifa
        GROUP BY ifa.item_producto
        ORDER BY sum(ifa.item_cantidad) DESC
        )

    OR
    p.prod_codigo IN(
        SELECT TOP 10 
        ifa.item_producto
        FROM Item_Factura ifa
        GROUP BY ifa.item_producto
        ORDER BY sum(ifa.item_cantidad) ASC
        )
   

-- HELPERS
SELECT TOP 1
    clie_codigo,
    clie_razon_social,
    count(f.fact_cliente) as cantidad_de_compras,
    sum(ifa.item_precio) as total_gastado
FROM
    Cliente c
JOIN
    Factura f 
    on c.clie_codigo = f.fact_cliente
JOIN
    Item_Factura ifa 
    on f.fact_tipo = ifa.item_tipo
    and f.fact_sucursal = ifa.item_sucursal
    and f.fact_numero = ifa.item_numero

GROUP BY
    clie_codigo,
    clie_razon_social

ORDER BY total_gastado DESC

-- LOS 10 MAS VENDIDOS
SELECT TOP 10
    p.prod_codigo,
    p.prod_detalle,
    SUM(ifa.item_cantidad) as cantidad_vendida
FROM
    Producto p
JOIN
    Item_factura ifa on p.prod_codigo = ifa.item_producto
JOIN
    Factura f on ifa.item_tipo = f.fact_tipo 
    and ifa.item_sucursal = f.fact_sucursal
    and ifa.item_numero = f.fact_numero

GROUP BY
    p.prod_codigo,
    p.prod_detalle
ORDER BY
    cantidad_vendida DESC

-- LOS 10 MENOS VENDIDOS
SELECT TOP 10
    p.prod_codigo,
    p.prod_detalle,
    SUM(ifa.item_cantidad) as cantidad_vendida
FROM
    Producto p
JOIN
    Item_factura ifa on p.prod_codigo = ifa.item_producto
JOIN
    Factura f on ifa.item_tipo = f.fact_tipo 
    and ifa.item_sucursal = f.fact_sucursal
    and ifa.item_numero = f.fact_numero

GROUP BY
    p.prod_codigo,
    p.prod_detalle
ORDER BY
    cantidad_vendida ASC



-- 


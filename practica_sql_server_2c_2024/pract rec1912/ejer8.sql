-- Mostrar para el o los artículos que tengan stock en todos los depósitos, nombre del
-- artículo, stock del depósito que más stock tiene del articulo.



-- Mostrar los artículos que tengan stock en todos los depósitos

SELECT 
    prod_codigo,
    prod_detalle,
    MAX(s.stoc_cantidad) as max_stock
FROM
    Producto p
JOIN
    Stock s on p.prod_codigo = s.stoc_producto and stoc_cantidad >0
JOIN
    Deposito d on depo_codigo = s.stoc_deposito

GROUP BY
    prod_codigo,
    prod_detalle

HAVING count(s.stoc_cantidad) = (Select Count(*) from DEPOSITO)
    
-- nombre del  artículo, stock del depósito que más stock tiene del articulo.
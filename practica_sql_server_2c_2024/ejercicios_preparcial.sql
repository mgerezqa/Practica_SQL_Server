-- EJERCICIOs preparcial

-- 1. Sabiendo que un producto recurrente es aquel producto que al menos
-- se compró durante 6 meses en el último año.
-- Realizar una consulta SQL que muestre los clientes que tengan
-- productos recurrentes y de estos clientes mostrar:

-- i. El código de cliente.
-- ii. El nombre del producto más comprado del cliente.
-- iii. La cantidad comprada total del cliente en el último año.

-- Ordenar el resultado por el nombre del cliente alfabéticamente.


SELECT 
    c.clie_codigo AS codigo_del_cliente,
    c.clie_razon_social AS nombre,
    (SELECT TOP 1 
      p.prod_detalle 
     FROM Factura f2
  JOIN item_factura ifact2 ON f2.fact_tipo = ifact2.item_tipo 
      AND f2.fact_sucursal = ifact2.item_sucursal 
      AND f2.fact_numero = ifact2.item_numero
  JOIN producto p ON p.prod_codigo = ifact2.item_producto 
   WHERE  
    f2.fact_cliente = c.clie_codigo
   GROUP BY 
    ifact2.item_producto , p.prod_detalle 
   ORDER BY  
    sum(ifact2.item_cantidad) desc
    ),
    SUM(ifact.item_cantidad) AS cantidad
FROM Factura f
JOIN cliente c ON f.fact_cliente = c.clie_codigo
JOIN item_factura ifact ON f.fact_tipo = ifact.item_tipo 
    AND f.fact_sucursal = ifact.item_sucursal 
    AND f.fact_numero = ifact.item_numero
JOIN producto p ON ifact.item_producto = p.prod_codigo
WHERE 
 YEAR(f.fact_fecha) = 2012  
  GROUP BY 
   c.clie_codigo,
   c.clie_razon_social 
HAVING 
 COUNT(DISTINCT MONTH(f.fact_fecha)) >= 6
ORDER BY 
 c.clie_razon_social ASC





-- 1. Implementar una restricción que no deje realizar operaciones masivas
-- sobre la tabla cliente. En caso de que esto se intente se deberá
-- registrar que operación se intentó realizar , en que fecha y hora y sobre
-- que datos se trató de realizar.







-- Realizar una consulta SQL que muestre aquellos productos que tengan
-- entre 2 y 4 componentes distintos a nivel producto y cuyos
-- componentes no fueron todos vendidos (todos) en 2012 pero si en el
-- 2011.
-- De estos productos mostrar:
-- i. El código de producto.
-- ii. El nombre del producto.
-- iii. El precio máximo al que se vendió en 2011 el producto.
-- El resultado deberá ser ordenado por cantidad de unidades vendidas
-- del producto en el 2011.
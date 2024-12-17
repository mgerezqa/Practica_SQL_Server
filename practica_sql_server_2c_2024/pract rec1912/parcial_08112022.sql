/*
Realizar una consulta SQL que permita saber si un cliente compro un producto
en todos los meses del 2012.

Ademas mostrar para el 2012:

- El cliente
- La razon social del cliente
- El producto comprado
- El detalle del producto
- La cantidad de productos distintos comprados por el cliente.
- Cantidad de productos con composicion comprados por el cliente.

El resultado debera ser ordenado poniendo primero aquellos clientes que compraron
mas de 10 productos distintos en el 2012.

*/

SELECT 
    cl.clie_codigo AS 'Codigo de Cliente',
    cl.clie_razon_social AS 'Razon Social del Cliente',
    p.prod_codigo AS 'Producto comprado',
    p.prod_detalle AS 'Detalle del producto',
    (
        SELECT COUNT(DISTINCT i2.item_producto)
        FROM Factura f2
        INNER JOIN Item_Factura i2 ON f2.fact_tipo = i2.item_tipo 
            AND f2.fact_sucursal = i2.item_sucursal 
            AND f2.fact_numero = i2.item_numero
        WHERE f2.fact_cliente = cl.clie_codigo
        AND YEAR(f2.fact_fecha) = 2012
    ) AS 'Cantidad de productos distintos comprados por el cliente',
    (
        SELECT COUNT(DISTINCT i2.item_producto)
        FROM Factura f2
        INNER JOIN Item_Factura i2 ON f2.fact_tipo = i2.item_tipo 
            AND f2.fact_sucursal = i2.item_sucursal 
            AND f2.fact_numero = i2.item_numero
        INNER JOIN Composicion c ON i2.item_producto = c.comp_producto
        WHERE f2.fact_cliente = cl.clie_codigo
        AND YEAR(f2.fact_fecha) = 2012
    ) AS 'Cantidad de productos con composicion comprados por el cliente'
FROM Cliente cl
INNER JOIN Factura f ON cl.clie_codigo = f.fact_cliente
INNER JOIN Item_Factura i ON f.fact_tipo = i.item_tipo 
    AND f.fact_sucursal = i.item_sucursal 
    AND f.fact_numero = i.item_numero
INNER JOIN Producto p ON i.item_producto = p.prod_codigo
WHERE YEAR(f.fact_fecha) = 2012
AND EXISTS ( -- El cliente compro un producto en todos los meses del 2012
    SELECT 1
    FROM (
        SELECT MONTH(f2.fact_fecha) AS mes
        FROM Factura f2
        INNER JOIN Item_Factura i2 ON f2.fact_tipo = i2.item_tipo 
            AND f2.fact_sucursal = i2.item_sucursal 
            AND f2.fact_numero = i2.item_numero
        WHERE f2.fact_cliente = cl.clie_codigo
        AND i2.item_producto = p.prod_codigo
        AND YEAR(f2.fact_fecha) = 2012
        GROUP BY MONTH(f2.fact_fecha)
    ) meses
    HAVING COUNT(*) = 12
)
GROUP BY 
    cl.clie_codigo, 
    cl.clie_razon_social, 
    p.prod_codigo,
    p.prod_detalle
HAVING ( -- Clientes que compraron mas de 10 productos distintos en el 2012
    SELECT COUNT(DISTINCT i2.item_producto)
    FROM Factura f2
    INNER JOIN Item_Factura i2 ON f2.fact_tipo = i2.item_tipo 
        AND f2.fact_sucursal = i2.item_sucursal 
        AND f2.fact_numero = i2.item_numero
    WHERE f2.fact_cliente = cl.clie_codigo
    AND YEAR(f2.fact_fecha) = 2012
) >= 10
ORDER BY 
    'Cantidad de productos distintos comprados por el cliente' DESC --Ordenar por cantidad de productos distintos comprados por el cliente

/*Realizar una consulta SQL que retorne para el año 2012
y solo para los clientes que tuvieron al menos una compra en dicho periodo:

Razón social del cliente
Cantidad de productos comprados en ese año redondeando sin decimales
Total de impuestos de ese año (fact_total_impuestos)
Producto mas comprado en ese año por ese cliente
Producto mas comprado en la historia  por ese cliente

El resultado debe ser ordenado colocando primero los clientes que compraron por primera
vez en ese año y luego por razón social.
*/

SELECT 
    c.clie_razon_social,
    COUNT(DISTINCT f.fact_numero) as 'Cantidad de compras',
    SUM(f.fact_total_impuestos) as total_impuestos,
    (
        SELECT TOP 1 i.item_producto
        FROM Item_Factura i
        JOIN Factura f2 
            ON i.item_tipo = f2.fact_tipo 
            AND i.item_sucursal = f2.fact_sucursal 
            AND i.item_numero = f2.fact_numero
        WHERE f2.fact_cliente = f.fact_cliente AND YEAR(f2.fact_fecha) = 2012
        GROUP BY i.item_producto
        ORDER BY SUM(i.item_cantidad) DESC
    ) as 'Producto mas comprado en el año',
    (
        SELECT TOP 1 i.item_producto
        FROM Item_Factura i
        JOIN Factura f2 
            ON i.item_tipo = f2.fact_tipo 
            AND i.item_sucursal = f2.fact_sucursal 
            AND i.item_numero = f2.fact_numero
        WHERE f2.fact_cliente = f.fact_cliente
        GROUP BY i.item_producto
        ORDER BY SUM(i.item_cantidad) DESC
    ) as 'Producto mas comprado de la historia'
FROM Cliente c
INNER JOIN Factura f 
    ON c.clie_codigo = f.fact_cliente
WHERE YEAR(f.fact_fecha) = 2012
GROUP BY 
    c.clie_razon_social,
    f.fact_cliente
HAVING COUNT(DISTINCT f.fact_numero) > 0
ORDER BY 
    MIN(f.fact_fecha) ASC,
    c.clie_razon_social ASC;
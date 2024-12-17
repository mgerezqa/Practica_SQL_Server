/* Realizar una consulta SQL que retorne para todas las zonas que tengan 3 o mas depósitos.

Detalle Zona
Cantidad de Depositos x Zona
Cantidad de productos distintos compuestos en sus depositos
Producto mas vendido en el año 2012 que tenga stock en al menos uno de sus depósitos
Mejor encargado perteneciente a esa zona (El que mas vendio en la historia)

El resultado debera ser ordenado por monto total vendido del encargado descendiente.
*/
SELECT 
    z.zona_codigo AS 'Codigo de Zona',
    z.zona_detalle AS 'Detalle de Zona',
    COUNT(d.depo_codigo) AS 'Cantidad de Depositos x Zona',
    (
        SELECT COUNT(DISTINCT c.comp_producto)
        FROM Composicion c
        INNER JOIN STOCK s ON c.comp_componente = s.stoc_producto
        INNER JOIN DEPOSITO d2 ON s.stoc_deposito = d2.depo_codigo
        WHERE d2.depo_zona = z.zona_codigo
    ) AS 'Cantidad de productos distintos compuestos en sus depositos',
    (
        SELECT TOP 1 p.prod_detalle
        FROM Producto p
        INNER JOIN Item_Factura i ON p.prod_codigo = i.item_producto
        INNER JOIN Factura f ON i.item_tipo = f.fact_tipo 
            AND i.item_sucursal = f.fact_sucursal 
            AND i.item_numero = f.fact_numero
        INNER JOIN STOCK s ON p.prod_codigo = s.stoc_producto
        INNER JOIN DEPOSITO d2 ON s.stoc_deposito = d2.depo_codigo
        WHERE d2.depo_zona = z.zona_codigo
            AND YEAR(f.fact_fecha) = 2012
        GROUP BY p.prod_codigo,prod_detalle
        ORDER BY SUM(i.item_cantidad) DESC
    ) AS 'Producto mas vendido en el año 2012 que tenga stock en al menos uno de sus depósitos',
    (
        SELECT TOP 1 e.empl_apellido + ', ' + e.empl_nombre
        FROM Empleado e
        INNER JOIN Factura f ON e.empl_codigo = f.fact_vendedor
        INNER JOIN DEPOSITO d2 ON e.empl_codigo = d2.depo_encargado
        WHERE d2.depo_zona = z.zona_codigo
        GROUP BY e.empl_codigo, e.empl_apellido, e.empl_nombre
        ORDER BY SUM(f.fact_total) DESC
    ) AS 'Mejor encargado perteneciente a esa zona (El que mas vendio en la historia)'
FROM Zona z
INNER JOIN DEPOSITO d ON z.zona_codigo = d.depo_zona
GROUP BY z.zona_codigo, z.zona_detalle
HAVING COUNT(d.depo_codigo) >= 3
ORDER BY (
    SELECT SUM(f.fact_total)
    FROM Factura f
    WHERE f.fact_vendedor = (
        SELECT TOP 1 e.empl_codigo
        FROM Empleado e
        INNER JOIN DEPOSITO d2 ON e.empl_codigo = d2.depo_encargado
        WHERE d2.depo_zona = z.zona_codigo
        GROUP BY e.empl_codigo
        ORDER BY (
            SELECT SUM(f2.fact_total)
            FROM Factura f2
            WHERE f2.fact_vendedor = e.empl_codigo
        ) DESC
    )
) DESC
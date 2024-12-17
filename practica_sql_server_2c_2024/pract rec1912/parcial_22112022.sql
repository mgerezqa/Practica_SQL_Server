/*Realizar una consulta SQL que muestre aquellos productos que tengan
3 componentes a nivel producto y cuyos componentes tengan 2 rubros distinos.

De estos productos mostrar:
- Codigo del producto
- Detalle del producto
- Cantidad de veces que fueron vendidos sus componentes en el 2012
- Monto total vendido del producto

El resultado deberá ser ordenado por cantidad de facturas del 2012 en las cuales se vendieron los componentes.
*/

SELECT 
    p.prod_codigo AS 'Codigo del producto',
    p.prod_detalle AS 'Detalle del producto',
    ISNULL((
        SELECT COUNT(*)
        FROM Factura fac
        INNER JOIN Item_Factura itf 
            ON fac.fact_tipo = itf.item_tipo
            AND fac.fact_sucursal = itf.item_sucursal
            AND fac.fact_numero = itf.item_numero
        INNER JOIN Composicion c 
            ON itf.item_producto = c.comp_componente
            AND c.comp_producto = p.prod_codigo
        WHERE YEAR(fac.fact_fecha) = 2012
    ), 0) AS 'Cantidad de veces que fueron vendidos sus componentes en el 2012',
    ISNULL((
        SELECT SUM(itf.item_cantidad * itf.item_precio)
        FROM Factura fac
        INNER JOIN Item_Factura itf 
            ON fac.fact_tipo = itf.item_tipo
            AND fac.fact_sucursal = itf.item_sucursal
            AND fac.fact_numero = itf.item_numero
        WHERE itf.item_producto = p.prod_codigo
    ), 0) AS 'Monto total vendido del producto'
FROM Producto p
WHERE p.prod_codigo IN (
    SELECT comp_producto
    FROM Composicion c1
    INNER JOIN Producto p1 ON c1.comp_componente = p1.prod_codigo
    GROUP BY comp_producto
    HAVING COUNT(*) > 1 -- Productos con exactamente 3 componentes
    AND COUNT(DISTINCT p1.prod_rubro) > 1 -- Componentes pertenecen a 2 rubros distintos
)
ORDER BY (
    SELECT COUNT(DISTINCT fac.fact_tipo + fac.fact_sucursal + fac.fact_numero)
    FROM Factura fac
    INNER JOIN Item_Factura itf 
        ON fac.fact_tipo = itf.item_tipo
        AND fac.fact_sucursal = itf.item_sucursal
        AND fac.fact_numero = itf.item_numero
    INNER JOIN Composicion c 
        ON itf.item_producto = c.comp_componente
        AND c.comp_producto = p.prod_codigo
    WHERE YEAR(fac.fact_fecha) = 2012
) DESC



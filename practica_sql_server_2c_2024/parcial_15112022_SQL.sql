-- Realizar una consulta SQL que permita saber los clientes que compraron todos los rubros disponibles del sistema en el 2012.

-- De estos clientes mostrar, siempre para el 2012:
-- 1. El codigo del cliente
-- 2. Código de producto que en cantidades más compró y su nombre.
-- 4. Cantidad de productos distintos comprados por el cliente.
-- 5. Cantidad de productos con composición comprados por el cliente.

-- El resultado deberá mostrado y ordenado estableciendo la siguiente prioridad :
-- alfábeticamente ascendente segun la  razón social del cliente 
-- los clientes que compraron entre un 20% y 30% del total facturado en el 2012 
-- los que no cumplan las condiciones anteriores.

-- Restricción:
-- No se permiten select en el from, es decir, select....from(select..) as T,....
-- No se permite Common Table Expressions, CTEs
-- No se permite el uso de variables
-- No se permite el uso de tablas temporales

SELECT 
    c.clie_codigo,
    c.clie_razon_social,
    (SELECT TOP 1 i.item_producto
     FROM Factura f
     JOIN Item_Factura i ON f.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal AND f.fact_numero = i.item_numero
     WHERE f.fact_cliente = c.clie_codigo AND YEAR(f.fact_fecha) = 2012
     GROUP BY i.item_producto
     ORDER BY SUM(i.item_cantidad) DESC) AS producto_mas_comprado,
    (SELECT TOP 1 p.prod_detalle
     FROM Factura f
     JOIN Item_Factura i ON f.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal AND f.fact_numero = i.item_numero
     JOIN Producto p ON i.item_producto = p.prod_codigo
     WHERE f.fact_cliente = c.clie_codigo AND YEAR(f.fact_fecha) = 2012
     GROUP BY p.prod_detalle
     ORDER BY SUM(i.item_cantidad) DESC) AS nombre_producto_mas_comprado,
    (SELECT COUNT(DISTINCT i.item_producto)
     FROM Factura f
     JOIN Item_Factura i ON f.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal AND f.fact_numero = i.item_numero
     WHERE f.fact_cliente = c.clie_codigo AND YEAR(f.fact_fecha) = 2012) AS productos_distintos_comprados,
    (SELECT COUNT(DISTINCT i.item_producto)
     FROM Factura f
     JOIN Item_Factura i ON f.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal AND f.fact_numero = i.item_numero
     JOIN Composicion comp ON i.item_producto = comp.comp_producto
     WHERE f.fact_cliente = c.clie_codigo AND YEAR(f.fact_fecha) = 2012) AS productos_con_composicion,
    CASE 
        WHEN EXISTS (
            SELECT 1
            FROM Factura f
            JOIN Item_Factura i ON f.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal AND f.fact_numero = i.item_numero
            JOIN Producto p ON i.item_producto = p.prod_codigo
            WHERE f.fact_cliente = c.clie_codigo AND YEAR(f.fact_fecha) = 2012
            GROUP BY f.fact_cliente
            HAVING COUNT(DISTINCT p.prod_rubro) = (SELECT COUNT(*) FROM Rubro)
        ) THEN 1
        WHEN (SELECT SUM(f.fact_total) * 100.0 / (SELECT SUM(fact_total) FROM Factura WHERE YEAR(fact_fecha) = 2012)
              FROM Factura f
              WHERE f.fact_cliente = c.clie_codigo AND YEAR(f.fact_fecha) = 2012) BETWEEN 20 AND 30 THEN 2
        ELSE 3
    END AS prioridad
FROM Cliente c
ORDER BY 
    prioridad,
    c.clie_razon_social;

-- 

SELECT 
    c.clie_codigo,
    (
        SELECT TOP 1 
            CONCAT(p1.prod_codigo, ' - ', RTRIM(p1.prod_detalle))
        FROM Producto p1
            JOIN Item_Factura if1 ON p1.prod_codigo = if1.item_producto
            JOIN Factura f1 ON if1.item_tipo = f1.fact_tipo 
                AND if1.item_sucursal = f1.fact_sucursal 
                AND if1.item_numero = f1.fact_numero
        WHERE f1.fact_cliente = c.clie_codigo 
            AND YEAR(f1.fact_fecha) = 2012
        GROUP BY p1.prod_codigo, p1.prod_detalle
        ORDER BY SUM(if1.item_cantidad) DESC
    ) as producto_mas_comprado,
    (
        SELECT COUNT(DISTINCT if2.item_producto)
        FROM Item_Factura if2
            JOIN Factura f2 ON if2.item_tipo = f2.fact_tipo 
                AND if2.item_sucursal = f2.fact_sucursal 
                AND if2.item_numero = f2.fact_numero
        WHERE f2.fact_cliente = c.clie_codigo 
            AND YEAR(f2.fact_fecha) = 2012
    ) as cantidad_productos_distintos,
    (
        SELECT COUNT(DISTINCT if3.item_producto)
        FROM Item_Factura if3
            JOIN Factura f3 ON if3.item_tipo = f3.fact_tipo 
                AND if3.item_sucursal = f3.fact_sucursal 
                AND if3.item_numero = f3.fact_numero
            JOIN Producto p3 ON if3.item_producto = p3.prod_codigo
            JOIN Composicion comp ON p3.prod_codigo = comp.comp_producto
        WHERE f3.fact_cliente = c.clie_codigo 
            AND YEAR(f3.fact_fecha) = 2012
    ) as cantidad_productos_con_composicion
FROM Cliente c
WHERE (
    -- Cantidad de rubros distintos que compró el cliente en 2012
    SELECT COUNT(DISTINCT p4.prod_rubro)
    FROM Factura f4
        JOIN Item_Factura if4 ON f4.fact_tipo = if4.item_tipo 
            AND f4.fact_sucursal = if4.item_sucursal 
            AND f4.fact_numero = if4.item_numero
        JOIN Producto p4 ON if4.item_producto = p4.prod_codigo
    WHERE f4.fact_cliente = c.clie_codigo 
        AND YEAR(f4.fact_fecha) = 2012
) = (
    -- Total de rubros distintos en el sistema
    SELECT COUNT(DISTINCT prod_rubro) 
    FROM Producto
)
ORDER BY 
    -- Primer criterio: Clientes que compraron entre 20% y 30% del total facturado
    CASE 
        WHEN (
            SELECT SUM(f5.fact_total)
            FROM Factura f5
            WHERE f5.fact_cliente = c.clie_codigo 
                AND YEAR(f5.fact_fecha) = 2012
        ) BETWEEN (
            SELECT 0.20 * SUM(fact_total)
            FROM Factura
            WHERE YEAR(fact_fecha) = 2012
        ) AND (
            SELECT 0.30 * SUM(fact_total)
            FROM Factura
            WHERE YEAR(fact_fecha) = 2012
        ) THEN 1
        ELSE 2
    END,
    -- Segundo criterio: Razón social alfabéticamente
    c.clie_razon_social ASC;

-- Realizar una consulta SQL que perminta saber los clientes que compraron por encima del promedio de compras (fact_total) de todos los clientes del 2012.

-- De estos clientes mostrar para el 2012:
-- 1. El codigo del cliente
-- 2. La razón social del cliente
-- 3. Código de producto que en cantidades más compró
-- 4. El nombre del producto del punto 3
-- 5. Cantidad de productos distintos comprados por el cliente
-- 6. Cantidad de productos con composición comprados por el cliente

-- El resultado deberá ser ordenado poniendo primero aquellos clientes
-- que compraron mas de entre 5 y 10 productos distintos en el 2012

-- Restricción:
-- No se permiten select en el from, es decir, select....from(select..) as T,....
-- No se permite Common Table Expressions, CTEs
-- No se permite el uso de variables


WITH PromedioCompras2012 AS (
    SELECT AVG(fact_total) as promedio_compras
    FROM Factura
    WHERE YEAR(fact_fecha) = 2012
),
ComprasCliente2012 AS (
    SELECT 
        C.clie_codigo,
        C.clie_razon_social,
        SUM(F.fact_total) as total_compras
    FROM Cliente C
    INNER JOIN Factura F ON F.fact_cliente = C.clie_codigo
    WHERE YEAR(F.fact_fecha) = 2012
    GROUP BY C.clie_codigo, C.clie_razon_social
    HAVING SUM(F.fact_total) > (SELECT promedio_compras FROM PromedioCompras2012)
),
ProductosMasComprados AS (
    SELECT 
        F.fact_cliente,
        IT.item_producto,
        P.prod_detalle,
        SUM(IT.item_cantidad) as cantidad_total,
        ROW_NUMBER() OVER (PARTITION BY F.fact_cliente ORDER BY SUM(IT.item_cantidad) DESC) as rn
    FROM Factura F
    INNER JOIN Item_Factura IT ON F.fact_tipo = IT.item_tipo 
        AND F.fact_sucursal = IT.item_sucursal 
        AND F.fact_numero = IT.item_numero
    INNER JOIN Producto P ON P.prod_codigo = IT.item_producto
    WHERE YEAR(F.fact_fecha) = 2012
    GROUP BY F.fact_cliente, IT.item_producto, P.prod_detalle
),
EstadisticasCliente AS (
    SELECT 
        F.fact_cliente,
        COUNT(DISTINCT IT.item_producto) as productos_distintos,
        COUNT(DISTINCT CASE WHEN CO.comp_producto IS NOT NULL THEN IT.item_producto END) as productos_compuestos
    FROM Factura F
    INNER JOIN Item_Factura IT ON F.fact_tipo = IT.item_tipo 
        AND F.fact_sucursal = IT.item_sucursal 
        AND F.fact_numero = IT.item_numero
    LEFT JOIN Composicion CO ON CO.comp_producto = IT.item_producto
    WHERE YEAR(F.fact_fecha) = 2012
    GROUP BY F.fact_cliente
)
SELECT 
    CC.clie_codigo,
    CC.clie_razon_social,
    PM.item_producto as producto_mas_comprado,
    PM.prod_detalle as nombre_producto,
    EC.productos_distintos,
    EC.productos_compuestos
FROM ComprasCliente2012 CC
INNER JOIN ProductosMasComprados PM ON PM.fact_cliente = CC.clie_codigo AND PM.rn = 1
INNER JOIN EstadisticasCliente EC ON EC.fact_cliente = CC.clie_codigo
ORDER BY 
    CASE WHEN EC.productos_distintos BETWEEN 5 AND 10 THEN 0 ELSE 1 END,
    EC.productos_distintos DESC;

-- ---------------------------------------------------------------------------------------------------
-- Alternativa sin CTES
-- ---------------------------------------------------------------------------------------------------

SELECT 
    c.clie_codigo,
    RTRIM(c.clie_razon_social) as razon_social,
    (
        SELECT TOP 1 
            p1.prod_codigo
        FROM Producto p1
            JOIN Item_Factura if1 ON p1.prod_codigo = if1.item_producto
            JOIN Factura f1 ON if1.item_tipo = f1.fact_tipo 
                AND if1.item_sucursal = f1.fact_sucursal 
                AND if1.item_numero = f1.fact_numero
        WHERE f1.fact_cliente = c.clie_codigo 
            AND YEAR(f1.fact_fecha) = 2012
        GROUP BY p1.prod_codigo
        ORDER BY SUM(if1.item_cantidad) DESC
    ) as producto_mas_comprado,
    (
        SELECT TOP 1 
            RTRIM(p2.prod_detalle)
        FROM Producto p2
            JOIN Item_Factura if2 ON p2.prod_codigo = if2.item_producto
            JOIN Factura f2 ON if2.item_tipo = f2.fact_tipo 
                AND if2.item_sucursal = f2.fact_sucursal 
                AND if2.item_numero = f2.fact_numero
        WHERE f2.fact_cliente = c.clie_codigo 
            AND YEAR(f2.fact_fecha) = 2012
        GROUP BY p2.prod_codigo, p2.prod_detalle
        ORDER BY SUM(if2.item_cantidad) DESC
    ) as nombre_producto,
    (
        SELECT COUNT(DISTINCT if3.item_producto)
        FROM Item_Factura if3
            JOIN Factura f3 ON if3.item_tipo = f3.fact_tipo 
                AND if3.item_sucursal = f3.fact_sucursal 
                AND if3.item_numero = f3.fact_numero
        WHERE f3.fact_cliente = c.clie_codigo 
            AND YEAR(f3.fact_fecha) = 2012
    ) as cantidad_productos_distintos,
    (
        SELECT COUNT(DISTINCT if4.item_producto)
        FROM Item_Factura if4
            JOIN Factura f4 ON if4.item_tipo = f4.fact_tipo 
                AND if4.item_sucursal = f4.fact_sucursal 
                AND if4.item_numero = f4.fact_numero
            JOIN Producto p4 ON if4.item_producto = p4.prod_codigo
            JOIN Composicion comp ON p4.prod_codigo = comp.comp_producto
        WHERE f4.fact_cliente = c.clie_codigo 
            AND YEAR(f4.fact_fecha) = 2012
    ) as cantidad_productos_con_composicion
FROM Cliente c
WHERE (
    SELECT SUM(f5.fact_total)
    FROM Factura f5
    WHERE f5.fact_cliente = c.clie_codigo 
        AND YEAR(f5.fact_fecha) = 2012
) > (
    SELECT AVG(fact_total)
    FROM Factura
    WHERE YEAR(fact_fecha) = 2012
)
ORDER BY 
    CASE 
        WHEN (
            SELECT COUNT(DISTINCT if6.item_producto)
            FROM Item_Factura if6
                JOIN Factura f6 ON if6.item_tipo = f6.fact_tipo 
                    AND if6.item_sucursal = f6.fact_sucursal 
                    AND if6.item_numero = f6.fact_numero
            WHERE f6.fact_cliente = c.clie_codigo 
                AND YEAR(f6.fact_fecha) = 2012
        ) BETWEEN 5 AND 10 THEN 0
        ELSE 1
    END,
    c.clie_codigo;
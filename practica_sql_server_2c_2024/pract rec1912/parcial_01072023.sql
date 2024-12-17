/*Realizar una consulta SQL que muestre aquellos clientes que en 2 años consecutivos compraron

De estos clientes mostrar: 

i. El código de cliente.
ii.El nombre del cliente.
iii. El numero de rubros que compro el cliente
iv. La cantidad de productos con composición que compro el cliente en el 2012.

El resultado deberá ser ordenado por cantidad de facturas del cliente en toda la historia, de manera ascendente.
*/

SELECT 
    cl.clie_codigo AS 'Codigo de Cliente',
    cl.clie_razon_social AS 'Nombre del Cliente',
    (SELECT 
     COUNT(DISTINCT rubr_id)
     FROM
     Item_Factura ifr
     INNER JOIN Producto pr ON ifr.item_producto = pr.prod_codigo
     INNER JOIN Rubro r ON pr.prod_rubro = r.rubr_id
    INNER JOIN Factura f2 ON ifr.item_tipo = f2.fact_tipo 
        AND ifr.item_sucursal = f2.fact_sucursal 
        AND ifr.item_numero = f2.fact_numero
        WHERE f2.fact_cliente = cl.clie_codigo
        ) 
    'Numero de rubros que compro el cliente',
    (SELECT
    COUNT(DISTINCT cp.comp_producto)
    FROM Item_Factura ifc
    INNER JOIN Factura f2 ON ifc.item_tipo = f2.fact_tipo 
        AND ifc.item_sucursal = f2.fact_sucursal 
        AND ifc.item_numero = f2.fact_numero
    INNER JOIN Producto p ON ifc.item_producto = p.prod_codigo
    INNER JOIN Composicion cp ON p.prod_codigo = cp.comp_producto
    WHERE f2.fact_cliente = cl.clie_codigo
    AND YEAR(f2.fact_fecha) = 2012)
    'Cantidad de productos con composicion que compro el cliente en el 2012'
FROM Cliente cl
GROUP BY
    cl.clie_codigo,
    cl.clie_razon_social
HAVING 
    EXISTS (
        SELECT YEAR(f2.fact_fecha)
        FROM Factura f2
        WHERE f2.fact_cliente = cl.clie_codigo
        AND YEAR(f2.fact_fecha) + 1 IN (
            SELECT YEAR(f3.fact_fecha)
            FROM Factura f3
            WHERE f3.fact_cliente = cl.clie_codigo
        )
    )
ORDER BY (
    SELECT COUNT(*)
    FROM Factura f 
    WHERE f.fact_cliente = cl.clie_codigo
) ASC


-- USANDO WHERE EXISTS

SELECT 
    cl.clie_codigo AS 'Codigo de Cliente',
    cl.clie_razon_social AS 'Nombre del Cliente',
    (SELECT 
        COUNT(DISTINCT r.rubr_id)
        FROM Item_Factura ifa
        INNER JOIN Producto p ON ifa.item_producto = p.prod_codigo
        INNER JOIN Rubro r ON p.prod_rubro = r.rubr_id
        INNER JOIN Factura f2 ON ifa.item_tipo = f2.fact_tipo 
            AND ifa.item_sucursal = f2.fact_sucursal 
            AND ifa.item_numero = f2.fact_numero
        WHERE f2.fact_cliente = cl.clie_codigo
    ) AS 'Numero de rubros que compro el cliente',
    (SELECT 
        COUNT(DISTINCT cp.comp_producto)
        FROM Item_Factura ifa
        INNER JOIN Factura f2 ON ifa.item_tipo = f2.fact_tipo 
            AND ifa.item_sucursal = f2.fact_sucursal 
            AND ifa.item_numero = f2.fact_numero
        INNER JOIN Producto p ON ifa.item_producto = p.prod_codigo
        INNER JOIN Composicion cp ON p.prod_codigo = cp.comp_producto
        WHERE f2.fact_cliente = cl.clie_codigo
        AND YEAR(f2.fact_fecha) = 2012
    ) AS 'Cantidad de productos con composicion que compro el cliente en 2012'
FROM Cliente cl
WHERE EXISTS (
    SELECT 1
    FROM Factura f1
    WHERE f1.fact_cliente = cl.clie_codigo
    GROUP BY YEAR(f1.fact_fecha)
    HAVING YEAR(f1.fact_fecha) = ANY (
        SELECT YEAR(f2.fact_fecha)
        FROM Factura f2
        WHERE f2.fact_cliente = cl.clie_codigo
        AND YEAR(f2.fact_fecha) = YEAR(f1.fact_fecha) - 1
    )
)
ORDER BY (
    SELECT COUNT(*)
    FROM Factura f 
    WHERE f.fact_cliente = cl.clie_codigo
) ASC



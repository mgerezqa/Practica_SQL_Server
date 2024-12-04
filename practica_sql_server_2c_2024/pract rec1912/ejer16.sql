-- Con el fin de lanzar una nueva campaña comercial para los clientes que menos compran
-- en la empresa, se pide una consulta SQL que retorne 
-- aquellos clientes  cuyas compras son inferiores a 1/3 del promedio de ventas del producto que más se vendió en el 2012.
-- Además mostrar
-- 1. Nombre del Cliente
-- 2. Cantidad de unidades totales vendidas en el 2012 para ese cliente.
-- 3. Código de producto que mayor venta tuvo en el 2012
-- (en caso de existir más de 1,
-- mostrar solamente el de menor código) para ese cliente.

SELECT 
    c.clie_razon_social 'Nombre del cliente',
    c.clie_domicilio 'Domicilio',
    SUM(ifa.item_cantidad) 'Unidades Totales 2012',
    (SELECT TOP 1 item_producto 
     FROM Item_Factura ifa2 
     JOIN Factura fa ON fa.fact_tipo = ifa2.item_tipo 
        AND fa.fact_sucursal = ifa2.item_sucursal 
        AND fa.fact_numero = ifa2.item_numero 
     WHERE YEAR(fa.fact_fecha) = 2012 
        AND c.clie_codigo = fa.fact_cliente 
     GROUP BY item_producto 
     ORDER BY SUM(ifa2.item_cantidad) DESC, item_producto ASC) 'Codigo Producto mas vendido 2012'
FROM Cliente c
JOIN Factura f ON c.clie_codigo = f.fact_cliente
JOIN Item_Factura ifa 
    ON f.fact_tipo = ifa.item_tipo 
    AND f.fact_sucursal = ifa.item_sucursal 
    AND f.fact_numero = ifa.item_numero
WHERE YEAR(f.fact_fecha) = 2012
GROUP BY c.clie_razon_social, c.clie_codigo,c.clie_domicilio
HAVING SUM(ifa.item_cantidad) < (
    SELECT TOP 1 SUM(item_cantidad)/3
    FROM Item_Factura ifa3
    JOIN Factura fa ON fa.fact_tipo = ifa3.item_tipo 
        AND fa.fact_sucursal = ifa3.item_sucursal 
        AND fa.fact_numero = ifa3.item_numero
    WHERE YEAR(fa.fact_fecha) = 2012
    GROUP BY item_producto
    ORDER BY SUM(item_cantidad) DESC
)
ORDER BY c.clie_domicilio ASC

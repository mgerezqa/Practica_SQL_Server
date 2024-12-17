/* Realizar una consulta SQL que retome para los 10 clientes que más compraron en el 2012 y que fueron
atendidos por mas de 3 vendedores distintos: 

i. Apellido y Nombre del vendedor.
ii.Cantidad  de productos distintos comprados en el 2012.
iii. Cantidad de unidades compradas dentro del primer semestre del 2012.

El resultado deberá mostrar ordenado la cantidad de ventas descendente 
del 2012 de cada cliente, en caso de igualdad de ventas, ordenar por codigo de cliente.
*/

SELECT TOP 10
    c.clie_codigo AS 'Codigo de Cliente',
    e.empl_apellido + ', ' + e.empl_nombre AS 'Apellido y Nombre del vendedor',
    COUNT(DISTINCT ifr.item_producto) AS 'Cantidad de productos distintos comprados en el 2012',
    SUM(CASE 
        WHEN MONTH(f.fact_fecha) BETWEEN 1 AND 6 
        THEN ifr.item_cantidad 
        ELSE 0 
    END) AS 'Cantidad de unidades compradas dentro del primer semestre del 2012'
FROM Cliente c
INNER JOIN Factura f ON c.clie_codigo = f.fact_cliente
INNER JOIN Empleado e ON f.fact_vendedor = e.empl_codigo
INNER JOIN Item_Factura ifr 
    ON f.fact_tipo = ifr.item_tipo
    AND f.fact_sucursal = ifr.item_sucursal
    AND f.fact_numero = ifr.item_numero
WHERE YEAR(f.fact_fecha) = 2012
GROUP BY 
    c.clie_codigo,
    e.empl_apellido,
    e.empl_nombre
HAVING COUNT(DISTINCT f.fact_vendedor) > 3
ORDER BY 
    SUM(f.fact_total) DESC,
    c.clie_codigo
-- 1. Mostrar el código, razón social de todos los clientes cuyo límite de crédito sea mayor o
-- igual a $ 1000 ordenado por código de cliente.

SELECT clie_codigo, clie_razon_social
FROM dbo.Cliente
WHERE clie_limite_credito >= 1000
ORDER BY clie_codigo;   

-- 2.Mostrar el código, detalle de todos los artículos vendidos en el año 2012 ordenados por
-- cantidad vendida.

SELECT prod_codigo,prod_detalle
FROM dbo.Producto
-- unir con tabla item-factura
INNER JOIN dbo.Item_Factura
ON Producto.prod_codigo = dbo.Item_Factura.item_producto
-- unir con tabla factura, por PK tipo,sucursal,nunero
INNER JOIN dbo.Factura
ON dbo.Item_Factura.item_tipo = dbo.Factura.fact_tipo AND dbo.Item_Factura.item_sucursal = dbo.Factura.fact_sucursal AND dbo.Item_Factura.item_numero = dbo.Factura.fact_numero
WHERE YEAR(fact_fecha) = 2012 


--3.Realizar una consulta que muestre código de producto, nombre de producto y el stock
-- total, sin importar en que deposito se encuentre, los datos deben ser ordenados por
-- nombre del artículo de menor a mayor.

SELECT prod_codigo, prod_detalle, SUM(stoc_cantidad) AS stock_total
FROM dbo.Producto
--unir con tabla stock por PK
INNER JOIN dbo.STOCK
ON Producto.prod_codigo = dbo.STOCK.stoc_producto
GROUP BY prod_codigo, prod_detalle
ORDER BY stock_total DESC;

-- 4.Realizar una consulta que muestre para todos los artículos código, detalle y cantidad de
-- artículos que lo componen. Mostrar solo aquellos artículos para los cuales el stock
-- promedio por depósito sea mayor a 100.


SELECT 
    p.prod_codigo AS codigo_producto,
    p.prod_detalle AS detalle,
    COUNT(c.comp_componente) AS cantidad_componentes
FROM 
    Producto p
JOIN 
    Composicion c ON p.prod_codigo = c.comp_producto
JOIN 
    STOCK s ON p.prod_codigo = s.stoc_producto
GROUP BY 
    p.prod_codigo, p.prod_detalle
HAVING 
    AVG(s.stoc_cantidad) > 100;


-- Diferencia entre COUNT(c.comp_componente) y SUM(c.comp_cantidad)
-- COUNT(c.comp_componente): Cuenta el número de filas en la tabla Composicion para cada producto, lo que equivale al número de componentes distintos que tiene cada producto.

-- Ejemplo: Si un producto tiene tres componentes diferentes, el resultado será 3.
-- SUM(c.comp_cantidad): Sumaría la cantidad total de componentes, considerando la cantidad especificada en el campo comp_cantidad.

--5.Realizar una consulta que muestre código de artículo, detalle y cantidad de egresos de
-- stock que se realizaron para ese artículo en el año 2012 (egresan los productos que
-- fueron vendidos). Mostrar solo aquellos que hayan tenido más egresos que en el 2011.

SELECT prod_codigo, prod_detalle, SUM(item_cantidad) as cantidad_de_ventas_2012
FROM dbo.Producto
-- unir con tabla item-factura
INNER JOIN dbo.Item_Factura
ON Producto.prod_codigo = dbo.Item_Factura.item_producto
-- unir con tabla factura, por PK tipo,sucursal,nunero
INNER JOIN dbo.Factura
ON dbo.Item_Factura.item_tipo = dbo.Factura.fact_tipo 
AND dbo.Item_Factura.item_sucursal = dbo.Factura.fact_sucursal 
AND dbo.Item_Factura.item_numero = dbo.Factura.fact_numero
WHERE YEAR(fact_fecha) = 2012
GROUP BY prod_codigo, prod_detalle
HAVING SUM(item_cantidad) > (
    SELECT SUM(I2.item_cantidad)
    FROM dbo.Item_Factura I2
    INNER JOIN dbo.Factura F2
    ON I2.item_tipo = F2.fact_tipo 
    AND I2.item_sucursal = F2.fact_sucursal 
    AND I2.item_numero = F2.fact_numero
    WHERE YEAR(F2.fact_fecha) = 2011
    AND I2.item_producto = Producto.prod_codigo
)
ORDER BY cantidad_de_ventas_2012 DESC;

-- Explicacion:
--  Se selecciona el codigo de producto, el detalle y la cantidad de ventas en el 2012, se agrupa por codigo de producto y detalle, se filtra por la cantidad de ventas en el 2012 que sea mayor a la cantidad de ventas en el 2011


-- Version mejorada sin subselect
--5b.Realizar una consulta que muestre código de artículo, detalle y cantidad de egresos de
-- stock que se realizaron para ese artículo en el año 2012 (egresan los productos que
-- fueron vendidos). Mostrar solo aquellos que hayan tenido más egresos que en el 2011

SELECT 
    p.prod_codigo, 
    p.prod_detalle, 
    SUM(
    CASE WHEN YEAR(f.fact_fecha) = 2012 
    THEN i.item_cantidad ELSE 0 END) AS cantidad_ventas_2012
FROM
    Producto p
JOIN
    Item_Factura i ON p.prod_codigo = i.item_producto
JOIN
    Factura f 
    ON i.item_tipo = f.fact_tipo 
    AND i.item_sucursal = f.fact_sucursal 
    AND i.item_numero = f.fact_numero
WHERE
    YEAR(f.fact_fecha) IN (2011, 2012)
GROUP BY
    p.prod_codigo, p.prod_detalle
HAVING
    SUM(
    CASE WHEN YEAR(f.fact_fecha) = 2012 
    THEN i.item_cantidad ELSE 0 END) > 
    ISNULL(SUM(
    CASE WHEN YEAR(f.fact_fecha) = 2011 
    THEN i.item_cantidad ELSE 0 END), 0)
ORDER BY cantidad_ventas_2012 DESC;


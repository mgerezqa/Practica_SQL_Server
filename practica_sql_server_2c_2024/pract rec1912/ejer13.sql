-- 13.Realizar una consulta que retorne para cada producto que posea composición 
-- nombre del producto, 
-- precio del producto, 
-- precio de la sumatoria de los precios por la cantidad de los productos que lo componen.
--  Solo se deberán mostrar los productos que estén compuestos por más de 2 productos y 
-- deben ser ordenados de mayor a menor por cantidad de productos que lo componen.

SELECT
    p.prod_detalle AS 'Nombre del producto',
    p.prod_precio AS 'Precio del producto',
    SUM(c.comp_cantidad * pc.prod_precio) AS 'Precio total'
FROM
    Producto p
JOIN
    Composicion c
    ON p.prod_codigo = c.comp_producto
JOIN
    Producto pc
    ON c.comp_componente = pc.prod_codigo
GROUP BY
    p.prod_codigo, p.prod_detalle, p.prod_precio
HAVING
    COUNT(c.comp_componente) > 2
ORDER BY
    COUNT(c.comp_componente) DESC;


-- NO HAY PRODUCTOS QUE ESTÉN COMPUESTOS POR MAS DE 2 COMPONENTES.

-- query auxiliar, quiero conocer la cantidad total de los componentes de un  producto


SELECT
    p.prod_detalle 'Producto nombre',
    COUNT(ISNULL(c.comp_producto,0)) 'Cantidad de componentes'
FROM
    Producto p
JOIN
    Composicion c
    ON p.prod_codigo = c.comp_producto
GROUP BY
    p.prod_codigo,
    p.prod_detalle



-- Jugando con having
SELECT
    p.prod_detalle 'Producto nombre',
    COUNT(ISNULL(c.comp_producto,0)) 'Cantidad de componentes'
FROM
    Producto p
LEFT JOIN
    Composicion c
    ON p.prod_codigo = c.comp_producto
GROUP BY
    p.prod_codigo,
    p.prod_detalle
HAVING
    COUNT(c.comp_producto) > 1


SELECT
    c.comp_producto AS 'Código del producto',
    SUM(c.comp_cantidad) AS 'Cantidad total de componentes'
FROM
    Composicion c
GROUP BY
    c.comp_producto;
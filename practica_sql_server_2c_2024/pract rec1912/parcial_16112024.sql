-- Realizar una consulta SQL que muestre la siguiente información para los clientes que hayan comprado productos en mas de tres rubros diferentes en 2012 y que no compro en años impares.

-- 1.El numero de fila.
-- 2.El codigo de cliente.
-- 3.El nombre de cliente.
-- 4.La cantidad total comprada por el cliente 
-- 5.La categoria en la que mas compro en 2012.

-- El resultado debe estar ordenado por la cantidad total comprada, de mayor a menor.

-- Nota: No se permiten select en el from, es decir, select... (from select...) as T...

SELECT
      ROW_NUMBER() OVER (ORDER BY c.clie_codigo) 'Numero de fila',
      c.clie_codigo 'Codigo de cliente',
      c.clie_razon_social 'Nombre de cliente',
      COUNT(f.fact_cliente)'Cantidad de compras realizadas',
        (SELECT TOP 1 rubr_detalle
        FROM Item_Factura
        JOIN Factura 
            ON  fact_tipo = item_tipo 
            AND fact_sucursal = item_sucursal   
            AND  fact_numero = item_numero
        JOIN Producto
            ON item_producto = prod_codigo
        JOIN Rubro
            ON prod_rubro = rubr_id 
        WHERE YEAR (fact_fecha) = 2012 AND fact_cliente = c.clie_codigo
        GROUP BY 
        rubr_id,
        rubr_detalle
        ORDER BY SUM(item_cantidad) DESC)
        'Categoria mas comprada'
FROM
        Cliente c
JOIN    Factura f
    ON  c.clie_codigo = f.fact_cliente
JOIN Item_Factura ifa
    ON  f.fact_tipo = ifa.item_tipo 
    AND f.fact_sucursal = ifa.item_sucursal   
    AND  f.fact_numero = ifa.item_numero 
JOIN Producto p
    ON ifa.item_producto = p.prod_codigo
JOIN Rubro r
    ON p.prod_rubro = r.rubr_id
WHERE YEAR(f.fact_fecha) = 2012    
GROUP BY 
      c.clie_codigo,
      c.clie_razon_social
HAVING 
    (SELECT COUNT(DISTINCT p3.prod_rubro)
     FROM Factura f3
     JOIN Item_Factura if3
         ON f3.fact_tipo = if3.item_tipo 
        AND f3.fact_sucursal = if3.item_sucursal 
        AND f3.fact_numero = if3.item_numero
     JOIN Producto p3
         ON if3.item_producto = p3.prod_codigo
     WHERE f3.fact_cliente = c.clie_codigo 
        AND YEAR(f3.fact_fecha) = 2012) > 3
    AND NOT EXISTS (
        SELECT 1
        FROM Factura f4
        WHERE f4.fact_cliente = c.clie_codigo
            AND YEAR(f4.fact_fecha) % 2 = 1)
ORDER BY SUM(ifa.item_cantidad) DESC;





SELECT 
    ROW_NUMBER() OVER (ORDER BY SUM(ifa.item_cantidad) DESC) as 'Número de fila',
    c.clie_codigo as 'Código de cliente',
    c.clie_razon_social as 'Nombre de cliente',
    SUM(ifa.item_cantidad) as 'Cantidad total comprada',
    (SELECT TOP 1 r2.rubr_detalle
     FROM Item_Factura if2
     JOIN Factura f2 ON f2.fact_tipo = if2.item_tipo 
        AND f2.fact_sucursal = if2.item_sucursal   
        AND f2.fact_numero = if2.item_numero
     JOIN Producto p2 ON if2.item_producto = p2.prod_codigo
     JOIN Rubro r2 ON p2.prod_rubro = r2.rubr_id
     WHERE YEAR(f2.fact_fecha) = 2012 
        AND f2.fact_cliente = c.clie_codigo
     GROUP BY r2.rubr_detalle
     ORDER BY SUM(if2.item_cantidad) DESC) as 'Categoría más comprada'
FROM Cliente c
JOIN Factura f ON c.clie_codigo = f.fact_cliente
JOIN Item_Factura ifa ON f.fact_tipo = ifa.item_tipo 
    AND f.fact_sucursal = ifa.item_sucursal   
    AND f.fact_numero = ifa.item_numero
JOIN Producto p ON ifa.item_producto = p.prod_codigo
JOIN Rubro r ON p.prod_rubro = r.rubr_id
WHERE YEAR(f.fact_fecha) = 2012
GROUP BY c.clie_codigo, c.clie_razon_social
HAVING 
    (SELECT COUNT(DISTINCT p3.prod_rubro)
     FROM Factura f3
     JOIN Item_Factura if3 ON f3.fact_tipo = if3.item_tipo 
        AND f3.fact_sucursal = if3.item_sucursal 
        AND f3.fact_numero = if3.item_numero
     JOIN Producto p3 ON if3.item_producto = p3.prod_codigo
     WHERE f3.fact_cliente = c.clie_codigo 
        AND YEAR(f3.fact_fecha) = 2012) > 3
    AND NOT EXISTS (
        SELECT 1
        FROM Factura f4
        WHERE f4.fact_cliente = c.clie_codigo
            AND YEAR(f4.fact_fecha) % 2 = 1)
ORDER BY SUM(ifa.item_cantidad) DESC;


SELECT * FROM RUBRO
SELECT * FROM Familia
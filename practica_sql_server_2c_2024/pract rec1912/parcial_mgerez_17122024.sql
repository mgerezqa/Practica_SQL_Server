
/* Sabiendo que en todos los años que operó la empresa se venden productos sin composición, se pide una consulta SQL que para cada año muestre:

i. El año.
ii. El producto sin composición mas vendido para ese año.
iii. Cantidad de facturas en las que se vendió ese producto con una cantidad igual a 1.
iv. El numero de la factura mas vieja del año donde ese producto se vendió
v. El codigo de cliente que mas compro ese producto.
vi. El promedio de ventas en cantidades de ese producto con respecto al total del año.
Dicho valor con redondeo simetrico a 2 decimales.. */

SELECT 
    YEAR(f.fact_fecha) AS 'Año',
    i.item_producto AS 'Producto más vendido',
    COUNT(CASE WHEN i.item_cantidad = 1 THEN 1 END) AS 'Cantidad facturas con ventas unitarias',
    MIN(f.fact_numero) AS 'Factura más vieja',
    (
        SELECT TOP 1 f2.fact_cliente
        FROM Factura f2
        JOIN Item_Factura i2 ON f2.fact_tipo = i2.item_tipo 
            AND f2.fact_sucursal = i2.item_sucursal 
            AND f2.fact_numero = i2.item_numero
        WHERE YEAR(f2.fact_fecha) = YEAR(f.fact_fecha)
        AND i2.item_producto = i.item_producto
        GROUP BY f2.fact_cliente
        ORDER BY SUM(i2.item_cantidad) DESC
    ) AS 'Cliente que más compró',
    ROUND(
        CAST(SUM(i.item_cantidad) AS DECIMAL(12,2)) / 
        CAST((
            SELECT COUNT(*) 
            FROM Factura f3 
            WHERE YEAR(f3.fact_fecha) = YEAR(f.fact_fecha)
        ) AS DECIMAL(12,2)), 
        2
    ) AS 'Promedio de ventas'
FROM Factura f
JOIN Item_Factura i ON f.fact_tipo = i.item_tipo 
    AND f.fact_sucursal = i.item_sucursal 
    AND f.fact_numero = i.item_numero
GROUP BY 
    YEAR(f.fact_fecha),
    i.item_producto
HAVING 
    -- Filtramos productos sin composición
    NOT EXISTS (
        SELECT 1 
        FROM Composicion c 
        WHERE c.comp_producto = i.item_producto
    )
    -- Nos quedamos solo con el producto más vendido de cada año
    AND SUM(i.item_cantidad) = (
        SELECT MAX(total_vendido)
        FROM (
            SELECT 
                i2.item_producto,
                SUM(i2.item_cantidad) as total_vendido
            FROM Factura f2
            JOIN Item_Factura i2 ON f2.fact_tipo = i2.item_tipo 
                AND f2.fact_sucursal = i2.item_sucursal 
                AND f2.fact_numero = i2.item_numero
            WHERE YEAR(f2.fact_fecha) = YEAR(f.fact_fecha)
            AND NOT EXISTS (
                SELECT 1 
                FROM Composicion c 
                WHERE c.comp_producto = i2.item_producto
            )
            GROUP BY i2.item_producto
        ) as ventas_productos
    )
ORDER BY YEAR(f.fact_fecha);



/* Crear una nueva tabla llamada con el siguiente formato:

    columna 1 : Producto 1
       Descripcion del producto
    columna 2: Producto 2
        Descripción del producto
    columna 3: Cantidad
        Cantidad de veces vendidos juntos

A continuación crear y ejecutar un store procedure que llene la citada tabla y retorne la cantidad de filas con las que quedó la misma.
Cada par de productos debe aparecer solo una vez en la tabla.


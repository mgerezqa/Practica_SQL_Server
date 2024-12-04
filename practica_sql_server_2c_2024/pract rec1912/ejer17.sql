-- 17.Escriba una consulta que retorne una estadística de ventas por año y mes para cada
-- producto.La consulta debe retornar:
-- PERIODO: Año y mes de la estadística con el formato YYYYMM
-- PROD: Código de producto
-- DETALLE: Detalle del producto
-- CANTIDAD_VENDIDA= Cantidad vendida del producto en el periodo
-- VENTAS_AÑO_ANT= Cantidad vendida del producto en el mismo mes del periodo pero del año anterior
-- CANT_FACTURAS= Cantidad de facturas en las que se vendió el producto en el
-- periodo
-- La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar ordenada
-- por periodo y código de producto.

SELECT
       YEAR(f.fact_fecha) 'Anio',
       MONTH(f.fact_fecha) 'Mes',
       p.prod_codigo 'Codigo de producto',
       p.prod_detalle 'Detalle del producto',
       sum(ifa.item_cantidad) 'Cantidad vendida del producto',
		(SELECT SUM(ISNULL(ifav.item_cantidad, 0))
		FROM Factura JOIN Item_Factura ifav ON fact_tipo + fact_sucursal + fact_numero = ifav.item_tipo + ifav.item_sucursal + ifav.item_numero
		WHERE YEAR(fact_fecha) = YEAR(F.fact_fecha)-1 AND
			MONTH(fact_fecha) = MONTH(F.fact_fecha) AND
			ifav.item_producto = prod_codigo
        ) 'Ventas anio anterior',
		COUNT(*) 'Cant. Facturas' --el resultado del agrupamiento termina siendo la cantidad de productos por factura, basta con contabilizar todos los resultados para obtener las facturas en 
        -- las que aparece el Producto.
FROM
    Producto p
JOIN
    Item_Factura ifa
    ON p.prod_codigo = ifa.item_producto

JOIN Factura f
    ON  f.fact_tipo = ifa.item_tipo 
    AND f.fact_sucursal = ifa.item_sucursal   
    AND  f.fact_numero = ifa.item_numero 

GROUP BY YEAR(f.fact_fecha),
         MONTH(f.fact_fecha),
         p.prod_codigo,
         p.prod_detalle
ORDER BY
        YEAR(f.fact_fecha),
        MONTH(f.fact_fecha),
        p.prod_codigo
         
-- corregida

SELECT 
    CAST(YEAR(f.fact_fecha) AS VARCHAR(4)) + 
    RIGHT('0' + CAST(MONTH(f.fact_fecha) AS VARCHAR(2)), 2) AS 'PERIODO',
    p.prod_codigo AS 'PROD',
    p.prod_detalle AS 'DETALLE',
    ISNULL(SUM(ifa.item_cantidad), 0) AS 'CANTIDAD_VENDIDA',
    ISNULL((
        SELECT SUM(ifav.item_cantidad)
        FROM Factura fv 
        JOIN Item_Factura ifav 
            ON fv.fact_tipo = ifav.item_tipo 
            AND fv.fact_sucursal = ifav.item_sucursal 
            AND fv.fact_numero = ifav.item_numero
        WHERE YEAR(fv.fact_fecha) = YEAR(F.fact_fecha) - 1 
            AND MONTH(fv.fact_fecha) = MONTH(F.fact_fecha)
            AND ifav.item_producto = p.prod_codigo
    ), 0) AS 'VENTAS_AÑO_ANT',
    COUNT(DISTINCT f.fact_tipo + f.fact_sucursal + f.fact_numero) AS 'CANT_FACTURAS'
FROM Producto p
JOIN Item_Factura ifa ON p.prod_codigo = ifa.item_producto
JOIN Factura f ON f.fact_tipo = ifa.item_tipo 
    AND f.fact_sucursal = ifa.item_sucursal   
    AND f.fact_numero = ifa.item_numero 
GROUP BY 
    YEAR(f.fact_fecha),
    MONTH(f.fact_fecha),
    p.prod_codigo,
    p.prod_detalle
ORDER BY 
    YEAR(f.fact_fecha),
    MONTH(f.fact_fecha),
    p.prod_codigo
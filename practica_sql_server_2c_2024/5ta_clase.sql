-- Ejercicio:

-- Dada la tabla clientes, realizar una consulta SQL que numere de menor a mayor cada fila de la tabla, considerando el codigo mas chico como 1. Usar la sentencia ROW y OVER.

-- Otra VERSION

SELECT clie_codigo,clie_razon_social, 
        ROW_NUMBER() OVER (ORDER BY clie_codigo) AS nro_fila
FROM Cliente

-- Desglose del código:
-- SELECT clie_codigo, clie_razon_social:

-- Esta parte del código selecciona las columnas clie_codigo y clie_razon_social de la tabla Cliente.
-- ROW_NUMBER() OVER (ORDER BY clie_codigo) AS nro_fila:

-- ROW_NUMBER() es una función de ventana que asigna un número único a cada fila dentro de su conjunto de resultados.
-- OVER (ORDER BY clie_codigo) especifica que las filas deben ser ordenadas por la columna clie_codigo antes de asignar los números de fila.
-- AS nro_fila asigna un alias a la columna generada por ROW_NUMBER(), llamándola nro_fila.
-- FROM Cliente:

-- Esta parte del código indica que la consulta se está realizando sobre la tabla Cliente.




SELECT *, (SELECT COUNT(*) FROM Cliente c2 WHERE c2.clie_codigo <= c1.clie_codigo) AS numero
FROM Cliente c1
WHERE clie_codigo > '00000'

-- El código SQL selecciona todas las columnas de la tabla Cliente y añade una columna adicional llamada numero. Esta nueva columna contiene el número de registros en la tabla Cliente que tienen un clie_codigo menor o igual al clie_codigo del registro actual. Además, solo se incluyen en el resultado los registros donde clie_codigo es mayor que '00000'.


-- Otra VERSION

Select clie_codigo,clie_razon_social, 
        (SELECT COUNT(*) FROM Cliente c2 WHERE c2.clie_codigo <= c1.clie_codigo) AS numero
FROM Cliente c1
Order by c1.clie_codigo


-- La cantidad de filas menores o iguales del registro en el cual estoy parado es el número de fila en la tabla.

-- Otra VERSION

SELECT 
    ROW_NUMBER() OVER 
    		(
    		PARTITION BY 
    			fact_cliente
    		ORDER BY 
    			fact_fecha asc 
    		) AS nro_fila,
    fact_cliente,
    fact_fecha 
FROM 
    Factura f 
ORDER BY 
	fact_cliente asc


-- 	10) BASE GDD: Mostrar los 10 productos más vendidos en la historia y también los 10 productos menos  vendidos en la historia. Además mostrar de esos productos, quien fue el cliente que  mayor compra realizo.


-- mostrar productos vendidos:

-- 10 productos más vendidos

SELECT TOP 10 
    P.prod_codigo AS CodigoProducto,
    P.prod_detalle AS DetalleProducto,
    SUM(I.item_cantidad) AS CantidadVendida,
    (SELECT TOP 1 F.fact_cliente 
     FROM [dbo].[Factura] F 
     INNER JOIN [dbo].[Item_Factura] I 
        ON F.fact_tipo = I.item_tipo 
        AND F.fact_sucursal = I.item_sucursal 
        AND F.fact_numero = I.item_numero
     WHERE I.item_producto = P.prod_codigo 
     GROUP BY F.fact_cliente 
     ORDER BY SUM(I.item_cantidad) DESC) AS ClienteMayorCompra
FROM Producto P
INNER JOIN [dbo].[Item_Factura] I
    ON P.prod_codigo = I.item_producto
GROUP BY P.prod_codigo, P.prod_detalle
ORDER BY SUM(I.item_cantidad) DESC;

-- 10 productos menos vendidos
SELECT TOP 10 
    P.prod_codigo AS CodigoProducto,
    P.prod_detalle AS DetalleProducto,
    SUM(I.item_cantidad) AS CantidadVendida,
    (SELECT TOP 1 F.fact_cliente 
     FROM [dbo].[Factura] F 
     INNER JOIN [dbo].[Item_Factura] I 
        ON F.fact_tipo = I.item_tipo 
        AND F.fact_sucursal = I.item_sucursal 
        AND F.fact_numero = I.item_numero
     WHERE I.item_producto = P.prod_codigo 
     GROUP BY F.fact_cliente 
     ORDER BY SUM(I.item_cantidad) DESC) AS ClienteMayorCompra
FROM [dbo].[Producto] P
INNER JOIN [dbo].[Item_Factura] I
    ON P.prod_codigo = I.item_producto
GROUP BY P.prod_codigo, P.prod_detalle
ORDER BY SUM(I.item_cantidad) ASC;




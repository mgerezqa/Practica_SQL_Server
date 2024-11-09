-- EJ 1:
--  HACER UNA QUERY QUE MUESTRE PARA TODOS LOS CLIENTES
-- LA CANTIDAD DE FACTURAS QUE TIENE.


SELECT 
    Clie.clie_codigo,
    Fact.fact_cliente,
    count(*) as count_fact_incorrecto,  -- Cuenta todas las filas, incluso si no hay facturas
    count(Fact.fact_cliente) as count_fact_correcto,  -- Cuenta correctamente las facturas
    count(1) as count_constante  -- Cuenta todas las filas, incluyendo las filas sin facturas
FROM dbo.Factura Fact
RIGHT JOIN dbo.Cliente Clie 
ON Fact.fact_cliente = Clie.clie_codigo
GROUP BY Clie.clie_codigo, Fact.fact_cliente
ORDER BY count_fact_correcto;

--EJ 1 : VERSION DESDE LA TABLA CLIENTE

SELECT 
    Clie.clie_codigo,
    Clie.clie_razon_social,
    count(Fact.fact_cliente) as count_fact_correcto
FROM dbo.Cliente Clie
LEFT JOIN dbo.Factura Fact 
ON Fact.fact_cliente = Clie.clie_codigo
GROUP BY 
Clie.clie_codigo, Clie.clie_razon_social
ORDER BY
count_fact_correcto;    


-- SELECT CASE WHEN ELSE

	SELECT 
	CASE 
		WHEN c.clie_codigo = '00000' THEN 'cliente cero'
		WHEN c.clie_codigo = '00001' THEN 'cliente uno'
		ELSE 'RESTO CLIENTES'
	END, 
	COUNT(*)
FROM Cliente c 
GROUP BY 
	CASE 
		WHEN c.clie_codigo = '00000' THEN 'cliente cero'
		WHEN c.clie_codigo = '00001' THEN 'cliente uno'
		ELSE 'RESTO CLIENTES'
	END


-- SELECCIONAR LOS PRIMEROS

SELECT TOP 10 * FROM Cliente c 
ORDER BY clie_codigo DESC

-- TEMA 7 PRACTICA SQL
-- RESOLUCION GUIA DE EJERCICIOS : 1,2,3,4

-- EJECICIO COMPOSICION
SELECT 	
	Producto.prod_codigo,
	Producto.prod_detalle,
	ISNULL(SUM(Composicion.comp_cantidad) / count(distinct stoc_deposito) ,0) AS num_componentes
FROM Producto
LEFT JOIN Composicion ON Composicion.comp_producto = Producto.prod_codigo
	 JOIN STOCK ON STOCK.stoc_producto = Producto.prod_codigo
GROUP BY
	Producto.prod_codigo, 
	Producto.prod_detalle
HAVING 
	AVG(STOCK.stoc_cantidad) > 100
ORDER BY 
	num_componentes
-- SQL
-- DLL: CREATE ALTER DROP
-- DML: SELECT INSERT UPDATE DELETE

USE [GD2015C1];
GO;

SELECT *  FROM dbo.Cliente
SELECT *  FROM dbo.Producto

SELECT
    [clie_domicilio] as Domicilio, --alias con as
    [clie_codigo] Codigo, --alias sin as
    1 + 1 AS SUMA,
    GETDATE() AS FECHA_HORA,
    YEAR(GETDATE()) as ANIO,
    SUBSTRING('EDGARDO',1,3) as NOMBRERECORTADO,
    SUBSTRING('clie_domicilio',1,3) as DOMICILIORECORTADO
FROM dbo.Cliente

-- Ej1: Filtrado por rango de id
--Seleccionar los clientes cuyo código esté entre 100 y 105
SELECT * FROM dbo.Cliente WHERE clie_codigo BETWEEN 100 AND 105
-- WHEERE CONDICIÓN DE FILTRO A NIVEL DE FILA

-- Ej2:Otro ejemplo de filtrado a nivel de tabla
-- Seleccionar los clientes cuyo código sea mayor o igual a 109 y cuyo límite de crédito sea menor o igual a 10000
SELECT * FROM dbo.Cliente 
WHERE clie_codigo >= '00109' AND
      clie_limite_credito <= 10000

-- no importa el orden de las condiciones

-- Ej3:Otro ejemplo de filtrado a nivel de tabla
-- Seleccionar los clientes cuyo código sea mayor o igual a 109 y cuyo límite de crédito sea menor o igual a 10000 y luego ordenarlos segun el límite de crédito
SELECT * FROM dbo.Cliente 
WHERE clie_codigo >= '00109' AND
      clie_limite_credito <= 10000
ORDER BY clie_limite_credito DESC

-- Ej4:Otro ejemplo de filtrado a nivel de tabla
--Selecciona el anio, mes , fact_cliente, fact_total de la tabla factura entre los anios 
-- 2010 y 2012 y ordenalos de forma ascendete por anio y descente por mes
SELECT
    YEAR(fact_fecha) as ANIO,
    MONTH(fact_fecha) as MES,
    fact_cliente,
    fact_total
FROM dbo.Factura 
WHERE YEAR(fact_fecha) BETWEEN 2010 AND 2012
ORDER BY YEAR(fact_fecha) ASC, MONTH(fact_fecha) DESC

--Ej5: Vincular tablas
--Seleccionar todas las columnas de la tabla Factura
--que tengan un cliente asociado 

-- JOIN : Vincula dos tablas por una columna en común, intersección

SELECT * FROM dbo.Factura Fact 
JOIN Cliente Clie ON Fact.fact_cliente = Clie.clie_codigo

--Como nuestro dominio son la facturas, entonces no puede
--haber mas registros que la cantidad total de factuas siempre será menos


SELECT * FROM dbo.Factura; --3000 facturas
SELECT * FROM dbo.Cliente; --3687 clientes


-- Producto conmutativo en la intersección

-- Ej6: Vincular tablas
---Selecciono todos los clientes que tengan un vendedor asociado

SELECT * FROM dbo.Cliente Clie 
JOIN Empleado Empl 
ON Clie.clie_vendedor = Empl.empl_codigo

--3665

-- Ej6: Vincular tablas
---Selecciono todos los clientes que tengan un vendedor asociado
-- en este caso verificamos que es lo mismo realizar la consulta
-- con la FK de la tabla cliente en cualquier lado de la igualdad
-- lo importante es que las vinculemos por la misma columna
SELECT * FROM dbo.Cliente Clie 
JOIN Empleado Empl 
ON  Empl.empl_codigo = Clie.clie_vendedor

--3665

--Ej7: Vincular Item_Factura con  Producto
--Seleccionar todas las columnas de la tabla Item_Factura
--que tengan un producto asociado 
SELECT * FROM dbo.Item_Factura ItemF
JOIN Producto Prod 
ON ItemF.item_producto = Prod.prod_codigo

-- Seleccionar todas las columnas de la tabla Producto
-- que tengan un item_factura asociada

SELECT * FROM Producto Prod
JOIN Item_Factura ItemF
ON Prod.prod_codigo = ItemF.item_producto

-- Ej8: Vincular Factura con item_factura
-- Seleccionar todas las columnas de la tabla Factura y vincular con Item_Factura
-- que tengan un item_factura asociado

SELECT * FROM dbo.Factura Fact
JOIN Item_Factura ItemF
ON 
Fact.fact_tipo = ItemF.item_tipo AND
Fact.fact_sucursal = ItemF.item_sucursal AND
Fact.fact_numero = ItemF.item_numero

SELECT * FROM dbo.Item_Factura --19484

--Idem anterior pero mostrando las columnas de Item_factura
SELECT * FROM Item_Factura ItemF
JOIN dbo.Factura Fact
ON 
Fact.fact_tipo = ItemF.item_tipo AND
Fact.fact_sucursal = ItemF.item_sucursal AND
Fact.fact_numero = ItemF.item_numero


-- Ej9: Vincular una factura con sus items y con sus nombres de producto

SELECT 
        P.prod_detalle, P.prod_codigo,P.prod_precio,
        I.item_cantidad, I.item_precio, I.item_cantidad,
        F.fact_fecha

FROM dbo.Factura F, dbo.Item_Factura I, dbo.Producto P
WHERE 
    F.fact_tipo = I.item_tipo AND
    F.fact_sucursal = I.item_sucursal AND
    F.fact_numero = I.item_numero AND
    I.item_producto = P.prod_codigo

/**/

SELECT * FROM dbo.Factura Fact
JOIN Item_Factura ItemF
ON 
    Fact.fact_tipo = ItemF.item_tipo AND
    Fact.fact_sucursal = ItemF.item_sucursal AND
    Fact.fact_numero = ItemF.item_numero

JOIN Producto Prod
ON
    ItemF.item_producto = Prod.prod_codigo


/*Ahora filtramos el conjuunto anterior por fecha 2012 y ordenados*/


SELECT * FROM dbo.Factura Fact
JOIN Item_Factura ItemF
ON 
    Fact.fact_tipo = ItemF.item_tipo AND
    Fact.fact_sucursal = ItemF.item_sucursal AND
    Fact.fact_numero = ItemF.item_numero

JOIN Producto Prod
ON
    ItemF.item_producto = Prod.prod_codigo

WHERE YEAR(Fact.fact_fecha) = 2012
ORDER BY 
    Fact.fact_fecha DESC


/*Funciones de grupo*/

-- Sumar el total de las facturas para cada cliente
SELECT 
    Fact.fact_cliente,
    Clie.clie_domicilio,
    SUM(Fact.fact_total) as TOTAL
FROM dbo.Factura Fact
    JOIN Cliente Clie
    ON Fact.fact_cliente = Clie.clie_codigo
GROUP BY Fact.fact_cliente,Clie.clie_domicilio


-- Cuantos vendedores distintos le vendieron a cada cliente.
-- Mostrar el total de facturas , el promedio de las facturas
-- y el domicilio del cliente, el id del cliente y el id del vendedor
SELECT 
    Fact.fact_cliente, --id del cliente
    Fact.fact_vendedor, -- id del vendedor
    Clie.clie_domicilio,
    Count(distinct Fact.fact_vendedor) as TOTAL,
    SUM(Fact.fact_total) as TOTAL ,
    AVG(Fact.fact_total) as PROMEDIO

FROM dbo.Factura Fact
    JOIN Cliente Clie
    ON Fact.fact_cliente = Clie.clie_codigo
GROUP BY Fact.fact_cliente,Clie.clie_domicilio,fact_vendedor


-- HAVING FILTRO A NIVEL DE GRUPO


-- Cuantos vendedores distintos le vendieron a cada cliente.
-- Mostrar el total de facturas , el promedio de las facturas
-- y el domicilio del cliente, el id del cliente y el id del vendedor

SELECT 
    Fact.fact_cliente, --id del cliente
    Fact.fact_vendedor, -- id del vendedor
    Clie.clie_domicilio,
    Count(distinct Fact.fact_vendedor) as TOTAL,
    SUM(Fact.fact_total) as TOTAL ,
    AVG(Fact.fact_total) as PROMEDIO
FROM dbo.Factura Fact
    JOIN Cliente Clie
    ON Fact.fact_cliente = Clie.clie_codigo
WHERE 
    YEAR(Fact.fact_fecha) = 2012    
GROUP BY 
    Fact.fact_cliente,Clie.clie_domicilio,fact_vendedor
HAVING 
    SUM(fact_total) >= 37000
ORDER BY 
    SUM(fact_total) ASC
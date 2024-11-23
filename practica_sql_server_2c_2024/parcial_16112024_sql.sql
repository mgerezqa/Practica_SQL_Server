------------------------------ SQL - PARCIAL (16/11/2024) ------------------------------

/*
    Curso: K3673
    Alumno: Franco Ezequiel Centurión
    Profesor: Edgardo Lacquaniti
    Legajo: 1780189
*/

-- NOTA :10

-- Realizar una consulta SQL que muestre la siguiente información para los clientes que hayan comprado productos en mas de tres rubros diferentes en 2012 y que no compro en años impares.

-- 1.El numero de fila.
-- 2.El codigo de cliente.
-- 3.El nombre de cliente.
-- 4.La cantidad total comprada por el cliente 
-- 5.La categoria en la que mas compro en 2012.

-- El resultado debe estar ordenado por la cantidad total comprada, de mayor a menor.

-- Nota: No se permiten select en el from, es decir, select... (from select...) as T...

SELECT
    ROW_NUMBER() over (ORDER BY SUM(if1.item_cantidad) DESC) as numero_fila,
    c1.clie_codigo as codigo_cliente,
    c1.clie_razon_social as nombre_cliente,

    SUM(if1.item_cantidad) as cantidad_total_comprada,

    (
        SELECT TOP 1
            r1.rubr_detalle     -- Categoria más comprada (agarre el detalle pero también podría haber agarrado el id)
        FROM Factura f2
            JOIN Item_Factura if2 ON f2.fact_tipo = if2.item_tipo and f2.fact_sucursal = if2.item_sucursal and f2.fact_numero = if2.item_numero
            JOIN Producto p1 ON if2.item_producto = p1.prod_codigo
            JOIN Rubro r1 ON p1.prod_rubro = r1.rubr_id
        WHERE f2.fact_cliente = c1.clie_codigo AND YEAR(f2.fact_fecha) = 2012
        GROUP BY r1.rubr_id, r1.rubr_detalle
        ORDER BY SUM(if2.item_cantidad)

    ) as categoria_mas_comprada_2012

FROM Cliente c1
    JOIN Factura f1 ON c1.clie_codigo = f1.fact_cliente
    JOIN Item_Factura if1 ON f1.fact_tipo = if1.item_tipo and f1.fact_sucursal = if1.item_sucursal and f1.fact_numero = if1.item_numero
GROUP BY c1.clie_codigo, c1.clie_razon_social
HAVING
    (
        SELECT COUNT(DISTINCT r2.rubr_id)
        FROM Rubro r2
            JOIN Producto p2 ON r2.rubr_id = p2.prod_rubro
            JOIN Item_Factura if2 ON p2.prod_codigo = if2.item_producto
            JOIN Factura f2 ON if2.item_tipo = f2.fact_tipo and if2.item_sucursal = f2.fact_sucursal and if2.item_numero = f2.fact_numero
        WHERE f2.fact_cliente = c1.clie_codigo AND YEAR(f2.fact_fecha) = 2012

        ) > 3       -- Compro en más de 3 rubros diferentes en el 2012
        AND
        NOT EXISTS( SELECT                      -- No existe una factura de ese cliente que haya sido emitida en un año impar (o sea, todas las compras fueron en años pares)
                        1
                    FROM Factura f3
                    WHERE f3.fact_cliente = c1.clie_codigo AND YEAR(f3.fact_fecha) % 2 != 0)

ORDER BY SUM(if1.item_cantidad) DESC


-- CONSULTA DE PRUEBA IA

WITH ClientesRubros2012 AS (
    -- Clientes que compraron en más de 3 rubros diferentes en 2012
    SELECT 
        f.fact_cliente,
        COUNT(DISTINCT p.prod_rubro) as cant_rubros
    FROM Factura f
    JOIN Item_Factura i ON f.fact_tipo = i.item_tipo 
        AND f.fact_sucursal = i.item_sucursal 
        AND f.fact_numero = i.item_numero
    JOIN Producto p ON i.item_producto = p.prod_codigo
    WHERE YEAR(f.fact_fecha) = 2012
    GROUP BY f.fact_cliente
    HAVING COUNT(DISTINCT p.prod_rubro) > 3
),
ClientesAnosImpares AS (
    -- Clientes que compraron en años impares
    SELECT DISTINCT fact_cliente
    FROM Factura
    WHERE YEAR(fact_fecha) % 2 = 1
),
RubroMasComprado2012 AS (
    -- Rubro más comprado por cliente en 2012
    SELECT 
        f.fact_cliente,
        p.prod_rubro,
        SUM(i.item_cantidad) as cantidad_rubro,
        ROW_NUMBER() OVER (PARTITION BY f.fact_cliente ORDER BY SUM(i.item_cantidad) DESC) as rn
    FROM Factura f
    JOIN Item_Factura i ON f.fact_tipo = i.item_tipo 
        AND f.fact_sucursal = i.item_sucursal 
        AND f.fact_numero = i.item_numero
    JOIN Producto p ON i.item_producto = p.prod_codigo
    WHERE YEAR(f.fact_fecha) = 2012
    GROUP BY f.fact_cliente, p.prod_rubro
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY SUM(i.item_cantidad) DESC) as Fila,
    c.clie_codigo as CodigoCliente,
    RTRIM(c.clie_razon_social) as NombreCliente,
    SUM(i.item_cantidad) as CantidadTotalComprada,
    RTRIM(r.rubr_detalle) as RubroMasComprado2012
FROM ClientesRubros2012 cr
JOIN Cliente c ON cr.fact_cliente = c.clie_codigo
JOIN Factura f ON c.clie_codigo = f.fact_cliente
JOIN Item_Factura i ON f.fact_tipo = i.item_tipo 
    AND f.fact_sucursal = i.item_sucursal 
    AND f.fact_numero = i.item_numero
JOIN RubroMasComprado2012 rmc ON c.clie_codigo = rmc.fact_cliente AND rmc.rn = 1
JOIN Rubro r ON rmc.prod_rubro = r.rubr_id
WHERE NOT EXISTS (
    SELECT 1 FROM ClientesAnosImpares cai 
    WHERE c.clie_codigo = cai.fact_cliente
)
GROUP BY 
    c.clie_codigo,
    c.clie_razon_social,
    r.rubr_detalle
ORDER BY 
    CantidadTotalComprada DESC;
-- Realizar una consulta SQL que muestre la siguiente información para los clientes que hayan comprado productos en mas de tres rubros diferentes en 2012 y que no compro en años impares.

-- 1.El numero de fila.
-- 2.El codigo de cliente.
-- 3.El nombre de cliente.
-- 4.La cantidad total comprada por el cliente 
-- 5.La categoria en la que mas compro en 2012.

-- El resultado debe estar ordenado por la cantidad total comprada, de mayor a menor.

-- Nota: No se permiten select en el from, es decir, select... (from select...) as T...

WITH Compras2012 AS (
    SELECT 
        f.fact_cliente AS clie_codigo,
        c.clie_razon_social AS clie_nombre,
        p.prod_rubro,
        SUM(i.item_cantidad) AS total_comprado
    FROM Factura f
    JOIN Item_Factura i ON f.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal AND f.fact_numero = i.item_numero
    JOIN Producto p ON i.item_producto = p.prod_codigo
    JOIN Cliente c ON f.fact_cliente = c.clie_codigo
    WHERE YEAR(f.fact_fecha) = 2012
    GROUP BY f.fact_cliente, c.clie_razon_social, p.prod_rubro
),
ClientesMasDeTresRubros AS (
    SELECT 
        clie_codigo,
        clie_nombre,
        COUNT(DISTINCT prod_rubro) AS rubros_diferentes,
        SUM(total_comprado) AS total_comprado
    FROM Compras2012
    GROUP BY clie_codigo, clie_nombre
    HAVING COUNT(DISTINCT prod_rubro) > 3
),
ClientesSinComprasImpares AS (
    SELECT DISTINCT
        c.clie_codigo
    FROM Cliente c
    LEFT JOIN Factura f ON c.clie_codigo = f.fact_cliente AND YEAR(f.fact_fecha) % 2 <> 0
    WHERE f.fact_fecha IS NULL
),
CategoriaMasComprada AS (
    SELECT 
        clie_codigo,
        prod_rubro,
        RANK() OVER (PARTITION BY clie_codigo ORDER BY SUM(total_comprado) DESC) AS rank_rubro
    FROM Compras2012
    GROUP BY clie_codigo, prod_rubro
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY cmtr.total_comprado DESC) AS numero_fila,
    cmtr.clie_codigo,
    cmtr.clie_nombre,
    cmtr.total_comprado,
    cmc.prod_rubro AS categoria_mas_comprada
FROM ClientesMasDeTresRubros cmtr
JOIN ClientesSinComprasImpares csci ON cmtr.clie_codigo = csci.clie_codigo
JOIN CategoriaMasComprada cmc ON cmtr.clie_codigo = cmc.clie_codigo AND cmc.rank_rubro = 1
ORDER BY cmtr.total_comprado DESC;

-- 2.Implementar los objetos necesarios para registrar, en tiempo real, los 10 productos mas vendidos por año
-- en una tabla específica.Esta tabla debe contener exclusivamente la información requerida, sin incluir filas adicionales.
-- Los "mas vendidos" se definen como aquellos productos con el mayor número de unidades vendidas.


-- Creo tabla auxiliar

CREATE TABLE ProductosMasVendidos (
    año INT,
    prod_codigo CHAR(8),
    unidades_vendidas DECIMAL(12, 2),
    PRIMARY KEY (año, prod_codigo)
);

--  Creo el procedimiento almacenado
 
ALTER PROCEDURE ActualizarProductosMasVendidos
AS
BEGIN
    -- Limpio la tabla antes de actualizar
    DELETE FROM ProductosMasVendidos;

    -- Los 10 productos más vendidos por año
    WITH ProductosVendidos AS (
        SELECT 
            YEAR(f.fact_fecha) AS año,
            i.item_producto,
            SUM(i.item_cantidad) AS unidades_vendidas,
            ROW_NUMBER() OVER (PARTITION BY YEAR(f.fact_fecha) ORDER BY SUM(i.item_cantidad) DESC) AS fila
        FROM Factura f
        JOIN Item_Factura i ON f.fact_tipo = i.item_tipo AND f.fact_sucursal = i.item_sucursal AND f.fact_numero = i.item_numero
        GROUP BY YEAR(f.fact_fecha), i.item_producto
    )
    INSERT INTO ProductosMasVendidos (año, prod_codigo, unidades_vendidas)
    SELECT 
        año,
        item_producto,
        unidades_vendidas
    FROM ProductosVendidos
    WHERE fila <= 10;
END;

-------------------------------- TESTING -------------------------------------

-- Se crea una etapa de prueba para verificar el correcto funcionamiento.
-- Inserto datos de prueba en las tablas Factura e Item_Factura.


-- Insertar datos de prueba en la tabla Factura
INSERT INTO Factura (fact_tipo, fact_sucursal, fact_numero, fact_fecha, fact_vendedor, fact_total, fact_total_impuestos, fact_cliente)
VALUES 
('A', '1111', '00000001', '2022-01-15', 1, 1000.00, 210.00, '00001'),
('A', '1111', '00000002', '2022-02-20', 1, 1500.00, 315.00, '00002'),
('A', '1111', '00000003', '2022-03-10', 2, 2000.00, 420.00, '00003');

-- Insertar datos de prueba en la tabla Item_Factura
INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
VALUES 
('A', '1111', '00000001', '00000030', 10, 100.00),
('A', '1111', '00000002', '00000030', 15, 100.00),
('A', '1111', '00000003', '00000030', 25, 200.00);

-- Ejecuto el procedimiento almacenado manualmente para verificar que funciona correctamente.

EXEC ActualizarProductosMasVendidos;

-- Verificar los resultados
SELECT * FROM ProductosMasVendidos;
------------------------------------------------------------------------------------------------------
-- Insertar, actualizar o eliminar registros en Item_Factura para activar el trigger y verificar que la tabla ProductosMasVendidos se actualiza correctamente.

-- Verificar que el trigger se activó y la tabla ProductosMasVendidos se actualizó
SELECT * FROM ProductosMasVendidos;

-- Actualizar un registro en Item_Factura
UPDATE Item_Factura
SET item_cantidad = 60000
WHERE item_tipo = 'A' AND item_sucursal = '1111' AND item_numero = '00000003' AND item_producto = '00000030';

-- Verificar que el trigger se activó y la tabla ProductosMasVendidos se actualizó
SELECT * FROM ProductosMasVendidos;

-- Eliminar un registro en Item_Factura
DELETE FROM Item_Factura
WHERE item_tipo = 'A' AND item_sucursal = '1111' AND item_numero = '00000004' AND item_producto = '00000030';

-- Verificar que el trigger se activó y la tabla ProductosMasVendidos se actualizó
SELECT * FROM ProductosMasVendidos;


-- Mostrar para todos los rubros de artículos código, detalle, cantidad de artículos de ese
-- rubro y stock total de ese rubro de artículos. Solo tener en cuenta aquellos artículos que
-- tengan un stock mayor al del artículo ‘00000000’ en el depósito ‘00’.


SELECT 
    rubr_id,
    rubr_detalle,
    COUNT(p.prod_codigo) as Cantidad_articulos_del_rubro,
    SUM(s.stoc_cantidad) as Stock_de_articulos
FROM
    Rubro r
JOIN 
    Producto p on r.rubr_id = p.prod_rubro
JOIN
    Stock s on stoc_producto = p.prod_codigo
GROUP BY
    rubr_id,
    rubr_detalle
HAVING --hasta aqui armo un subconjunto, del cual voy a tomar el stoc_cantidad
    SUM(s.stoc_cantidad)>( --comparo con otra cantidad y dentro de la clausula defino un subconj diferente
        SELECT
                SUM(s2.stoc_cantidad)
        FROM
                Stock s2
        WHERE
                s2.stoc_producto = '00000000' and s2.stoc_deposito = '00'
    )
ORDER BY
    Stock_de_articulos ASC;

-- ******************* TESTING ***********************

SELECT * FROM Rubro

-- Insertar datos de prueba en la tabla Rubro
INSERT INTO Rubro (rubr_id, rubr_detalle) VALUES ('T001', 'Electrónica');
INSERT INTO Rubro (rubr_id, rubr_detalle) VALUES ('T002', 'Muebles');

SELECT * FROM Producto

-- Insertar datos de prueba en la tabla Producto
INSERT INTO Producto (prod_codigo, prod_detalle, prod_rubro) VALUES ('TEST001', 'Televisor', 'T001');
INSERT INTO Producto (prod_codigo, prod_detalle, prod_rubro) VALUES ('TEST002', 'Sofá', 'T002');
INSERT INTO Producto (prod_codigo, prod_detalle, prod_rubro) VALUES ('TEST003', 'Laptop', 'T001');

SELECT * FROM Stock
WHERE
    stoc_deposito = ''

-- Insertar datos de prueba en la tabla Stock
INSERT INTO Stock (stoc_producto, stoc_deposito, stoc_cantidad) VALUES ('TEST001', '02', 150);
INSERT INTO Stock (stoc_producto, stoc_deposito, stoc_cantidad) VALUES ('TEST002', '02', 50);
INSERT INTO Stock (stoc_producto, stoc_deposito, stoc_cantidad) VALUES ('TEST003', '02', 200);
-- INSERT INTO Stock (stoc_producto, stoc_deposito, stoc_cantidad) VALUES ('00000000', '00', 100);

SELECT * FROM DEPOSITO


-- Explicación
-- Verificar los Resultados
-- Revisa los resultados de la consulta para asegurarte de que solo se incluyan los rubros cuyos artículos tienen un stock total mayor que el stock del artículo '00000000' en el depósito '00'. En el ejemplo de datos de prueba:

-- Rubro 'Electrónica' debería aparecer porque el stock total (150 + 200 = 350) es mayor que 100.
-- Rubro 'Muebles' no debería aparecer porque el stock total (50) es menor que 100.
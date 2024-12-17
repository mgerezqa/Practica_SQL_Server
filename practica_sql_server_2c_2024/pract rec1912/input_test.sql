


-- NOTA

-- fact_tipo, fact_sucursal,fact_numero es una PK compuesta


-- Insertar un registro en la tabla Factura
INSERT INTO Factura (fact_tipo, fact_sucursal, fact_numero, fact_fecha, fact_vendedor, fact_total, fact_total_impuestos, fact_cliente)
VALUES ('A', '0001', '00000001', GETDATE(), 1, 1000.00, 100.00, '00001');
GO

-- INSERT INTO Factura (fact_tipo, fact_sucursal, fact_numero, fact_fecha, fact_vendedor, fact_total, fact_total_impuestos, fact_cliente)
-- VALUES ('A', '0001', '00000002', GETDATE(), 1, 1000.00, 250.00, '00001');
-- GO

-- INSERT INTO Factura (fact_tipo, fact_sucursal, fact_numero, fact_fecha, fact_vendedor, fact_total, fact_total_impuestos, fact_cliente)
-- VALUES ('A', '0001', '00000003', GETDATE(), 1, 1000.00, 500.00, '00001');
-- GO

-- Crear registros de prueba en la tabla Producto
INSERT INTO [dbo].[Producto] (prod_codigo, prod_detalle) VALUES ('TEST0004', 'Producto de Prueba 4');


-- Insertar una venta del producto 'TEST0004'
INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
VALUES ('A', '0001', '00000001', 'TEST0004', 10, 100.00);
GO

-- Insertar otra venta del producto '00000030' en el mismo mes y año
-- INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
-- VALUES ('A', '0001', '00000002', '00000030', 5, 100.00);
-- GO

-- -- Insertar una venta del producto '00000030' en un mes diferente
-- INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
-- VALUES ('A', '0001', '00000003', '00000030', 8, 100.00);
-- GO

-- ---------------------------------------------------------------------------

-- Crear registros de prueba en la tabla Producto
INSERT INTO [dbo].[Producto] (prod_codigo, prod_detalle) VALUES ('TEST0001', 'Producto de Prueba 1');
INSERT INTO [dbo].[Producto] (prod_codigo, prod_detalle) VALUES ('TEST0002', 'Producto de Prueba 2');

-- Crear registros de prueba en la tabla STOCK
-- PRODUCTO QUE TIENE STOCK
INSERT INTO [dbo].[STOCK] (stoc_producto, stoc_deposito, stoc_cantidad) VALUES ('TEST0001', '00', 100);
-- PRODUCTO QUE NO TIENE STOCK
INSERT INTO [dbo].[STOCK] (stoc_producto, stoc_deposito, stoc_cantidad) VALUES ('TEST0002', '00', 0 );


SELECT * FROM Producto

SELECT * FROM Factura
WHERE fact_cliente = '00001'

SELECT * FROM Item_Factura



-- 
-- Eliminar una venta del producto 'TEST0004'
DELETE FROM Item_Factura
WHERE item_producto = 'TEST0004'

-- Eliminar producto TEST0004
DELETE FROM Producto
WHERE prod_codigo = 'TEST0004'
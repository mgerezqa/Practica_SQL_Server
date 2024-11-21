-- EJERCICIO:
-- 	Crear el/los objetos de base de datos que ante la venta 
-- 	del producto '00000030' registre en una estructura adicional
-- 	el mes, anio y la cantidad de ese producto que se esta 
-- 	comprando por mes y anio.
	
-- 1) Entender que pide. (5 minutos.)


-- Se requiere crear un mecanismo que, al realizarse una venta del producto con código '00000030', registre en una estructura adicional (una tabla) el mes, año y la cantidad de ese producto que se está comprando por mes y año.



-- 2) Que tipo de trigger me conviene y sobre que evento y tabla 
--    (5 minutos)


-- Para este caso, lo más conveniente es crear un trigger AFTER INSERT en la tabla que registra las ventas (por ejemplo, Item_Factura). Este trigger se activará después de que se inserte un nuevo registro de venta y verificará si el producto vendido es '00000030'. Si es así, actualizará o insertará la información en la tabla adicional.
   
-- 3) que otros objetos necesito para poder desarrollarlo
--    (5 minutos)

-- Se necesita una tabla adicional para guardar el historico de ventas del producto 00000030. 
   
-- 4) desarrollo
--    (15 minutos)
   
USE GD2015C1;
GO

CREATE TABLE RegistroVentasProducto (
    producto_codigo CHAR(8),
    mes INT,
    anio INT,
    cantidad DECIMAL(12, 2),
    PRIMARY KEY (producto_codigo, mes, anio)
);
GO

USE GD2015C1;
GO

CREATE TRIGGER trg_AfterInsertVentaProducto
ON Item_Factura
AFTER INSERT
AS
BEGIN
    DECLARE @producto_codigo CHAR(8);
    DECLARE @cantidad DECIMAL(12, 2);
    DECLARE @mes INT;
    DECLARE @anio INT;

    -- Obtener los valores del nuevo registro insertado
    SELECT @producto_codigo = item_producto, 
           @cantidad = item_cantidad,
           @mes = MONTH(GETDATE()), 
           @anio = YEAR(GETDATE())
    FROM inserted
    WHERE item_producto = '00000030';

    -- Verificar si el producto es '00000030'
    IF @producto_codigo = '00000030'
    BEGIN
        -- Verificar si ya existe un registro para el mes y año
        IF EXISTS (SELECT 1 FROM RegistroVentasProducto 
                   WHERE producto_codigo = @producto_codigo 
                   AND mes = @mes 
                   AND anio = @anio)
        BEGIN
            -- Actualizar la cantidad existente
            UPDATE RegistroVentasProducto
            SET cantidad = cantidad + @cantidad
            WHERE producto_codigo = @producto_codigo 
            AND mes = @mes 
            AND anio = @anio;
        END
        ELSE
        BEGIN
            -- Insertar un nuevo registro
            INSERT INTO RegistroVentasProducto (producto_codigo, mes, anio, cantidad)
            VALUES (@producto_codigo, @mes, @anio, @cantidad);
        END
    END
END;
GO



-- 5) testing 
--    (5 minutos)



-- Insertar un registro en la tabla Factura
INSERT INTO Factura (fact_tipo, fact_sucursal, fact_numero, fact_fecha, fact_vendedor, fact_total, fact_total_impuestos, fact_cliente)
VALUES ('A', '0001', '00000001', GETDATE(), 1, 1000.00, 100.00, '00001');
GO

INSERT INTO Factura (fact_tipo, fact_sucursal, fact_numero, fact_fecha, fact_vendedor, fact_total, fact_total_impuestos, fact_cliente)
VALUES ('A', '0001', '00000002', GETDATE(), 1, 1000.00, 250.00, '00001');
GO

INSERT INTO Factura (fact_tipo, fact_sucursal, fact_numero, fact_fecha, fact_vendedor, fact_total, fact_total_impuestos, fact_cliente)
VALUES ('A', '0001', '00000003', GETDATE(), 1, 1000.00, 500.00, '00001');
GO



-- Insertar una venta del producto '00000030'
INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
VALUES ('A', '0001', '00000001', '00000030', 10, 100.00);
GO

-- Insertar otra venta del producto '00000030' en el mismo mes y año
INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
VALUES ('A', '0001', '00000002', '00000030', 5, 100.00);
GO

-- Insertar una venta del producto '00000030' en un mes diferente
INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
VALUES ('A', '0001', '00000003', '00000030', 8, 100.00);
GO

-- 

-- Consultar la tabla RegistroVentasProducto para verificar el registro
SELECT * FROM RegistroVentasProducto
WHERE producto_codigo = '00000030';
GO

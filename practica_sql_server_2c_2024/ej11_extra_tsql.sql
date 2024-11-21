	-- EJERCICIO:
-- Crear el/los objetos de base de datos que ante la venta  del producto '00000030' registre en una estructura adicional
-- el mes, anio y la cantidad de ese producto que se esta  comprando por mes y anio.
	
-- 1) Entender que pide. (5 minutos.)

-- 2) Que tipo de trigger me conviene y sobre que evento y tabla 
--    (5 minutos)
   
-- 3) que otros objetos necesito para poder desarrollarlo
--    (5 minutos)
   
-- 4) desarrollo
--    (15 minutos)
   
-- 5) testing 
--    (5 minutos)


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



ALTER TRIGGER trg_AfterInsertVentaProducto
ON Item_Factura
AFTER INSERT
AS
BEGIN
    -- Declarar variables
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

    -- Mensaje de depuración
    PRINT 'Producto: ' + @producto_codigo + ', Cantidad: ' + CAST(@cantidad AS VARCHAR) + ', Mes: ' + CAST(@mes AS VARCHAR) + ', Año: ' + CAST(@anio AS VARCHAR);

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


-- Testing


-- seleccinar fact_cliente 
SELECT * FROM Cliente
WHERE clie_codigo = '00001';

-- Precondición) Prestar atención que tiene que existir fact_cliente

-- Como vamos a insertar tres registros para la tabla auxiliar RegistroVentasProducto, vamos a insertar tres registros en la tabla Factura y en la tabla Item_Factura para que se dispare el trigger.


-- 1) Crear una factura con el producto '00000030' en el mes y año actual.

-- Insertar un registro en la tabla Factura
INSERT INTO Factura (fact_tipo, fact_sucursal, fact_numero, fact_fecha, fact_vendedor, fact_total, fact_total_impuestos, fact_cliente)
VALUES ('A', '0001', '00000001', GETDATE(), 1, 1000.00, 100.00, '00001');
GO


-- Insertar registro en la tabla Factura con 00000002 y fecha octubre 2024
INSERT INTO Factura (fact_tipo, fact_sucursal, fact_numero, fact_fecha, fact_vendedor, fact_total, fact_total_impuestos, fact_cliente)
VALUES ('A', '0001', '00000002', '2024-10-01', 1, 1000.00, 100.00, '00001');

-- Insertar registro en la tabla Factura con 00000003 y fecha julio 2023
INSERT INTO Factura (fact_tipo, fact_sucursal, fact_numero, fact_fecha, fact_vendedor, fact_total, fact_total_impuestos, fact_cliente)
VALUES ('A', '0001', '00000003', '2023-07-01', 1, 1000.00, 100.00, '00001');




-- Inserto una venta del producto '00000030' , por cada venta corresponde una factura diferente 
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


-- Consultar la tabla RegistroVentasProducto para verificar el registro
SELECT * FROM RegistroVentasProducto
WHERE producto_codigo = '00000030';


SELECT * FROM Item_Factura
WHERE item_producto = '00000030';


-- selecciona la factura con la pk 'A', '0001', '00000001'
SELECT * FROM Factura
WHERE fact_tipo = 'A' AND fact_sucursal = '0001' AND fact_numero = '00000001';
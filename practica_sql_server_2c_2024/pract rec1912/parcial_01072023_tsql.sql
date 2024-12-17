/* Implementar una regla de negocio para mantener siempre consistente (actualizada bajo cualquier circunstancia)
una nueva tabla llamada PRODUCTOS_VENDIDOS. 
En esta tabla debe registrar 
el periodo (YYYYMM), 
el codigo de producto, 
el precio maximo de venta 
y las unidades venidadas. 
Toda esta información debe estar por periodo (YYYYMM).
*/

-- Primero creamos la tabla
CREATE TABLE dbo.PRODUCTOS_VENDIDOS (
    periodo CHAR(6) NOT NULL,
    prod_codigo CHAR(8) NOT NULL,
    precio_maximo DECIMAL(12,2) NOT NULL,
    unidades_vendidas DECIMAL(12,2) NOT NULL,
    CONSTRAINT PK_PRODUCTOS_VENDIDOS PRIMARY KEY (periodo, prod_codigo),
    CONSTRAINT FK_PRODUCTOS_VENDIDOS_PRODUCTO FOREIGN KEY (prod_codigo) 
        REFERENCES dbo.Producto(prod_codigo)
)
GO

-- Luego creamos el trigger
CREATE OR ALTER TRIGGER dbo.TR_P01072023_ACTUALIZAR_PRODUCTOS_VENDIDOS
ON dbo.Item_Factura
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Tabla temporal para almacenar los períodos y productos afectados
    CREATE TABLE #PeriodosAfectados (
        periodo CHAR(6),
        prod_codigo CHAR(8)
    )

    -- Insertar períodos afectados por registros insertados o actualizados
    INSERT INTO #PeriodosAfectados
    SELECT DISTINCT 
        FORMAT(f.fact_fecha, 'yyyyMM'),
        i.item_producto
    FROM inserted i
    INNER JOIN dbo.Factura f ON i.item_tipo = f.fact_tipo 
        AND i.item_sucursal = f.fact_sucursal 
        AND i.item_numero = f.fact_numero

    -- Insertar períodos afectados por registros eliminados
    INSERT INTO #PeriodosAfectados
    SELECT DISTINCT 
        FORMAT(f.fact_fecha, 'yyyyMM'),
        d.item_producto
    FROM deleted d
    INNER JOIN dbo.Factura f ON d.item_tipo = f.fact_tipo 
        AND d.item_sucursal = f.fact_sucursal 
        AND d.item_numero = f.fact_numero

    -- Actualizar o insertar registros en PRODUCTOS_VENDIDOS
    MERGE INTO dbo.PRODUCTOS_VENDIDOS AS target
    USING (
        SELECT 
            FORMAT(f.fact_fecha, 'yyyyMM') as periodo,
            i.item_producto,
            MAX(i.item_precio) as precio_maximo,
            SUM(i.item_cantidad) as unidades_vendidas
        FROM dbo.Item_Factura i
        INNER JOIN dbo.Factura f ON i.item_tipo = f.fact_tipo 
            AND i.item_sucursal = f.fact_sucursal 
            AND i.item_numero = f.fact_numero
        INNER JOIN #PeriodosAfectados pa 
            ON FORMAT(f.fact_fecha, 'yyyyMM') = pa.periodo 
            AND i.item_producto = pa.prod_codigo
        GROUP BY FORMAT(f.fact_fecha, 'yyyyMM'), i.item_producto
    ) AS source
    ON (target.periodo = source.periodo AND target.prod_codigo = source.item_producto)
    WHEN MATCHED THEN
        UPDATE SET 
            precio_maximo = source.precio_maximo,
            unidades_vendidas = source.unidades_vendidas
    WHEN NOT MATCHED THEN
        INSERT (periodo, prod_codigo, precio_maximo, unidades_vendidas)
        VALUES (source.periodo, source.item_producto, source.precio_maximo, source.unidades_vendidas);

    DROP TABLE #PeriodosAfectados;
END
GO

-- Verificamos que el trigger se haya creado correctamente

IF OBJECT_ID('dbo.TR_ACTUALIZAR_PRODUCTOS_VENDIDOS', 'TR') IS NOT NULL
    PRINT 'El trigger TR_ACTUALIZAR_PRODUCTOS_VENDIDOS se ha creado correctamente.'
ELSE
    PRINT 'Error al crear el trigger TR_ACTUALIZAR_PRODUCTOS_VENDIDOS.'



-- Ejemplo de inserción

-- Insertar un registro en la tabla Factura
INSERT INTO Factura (fact_tipo, fact_sucursal, fact_numero, fact_fecha, fact_vendedor, fact_total, fact_total_impuestos, fact_cliente)
VALUES ('A', '0001', '00000001', GETDATE(), 1, 1000.00, 100.00, '00001');
GO

-- Crear registros de prueba en la tabla Producto
INSERT INTO [dbo].[Producto] (prod_codigo, prod_detalle) VALUES ('TEST0004', 'Producto de Prueba 4');

-- Insertar una venta del producto 'TEST0004'
INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
VALUES ('A', '0001', '00000001', 'TEST0004', 10, 100.00);
GO

SELECT * FROM dbo.PRODUCTOS_VENDIDOS;
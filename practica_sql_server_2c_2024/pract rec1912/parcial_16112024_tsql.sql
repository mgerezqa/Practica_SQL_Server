/*
Implementar  los objetos necesarios para registrar, en tiempo real, los 10 productos más vendidos por año
en una tabla específica. Esta tabla debe contener exclusivamente la información requerida, sin incluir filas adicionales.
Los "mas vendidos" se definen como aquellos productos con el mayor numero de unidades vendidas.
*/

-- Crear tabla de productos más vendidos
CREATE TABLE dbo.TopProductosVendidos (
    anio INT NOT NULL,
    prod_codigo CHAR(8) NOT NULL,
    prod_detalle CHAR(50) NULL,
    unidades_vendidas DECIMAL(12,2) NOT NULL,
    monto_total DECIMAL(12,2) NOT NULL,
    ultima_actualizacion DATETIME NOT NULL,
    CONSTRAINT PK_TopProductosVendidos PRIMARY KEY (anio, prod_codigo),
    CONSTRAINT FK_TopProductosVendidos_Producto 
        FOREIGN KEY (prod_codigo) REFERENCES dbo.Producto(prod_codigo)
)
GO

CREATE OR ALTER TRIGGER dbo.TR_P16112024_Actualizar_TopProductosVendidos
ON dbo.Item_Factura
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Identificar los años afectados
    DECLARE @AnosAfectados TABLE (anio INT)
    
    INSERT INTO @AnosAfectados
    SELECT DISTINCT YEAR(f.fact_fecha)
    FROM Factura f
    INNER JOIN (
        SELECT DISTINCT item_tipo, item_sucursal, item_numero 
        FROM inserted
        UNION
        SELECT DISTINCT item_tipo, item_sucursal, item_numero 
        FROM deleted
    ) cambios ON f.fact_tipo = cambios.item_tipo 
        AND f.fact_sucursal = cambios.item_sucursal 
        AND f.fact_numero = cambios.item_numero;

    -- Tabla variable para almacenar los productos más vendidos por año
    DECLARE @ProductosVendidosPorAno TABLE (
        anio INT,
        item_producto CHAR(8),
        prod_detalle CHAR(50),
        unidades_vendidas DECIMAL(12,2),
        monto_total DECIMAL(12,2),
        rn INT
    )

    -- Obtener los productos más vendidos
    INSERT INTO @ProductosVendidosPorAno
    SELECT 
        YEAR(f.fact_fecha) as anio,
        i.item_producto,
        p.prod_detalle,
        SUM(i.item_cantidad) as unidades_vendidas,
        SUM(i.item_cantidad * i.item_precio) as monto_total,
        ROW_NUMBER() OVER (
            PARTITION BY YEAR(f.fact_fecha) 
            ORDER BY SUM(i.item_cantidad) DESC
        ) as rn
    FROM dbo.Item_Factura i
    INNER JOIN dbo.Factura f ON i.item_tipo = f.fact_tipo 
        AND i.item_sucursal = f.fact_sucursal 
        AND i.item_numero = f.fact_numero
    INNER JOIN dbo.Producto p ON i.item_producto = p.prod_codigo
    WHERE YEAR(f.fact_fecha) IN (SELECT anio FROM @AnosAfectados)
    GROUP BY YEAR(f.fact_fecha), i.item_producto, p.prod_detalle;

    -- Actualizar la tabla final usando MERGE
    MERGE INTO dbo.TopProductosVendidos AS target
    USING (
        SELECT 
            anio, 
            item_producto,
            prod_detalle,
            unidades_vendidas,
            monto_total,
            GETDATE() as ultima_actualizacion
        FROM @ProductosVendidosPorAno
        WHERE rn <= 10
    ) AS source
    ON target.anio = source.anio AND target.prod_codigo = source.item_producto
    WHEN MATCHED THEN
        UPDATE SET 
            target.unidades_vendidas = source.unidades_vendidas,
            target.monto_total = source.monto_total,
            target.prod_detalle = source.prod_detalle,
            target.ultima_actualizacion = source.ultima_actualizacion
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (anio, prod_codigo, prod_detalle, unidades_vendidas, monto_total, ultima_actualizacion)
        VALUES (
            source.anio, 
            source.item_producto, 
            source.prod_detalle, 
            source.unidades_vendidas, 
            source.monto_total,
            source.ultima_actualizacion
        )
    WHEN NOT MATCHED BY SOURCE AND target.anio IN (SELECT anio FROM @AnosAfectados) THEN
        DELETE;
END


-- TESTING

SELECT * FROM Cliente
SELECT * FROM Empleado

SELECT * FROM dbo.Producto
WHERE prod_codigo = '00000030'

-- Insertar un registro en la tabla Factura

INSERT INTO Factura (fact_tipo, fact_sucursal, fact_numero, fact_fecha, fact_vendedor, fact_total, fact_total_impuestos, fact_cliente)
VALUES ('A', '0001', '00007003', GETDATE(), 1, 1000.00, 250.00, '00001');
GO

SELECT * FROM Factura 
WHERE fact_tipo = 'A' 
AND fact_sucursal = '0001' 
AND fact_numero = '00007003';

-- Insertar una venta del producto '00000030'
INSERT INTO Item_Factura(item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
VALUES ('A', '0001', '00007003', '00000030', 50000, 100.00);
GO

SELECT * FROM Item_Factura
WHERE item_numero = '00007003'

SELECT * FROM TopProductosVendidos





SELECT 
    YEAR(f.fact_fecha) as anio,
    i.item_producto,
    SUM(i.item_cantidad) as unidades_vendidas
FROM dbo.Item_Factura i
INNER JOIN dbo.Factura f ON i.item_tipo = f.fact_tipo 
    AND i.item_sucursal = f.fact_sucursal 
    AND i.item_numero = f.fact_numero
GROUP BY YEAR(f.fact_fecha), i.item_producto
ORDER BY anio, unidades_vendidas DESC;
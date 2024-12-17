/* Implementar una regla de negocio de validación en linea que permita implementar una logica de control
de precios en las ventas. Se deberá poder seleccionar una lista de rubros y aquellos productos de los rubros
que sean los seleccionados no podrán aumentar por mes mas de un 2%. En caso de que no se tenga referencia del mes anterior no validar 
dicha regla. */


-- Resolver con pseducódigo
/*
INICIO
  CREAR TABLA RUBROS_CONTROLADOS
    - rubro_id: CHAR(4) PK
    - rubro_detalle: CHAR(50)

  CREAR CONSTRAINT EN ITEM_FACTURA QUE VALIDE:
    AL INSERTAR/ACTUALIZAR UN ITEM:
      1. OBTENER EL RUBRO DEL PRODUCTO DEL ITEM
      2. VERIFICAR SI EL RUBRO ESTÁ EN RUBROS_CONTROLADOS
      3. SI ESTÁ EN RUBROS_CONTROLADOS:
          - OBTENER PRECIO DEL MES ANTERIOR DEL PRODUCTO
          - SI EXISTE PRECIO DEL MES ANTERIOR:
              - CALCULAR DIFERENCIA PORCENTUAL
              - SI DIFERENCIA > 2%:
                  RECHAZAR OPERACIÓN
              SINO:
                  PERMITIR OPERACIÓN
          - SI NO EXISTE PRECIO DEL MES ANTERIOR:
              PERMITIR OPERACIÓN
      4. SI NO ESTÁ EN RUBROS_CONTROLADOS:
          PERMITIR OPERACIÓN
FIN

*/

-- Crear tabla de rubros controlados

-- 1. Crear tabla de rubros controlados
CREATE TABLE dbo.RUBROS_CONTROLADOS (
    rubr_id CHAR(4) NOT NULL,
    CONSTRAINT PK_RUBROS_CONTROLADOS PRIMARY KEY (rubr_id),
    CONSTRAINT FK_RUBROS_CONTROLADOS_RUBRO FOREIGN KEY (rubr_id) 
        REFERENCES dbo.Rubro(rubr_id)
)
GO

-- 2. Crear constraint para validar el aumento de precios
CREATE TRIGGER TR_Control_Precios_Item_Factura
ON dbo.Item_Factura
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Si encontramos algún item que viole la regla, hacemos rollback
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.Factura f ON f.fact_tipo = i.item_tipo 
            AND f.fact_sucursal = i.item_sucursal 
            AND f.fact_numero = i.item_numero
        INNER JOIN dbo.Producto p ON p.prod_codigo = i.item_producto
        INNER JOIN dbo.RUBROS_CONTROLADOS rc ON p.prod_rubro = rc.rubr_id
        WHERE EXISTS (
            -- Buscamos el precio del mes anterior para el mismo producto
            SELECT 1
            FROM dbo.Item_Factura if_ant
            INNER JOIN dbo.Factura f_ant ON f_ant.fact_tipo = if_ant.item_tipo 
                AND f_ant.fact_sucursal = if_ant.item_sucursal 
                AND f_ant.fact_numero = if_ant.item_numero
            WHERE if_ant.item_producto = i.item_producto
            AND DATEADD(MONTH, DATEDIFF(MONTH, 0, f_ant.fact_fecha), 0) = 
                DATEADD(MONTH, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, f.fact_fecha), 0))
            AND i.item_precio > if_ant.item_precio * 1.02
        )
    )
    BEGIN
        RAISERROR ('No se permite un aumento mayor al 2% en productos de rubros controlados respecto al mes anterior.', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
END
GO

-- Caso de prueba

SELECT * FROM dbo.RUBROS_CONTROLADOS;

SELECT * FROM dbo.Factura;

SELECT * FROM dbo.Producto;

-- 1. Insertar un rubro controlado

INSERT INTO dbo.RUBROS_CONTROLADOS (rubr_id) VALUES ('T001');

-- 2. Insertar una factura del mes pasado
INSERT INTO dbo.Factura (fact_tipo, fact_sucursal, fact_numero, fact_fecha)
VALUES ('A', '0001', '00007001', DATEADD(MONTH, -1, GETDATE()));

-- Insertar item con precio base
INSERT INTO dbo.Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
VALUES ('A', '0001', '00007001', 'TEST001', 1, 100.00);

-- 3. Insertar una factura del mes actual
INSERT INTO dbo.Factura (fact_tipo, fact_sucursal, fact_numero, fact_fecha)
VALUES ('A', '0001', '00007002', GETDATE());

-- Caso que debería funcionar (aumento del 2%)
INSERT INTO dbo.Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
VALUES ('A', '0001', '00007002', 'TEST001', 1, 102.00);

-- Caso que debería fallar (aumento mayor al 2%)
INSERT INTO dbo.Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
VALUES ('A', '0001', '00007002', 'TEST001', 1, 103.00);

SELECT * FROM Rubro
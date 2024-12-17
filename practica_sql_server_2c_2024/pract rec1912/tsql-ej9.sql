-- Crear el/los objetos de base de datos que ante alguna modificación de un ítem de
-- factura de un artículo con composición realice el movimiento de sus
-- correspondientes componentes.
CREATE TRIGGER TR_Item_Factura_Composicion
ON Item_Factura
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Solo nos interesa procesar si se modificó la cantidad
    IF NOT UPDATE(item_cantidad)
        RETURN;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Tabla temporal para almacenar los componentes a procesar
        CREATE TABLE #ComponentesAProcesar (
            item_tipo char(1),
            item_sucursal char(4),
            item_numero char(8),
            componente char(8),
            cantidad_anterior decimal(12,2),
            cantidad_nueva decimal(12,2),
            cantidad_por_unidad decimal(12,2)
        );
        
        -- Obtener los productos modificados que tienen composición
        INSERT INTO #ComponentesAProcesar
        SELECT 
            i.item_tipo,
            i.item_sucursal,
            i.item_numero,
            c.comp_componente,
            (d.item_cantidad * c.comp_cantidad) as cantidad_anterior,
            (i.item_cantidad * c.comp_cantidad) as cantidad_nueva,
            c.comp_cantidad
        FROM inserted i
        INNER JOIN deleted d ON 
            i.item_tipo = d.item_tipo AND 
            i.item_sucursal = d.item_sucursal AND 
            i.item_numero = d.item_numero AND 
            i.item_producto = d.item_producto
        INNER JOIN Composicion c ON i.item_producto = c.comp_producto
        WHERE i.item_cantidad != d.item_cantidad;
        
        -- Si no hay componentes a procesar, terminamos
        IF NOT EXISTS (SELECT 1 FROM #ComponentesAProcesar)
        BEGIN
            DROP TABLE #ComponentesAProcesar;
            RETURN;
        END;
        
        -- Procesar cada componente
        -- 1. Si ya existe el componente en la factura, actualizamos la cantidad
        UPDATE ItemF
        SET ItemF.item_cantidad = ItemF.item_cantidad + (CP.cantidad_nueva - CP.cantidad_anterior)
        FROM Item_Factura ItemF
        INNER JOIN #ComponentesAProcesar CP ON
            ItemF.item_tipo = CP.item_tipo AND
            ItemF.item_sucursal = CP.item_sucursal AND
            ItemF.item_numero = CP.item_numero AND
            ItemF.item_producto = CP.componente;
            
        -- 2. Si no existe el componente, lo insertamos
        INSERT INTO Item_Factura (
            item_tipo,
            item_sucursal,
            item_numero,
            item_producto,
            item_cantidad,
            item_precio
        )
        SELECT 
            CP.item_tipo,
            CP.item_sucursal,
            CP.item_numero,
            CP.componente,
            CP.cantidad_nueva,
            P.prod_precio
        FROM #ComponentesAProcesar CP
        INNER JOIN Producto P ON CP.componente = P.prod_codigo
        WHERE NOT EXISTS (
            SELECT 1
            FROM Item_Factura ItemF
            WHERE ItemF.item_tipo = CP.item_tipo
            AND ItemF.item_sucursal = CP.item_sucursal
            AND ItemF.item_numero = CP.item_numero
            AND ItemF.item_producto = CP.componente
        );
        
        -- Actualizar el total de la factura
        UPDATE F
        SET fact_total = (
            SELECT SUM(item_cantidad * item_precio)
            FROM Item_Factura ItemF
            WHERE ItemF.item_tipo = F.fact_tipo
            AND ItemF.item_sucursal = F.fact_sucursal
            AND ItemF.item_numero = F.fact_numero
        )
        FROM Factura F
        WHERE EXISTS (
            SELECT 1 
            FROM #ComponentesAProcesar CP
            WHERE CP.item_tipo = F.fact_tipo
            AND CP.item_sucursal = F.fact_sucursal
            AND CP.item_numero = F.fact_numero
        );
        
        DROP TABLE #ComponentesAProcesar;
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        IF OBJECT_ID('tempdb..#ComponentesAProcesar') IS NOT NULL
            DROP TABLE #ComponentesAProcesar;
            
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
-- Realizar un procedimiento que si en alguna factura 
-- se facturaron componentes que conforman un combo determinado (o sea que juntos componen otro
-- producto de mayor nivel), 
-- caso deberá reemplazar las filas correspondientes a dichos productos por una sola fila con el producto que 
-- componen con la cantidad de dicho producto que corresponda.


CREATE PROCEDURE SP_ConsolidarComponentes
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Crear tabla temporal para almacenar las facturas a procesar
        CREATE TABLE #FacturasAProcesar (
            fact_tipo char(1),
            fact_sucursal char(4),
            fact_numero char(8)
        );
        
        -- Identificar facturas que tienen componentes que forman productos
        INSERT INTO #FacturasAProcesar
        SELECT DISTINCT 
            i1.item_tipo,
            i1.item_sucursal,
            i1.item_numero
        FROM Item_Factura i1
        WHERE EXISTS (
            -- Verificar si hay otros componentes en la misma factura que juntos forman un producto
            SELECT 1
            FROM Composicion c1
            WHERE c1.comp_componente = i1.item_producto
            AND EXISTS (
                SELECT 1
                FROM Item_Factura i2
                INNER JOIN Composicion c2 ON c2.comp_componente = i2.item_producto
                WHERE i2.item_tipo = i1.item_tipo
                AND i2.item_sucursal = i1.item_sucursal
                AND i2.item_numero = i1.item_numero
                AND c2.comp_producto = c1.comp_producto
                AND i2.item_producto != i1.item_producto
            )
        );
        
        -- Procesar cada factura identificada
        DECLARE @tipo char(1), @sucursal char(4), @numero char(8)
        DECLARE cur_facturas CURSOR FOR
        SELECT fact_tipo, fact_sucursal, fact_numero
        FROM #FacturasAProcesar;
        
        OPEN cur_facturas;
        FETCH NEXT FROM cur_facturas INTO @tipo, @sucursal, @numero;
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Crear tabla temporal para almacenar los combos encontrados
            CREATE TABLE #CombosEncontrados (
                producto_combo char(8),
                cantidad_combo decimal(12,2)
            );
            
            -- Identificar y calcular combos
            INSERT INTO #CombosEncontrados
            SELECT 
                c1.comp_producto,
                MIN(FLOOR(i.item_cantidad / c1.comp_cantidad)) as cantidad_combo
            FROM Item_Factura i
            INNER JOIN Composicion c1 ON c1.comp_componente = i.item_producto
            WHERE i.item_tipo = @tipo
            AND i.item_sucursal = @sucursal
            AND i.item_numero = @numero
            GROUP BY c1.comp_producto
            HAVING COUNT(DISTINCT i.item_producto) = (
                SELECT COUNT(*)
                FROM Composicion c2
                WHERE c2.comp_producto = c1.comp_producto
            );
            
            -- Insertar los nuevos registros de combos
            INSERT INTO Item_Factura (
                item_tipo, 
                item_sucursal,
                item_numero,
                item_producto,
                item_cantidad,
                item_precio
            )
            SELECT 
                @tipo,
                @sucursal,
                @numero,
                ce.producto_combo,
                ce.cantidad_combo,
                (SELECT prod_precio FROM Producto WHERE prod_codigo = ce.producto_combo)
            FROM #CombosEncontrados ce;
            
            -- Eliminar los componentes originales
            DELETE i
            FROM Item_Factura i
            INNER JOIN Composicion c ON c.comp_componente = i.item_producto
            WHERE i.item_tipo = @tipo
            AND i.item_sucursal = @sucursal
            AND i.item_numero = @numero
            AND c.comp_producto IN (SELECT producto_combo FROM #CombosEncontrados);
            
            -- Actualizar el total de la factura
            UPDATE Factura
            SET fact_total = (
                SELECT SUM(item_cantidad * item_precio)
                FROM Item_Factura
                WHERE item_tipo = @tipo
                AND item_sucursal = @sucursal
                AND item_numero = @numero
            )
            WHERE fact_tipo = @tipo
            AND fact_sucursal = @sucursal
            AND fact_numero = @numero;
            
            DROP TABLE #CombosEncontrados;
            FETCH NEXT FROM cur_facturas INTO @tipo, @sucursal, @numero;
        END;
        
        CLOSE cur_facturas;
        DEALLOCATE cur_facturas;
        
        DROP TABLE #FacturasAProcesar;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        -- Registrar el error
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;
        
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
            
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;

-- Seleccionar todos los productos que son componentes de otro producto
SELECT DISTINCT 
    p.prod_codigo,
    p.prod_detalle
FROM Producto p
INNER JOIN Composicion c ON p.prod_codigo = c.comp_componente
ORDER BY p.prod_codigo;


-- Seleccionar todos los productos que son componentes de otro producto
SELECT 
    p.prod_codigo AS codigo_componente,
    p.prod_detalle AS detalle_componente,
    pcomp.prod_codigo AS codigo_producto_padre,
    pcomp.prod_detalle AS detalle_producto_padre
FROM Producto p
INNER JOIN Composicion c ON p.prod_codigo = c.comp_componente
INNER JOIN Producto pcomp ON c.comp_producto = pcomp.prod_codigo
ORDER BY p.prod_codigo;


-- Seleccionar los productos que están compuesto
SELECT * FROM Item_Factura
LEFT JOIN
Composicion
ON Item_Factura.item_producto = Composicion.comp_producto
WHERE Composicion.comp_producto IS NOT NULL

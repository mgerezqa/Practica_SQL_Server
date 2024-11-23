-- Implementar una regla de negocio de validación en línea que permita validar el STOCK al realizarse una venta.
-- Cada venta se debe descontar sobre el depósito 00. 
-- En caso de que se venda un producto compuesto, el descuento de stock se debe realizar por sus componentes. 
-- Si no hay STOCK para ese articulo, no se deberá guardar ese articulo, pero si los otros en los cuales hay stock positivo.
-- Es decir, solamente se deberán guardar aquellos para los cuales si hay stock, sin guardarse los que no poseen cantidades suficientes.

-- NOTA: Resolver con TSQL.


USE GD2015C1;
GO

CREATE OR ALTER TRIGGER trg_P12112022_ValidarStockAntesDeInsertar
ON Item_Factura
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @item_tipo CHAR(1);
    DECLARE @item_sucursal CHAR(4);
    DECLARE @item_numero CHAR(8);
    DECLARE @item_producto CHAR(8);
    DECLARE @item_cantidad DECIMAL(12, 2);
    DECLARE @stock_disponible DECIMAL(12, 2);
    DECLARE @comp_cantidad DECIMAL(12, 2);
    DECLARE @comp_componente CHAR(8);

    DECLARE cur CURSOR FOR
    SELECT item_tipo, item_sucursal, item_numero, item_producto, item_cantidad
    FROM inserted;

    OPEN cur;
    FETCH NEXT FROM cur INTO @item_tipo, @item_sucursal, @item_numero, @item_producto, @item_cantidad;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Verificar si el producto es compuesto
        IF EXISTS (SELECT 1 FROM Composicion WHERE comp_producto = @item_producto)
        BEGIN
            -- Verificar stock de los componentes
            DECLARE comp_cur CURSOR FOR
            SELECT comp_componente, comp_cantidad
            FROM Composicion
            WHERE comp_producto = @item_producto;

            OPEN comp_cur;
            FETCH NEXT FROM comp_cur INTO @comp_componente, @comp_cantidad;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Verificar stock del componente
                SELECT @stock_disponible = stoc_cantidad
                FROM STOCK
                WHERE stoc_producto = @comp_componente AND stoc_deposito = '00';

                IF @stock_disponible < @item_cantidad * @comp_cantidad
                BEGIN
                    -- No hay suficiente stock para el componente, no insertar el artículo
                    FETCH NEXT FROM cur INTO @item_tipo, @item_sucursal, @item_numero, @item_producto, @item_cantidad;
                    CONTINUE;
                END

                FETCH NEXT FROM comp_cur INTO @comp_componente, @comp_cantidad;
            END

            CLOSE comp_cur;
            DEALLOCATE comp_cur;
        END
        ELSE
        BEGIN
            -- Verificar stock del producto
            SELECT @stock_disponible = stoc_cantidad
            FROM STOCK
            WHERE stoc_producto = @item_producto AND stoc_deposito = '00';

            IF @stock_disponible < @item_cantidad
            BEGIN
                -- No hay suficiente stock para el producto, no insertar el artículo
                FETCH NEXT FROM cur INTO @item_tipo, @item_sucursal, @item_numero, @item_producto, @item_cantidad;
                CONTINUE;
            END
        END

        -- Insertar el artículo si hay suficiente stock
        INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
        SELECT item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio
        FROM inserted
        WHERE item_tipo = @item_tipo AND item_sucursal = @item_sucursal AND item_numero = @item_numero AND item_producto = @item_producto;

        -- Descontar el stock
        IF EXISTS (SELECT 1 FROM Composicion WHERE comp_producto = @item_producto)
        BEGIN
            -- Descontar stock de los componentes
            DECLARE comp_cur2 CURSOR FOR
            SELECT comp_componente, comp_cantidad
            FROM Composicion
            WHERE comp_producto = @item_producto;

            OPEN comp_cur2;
            FETCH NEXT FROM comp_cur2 INTO @comp_componente, @comp_cantidad;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                UPDATE STOCK
                SET stoc_cantidad = stoc_cantidad - @item_cantidad * @comp_cantidad
                WHERE stoc_producto = @comp_componente AND stoc_deposito = '00';

                FETCH NEXT FROM comp_cur2 INTO @comp_componente, @comp_cantidad;
            END

            CLOSE comp_cur2;
            DEALLOCATE comp_cur2;
        END
        ELSE
        BEGIN
            -- Descontar stock del producto
            UPDATE STOCK
            SET stoc_cantidad = stoc_cantidad - @item_cantidad
            WHERE stoc_producto = @item_producto AND stoc_deposito = '00';
        END

        FETCH NEXT FROM cur INTO @item_tipo, @item_sucursal, @item_numero, @item_producto, @item_cantidad;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO



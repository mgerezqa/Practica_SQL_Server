/*Implementar una regla de negocio en linea que al realizar una venta (solo inserción)
-- permita componer los productos descompuestos.Hacelo genérico.
Ejemplo: Si se guardan en la factura 2 hamburguesas,2 papas y 2 gaseoas se deberá guardar en la factra dos unidades del Combo1. 
Donde un Combo1 equivale a 1 hamburguesa, 1 papa y 1 gaseosa.

 Nota: Considerar que cada vez que se guardan los items, se mandan todos los productos de ese item a la vez, y no de manera parcial
*/

CREATE OR ALTER TRIGGER trg_ComponerCombos
ON Item_Factura
AFTER INSERT
AS
BEGIN
    DECLARE @fact_tipo CHAR(2), @fact_sucursal CHAR(2), @fact_numero INT;

    -- Obtener los datos de la factura
    SELECT @fact_tipo = i.item_tipo, @fact_sucursal = i.item_sucursal, @fact_numero = i.item_numero
    FROM inserted i
    GROUP BY i.item_tipo, i.item_sucursal, i.item_numero;

    -- Iterar sobre cada tipo de combo definido en la tabla Composicion
    DECLARE combo_cursor CURSOR FOR
    SELECT DISTINCT comp_producto
    FROM Composicion;

    DECLARE @combo_producto CHAR(8);
    OPEN combo_cursor;
    FETCH NEXT FROM combo_cursor INTO @combo_producto;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @min_combos INT = NULL;

        -- Calcular la cantidad de combos posibles para el combo actual
        SELECT @min_combos = MIN(i.item_cantidad / c.comp_cantidad)
        FROM inserted i
        JOIN Composicion c ON i.item_producto = c.comp_componente
        WHERE c.comp_producto = @combo_producto
        AND i.item_tipo = @fact_tipo AND i.item_sucursal = @fact_sucursal AND i.item_numero = @fact_numero
        GROUP BY c.comp_producto;

        IF @min_combos IS NOT NULL AND @min_combos > 0
        BEGIN
            -- Actualizar las cantidades de los productos
            UPDATE Item_Factura
            SET item_cantidad = item_cantidad - @min_combos * c.comp_cantidad
            FROM Item_Factura i
            JOIN Composicion c ON i.item_producto = c.comp_componente
            WHERE i.item_tipo = @fact_tipo AND i.item_sucursal = @fact_sucursal AND i.item_numero = @fact_numero
            AND c.comp_producto = @combo_producto;

            -- Insertar los combos en la factura
            INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad)
            VALUES (@fact_tipo, @fact_sucursal, @fact_numero, @combo_producto, @min_combos);
        END

        FETCH NEXT FROM combo_cursor INTO @combo_producto;
    END

    CLOSE combo_cursor;
    DEALLOCATE combo_cursor;
END;


-- TESTING -- 

SELECT * FROM Factura;

SELECT * from Item_Factura;

-- Selecciona de la tabla producto donde el detalle del producto empieza con 'HAMB
SELECT * FROM Producto WHERE prod_detalle LIKE 'HAM%';


-- Insertar una factura con 2 hamburguesas, 2 papas y 2 gaseosas
INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad)
VALUES ('F1', 'S1', 1, 'HAMBUR01', 2),
       ('F1', 'S1', 1, 'PAPA01', 2),
       ('F1', 'S1', 1, 'GASEOS01', 2);

-- Verificar que se haya insertado el combo
SELECT * FROM Item_Factura WHERE item_tipo = 'F1' AND item_sucursal = 'S1' AND item_numero = 1;

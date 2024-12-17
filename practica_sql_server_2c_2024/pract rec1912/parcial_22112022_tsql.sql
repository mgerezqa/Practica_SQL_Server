/* Implementar una regla de negocio en linea donde se valide que nunca un producto compuesto pueda estar compuesto 
por componentes de rubros distintos a el.*/


-- Agregamos la constraint a la tabla Composicion
ALTER TABLE dbo.Composicion
ADD CONSTRAINT CK_Composicion_Mismo_Rubro
CHECK (
    NOT EXISTS (
        -- Buscamos si hay algún componente con rubro diferente al producto principal
        SELECT 1
        FROM dbo.Producto p_comp  -- Producto componente
        INNER JOIN dbo.Producto p_princ  -- Producto principal
            ON p_princ.prod_codigo = comp_producto
        WHERE p_comp.prod_codigo = comp_componente
            AND p_comp.prod_rubro <> p_princ.prod_rubro
    )
)


-- Explicación del código:

-- Usamos ALTER TABLE para agregar una nueva constraint a la tabla Composicion
-- La constraint usa CHECK con NOT EXISTS para validar que no haya casos inválidos
-- Dentro del EXISTS:

-- Unimos la tabla Producto dos veces para comparar el producto principal y el componente
-- Verificamos que el rubro del componente sea igual al rubro del producto principal
-- Si EXISTS encuentra algún caso donde los rubros son diferentes, la constraint falla

-- Caso que debería fallar (productos de diferentes rubros)

SELECT * FROM Rubro;
SELECT * FROM Producto;
SELECT * FROM Composicion;

-- 1. Primero insertamos algunos rubros de prueba
INSERT INTO dbo.Rubro (rubr_id, rubr_detalle) VALUES 
('T001', 'Electrónica'),
('T002', 'Muebles');

-- 2. Insertamos productos de prueba en diferentes rubros
INSERT INTO dbo.Producto (prod_codigo, prod_detalle, prod_precio, prod_rubro) VALUES 
-- Productos del rubro BEBIDAS
('TEST004', 'TECLADO', 100.00, 'T001'),
('TEST005', 'MONITOR', 20000.00, 'T001'),
('TEST006', 'CPU', 80000.00, 'T001');

-- Caso 1: Debería FUNCIONAR - Mismo rubro (T001 - Electrónica)
INSERT INTO dbo.Composicion (comp_producto, comp_componente, comp_cantidad) VALUES
('TEST003', 'TEST004', 1),
('TEST003', 'TEST005', 1);

-- Caso 2: Debería FALLAR - Rubros diferentes (ELectrónica y Muebles)
INSERT INTO dbo.Composicion (comp_producto, comp_componente, comp_cantidad) VALUES
('TEST003', 'TEST004', 1),
('TEST003', 'TEST002', 1);



-- Eliminar una venta del producto 'TEST0004'
DELETE FROM Item_Factura
WHERE item_producto = 'TEST0004'

-- Eliminar producto TEST0004
DELETE FROM Producto
WHERE prod_codigo = 'TEST0004'


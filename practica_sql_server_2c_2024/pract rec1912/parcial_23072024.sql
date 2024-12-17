/* Se desea obtener un informe sobre la demanda de los productos que posee la empresa 
en su catalogo y las caracteristicas del mismo.Para cumplir con este pedido se requiere
-- que realice una consulta que devuelva, para todos los productos, las siguientes columnas:

-- 1. El codigo del producto.
-- 2. El detalle del producto.
-- 3. Es producto compuesto ? (Si es compuesto mostrar 'Si', sino 'No')
-- 4  Es componente de algun producto compuesto ? (Si es componente mostrar 'Si', sino 'No')
-- 5. Cantidad de depositos donde existe stock del producto.
-- 6. Cantidad de unidades vendidas de ese producto.
-- 7. Codigo del cliente que mas compro ese producto.

Los datos deben estar ordenados por monto total vendido de ese producto, de mayor a menor.
Se debe crear la consulta de tal forma que los valores en NULL se reemplacen por 0 o por un string
vacio segun corresponda el tipo de dato. */


SELECT
        p.prod_codigo 'Codigo del producto',
        p.prod_detalle 'Detalle del producto',
        (CASE WHEN EXISTS 
        (SELECT 1 FROM Composicion WHERE comp_producto = p.prod_codigo) 
        THEN 'Si' 
        ELSE 'No' 
        END) 'Es componente de compuesto',
        (CASE WHEN EXISTS 
        (-- Seleccionar todos los productos que son componentes de otro producto
        SELECT 1
        FROM Producto pa
        INNER JOIN Composicion c ON p.prod_codigo = c.comp_componente
        INNER JOIN Producto pcomp ON c.comp_producto = pcomp.prod_codigo)
         THEN 'Si' 
         ELSE 'No' 
         END) 'Es producto compuesto',
        ISNULL(
            (SELECT COUNT(DISTINCT stoc_deposito) 
            FROM Stock 
            WHERE stoc_producto = p.prod_codigo), 0) 'Cantidad de depositos c/stock',
        ISNULL(
            (SELECT SUM(item_cantidad)
             FROM Item_factura
             WHERE item_producto = p.prod_codigo),0) 'Cantidad de unidades vendidas',
        ISNULL(
            (SELECT TOP 1 c.clie_codigo
            FROM Cliente c
            INNER JOIN Factura f 
            ON c.clie_codigo = f.fact_cliente
            INNER JOIN Item_factura i 
            ON f.fact_tipo = i.item_tipo 
            AND f.fact_sucursal = i.item_sucursal 
            AND f.fact_numero = i.item_numero
            WHERE i.item_producto = p.prod_codigo
            GROUP BY c.clie_codigo
            ORDER BY SUM(i.item_cantidad * i.item_precio) DESC),0)
            'Codigo del cliente que mas compro'
FROM Producto p
GROUP BY p.prod_codigo, p.prod_detalle



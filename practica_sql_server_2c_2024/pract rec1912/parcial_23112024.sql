/* El objetivo es realizar una consula SQL que identifique a los vendedores que durante los ultimos tres años consecutivos,
incrementarion sus ventas en un 100% cada año respecto al año anterior.
La consulta debe devolver los siguientes datos:
    1.El numero de fila(orden correlativo)
    2.El nombre del vendedor.
    3.La cantidad de empleados a cargo de cada vendedor.
    4.La cantidad de clientes a los que vendió en total.
*/

-- El resultado debe estar ordenado en forma descendente según el monto total de ventas del vendedor(de mayor a menor).

SELECT
   ROW_NUMBER() OVER (ORDER BY SUM(e.empl_codigo) DESC) 'Numero de fila',
   e.empl_nombre 'Nombre del vendedor',
   (
       SELECT COUNT(*)
       FROM Empleado
       WHERE empl_jefe = e.empl_codigo
   ) 'Cantidad de empleados a cargo',
   COUNT(DISTINCT f.fact_cliente) 'Cantidad de clientes a los que vendio en total'
FROM
   Empleado e
JOIN
   Factura f ON e.empl_codigo = f.fact_vendedor
WHERE
   YEAR(f.fact_fecha) BETWEEN (SELECT MAX(YEAR(fact_fecha)) - 3 FROM Factura) 
   AND (SELECT MAX(YEAR(fact_fecha)) FROM Factura)
GROUP BY
   e.empl_codigo,
   e.empl_nombre
HAVING
   SUM(f.fact_total) > 2 * COALESCE(
       (SELECT SUM(fact_total)
        FROM Factura f2
        WHERE YEAR(f2.fact_fecha) = (SELECT MAX(YEAR(fact_fecha)) - 3 FROM Factura)
        AND f2.fact_vendedor = e.empl_codigo), 0)
   AND SUM(f.fact_total) > 2 * COALESCE(
       (SELECT SUM(fact_total)
        FROM Factura f2
        WHERE YEAR(f2.fact_fecha) = (SELECT MAX(YEAR(fact_fecha)) - 2 FROM Factura)
        AND f2.fact_vendedor = e.empl_codigo), 0)
   AND SUM(f.fact_total) > 2 * COALESCE(
       (SELECT SUM(fact_total)
        FROM Factura f2
        WHERE YEAR(f2.fact_fecha) = (SELECT MAX(YEAR(fact_fecha)) - 1 FROM Factura)
        AND f2.fact_vendedor = e.empl_codigo), 0)
ORDER BY
   SUM(f.fact_total) DESC;


SELECT * FROM Empleado
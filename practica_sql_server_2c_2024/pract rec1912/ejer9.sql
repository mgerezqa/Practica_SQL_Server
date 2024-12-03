-- 9 Mostrar el código y nombre del jefe, el código y nombre del empleado al que supervisa , 
-- y la cantidad de depósitos que ambos tienen asignados.


SELECT
      e1.empl_codigo as empleado_codigo,
      e1.empl_apellido as empleado_apellido,
      e1.empl_nombre as empleado_nombre,
      e2.empl_codigo as jefe_codigo,
      e2.empl_nombre as jefe_nombre,
      e2.empl_apellido as jefe_apellido,
      COUNT(d.depo_encargado) as cantidad_de_depositos
FROM
      Empleado e1
LEFT JOIN 
      Empleado e2 on  e1.empl_jefe = e2.empl_codigo
JOIN
      Deposito d on (d.depo_encargado = e1.empl_codigo or d.depo_encargado = e2.empl_jefe)
GROUP BY
       e1.empl_codigo,
      e1.empl_apellido,
      e1.empl_nombre ,
      e2.empl_codigo ,
      e2.empl_nombre ,
      e2.empl_apellido
ORDER BY
      cantidad_de_depositos ASC



-- ESTA MANERA ESTA MAL PORQUE ESTOY MOSTRANDO EMPLEADOS QUE NO SON JEFES EN COLUMNAS DE JEFES
-- SELECT
--         jefe.empl_codigo as jefe_cod,
--         jefe.empl_nombre as jefe_nombre,
--         jefe.empl_apellido as jefe_apellido,
--         -- en caso de obtener valor null, mostrar leyenda "no es jefe"
--         sub.empl_codigo as subordinado_cod,
--         sub.empl_nombre as subordinado_nombre,
--         sub.empl_apellido as subordinado_apellido
-- FROM
--         Empleado jefe
-- LEFT JOIN
--         Empleado sub on sub.empl_jefe = jefe.empl_codigo



-- SELECT
--       e.empl_codigo AS codigo_empleado,
--       e.empl_jefe AS codigo_jefe,
--         CASE
--             WHEN e.empl_jefe IS NULL THEN 'No es Jefe'
--         ELSE 'Es Jefe'
--         END AS descripcion_jefe,

--       CONCAT(e.empl_nombre, ' ', e.empl_apellido) AS nombre_completo,
--       COUNT(d.depo_codigo) AS cantidad_depositos_asignados
-- FROM   
--       Empleado e
-- LEFT JOIN 
--       Deposito d ON e.empl_jefe = d.depo_encargado
-- GROUP BY
--       e.empl_codigo,
--       e.empl_jefe,
--       CONCAT(e.empl_nombre, ' ', e.empl_apellido);



SELECT * FROM Empleado

SELECT * FROM Deposito


-- Cantidad de depositos que tiene un empleado.

SELECT
        e.empl_codigo,
        e.empl_apellido,
        COUNT(d.depo_codigo) as cantidad_de_depositos_a_cargo
FROM 
    Empleado e
JOIN
    Deposito d on e.empl_codigo = d.depo_encargado 

GROUP BY
    e.empl_codigo,
    e.empl_apellido


-- Helper

SELECT * FROM DEPOSITO
order BY depo_encargado
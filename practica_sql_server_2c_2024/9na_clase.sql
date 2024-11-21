-- Repaso de la 9na clase de SQL Server

-- PRACTICA DE SQL SERVER

-- 3) Cree el/los objetos de base de datos necesarios para corregir la tabla empleado en caso que sea necesario. 
-- Se sabe que debería existir un único gerente general (debería ser el único empleado sin jefe). 
-- Si detecta que hay más de un empleado sin jefe deberá elegir entre ellos el gerente general, el cual será seleccionado por mayor salario. 
-- Si hay más de uno se seleccionara el de mayor antigüedad en la empresa. 
-- Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla de un único empleado sin jefe (el gerente general) y deberá retornar la cantidad de empleados que había sin jefe antes de la ejecución.


-- 5. Realizar un procedimiento que complete con los datos existentes en el modelo provisto la tabla de hechos denominada Fact_table tiene las siguiente definición:
-- Create table Fact_table ( anio char(4),
-- mes char(2),
-- familia char(3),
-- rubro char(4),
-- zona char(3),
-- cliente char(6), producto char(8), cantidad decimal(12,2), monto decimal(12,2)
-- )
-- Alter table Fact_table
-- Add constraint primary key(anio,mes,familia,rubro,zona,cliente,producto)


-- EJERCICIO: REALIZAR UN DELETE EN CASCADA SOBRE LA TABLA CLIENTE 
-- QUE SE EJECUTE CUANDO UN USUARIO EJECUTA UN DELETE. 
-- ESTO SIGNIFICA QUE SI QUIERO BORRAR UN CLIENTE ME PERMITA HACERLO 
-- BORRANDO DE LAS TABLAS ADECUADAS.


-- DELETE CLIENTE WHERE .....


-- 15. Escriba una consulta que retorne los pares de productos que hayan sido vendidos juntos (en la misma factura) más de 500 veces. El resultado debe mostrar el código y descripción de cada uno de los productos y la cantidad de veces que fueron vendidos juntos. El resultado debe estar ordenado por la cantidad de veces que se vendieron juntos dichos productos. Los distintos pares no deben retornarse más de una vez.
-- Ejemplo de lo que retornaría la consulta:
-- PROD1 DETALLE1 PROD2 DETALLE2 VECES
-- 1731 MARLBORO KS 1 7 1 8 P H ILIPS MORRIS KS 5 0 7
-- 1718 PHILIPS MORRIS KS 1 7 0 5 P H I L I P S MORRIS BOX 10 5 6 2
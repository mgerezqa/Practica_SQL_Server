<!-- SQL -->

### 2023_07_04

1. Se solicita estadística por Año y familia, para ello se deberá mostrar.
  Año, Código de familia, Detalle de familia, cantidad de facturas, cantidad
  de productos con composición vendidos, monto total vendido.
   Solo se deberán considerar las familias que tengan al menos un producto con
  composición y que se hayan vendido conjuntamente (en la misma factura)
  con otra familia distinta.
  NOTA: No se permite el uso de sub-selects en el FROM ni funciones
  definidas por el usuario para este punto,*/

  

------



### 2023_07_08


2. Se pide que realice un reporte generado por una sola query que de cortes de informacion por periodos
(anual,semestral y bimestral). Un corte por el año, un corte por el semestre el año y un corte por bimestre el año. 
En el corte por año mostrar las ventas totales realizadas por año, la cantidad de rubros distintos comprados por año, 
la cantidad de productos con composición distintos comprados por año y la cantidad de clientes que compraron por año.
Luego, en la información del semestre mostrar la misma información, es decir, las ventas totales por semestre, cantidad de rubros 
por semestre, etc. y la misma logica por bimestre. El orden tiene que ser cronologico.

### -- nota:8 sin comentarios



------




### Parcial_2021

1. Armar una consulta SQL que retorne: █:DONE

- Razón social del cliente

- Límite de crédito del cliente
- Producto más comprado en la historia (en unidades)     -- Yo interpreto que es el producto mas comprado en la historia del cliente
- Solamente deberá mostrar aquellos clientes que tuvieron mayor cantidad de ventas en el 2012 que en el 2011 en cantidades y cuyos montos de ventas en dichos años sean un 30 % mayor el 2012 con respecto al 2011. 
- El resultado deberá ser ordenado por código de cliente ascendente

NOTA: No se permite el uso de sub-selects en el FROM.



<hr>

### Parcial_2022_11_08

*--todo: comentario de mi resuelto : en 5 y 6 se pueden resolver sin subquerys y es importante. ver como se hace en otros parciales sin subqueys :D*

1. Realizar una consulta SQL que permita saber si un cliente compro un producto en todos los meses del 2012.

Además, mostrar para el 2012: 
1. El cliente
2. La razón social del cliente
3. El producto comprado
4. El nombre del producto
5. Cantidad de productos distintos comprados por el cliente.
6. Cantidad de productos con composición comprados por el cliente.

El resultado deberá ser ordenado poniendo primero aquellos clientes que compraron más de 10 productos distintos en el 2012. 



<hr>

### Parcial_2022_11_08



Realizar una consulta SQL que permita saber los clientes que compraron por encima del promedio de compras (fact_total) de todos

los clientes del 2012.

De estos clientes mostrar para el 2012:

1.El código del cliente

2.La razón social del cliente

3.Código de producto que en cantidades más compro.

4,El nombre del producto del punto 3.

5,Cantidad de productos distintos comprados por el cliente,

6.Cantidad de productos con composición comprados por el cliente, EI resultado deberá ser ordenado poniendo primero aquellos clientes que compraron más de entre 5 y 10 productos distintos en el 2012.



<hr>



### Parcial_2022_11_12



Realizar una consulta SQL que permita saber los clientes que compraron por encima del promedio de compras (fact_total) de todos los clientes del 2012.

De estos clientes mostrar para el 2012:

1.El código del cliente

2.La razón social del cliente

3.Código de producto que en cantidades más compro.

4,El nombre del producto del punto 3.

5,Cantidad de productos distintos comprados por el cliente,

6.Cantidad de productos con composición comprados por el cliente,

EI resultado deberá ser ordenado poniendo primero aquellos clientes

que compraron más de entre 5 y 10 productos distintos en el 2012 



<hr>

### Parcial_2022_11_15



Realizar una consulta SQL que permita saber 

  los clientes que compraron todos los rubros disponibles del sistema en el 2012.

De estos clientes mostrar, siempre para el 2012: 

  1.El código del cliente

  2.Código de producto que en cantidades más compro.

  3.El nombre del producto del punto 2.

  4.Cantidad de productos distintos comprados por el cliente.

  5.Cantidad de productos con composición comprados por el cliente.

El resultado deberá ser ordenado por razón social del cliente

alfabéticamente primero y luego, los clientes que compraron entre un

20 % y 30% del total facturado en el 2012 primero, luego, los restantes,

<hr>

### Parcial_2022_11_22

pensar en un big mac : buger papa coca

Realizar una consulta SQL que muestre aquellos productos que 

   tengan 3 componentes a nivel producto y 

   cuyos componentes tengan 2 rubros distintos.

De estos productos mostrar:

   i. El código de producto.

   ii. El nombre del producto.

   iii. La cantidad de veces que fueron vendidos sus componentes en el 2012.

   iv. Monto total vendido del producto.

El resultado ser ordenado por cantidad de facturas del 2012 en las cuales se vendieron los componentes.

**Nota: No se permiten select en el from, es decir, select from (select as T....**

*/

<hr>

### Parcial 2023_06_27

I.Realizar una consulta SQL que retorne para  todas las zonas que tengan 3 (tres) o más depósitos.

- Detalle Zona
- Cantidad de Depósitos x Zona
- Cantidad de Productos distintos compuestos en sus depósitos
- Producto mas vendido en el año 2012 que tonga stock en al menos uno de sus depósitos.
-  Mejor encargado perteneciente a esa zona (El que mas vendió en la historia).

El resultado deberá ser ordenado por monto total vendido del encargado DESC.

zona--> deposito --> Stock

*/

<hr>

### Parcial 2023_06_17_TN

1. Realizar una consulta SOL que retorne para los 10 clientes que más

compraron en el 2012 y que fueron atendldos por más de 3 vendedores

distintos:

- Apellido y Nombro del Cliente.
- Cantidad de Productos distintos comprados en el 2012,
- Cantidad de unidades compradas dentro del primer semestre del 2012.

El resultado deberá mostrar ordenado la cantidad de ventas  de forma descendente del 2012 de cada cliente, en caso de igualdad de ventas i ordenar por código de cliente.

NOTA: No se permite el uso de sub-setects en el FROM ni funciones definidas por el usuario para este punto,

*/

<hr>

### Parcial 2023_06_28



Realizar una consulta SQL que devuelva todos los clientes que durante 2 años consecutivos compraron al menos 5 productos distintos. 

De esos clientes mostrar:

• El código de cliente

• El monto total comprado en el 2012

• La cantidad de unidades de productos compradas en el 2012

El resultado debe ser ordenado primero por aquellos clientes que compraron solo productos compuestos en algun momento, luego el resto.

Nota: No se permiten select en el from, es decir, select from (select ...) as T ...



<hr>

### Parcial 2023_06_29



Realiza una consulta SQL que devuelva todos los clientes que durante 2  años consecutivos compraron al menos 5 productos  distintos. 

De esos clientes mostrar.

• codigo cliente

• El monto total comprado en el 2012

• La cantidad de unidades de productos compradas  en el 2012

El resultado debe ser ordenado primero por aquellos clientes que compraron solo productos compuestos en algún momento, luego el resto.



<hr>

### Parcial 2023_07_01

/* nota:7 sin comentarios del profesor.

1. Realizar una consulta SQL que muestre aquellos clientes que en 2 años consecutivos compraron.

De estos clientes mostrar

-   El código de cliente.
-   El nombre del cliente.
-   El numero de rubros que compro el cliente.
-   La cantidad de productos con composición que compro el cliente en el 2012.

El resultado deberá ser ordenado por cantidad de facturas del cliente en toda la historia, de manera ascendente.

Nota: No se permiten select en el from, es decir, select ... from (select ...) as T,

<hr>

### X_SQL_parcial_2022_11_19 

  ►AUN NO COMPARADO CON OTRA PERSONA

Realizar una consulta SQL que permita saber los clientes que compraron en el 2012 al menos 1 unidad de todos los productos compuestos.

De estos clientes mostrar, siempre para el 2012:

​    ►I. El código del cliente

​    ►2. Código de producto que en cantidades más compro.

?? 3. El número de fila según el orden establecido con un alias llamado ORDINAL. 

​    ►4. Cantidad de productos distintos comprados por el cliente.

​    ►5. Monto total comprado.

El resultado deberá ser ordenado por razón social del cliente

alfabéticamente primero y luego, los clientes que compraron entre un

20 % y 30% del total facturado en el 2012 primero, luego, los restantes.*/

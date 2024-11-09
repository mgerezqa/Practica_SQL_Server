
-- 2. Mostrar el código, detalle de todos los artículos vendidos en el año 2012 ordenados por cantidad vendida.

Select prod_codigo,
       prod_detalle,
       sum(I.item_cantidad) as cantidad_vendida
from dbo.Producto P
inner join dbo.Item_Factura I
    on P.prod_codigo = I.item_producto
inner join dbo.Factura F
    on I.item_tipo = F.fact_tipo 
    and I.item_sucursal = F.fact_sucursal
    and I.item_numero = F.fact_numero
where
    year(F.fact_fecha) = 2012
group by 
    prod_codigo,prod_detalle
ORDER BY 
    cantidad_vendida;


-- SOLUCION 2 AGRUPANDO POR FECHA
Select prod_codigo,
       prod_detalle,
       sum(I.item_cantidad) as cantidad_vendida
from dbo.Producto P
inner join dbo.Item_Factura I
    on P.prod_codigo = I.item_producto
inner join dbo.Factura F
    on I.item_tipo = F.fact_tipo 
    and I.item_sucursal = F.fact_sucursal
    and I.item_numero = F.fact_numero
group by 
    prod_codigo,
    prod_detalle,
    year(F.fact_fecha)

HAVING
    year(F.fact_fecha) = 2012
ORDER BY 
    cantidad_vendida;


-- CONCLUSIONES
-- HACER EL FILTRO POR AÑO EN EL WHERE ES MAS EFICIENTE QUE HACERLO EN EL HAVING PORQUE EL WHERE SE EJECUTA ANTES DE AGRUPAR LOS DATOS
-- POR LO QUE SE REDUCE EL VOLUMEN DE DATOS A AGRUPAR
-- EN CAMBIO EL HAVING SE EJECUTA DESPUES DE AGRUPAR LOS DATOS POR LO QUE SE AGRUPAN MAS DATOS
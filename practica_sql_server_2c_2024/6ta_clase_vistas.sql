
-- Vistas: Tabla virtual
-- una vista me permite enmascarar una consulta SQL como si fuera una tabla 

-- Estaticas y dinámicas

-- Vamos a trabajar mayormente con vistas dinámicas

-- Estaticas y dinámicas

-- Vamos a trabajar mayormente con vistas dinámicas

CREATE VIEW VIEW_EJEMPLO 
AS
SELECT 
    c.clie_codigo,
    c.clie_razon_social,
    SUM(f.fact_total) AS total_facturado
FROM 
    Cliente c
JOIN 
    Factura f ON c.clie_codigo = f.fact_cliente
GROUP BY 
    c.clie_codigo,
    c.clie_razon_social;
GO

SELECT * FROM VIEW_EJEMPLO
WHERE
    cod = '00010'


    -- otRA VISTA   
-- Crear una vista que realice un query de la facturación total por cliente y por año.
create view VIEW_year_clie ( cod_clie , anio, total_anio  )
AS

	SELECT 
		fact_cliente ,
		year(fact_fecha),
		sum(fact_total)
	FROM Factura f 
	group by 
		fact_cliente,
		year(fact_fecha)
GO



SELECT * FROM VIEW_year_clie 

-- Funciones

CREATE FUNCTION fnc_cuadrado(  @param1 decimal(12,2)  )
RETURNS decimal(14,4) 
AS
BEGIN
	declare @result decimal(12,2) 
	
	set @result = @param1 * @param1
	return @result 
	
	
END;

select dbo.fnc_cuadrado(12)

-- Funciones con parametros de salida
-- Funcion que retorna una tabla

CREATE function fnc_tabla( @codigo char(6))
RETURNS TABLE
AS
    RETURN
    (
        SELECT 
            *
        FROM Cliente
        WHERE clie_codigo != @codigo
    );

-- es una funcion que actua como un filtro excluyendo el codigo de cliente que se le pasa por parametro sobre la tabla cliente


SELECT * FROM dbo.fnc_tabla('00000')
ORDER BY 
    clie_codigo asc



-- Resumen
-- La función fnc_tabla toma un parámetro de entrada @codigo de tipo char(6) y devuelve una tabla que contiene todas las filas de la tabla Cliente donde el valor de clie_codigo no es igual al valor del parámetro @codigo
-- 4. Cree el/los objetos de base de datos necesarios para actualizar la columna de
-- empleado empl_comision con la sumatoria del total de lo vendido por ese
-- empleado a lo largo del último año. Se deberá retornar el código del vendedor
-- que más vendió (en monto) a lo largo del último año.

-- Enfoque: Automatizar la actualización de la columna empl_comision con la sumatoria
-- del total de lo vendido por ese empleado a lo largo del último año. Luego, retornar
-- el código del vendedor que más vendió (en monto) a lo largo del último año.
-- objeto de tsql a utilizar: store procedure

CREATE PROCEDURE dbo.ej4_tsql_sp_actualizar_comisiones 
@emple_vendedor NUMERIC(6, 0) 
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @mejor_vendedor NUMERIC(6, 0)
    DECLARE @ultimo_anio INT
    SELECT @ultimo_anio = MAX(YEAR(fact_fecha)) FROM Factura

    -- Actualizar la columna empl_comision con la sumatoria del total de lo vendido por ese empleado a lo largo del último año
    UPDATE Empleado
    SET empl_comision = ISNULL((
        SELECT SUM(fact_total)
        FROM Factura
        WHERE fact_vendedor = @emple_vendedor
        AND YEAR(fact_fecha) = @ultimo_anio
    ), 0)
    WHERE empl_codigo = @emple_vendedor  -- Esta es la condición que faltaba

    
    -- Retornar el código del vendedor que más facturas vendió (en monto) a lo largo del último año
    SELECT TOP 1 
    @mejor_vendedor = fact_vendedor
    FROM Factura
    WHERE YEAR(fact_fecha) = @ultimo_anio
    GROUP BY fact_vendedor 
    ORDER BY SUM(fact_total) DESC
    RETURN @mejor_vendedor

END

-- Ejectuar el store procedure
DECLARE @resultado NUMERIC(6,0)
EXEC @resultado = dbo.ej4_tsql_sp_actualizar_comisiones @emple_vendedor = 9  --cod empleado
SELECT @resultado as mejor_vendedor

-- helper
SELECT * FROM Empleado
-- 3. Cree el/los objetos de base de datos necesarios para corregir la tabla empleado
-- en caso que sea necesario. 
-- Se sabe que debería existir un único gerente general (debería ser el único empleado sin jefe).
-- Si detecta que hay más de un empleado sin jefe deberá elegir entre ellos el gerente general, 
-- el cual será seleccionado por mayor salario.
-- Si hay más de uno se seleccionara el de mayor antigüedad en la
-- empresa.
--  Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla
-- de un único empleado sin jefe (el gerente general) y deberá retornar la cantidad
-- de empleados que había sin jefe antes de la ejecución.


CREATE PROCEDURE dbo.sp_correccion_tabla_empleado 
    @empleados_sin_jefe INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Guardar cantidad de empleados sin jefe inicial
    SELECT @empleados_sin_jefe = COUNT(*)
    FROM Empleado
    WHERE empl_jefe IS NULL
    
    -- Si hay más de un empleado sin jefe
    IF @empleados_sin_jefe > 1
    BEGIN
        -- Declarar variable para almacenar el ID del gerente general
        DECLARE @gerente_general numeric(6,0)
        
        -- Seleccionar el gerente general (mayor salario y si hay empate, mayor antigüedad)
        SELECT TOP 1 @gerente_general = empl_codigo
        FROM Empleado
        WHERE empl_jefe IS NULL
        ORDER BY empl_salario DESC, empl_ingreso ASC
        
        -- Actualizar todos los empleados sin jefe (excepto el gerente general)
        -- asignándoles como jefe al gerente general
        UPDATE Empleado
        SET empl_jefe = @gerente_general
        WHERE empl_jefe IS NULL
        AND empl_codigo != @gerente_general
    END
    
    RETURN 0
END


DECLARE @cant_sin_jefe INT

EXEC dbo.sp_correccion_tabla_empleado @empleados_sin_jefe = @cant_sin_jefe OUTPUT

SELECT @cant_sin_jefe as 'Cantidad inicial de empleados sin jefe'

-----------------------------------------------------------------------------------------------------------------
-- version con funcion , mal porque no es el objeto apropiado.
-----------------------------------------------------------------------------------------------------------------


CREATE PROCEDURE dbo.sp_correccion_tabla_empleado_v2
    @empleados_sin_jefe INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Guardar cantidad de empleados sin jefe inicial
    SELECT @empleados_sin_jefe = COUNT(*)
    FROM Empleado
    WHERE empl_jefe IS NULL
    
    -- Si hay más de un empleado sin jefe
    IF @empleados_sin_jefe > 1
    BEGIN
        -- Declarar variable para almacenar el ID del gerente general
        DECLARE @gerente_general numeric(6,0)
        
        -- Seleccionar el gerente general (mayor salario y si hay empate, mayor antigüedad)
        SELECT TOP 1 @gerente_general = empl_codigo
        FROM Empleado
        WHERE empl_jefe IS NULL
        ORDER BY empl_salario DESC, empl_ingreso ASC
        
        -- Actualizar todos los empleados sin jefe (excepto el gerente general)
        -- asignándoles como jefe al gerente general
        UPDATE Empleado
        SET empl_jefe = @gerente_general
        WHERE empl_jefe IS NULL
        AND empl_codigo != @gerente_general
    END
    
    RETURN 0
END
-- helper
-- SELECT * FROM EMPLEADO
-- SELECT COUNT(*) FROM EMPLEADO WHERE empl_jefe IS NULL

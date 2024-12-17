CREATE PROCEDURE dbo.ej4_tsql_sp_actualizar_comisiones_transq
    @emple_vendedor NUMERIC(6, 0) 
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Variables para el proceso
    DECLARE @mejor_vendedor NUMERIC(6, 0)
    DECLARE @ultimo_anio INT
    DECLARE @error_message NVARCHAR(4000)
    DECLARE @error_severity INT
    DECLARE @error_state INT

    BEGIN TRY
        -- Iniciamos la transacción
        BEGIN TRANSACTION;

        -- Validamos que el empleado exista
        IF NOT EXISTS (SELECT 1 FROM Empleado WHERE empl_codigo = @emple_vendedor)
        BEGIN
            RAISERROR('El empleado %d no existe en la base de datos.', 16, 1, @emple_vendedor)
        END

        -- Obtenemos el último año
        SELECT @ultimo_anio = MAX(YEAR(fact_fecha)) FROM Factura
        
        IF @ultimo_anio IS NULL
        BEGIN
            RAISERROR('No existen facturas en la base de datos.', 16, 1)
        END

        -- Actualizar la comisión SOLO del empleado recibido por parámetro
        UPDATE Empleado
        SET empl_comision = ISNULL((
            SELECT SUM(fact_total)
            FROM Factura
            WHERE fact_vendedor = @emple_vendedor
            AND YEAR(fact_fecha) = @ultimo_anio
        ), 0)
        WHERE empl_codigo = @emple_vendedor

        -- Retornar el código del vendedor que más facturas vendió
        SELECT TOP 1 
        @mejor_vendedor = fact_vendedor
        FROM Factura
        WHERE YEAR(fact_fecha) = @ultimo_anio
        GROUP BY fact_vendedor 
        ORDER BY SUM(fact_total) DESC

        -- Si llegamos hasta aquí, todo salió bien, confirmamos la transacción
        COMMIT TRANSACTION;
        
        RETURN @mejor_vendedor

    END TRY
    BEGIN CATCH
        -- Si hay error, hacemos rollback
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Capturamos los detalles del error
        SELECT 
            @error_message = ERROR_MESSAGE(),
            @error_severity = ERROR_SEVERITY(),
            @error_state = ERROR_STATE();

        -- Relanzamos el error con los detalles
        RAISERROR(@error_message, @error_severity, @error_state);
        
        RETURN -1; -- Retornamos -1 para indicar que hubo un error
    END CATCH
END

-- 

-- TESTING

-- Ejemplo de uso exitoso
DECLARE @resultado NUMERIC(6,0)
EXEC @resultado = dbo.ej4_tsql_sp_actualizar_comisiones_transq @emple_vendedor = 9
IF @resultado = -1
    PRINT 'Hubo un error en la ejecución'
ELSE
    PRINT 'El mejor vendedor es: ' + CAST(@resultado AS VARCHAR)

-- Ejemplo con error (empleado que no existe)
DECLARE @resultado2 NUMERIC(6,0)
EXEC @resultado2 = dbo.ej4_tsql_sp_actualizar_comisiones_transq @emple_vendedor = 99999

-- 

-- Control de Transacciones:

-- BEGIN TRANSACTION al inicio
-- COMMIT si todo sale bien
-- ROLLBACK si hay algún error


-- Validaciones:

-- Verifica que el empleado exista
-- Verifica que haya facturas en la base de datos


-- Manejo de Errores:

-- Usa TRY-CATCH para capturar cualquier error
-- Captura detalles específicos del error
-- Retorna -1 en caso de error
-- Relanza el error con información detallada


-- Mejor Control:

-- Verifica @@TRANCOUNT antes de hacer ROLLBACK
-- Usa RAISERROR para errores personalizados
/*
Realizar un  stored procedure que reciba como parámetro la descripción de un nuevo producto a ingresar en la tabla e informe su código
y descripción de familia sugerido de acuerdo a la siguiente lógica:
Se deben tomar las primeras 2 palabras del nuevo producto y buscar cada una de ellas si están contenidas en la descripción 
de los productos ya existentes, por cada registro que encuentre verificar la familia que posee, se debe sugerir la familia que mas 
ocurrencias tuvo, si no se encuentras coincidencias o existen 2 familias con las misma cantiad máxima de ocurrencias debe informar
que no suigere ninguna familia, todas las comparaciones no deben ser case sensitive.
Por ejemplo para el set de datos nativo de la base si se ingresara la descripción "Pilas A23" se debe sugerir la familia "Pilas"
*/

CREATE OR ALTER PROCEDURE SugerirFamilia
    @Descripcion NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- Tomar las primeras dos palabras de la descripción del nuevo producto
    DECLARE @Palabra1 NVARCHAR(50), @Palabra2 NVARCHAR(50);
    DECLARE @PosEspacio INT;

    -- Inicializar las palabras
    SET @Palabra1 = '';
    SET @Palabra2 = '';

    -- Extraer la primera palabra
    SET @PosEspacio = CHARINDEX(' ', @Descripcion);
    IF @PosEspacio > 0
    BEGIN
        SET @Palabra1 = SUBSTRING(@Descripcion, 1, @PosEspacio - 1);
        SET @Descripcion = LTRIM(SUBSTRING(@Descripcion, @PosEspacio + 1, LEN(@Descripcion) - @PosEspacio));
    END
    ELSE
    BEGIN
        SET @Palabra1 = @Descripcion;
        SET @Descripcion = '';
    END

    -- Extraer la segunda palabra
    SET @PosEspacio = CHARINDEX(' ', @Descripcion);
    IF @PosEspacio > 0
    BEGIN
        SET @Palabra2 = SUBSTRING(@Descripcion, 1, @PosEspacio - 1);
    END
    ELSE
    BEGIN
        SET @Palabra2 = @Descripcion;
    END

    -- Crear una tabla temporal para almacenar las familias encontradas
    CREATE TABLE #Familias (
        familia_id INT,
        ocurrencias INT
    );

    -- Buscar coincidencias de la primera palabra en las descripciones de productos existentes
    INSERT INTO #Familias (familia_id, ocurrencias)
    SELECT 
        p.prod_familia,
        COUNT(*) AS ocurrencias
    FROM 
        Producto p
    WHERE 
        LOWER(p.prod_detalle) LIKE '%' + LOWER(@Palabra1) + '%'
    GROUP BY 
        p.prod_familia;

    -- Buscar coincidencias de la segunda palabra en las descripciones de productos existentes
    INSERT INTO #Familias (familia_id, ocurrencias)
    SELECT 
        p.prod_familia,
        COUNT(*) AS ocurrencias
    FROM 
        Producto p
    WHERE 
        LOWER(p.prod_detalle) LIKE '%' + LOWER(@Palabra2) + '%'
    GROUP BY 
        p.prod_familia;

    -- Sumar las ocurrencias por familia
    SELECT 
        familia_id,
        SUM(ocurrencias) AS total_ocurrencias
    INTO 
        #FamiliasTotales
    FROM 
        #Familias
    GROUP BY 
        familia_id;

    -- Determinar la familia con más ocurrencias
    DECLARE @FamiliaSugerida NVARCHAR(50);
    DECLARE @MaxOcurrencias INT;
    DECLARE @FamiliaID INT;

    SELECT 
        TOP 1 @FamiliaID = familia_id, 
        @MaxOcurrencias = total_ocurrencias
    FROM 
        #FamiliasTotales
    ORDER BY 
        total_ocurrencias DESC;

    -- Verificar si hay más de una familia con la misma cantidad máxima de ocurrencias
    IF (SELECT COUNT(*) FROM #FamiliasTotales WHERE total_ocurrencias = @MaxOcurrencias) > 1
    BEGIN
        SET @FamiliaSugerida = 'No se sugiere ninguna familia';
    END
    ELSE
    BEGIN
        -- Obtener el detalle de la familia sugerida
        SELECT @FamiliaSugerida = fami_detalle
        FROM Familia
        WHERE fami_id = @FamiliaID;
    END

    -- Devolver el resultado
    SELECT 
        @FamiliaSugerida AS FamiliaSugerida;

    -- Limpiar las tablas temporales
    DROP TABLE #Familias;
    DROP TABLE #FamiliasTotales;
END;

SELECT * FROM Familia;
EXEC SugerirFamilia @Descripcion = 'Pilas A23';

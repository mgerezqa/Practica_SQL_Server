
USE GD2015C1


SELECT name AS TriggerName,
       object_id AS TriggerID,
       parent_class_desc AS TriggerType,
       create_date AS CreationDate,
       modify_date AS LastModifiedDate
FROM sys.triggers;
GO

-- BORRAR TRIGGER

-- DROP TRIGGER IF EXISTS <TRIGGER_NAME>;


DROP TRIGGER IF EXISTS TR_ACTUALIZAR_PRODUCTOS_VENDIDOS;

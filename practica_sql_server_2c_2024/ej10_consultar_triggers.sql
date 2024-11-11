SELECT name AS TriggerName,
       object_id AS TriggerID,
       parent_class_desc AS TriggerType,
       create_date AS CreationDate,
       modify_date AS LastModifiedDate
FROM sys.triggers;
GO

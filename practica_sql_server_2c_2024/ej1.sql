-- Práctica de SQL
-- Según el modelo dado resuelva:
-- 1. Mostrar el código, razón social de todos los clientes cuyo límite de crédito sea
-- mayor o igual a $ 1000 ordenado por código de cliente.

SELECT 
    clie_codigo,
    clie_razon_social
FROM dbo.Cliente
WHERE clie_limite_credito >= 1000
ORDER BY clie_codigo; 
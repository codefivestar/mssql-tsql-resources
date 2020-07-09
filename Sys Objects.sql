----------------------------------------------------------------------------------------------------------
-- Author          : Hidequel Puga
-- Email           : codefivestar@gmail.com
-- Date            : 2020-07-08
-- Description     : Contains a row for each user-defined, schema-scoped object that is created within a database, 
--                   including natively compiled scalar user-defined function.
-- Used For        : Audits
-- References      : https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-objects-transact-sql?view=sql-server-ver15
----------------------------------------------------------------------------------------------------------

USE [master]
GO

-- A. Returning all the objects that have been modified in the last N days
SELECT name AS object_name
	, SCHEMA_NAME(schema_id) AS schema_name
	, type_desc
	, create_date
	, modify_date
FROM sys.objects
WHERE modify_date > GETDATE() - 360
ORDER BY modify_date;
GO

-- B. Returning the parameters for a specified stored procedure or function
SELECT SCHEMA_NAME(schema_id) AS schema_name
	, o.name AS object_name
	, o.type_desc
	, p.parameter_id
	, p.name AS parameter_name
	, TYPE_NAME(p.user_type_id) AS parameter_type
	, p.max_length
	, p.precision
	, p.scale
	, p.is_output
FROM sys.objects AS o
INNER JOIN sys.parameters AS p
	ON o.object_id = p.object_id
WHERE o.object_id = OBJECT_ID('<schema_name.object_name>')
ORDER BY schema_name
	, object_name
	, p.parameter_id;
GO

-- C. Returning all the user-defined functions in a database
SELECT name AS function_name
	, SCHEMA_NAME(schema_id) AS schema_name
	, type_desc
	, create_date
	, modify_date
FROM sys.objects
WHERE type_desc LIKE '%FUNCTION%';
GO

-- D. Returning the owner of each object in a schema.
SELECT 'OBJECT' AS entity_type
	, USER_NAME(OBJECTPROPERTY(object_id, 'OwnerId')) AS owner_name
	, name
FROM sys.objects
WHERE SCHEMA_NAME(schema_id) = '<schema_name>'

UNION

SELECT 'TYPE' AS entity_type
	, USER_NAME(TYPEPROPERTY(SCHEMA_NAME(schema_id) + '.' + name, 'OwnerId')) AS owner_name
	, name
FROM sys.types
WHERE SCHEMA_NAME(schema_id) = '<schema_name>'

UNION

SELECT 'XML SCHEMA COLLECTION' AS entity_type
	, COALESCE(USER_NAME(xsc.principal_id), USER_NAME(s.principal_id)) AS owner_name
	, xsc.name
FROM sys.xml_schema_collections AS xsc
INNER JOIN sys.schemas AS s
	ON s.schema_id = xsc.schema_id
WHERE s.name = '<schema_name>';
GO


 
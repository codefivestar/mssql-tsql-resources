----------------------------------------------------------------------------------------------------------
-- Author          : Hidequel Puga
-- Email           : codefivestar@gmail.com
-- Date            : 2019-05-28 09:48 a.m.
-- Description     : Script to get values without insert.
-- Reference       : https://modern-sql.com/use-case/select-without-from
--                   https://modern-sql.com/feature/values
----------------------------------------------------------------------------------------------------------

SELECT *
  FROM (VALUES ('1', 'Value 1')
             , ('2', 'Value 2')
			       , ('3', 'Value 3')
			       , ('4', 'Value 4')
			       , ('5', 'Value 5')
			       , ('6', 'Value 6')
			       , ('7', 'Value 7')) Producto ([ID], [Desc]);
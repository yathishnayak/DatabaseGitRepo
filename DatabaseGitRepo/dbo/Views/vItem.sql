





CREATE VIEW [dbo].[vItem]
AS
SELECT			I.*, M.Description AS MasterDesc
FROM			Item I 
INNER JOIN		Item M ON I.MasterItemkey = M.ItemKey
WHERE			M.Statuskey = 1 -- AND M.Description LIKE '%Chassis Split%'  -- and I.ItemKey= I.MasterItemKey

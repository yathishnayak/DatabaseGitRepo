
CREATE PRocEDURE [dbo].[Admin_GetTabDetails]
AS
BEGIN
	SELECT 1 AS Tabkey, 'Driver App' AS TabName
	UNION ALL
	SELECT 2 AS Tabkey, 'TMS' AS TabName
	UNION ALL
	SELECT 3 AS Tabkey, 'Integration' AS TabName
	UNION ALL
	SELECT 4 AS Tabkey, 'Database' AS TabName
END

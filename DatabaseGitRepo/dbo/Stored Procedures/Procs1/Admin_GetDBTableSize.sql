CREATE PRocEDURE [dbo].[Admin_GetDBTableSize]
AS
SELECT		t.NAME AS TableName,
			p.rows AS RowCounts,
			CAST(SUM(a.total_pages) * 8.0 / 1024 AS DECIMAL(18, 2)) AS TotalSpaceMB,
			CAST(SUM(a.used_pages) * 8.0 / 1024 AS DECIMAL(18, 2)) AS UsedSpaceMB,
			CAST(SUM(a.data_pages) * 8.0 / 1024 AS DECIMAL(18, 2)) AS DataSpaceMB
INTO		#DBDate
FROM		sys.tables t
INNER JOIN  sys.indexes i ON t.object_id = i.object_id
INNER JOIN	sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN	sys.allocation_units a ON p.partition_id = a.container_id
WHERE		p.index_id IN (0, 1) -- Heap or Clustered Index
GROUP BY	t.NAME, p.rows
ORDER BY	TotalSpaceMB DESC;




DECLARE @JsonResult NVARCHAR(MAX) = ''
SET @JsonResult = (SELECT  CAST(SUM(total_pages) * 8.0 / (1024 * 1024) AS DECIMAL(18, 2)) AS TotalDBSpaceGB
,TableDetails =  (SELECT * FROM #DBDate ORDER BY	TotalSpaceMB DESC  FOR JSON PATH)
FROM  sys.allocation_units
FOR JSON PATH)

SELECT @JsonResult AS JsonResult

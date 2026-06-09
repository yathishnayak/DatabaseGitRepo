

CREATE VIEW    [dbo].[COST_VGetFileErrorFileCreateStatus] -- SELECT * FROM COST_VGetFileErrorFileCreateStatus
AS
SELECT			FileProcesskey
				, CASE WHEN FileProcessStatus = 0 AND ISNULL(IsfileDownloaded,0) = 0 AND DiffMinutes > 5 THEN 'Error in File Creation'  
				WHEN FileProcessStatus = 0 AND ISNULL(IsfileDownloaded,0) = 0 AND DiffMinutes Between 2 and 5 THEN 'Taking Long time to Create File' 
				WHEN FileProcessStatus = 0 AND ISNULL(IsfileDownloaded,0) = 0 AND DiffMinutes < 2 THEN 'Downloading....' 
				WHEN FileProcessStatus = 0 AND ISNULL(IsfileDownloaded,0) = 1 THEN 'Click to Download'
				ELSE '' END AS FIleLink , DiffMinutes, IsfileDownloaded
FROM			(SELECT			FileProcesskey, IsfileDownloaded, FileLink, DATEDIFF(minute, DateUploaded, GETDATE()) AS DiffMinutes ,FileProcessStatus, IsRecordUpdated
				FROM			COST_FileProcessInfo
				WHERE			ISNULL(IsRecordUpdated,0) = 0) A



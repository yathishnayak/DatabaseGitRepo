

CREATE PROCEDURE [dbo].[COST_UpdateFileDownloadStatus] -- COST_UpdateFileDownloadStatus  6,1
(
	@FileProcesskey			INT,
	@IsFileCreated			BIT
)

AS

BEGIN
	UPDATE	COST_FileProcessInfo 
	SET		IsFileDownloaded = @IsFileCreated
	WHERE	FileProcessKey = @FileProcesskey 	

	UPDATE				FP
	SET					FileLink = FE.FileLink, IsRecordUpdated =  CASE WHEN DiffMinutes > 5 OR @IsFileCreated = 1 THEN 1 ELSE 0 END
	FROm				COST_VGetFileErrorFileCreateStatus FE
	INNER JOIN			COST_FileProcessInfo FP ON FE.FileProcessKey = FP.FileProcessKey

END

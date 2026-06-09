

CREATE PROCEDURE [dbo].[COSTACC_UpdateFileDownloadStatus] -- COSTACC_UpdateFileDownloadStatus  6,1
(
	@FileProcesskey			INT,
	@IsFileCreated			BIT
)
AS
BEGIN
	UPDATE	COSTACC_FileProcessInfo 
	SET		IsFileDownloaded = @IsFileCreated
	WHERE	FileProcessKey = @FileProcesskey 	

	UPDATE				FP
	SET					FileLink = FE.FileLink, 
						IsRecordUpdated =  CASE WHEN DiffMinutes > 5 OR @IsFileCreated = 1 THEN 1 ELSE 0 END
	FROm				COSTACC_VGetFileErrorFileCreateStatus FE
	INNER JOIN			COSTACC_FileProcessInfo FP ON FE.FileProcessKey = FP.FileProcessKey

END



CREATE PROCEDURE [dbo].[SELL_NACAccUpdateFileDownloadStatus]
(
	@FileProcesskey			INT,
	@IsFileCreated			BIT
)
AS
BEGIN
	UPDATE	SELL_NAC_Accessorial_FileProcessInfo 
	SET		IsFileDownloaded = @IsFileCreated
	WHERE	FileProcessKey = @FileProcesskey 	

	UPDATE				FP
	SET					FileLink = Case when isnull(@IsFileCreated,0) = 0 then 'Error in File Creation' else 'Click to Download' end , 
						IsRecordUpdated =   @IsFileCreated 
	FROm				COSTACC_FileProcessInfo FP 
	Where				FileProcessKey = @FileProcesskey

END

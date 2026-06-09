
CREATE PROCEDURE [dbo].[SELL_NAC_Bobtail_UpdateFileDownloadStatus]
(
	@FileProcesskey			INT,
	@IsFileCreated			BIT
)
AS
BEGIN
	UPDATE	SELL_NAC_Bobtail_FileProcessInfo 
	SET		IsFileDownloaded = @IsFileCreated
	WHERE	FileProcessKey = @FileProcesskey 	

	UPDATE				FP
	SET					FileLink = Case when isnull(@IsFileCreated,0) = 0 then 'Error in File Creation' else 'Click to Download' end , 
						IsRecordUpdated =   @IsFileCreated 
	FROm				SELL_NAC_Bobtail_FileProcessInfo FP 
	Where				FileProcessKey = @FileProcesskey

END

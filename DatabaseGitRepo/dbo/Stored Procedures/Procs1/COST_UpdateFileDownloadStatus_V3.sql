CREATE PROCEDURE [dbo].[COST_UpdateFileDownloadStatus_V3] -- COST_UpdateFileDownloadStatus  6,1
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output,
	@IsDebug		bit = 0
)
AS
BEGIN
	DECLARE @FileProcesskey			INT,
			@IsFileCreated			BIT

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	Select @FileProcesskey = IsFileCreated, @IsFileCreated = IsFileCreated
	from OpenJSON(@JsonString, '$')
	WITH (
		FileProcesskey	int			'$.FileProcesskey',
		IsFileCreated	BIT			'$.IsFileCreated'	
	)

	UPDATE	COST_FileProcessInfo 
	SET		IsFileDownloaded = @IsFileCreated
	WHERE	FileProcessKey = @FileProcesskey 	

	UPDATE				FP
	SET					FileLink = FE.FileLink, IsRecordUpdated =  CASE WHEN DiffMinutes > 5 OR @IsFileCreated = 1 THEN 1 ELSE 0 END
	FROm				COST_VGetFileErrorFileCreateStatus FE
	INNER JOIN			COST_FileProcessInfo FP ON FE.FileProcessKey = FP.FileProcessKey

END

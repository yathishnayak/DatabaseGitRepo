/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING NVARCHAR(MAX) = ''
	EXEC [COSTACC_GetFileUploadStatus_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/

CREATE PROCEDURE [dbo].[COSTACC_GetFileUploadStatus_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	 -- SELECT * FROM COST_FileProcessInfo
	UPDATE		FP
	SET			FileLink = FE.FileLink, 
				IsRecordUpdated =  CASE WHEN DiffMinutes > 5 OR FE.IsfileDownloaded = 1 THEN 1 ELSE 0 END
	FROm		COSTACC_VGetFileErrorFileCreateStatus FE
	INNER JOIN	COSTACC_FileProcessInfo FP ON FE.FileProcessKey = FP.FileProcessKey

	SELECT		FileProcessKey,FileName,DateUploaded,FileUploadStatus,
				FileProcessStatus,IsEmailSent, ISNULL(Isfiledownloaded,0)Isfiledownloaded , 
				U.UserName AS UserName
				, ISNULL(FileLink,'')FileLink, '' AS FileURL
	FROM		COSTACC_FileProcessInfo F
	LEft join	[User] U on F.UserKey = U.UserKey
	ORDER BY	FileProcessKey DESC
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
END
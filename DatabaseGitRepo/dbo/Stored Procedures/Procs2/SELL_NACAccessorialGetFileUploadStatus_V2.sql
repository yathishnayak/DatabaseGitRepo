/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = ''
	EXEC [SELL_NACAccessorialGetFileUploadStatus_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason 
**/
CREATE PROCEDURE [dbo].[SELL_NACAccessorialGetFileUploadStatus_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
	
	 -- SELECT * FROM SELL_NAC_Accessorial_FileProcessInfo

	SELECT		FileProcessKey,FileName,DateUploaded,CustName,FileUploadStatus,FileProcessStatus,IsEmailSent, ISNULL(Isfiledownloaded,0)Isfiledownloaded, 
				U.UserName AS UserName, ISNULL(FileLink,'')FileLink, '' AS FileURL
	FROM		SELL_NAC_Accessorial_FileProcessInfo F WITH (NOLOCK)
	LEft join	[User] U WITH (NOLOCK) on F.UserKey = U.UserKey
	LEFT JOIN	Customer C WITH (NOLOCK) ON (C.CustKey=F.CustKey)
	ORDER BY	FileProcessKey DESC
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'

END
/**
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX) = '{"DocumentKey" : "36678", "DriverKey" : 1681}',
	@Status BIT = 0,
	@IsDebug BIT = 1,
	@Reason VARCHAR(1000) = ''
EXEC [Insert_DriverDocument_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Insert_DriverDocument_V3]
/*
dbo.fn_insert_orderheader_document
Insert Multiple Order Detail Documents 
*/
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE
		@DocumentKey	VARCHAR(100),
		@DriverKey		INT

	SELECT
		@DocumentKey			=		DocumentKey,
		@DriverKey				=		DriverKey	
	FROM OPENJSON(@JSONString)
	WITH
	(
		DocumentKey		VARCHAR(100)		'$.DocumentKey',
		DriverKey		INT					'$.DriverKey'
	)



	SELECT OriginalFileName,DocumentKey INTO #NewFiles
	FROM dbo.Document 
	WHERE DocumentKey IN (
								SELECT [Value] 
								FROM [Fn_SplitParam] ( @DocumentKey)
						 );


	SELECT  OriginalFileName INTO #ExistingFile
	FROM DriverDocuments ODD WITH(NOLOCK)
		INNER JOIN dbo.Document D WITH(NOLOCK) ON D.DocumentKey=ODD.DocumentKey 
	WHERE D.IsDeleted=0 AND ODD.DriverKey=@DriverKey;

	
	INSERT INTO dbo.DriverDocuments(DriverKey, Documentkey)
	SELECT @DriverKey,DocumentKey
	FROM #NewFiles
	WHERE OriginalFileName NOT IN ( SELECT OriginalFileName FROM #ExistingFile );

	DECLARE @UserName NVARCHAR(MAX)='',@DriverName VARCHAR(20)='', @DriverId VARCHAR(30)
	SELECT @UserName=ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey=(SELECT CreateUserKey FROM Document WITH(NOLOCK) WHERE DocumentKey=@DocumentKey)
	SELECT @DriverId=ISNULL(DriverID, '') FROM Driver WITH(NOLOCK) WHERE DriverKey = @DriverKey
	
	INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
	SELECT GETDATE(),@UserName,'Driver',@DriverId,@DriverKey,null,'Text','Driver Document uploaded by ' +@UserName

	SET @Status = 1
	SET @Reason = 'Driver Document Inserted Successfully'
END

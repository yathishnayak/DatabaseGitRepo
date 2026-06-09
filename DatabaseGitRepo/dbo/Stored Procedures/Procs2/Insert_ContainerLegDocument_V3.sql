/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"RouteKey" : 177973, "DocumentKey" : "596696"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Insert_ContainerLegDocument_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Insert_ContainerLegDocument_V3]
(
	@UserKey		INT = 0,
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
		@RouteKey		INT,
		@DocumentKey	VARCHAR(100)

	SELECT 
		@RouteKey			=	RouteKey	,
		@DocumentKey		=	DocumentKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		RouteKey			INT					'$.RouteKey',
		DocumentKey		VARCHAR(100)		'$.DocumentKey'
	)

	SELECT OriginalFileName,DocumentKey INTO #NewFiles
	FROM dbo.Document WITH (NOLOCK) 
	WHERE DocumentKey IN (
								SELECT [Value] 
								FROM [Fn_SplitParam] ( @DocumentKey)
						 );


	SELECT  OriginalFileName INTO #ExistingFile
	FROM ContainerLegDocuments CLD WITH (NOLOCK) 
		INNER JOIN dbo.Document D WITH (NOLOCK)  ON D.DocumentKey=CLD.DocumentKey 
	WHERE D.IsDeleted=0 AND CLD.RouteKey=@RouteKey;

	
	INSERT INTO dbo.ContainerLegDocuments(RouteKey, Documentkey)
	SELECT @RouteKey,DocumentKey
	FROM #NewFiles
	WHERE OriginalFileName NOT IN ( SELECT OriginalFileName FROM #ExistingFile );

	DECLARE @UserName NVARCHAR(MAX)='',@ContainerNo VARCHAR(20)='', @LegID VARCHAR(100), @OrderDetailKey INT

	SELECT @ContainerNo = OD.ContainerNo, @LegID = L.LegID, @OrderDetailKey = OD.OrderDetailKey
	FROM OrderDetail OD WITH(NOLOCK)
	INNER JOIN Routes RT WITH(NOLOCK) ON OD.OrderDetailKey = RT.OrderDetailKey
	LEFT JOIN Leg L WITH(NOLOCK) ON RT.LegKey = L.LegKey
	WHERE RT.RouteKey = @Routekey
	SELECT @UserName=ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey=(SELECT CreateUserKey FROM Document WITH(NOLOCK) WHERE DocumentKey=@DocumentKey)
	
	INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
	SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Document uploaded for Leg ' + @LegID + ' by ' +@UserName

	SET @Status = 1
	SET @Reason = 'Success'

END

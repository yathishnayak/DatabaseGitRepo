/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"OrderDetailKey" : 47697, "LastFreeDay" : "2026-01-05"}'
	EXEC [Update_OrderDetail_LastFreeDay_V2] @Userkey, @JSONSTRING, @IsDebug, @Status OUTPUT, @Reason Output
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Update_OrderDetail_LastFreeDay_V2]
/*
Update detail data from Container Screen
*/
(
	@UserKey		INT = 1144,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE 
		@OrderDetailKey		INT,
		@LastFreeDay		Date

	SELECT 
		@OrderDetailKey	= OrderDetailKey,	
		@LastFreeDay		= LastFreeDay	
	FROM OPENJSON(@JSONString)
	WITH
	(
		OrderDetailKey	INT			'$.OrderDetailKey',	
		LastFreeDay		DATE		'$.LastFreeDay'	
	)

	SET @Status=0;
	DECLARE @UserName				NVARCHAR(100)='',
			@ContainerNo			NVARCHAR(20)

	SELECT  @UserName=ISNULL(UserName,'') FROM [User] WITH (NOLOCK) WHERE UserKey=@UserKey			
	SELECT TOP 1 @ContainerNo = ContainerNo FROM OrderDetail WITH (NOLOCK) WHERE OrderDetailKey=@OrderDetailKey

	UPDATE OrderDetail 
	SET LastFreeDay= @LastFreeDay, LastUpdateDate = GETDATE(), UpdateUserKey = @UserKey  
	WHERE OrderDetailKey= @OrderDetailKey 

	UPDATE Container_GnosisData 
	SET LFD= @LastFreeDay, LFDChangedByUser=CASE WHEN ISNULL(@LastFreeDay,'')<>ISNULL(LFD,'') THEN 1 ELSE LFDChangedByUser END
	WHERE OrderDetailKey= @OrderDetailKey

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,
			 null,'Text','LastFreeDay is updated by '+@UserName

	SET @Status=1
	SET @Reason = 'Success'
END
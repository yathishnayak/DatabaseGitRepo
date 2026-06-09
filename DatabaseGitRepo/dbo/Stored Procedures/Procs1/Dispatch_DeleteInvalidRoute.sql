/*
DECLARE @UserKey  INT=953,  
	@JsonString  VARCHAR(MAX)='{"OrderDetailKey":131095,"RouteKey":459504}',  
	@IsDebug  BIT = 1,  
	@Status   BIT = 0 ,  
	@Reason   NVARCHAR(1000) = '' 

EXEC [Dispatch_DeleteInvalidRoute] @UserKey,@JsonString,@IsDebug,@Status output,@Reason output
SELECT @Status AS Status, @Reason AS Reason 
	*/

CREATE PROCEDURE [dbo].[Dispatch_DeleteInvalidRoute]
(
	@UserKey  INT=512,  
	@JsonString  VARCHAR(MAX)='',  
	@IsDebug  BIT = 1,  
	@Status   BIT = 0 OUTPUT,  
	@Reason   NVARCHAR(1000) = '' OUTPUT  
)
as
begin
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;

	IF(ISNULL(@JsonString,'')='')  
	BEGIN  
		SET @Status=0;  
		SET @Reason= 'Parameter not found';  
		RETURN;  
	END  

	DECLARE @OrderDetailKey			INT = 0,
			@RouteKey				INT = 0,
			@FromLocation			NVARCHAR(100)='',
			@ToLocation				NVARCHAR(100)='',
			@MappingRouteKey		INT=0,
			@MappingFromLocation	NVARCHAR(100)='',
			@MappingToLocation		NVARCHAR(100)='',
			@UserName				VARCHAR(100),
			@Comment				VARCHAR(500)='', 
			@ContainerNo			NVARCHAR(20)=''

	SELECT  @OrderDetailKey=OrderDetailKey ,
			@RouteKey=RouteKey
	FROM OPENJSON(@JsonString, '$')  
	WITH(   
		OrderDetailKey	INT  '$.OrderDetailKey'  ,
		RouteKey		INT  '$.RouteKey'
		)

	IF(SELECT COUNT(1) FROM Routes RT WHERE RouteKey=@RouteKey)=0
	BEGIN
		SET @Reason='Route does not exist';
		SET @Status=0;
	END

	ELSE IF(SELECT COUNT(*) FROM OrderExpense WHERE RouteKey=@RouteKey)>0
	BEGIN
		SELECT @UserName = ISNULL(UserName,'') FROM [User] WITH(NOLOCK) WHERE UserKey = @UserKey
		SELECT @ContainerNo = ISNULL(ContainerNo,'') FROM OrderDetail WITH(NOLOCK) WHERE OrderDetailKey = @OrderDetailKey

		SELECT @FromLocation=L.FromLocation,@ToLocation=L.ToLocation
		FROM Leg L WITH (NOLOCK) 
		INNER JOIN Routes RT WITH (NOLOCK) ON RT.LegKey=L.LegKey AND RouteKey=@RouteKey

		SELECT TOP 1 @MappingRouteKey=RouteKey
		FROM Leg L WITH (NOLOCK) 
		INNER JOIN Routes RT WITH (NOLOCK) ON RT.LegKey=L.LegKey AND RouteKey<>@RouteKey 
						AND L.FromLocation=@FromLocation AND L.ToLocation=@ToLocation AND OrderDetailKey=@OrderDetailKey ORDER BY RouteKey DESC


		IF ISNULL(@MappingRouteKey,0)=0
			BEGIN
				SET @Status=0
				SET @Reason='No mapping route found. Cannot delete route with expenses.'
				RETURN
			END

		UPDATE OrderExpense SET RouteKey=@MappingRouteKey WHERE RouteKEy=@RouteKey

		SET @Comment= 'Leg ' + ISNULL(@FromLocation,'') + ' To ' + ISNULL(@ToLocation,'') + ' Deleted'
		INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		Select GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, 'Leg', 'Text' , @Comment

		IF EXISTS (SELECT 1 FROM RouteVouchers WHERE RouteKey=@RouteKey)
		BEGIN
			SET @Status=0
			SET @Reason='Route is used in vouchers. Cannot delete.'
			RETURN
		END

		DELETE FROM Routes WHERE RouteKey = @RouteKey
		SET @Reason='Success';
		SET @Status=1;
	END
	ELSE IF(SELECT COUNT(*) FROM OrderExpense WHERE RouteKey=@RouteKey)=0
	BEGIN
		SELECT @UserName = ISNULL(UserName,'') FROM [User] WITH(NOLOCK) WHERE UserKey = @UserKey
		SELECT @ContainerNo = ISNULL(ContainerNo,'') FROM OrderDetail WITH(NOLOCK) WHERE OrderDetailKey = @OrderDetailKey

		SELECT @FromLocation=L.FromLocation,@ToLocation=L.ToLocation
		FROM Leg L WITH (NOLOCK) 
		INNER JOIN Routes RT WITH (NOLOCK) ON RT.LegKey=L.LegKey AND RouteKey=@RouteKey

		--SELECT TOP 1 @MappingRouteKey=RouteKey
		--FROM Leg L WITH (NOLOCK) 
		--INNER JOIN Routes RT WITH (NOLOCK) ON RT.LegKey=L.LegKey AND RouteKey<>@RouteKey 
		--				AND L.FromLocation=@FromLocation AND L.ToLocation=@ToLocation AND OrderDetailKey=@OrderDetailKey ORDER BY RouteKey DESC

		--UPDATE OrderExpense SET RouteKey=@MappingRouteKey WHERE RouteKEy=@RouteKey

		SET @Comment= 'Leg ' + ISNULL(@FromLocation,'') + ' To ' + ISNULL(@ToLocation,'') + ' Deleted'
		INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		Select GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, 'Leg', 'Text' , @Comment

		IF EXISTS (SELECT 1 FROM RouteVouchers WHERE RouteKey=@RouteKey)
		BEGIN
			SET @Status=0
			SET @Reason='Route is used in vouchers. Cannot delete.'
			RETURN
		END

		DELETE FROM Routes WHERE RouteKey = @RouteKey
		SET @Reason='Success';
		SET @Status=1;
	END
	ELSE
	BEGIN
		SET @Reason='Failed To Delete';
		SET @Status=0;
	END	
END
CREATE PROCEDURE [dbo].[Scheduler_DeleteOrderDetailStops]  
(  
 @UserKey  INT=512,  
 @JsonString  VARCHAR(MAX)='',  
 @IsDebug  BIT = 1,  
 @Status   BIT = 0 OUTPUT,  
 @Reason   NVARCHAR(1000) = '' OUTPUT  
)  
AS  
BEGIN  
 SET NOCOUNT ON;  
 SET FMTONLY OFF;  
 SET ARITHABORT ON;  
  
	IF(ISNULL(@JsonString,'')='')  
	BEGIN  
	 SET @Status=0;  
	 SET @Reason='Parameter not found';  
	 RETURN;  
	END  
	 
	DECLARE @OrderDetailStopKey INT=0;  
	DECLARE @OrderDetailKey INT=0,
			@LocationType NVARCHAR(100),
			@StopTypeShortcode NVARCHAR(10),
			@Comments NVARCHAR(1000),
			@Containerno NVARCHAR(20),
			@UserName NVARCHAR(200)
	  
	SELECT  @OrderDetailStopKey=OrderDetailStopKey  ,
			@OrderDetailKey=OrderDetailKey,
			@LocationType=LocationType,
			@StopTypeShortcode=StopTypeShortcode
	FROM OPENJSON(@JsonString, '$')  
	WITH(   
	  OrderDetailStopKey	INT				'$.OrderDetailStopKey' ,
	  OrderDetailKey		INT				'$.OrderDetailKey',
	  LocationType			NVARCHAR(100)	'$.LocationType',
	  StopTypeShortcode	NVARCHAR(10)	'$.StopTypeShortcode'
	 )  
	--SET @OrderDetailKey = (SELECT TOP 1 ISNULL(OrderDetailKey,0) FROM OrderDetailStops WHERE OrderDetailStopKey=@OrderDetailStopKey)  
	
	SELECT @UserName=UserName FROm [User] WHERE UserKey=@UserKey
	SELECT @Containerno=ContainerNo FROm OrderDetail WHERE OrderDetailKey=@OrderDetailKey
	SET @Comments=CASE WHEN @OrderDetailStopKey=0 THEN 'Order detail stop added and deleted instantly, location type: '+@LocationType +', stop type code: '+@StopTypeShortcode+ ' by '+@UserName
	ELSE 'Order detail stop deleted, '+ ISNULL((SELECT * FROm OrderDetailStops WHERE OrderDetailStopKey=@OrderDetailStopKey FOR JSON PATH),'') + ' by '+@UserName END
	INSERT INTO AuditLogDetail
	(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
	values(GETDATE(),@UserName,'Container',@Containerno,@OrderDetailKey,'','Text',@Comments)

	DELETE FROM OrderDetailStops WHERE OrderDetailStopKey=@OrderDetailStopKey;  
	  
	EXEC RoutesAndStopsLinking @OrderDetailKey,1,0  
	EXEC Scheduler_RecreateLegID @OrderDetailKey  
	SET @Status = 1;  
	SET @Reason = 'Success';  
END  
  
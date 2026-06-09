/** 
Declare 
	@UserKey		INT=953,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"RouteKey":727577, "ActualArrival":"2026-02-05 14:52", "UpdateType":"JCB User"}'
	EXEC [Update_DispatchActionData_ActualArrival_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
    SELECT @Status, @Reason
**/
  
CREATE PROCEDURE [dbo].[Update_DispatchActionData_ActualArrival_V2] -- [Update_DispatchActionData_ActualArrival] 727577, '2021-04-28', 2  
-- [Update_DispatchActionData_ActualArrival] 727577, '2026-01-13', 953, 'JCB User'
/*Dispatch Screen*/  
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
 
 IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
		
 IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END	

 DECLARE
     @RouteKey  INT,  
     @ActualArrival DATETIME,  
     @UpdateType  VARCHAR(10)=''  
    --@OutPut   BIT OUTPUT,  
    --@IsReadyToComplete BIT OUTPUT  

SELECT 
    @RouteKey           = RouteKey,  
    @ActualArrival      = ActualArrival,   
    @UpdateType         = UpdateType
FROM OPENJSON(@JSONString)
WITH
(
    RouteKey        INT         '$.RouteKey',
    ActualArrival   DATETIME    '$.ActualArrival',
    UpdateType      VARCHAR(10) '$.UpdateType'
)
  
 DECLARE @OrderDetailKey  INT  
 DECLARE @DriverAsgStatusKey SMALLINT  
 DECLARE @IsReadyToComplete BIT  
 DECLARE @StatusKey SMALLINT  
 DECLARE @StatusDesc VARCHAR(200)  
 DECLARE @LegNo SMALLINT  
 DECLARE @NexLeg SMALLINT  
 DECLARE @CurrLeg VARCHAR(50) 
 DECLARE @USerName varchar(100),@Comment varchar(500),@ContainerNo NVARCHAR(20)='',@LegId NVARCHAR(100)=''
  
 CREATE TABLE #CurrLeg  
 (  
  OrderDetailKey INT,  
  CurrOPenRoutekey INT,  
 )  
  
 CREATE TABLE #AllOrdComplLeg  
 (  
  OrderDetailKey INT,  
  LastRoutekey   INT,  
 )  
  
 --SET @OutPut=0;  
 SET @OrderDetailKey= (  
       SELECT DISTINCT OrderDetailKey   
       FROM dbo.[Routes] WITH (NOLOCK) WHERE RouteKey= @RouteKey  
       )  
 SET @DriverAsgStatusKey= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='DriverAssigned')  
  
 UPDATE dbo.[Routes]  
 SET     
  ActualArrival = @ActualArrival,  
  UpdateUserKey = @UserKey,  
  LastUpdateDate = GETDATE(),  
  ActualArrivalUpdateMethod=@UpdateType  
 WHERE RouteKey= @RouteKey;  
  
  update ODS SET   
  ActualDeliveryDate = @ActualArrival,  
  ActualDeliveryUserKey = @UserKey,  
  ActualDeliverySetDateTime = GetDate()  
 from ORderDetailStops ODS  
 where ToRouteKey = @RouteKey  

 SELECT @USerName = ISNULL(UserName,'') FROM [User] WITH (NOLOCK) WHERE UserKey = @UserKey
 SELECT @ContainerNo = ISNULL(ContainerNo,'') FROM OrderDetail WITH (NOLOCK) WHERE OrderDetailKey=@OrderDetailKey
 SELECT @LegId=ISNULL(L.LegId,'') FROM Leg L WITH (NOLOCK)
 INNER JOIN Routes RT WITH (NOLOCK) ON RT.LegKey=L.LegKey
 WHERE RouteKey=@RouteKey
 
 SET @Comment = 'Actual Arrival added for leg '+@LegId + ', changed by '+@USerName
 INSERT INTO  AuditLogDetail(DateCreated,CreateUser,RefType,RefId,Stage,CommentType,Comments,RefKey)
 VALUES(GETDATE(),@USerName,'Container',@ContainerNo,null,'Text',@Comment,@OrderDetailKey)
 /*  
 declare @cnt smallint,  
  @driverKey int  
 select @cnt= count(1) , @driverKey = R.DriverKey  
 from Routes R   
 inner join DriverRoute DR on DR.RouteKey = R.RouteKey and Dr.driverKey = R.DriverKey  
 where R.RouteKey = @RouteKey   
 group by R.DriverKey  
   
 if(@cnt > 0 )  
 begin  
  update DriverRoute set DriverCompleteDate = @ActualArrival  
  where RouteKey = @RouteKey and DriverKey = @driverKey  
 end  
 else  
 Begin  
  insert into DriverRoute (RouteKey, DriverKey, DriverStartDate, DriverCompleteDate)  
  select RouteKey, DriverKey, ActualDeparture, @ActualArrival from routes where RouteKey = @RouteKey  
 End  
 */  
  
 --********************Container Status Update******************************  
 IF ( SELECT COUNT(1)   
   FROM dbo.[Routes] RT  WITH (NOLOCK)  
    INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.[Status]=RT.[Status]   
   WHERE RT.OrderDetailKey= @OrderDetailKey AND RTS.[Description]<>'Leg Completed'  
    AND (  
      ISNULL(RT.driverKey ,0) > 0 OR ISNULL(RT.ChassisNo,'') <> ''  OR   
      ISNULL(RT.ActualDeparture,'1970-01-01 00:00:00.000') <>  '1970-01-01 00:00:00.000' OR  
      ISNULL(RT.ActualArrival,'1970-01-01 00:00:00.000') <> '1970-01-01 00:00:00.000'  
     )  
    )>0  
 BEGIN  
  UPDATE dbo.OrderDetail  
  SET [Status]= ( SELECT [Status] FROM dbo.OrderDetailStatus WITH (NOLOCK) WHERE [Description]='Dispatch InProgress' AND IsActive=1 ),  
   StatusDate=GETDATE()  
  WHERE OrderDetailKey= @OrderDetailKey;  
 END;  
 --**************************Container Leg Status****************************  
 IF  (   
   SELECT COUNT(1)   
   FROM dbo.[Routes] RT  WITH (NOLOCK)
    INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.[Status]=RT.[Status]  
   WHERE RouteKey= @RouteKey AND RTS.[Description]<>'Leg Completed' AND RT.DriverKey IS NULL   
      AND RT.ActualDeparture IS NULL AND RT.ActualArrival IS NULL  
  )>0  
 BEGIN  
  UPDATE dbo.[Routes]  
  SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='Open' AND IsActive=1 )  
  WHERE RouteKey= @RouteKey AND [Status]<>@DriverAsgStatusKey;  
 END;  
 IF  (   
   SELECT COUNT(1)   
   FROM dbo.[Routes] RT  WITH (NOLOCK)
    INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.[Status]=RT.[Status]  
   WHERE RouteKey= @RouteKey AND RTS.[Description]<>'Leg Completed' AND RT.DriverKey IS NOT NULL   
      AND RT.ActualDeparture IS NULL AND RT.ActualArrival IS NULL  
  )>0  
 BEGIN  
  UPDATE dbo.[Routes]  
  SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='DriverAssigned' AND IsActive=1 )  
  WHERE RouteKey= @RouteKey AND [Status]<>@DriverAsgStatusKey;  
 END;  
 IF  (   
   SELECT COUNT(1)   
   FROM dbo.[Routes] RT WITH (NOLOCK)  
    INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.[Status]=RT.[Status]  
   WHERE RouteKey= @RouteKey AND RTS.Description<>'Leg Completed' AND RT.DriverKey IS NOT NULL   
    AND RT.ActualDeparture IS NOT NULL AND RT.ActualArrival IS NULL  
  )>0  
 BEGIN  
  UPDATE dbo.[Routes]  
  SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='Delivery Pending' AND IsActive=1 )  
  WHERE RouteKey= @RouteKey  
 END;  
 IF  (   
   SELECT COUNT(1)   
   FROM dbo.[Routes] RT WITH (NOLOCK)  
    INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.[Status]=RT.[Status]  
   WHERE RouteKey= @RouteKey AND RTS.[Description]<>'Leg Completed' AND RT.DriverKey IS NOT NULL   
    AND RT.ActualDeparture IS NOT NULL AND RT.ActualArrival IS NOT NULL  
  )>0  
 BEGIN  
  UPDATE dbo.[Routes]  
  SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='Ready To Complete' AND IsActive=1 )  
  WHERE RouteKey= @RouteKey  
 END;  


 IF (
 SELECT COUNT(1) FROM  dbo.[Routes]  WHERE RouteKey=@RouteKey and (ToLocation LIKE 'Shipper%' OR ToLocation LIKE 'Consignee%' OR ToLocation LIKE 'Customer%')
 )>0
 BEGIN 
   Update OrderDetail 
   SET [Status] = 17  WHERE OrderDetailKey=@OrderDetailKey
 END 


 --*********************************************************************  
 SELECT ROW_NUMBER() OVER ( PARTITION BY A.Orderdetailkey ORDER BY Routekey) AS LegNo,A.OrderDetailKey,  
     W.RouteKey INTO #RouteLegNo  
 FROM (SELECT OrderDetailKey FROM dbo.[Routes] WITH (NOLOCK) WHERE RouteKey= @RouteKey ) A   
  INNER JOIN dbo.Routes W WITH (NOLOCK) ON W.OrderDetailKey=A.OrderDetailKey    
  
 SET @StatusKey=( SELECT [Status] FROM [Routes] WITH (NOLOCK) WHERE RouteKey=@RouteKey)  
 SET @StatusDesc=( SELECT [Description] FROM RouteStatus WITH (NOLOCK) WHERE [Status]=@StatusKey)  
 SET @LegNo= ( SELECT LegNo FROM #RouteLegNo WHERE RouteKey=@RouteKey )  
  
 --*************************************************************************  
 SELECT A.OrderDetailKey,COUNT(RT.RouteKey) AS LegCount INTO #LegCount  
 FROM (SELECT OrderDetailKey FROM dbo.[Routes] WITH (NOLOCK) WHERE RouteKey= @RouteKey) A   
   LEFT JOIN dbo.Routes RT WITH (NOLOCK) ON RT.OrderDetailKey=A.OrderDetailKey  
 GROUP BY A.OrderDetailKey  
  
 INSERT INTO #CurrLeg (OrderDetailKey,CurrOPenRoutekey)  
 SELECT A.OrderDetailKey,ISNULL(MIN(RT.RouteKey),0) AS CurrOPenRoutekey  
 FROM (SELECT OrderDetailKey FROM dbo.[Routes] WITH (NOLOCK) WHERE RouteKey= @RouteKey) A   
  INNER JOIN dbo.Routes RT WITH (NOLOCK)  ON RT.OrderDetailKey=A.OrderDetailKey  
  INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.[Status]=RT.[Status]  
 WHERE RTS.[Description]<>'Leg Completed'  
 GROUP BY A.OrderDetailKey  
  
 SELECT A.OrderDetailKey INTO #AllOrdCompLeg   
 FROM (SELECT OrderDetailKey FROM dbo.[Routes] WITH (NOLOCK) WHERE RouteKey= @RouteKey) A  
 WHERE A.OrderDetailKey NOT IN ( SELECT OrderDetailKey FROM #CurrLeg)  
  
 INSERT INTO #AllOrdComplLeg (OrderDetailKey,LastRoutekey)  
 SELECT OrderDetailKey,CurrOPenRoutekey   
 FROM #CurrLeg  
  
 INSERT INTO #CurrLeg (OrderDetailKey,CurrOPenRoutekey)  
 SELECT A.OrderDetailKey,ISNULL(MAX(RT.RouteKey),0) AS CurrOPenRoutekey  
 FROM #AllOrdCompLeg A   
  INNER JOIN dbo.Routes RT WITH (NOLOCK) ON RT.OrderDetailKey=A.OrderDetailKey    
 GROUP BY A.OrderDetailKey  
  
 SELECT @NexLeg=CASE WHEN C.LastRoutekey IS NULL THEN 0 ELSE ISNULL(R.LegNo,0) END   
  ,  @CurrLeg =CAST(ISNULL(@LegNo,0) AS VARCHAR(50))+' of '+CAST(L.LegCount AS VARCHAR(50))  
 FROM #RouteLegNo R   
  INNER JOIN #CurrLeg Q ON Q.OrderDetailKey=R.OrderDetailKey  
  INNER JOIN #LegCount L ON L.OrderDetailKey=Q.OrderDetailKey  
  LEFT JOIN #AllOrdComplLeg C ON C.OrderDetailKey=R.OrderDetailKey  
    
 --*************************************************************************  
  SET @IsReadyToComplete = ( SELECT dbo.FN_IsRouteComplete(@RouteKey));  
    
  SELECT  @IsReadyToComplete AS ReadyToComplete,@StatusKey AS [StatusKey],  
    @StatusDesc AS StatusDesc , @LegNo AS LegNo,@NexLeg AS NextLeg,@CurrLeg AS CurLeg FOR JSON PATH;   

   SET @Status = 1
   SET @Reason = 'Success'
END  
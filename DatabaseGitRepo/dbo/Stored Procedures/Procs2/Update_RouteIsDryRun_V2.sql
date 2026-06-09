/*
DECLARE 
	@UserKey INT=1144,
	@JSONString NVARCHAR(MAX)= '{"RouteKey":178264,"IsDryRun" : 0, "DryRunType" : 0}',
	@Status	BIT=0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Update_RouteIsDryRun_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Update_RouteIsDryRun_V2]  -- declare @Status bit exec Update_RouteIsDryRun 178484,0,0,488,@Status output select @Status    
(
	@UserKey		INT = 1144,
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
    @RouteKey INT,    
    @IsDryRun BIT,    
    @DryRunType INT

    SELECT 
	    @RouteKey		=		RouteKey,
	    @IsDryRun	    =		IsDryRun,
        @DryRunType     =       DryRunType
    -- @UpdateUserKey		=		UpdateUserKey
    FROM OPENJSON(@JSONString)
    WITH
    (
	    RouteKey			INT				'$.RouteKey',
	    IsDryRun			BIT		        '$.IsDryRun',
        DryRunType          INT             '$.DryRunType'
    )
     
 DECLARE @USerName varchar(100),    
   @CommentKey int,    
   @Comment varchar(500)='',    
   @OrderDetailKey INT    
    
   select @USerName = ISNULL(UserName,'') from [User]  WITH(NOLOCK) where UserKey = @UserKey    
    
 SET @Status=0;    
 SET @OrderDetailKey =(SELECT TOP 1 OrderDetailKey FROM [Routes]  WITH(NOLOCK) WHERE RouteKey=@RouteKey)    
    
    
 --if(isnull(@IsDryRun,0) = 0)    
 --begin    
 -- set @Status = 0    
 -- return    
 --end    
    
    
    
 if(isnull(@IsDryRun ,0) =1)    
 Begin      
    
  update routes set    
    IsDryRun = 1,     
    DryRunSetUser = @UserKey,     
    DryRunSetDate = GETDATE(),    
    LastUpdateDate=GETDATE(),    
    UpdateUserKey=@UserKey,    
    DryRunType= @DryRunType    
  where RouteKey = @routeKey    
     
  set @Comment = 'Container Leg Marked DryRun by ' + @USerName + ' on ' + convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108);    
     
   Declare @OrderDetailStopKey int = 0,    
    @StopTypeKey  int = 0,    
    @FromLocationType varchar(20) = '',    
    @ToLocationType  varchar(20) = ''    
    
  select @FromLocationType =  L.FromLocation, @ToLocationType = L.ToLocation    
  from Routes RT WITH(NOLOCK)    
  inner join Leg L WITH(NOLOCK) on RT.LegKey = L.LegKey    
  where Routekey = @RouteKey    
    
  if(@DryRunType = 1 and @FromLocationType = 'PORT')    
  Begin    
   select @OrderDetailStopKey = OrderDetailStopKey    
   from OrderDetailStops ODS WITH(NOLOCK)    
   where FromRouteKey = @RouteKey    
  End    
  ELSE IF (@DryRunType = 1 and @ToLocationType = 'PORT')    
  BEGIN    
   select @OrderDetailStopKey = OrderDetailStopKey    
   from OrderDetailStops ODS WITH(NOLOCK)    
   where ToRouteKey = @RouteKey    
  END    
  ELSE IF (@DryRunType = 2 and @ToLocationType in ('Consignee','Customer','Shipper'))    
  BEGIN    
   select @OrderDetailStopKey = OrderDetailStopKey    
   from OrderDetailStops ODS WITH(NOLOCK)    
   where ToRouteKey = @RouteKey    
  END    
  ELSE IF (@DryRunType = 2 and @FromLocationType in ('Consignee','Customer','Shipper'))    
  BEGIN    
   select @OrderDetailStopKey = OrderDetailStopKey    
   from OrderDetailStops ODS WITH(NOLOCK)    
   where FromRouteKey = @RouteKey    
  END    
    
  if(@IsDebug = 1)    
  Begin    
   SELECT @OrderDetailStopKey as OrderDetailStopKey,     
     @FromLocationType as FromLocationType,    
     @ToLocationType as ToLocationType    
  End    
  if(isnull(@OrderDetailStopKey,0) > 0)    
  Begin    
   -- Declare @JsonString varchar(max) = ''    
   select @JsonString = ( select OrderDetailStopKey, OrderStopKey, ODs.StopTypeKey, StopTypeName, OrderDetailKey,    
    StopAddrKey, StopTypeShortcode, StopName, StopNumber, LocationType,    
    SchedulePickupDate,ScheduleDeliveryDate, ActualPickupDate,ActualDeliveryDate,DropOrLive,    
    SchedulePickupDateto as SchedulePickupToDate,ScheduleDeliveryDateto as ScheduleDeliverToDate,    
    left(convert(time,SchedulePickupDate),5) as SchedulePickupFromTime,     
    left(convert(time,SchedulePickupDateTo),5) as SchedulePickupToTime,     
    left(convert(time,ScheduleDeliveryDate),5) as ScheduleDeliveryFromTime,    
    left(convert(time,ScheduleDeliveryDateTo),5) as ScheduleDeliveryToTime,     
    Is247Pickup, Is247Delivery, Case when @DryRunType = 1 then 1 else 0 end as IsDryRunPort,    
    case when @DryRunType = 2 then 1 else 0 end as IsDryRunCustomer, IsBobTail,    
    IsEmpty, IsStreetTurn, IsChassisSplit    
   from OrderDetailstops ODS WITH(NOLOCK)    
   Inner join StopsMaster SM WITH(NOLOCK) on ODS.StopTypeKey = SM.StopTypeKey    
   where orderdetailstopkey = @OrderDetailStopKey    
   FOR JSON PATH    
   )    
   if(@IsDebug = 1)    
   Begin    
    select @JsonString as JSONString    
   End    
    
   -- Declare @Status   BIT = 0 , @Reason   NVARCHAR(1000) = ''     
    
   exec [Scheduler_InsertUpdateStops_v2] @UserKey,@JsonString,0, @Status output, @Reason output    
   if(@IsDebug = 1)    
   Begin    
    select @Status as Status, @Reason as Reason    
   End    End    
 End    
     
 if(isnull(@IsDryRun ,0) =0)    
 Begin    
    
  update routes set    
    IsDryRun = 0,     
    DryRunSetUser = null,     
    DryRunSetDate = null,    
    LastUpdateDate=GETDATE(),    
    UpdateUserKey=@UserKey,    
    DryRunType= 0    
  where RouteKey = @routeKey    
     
  set @Comment = 'Container Leg UnChecked DryRun by ' + @USerName + ' on ' + convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108);    
      
 End    
    
    
 INSERT INTO  AuditLogDetail (DateCreated,CreateUser,RefType,RefId,Stage,CommentType,Comments,RefKey)    
 VALUES(GETDATE(),@UserName,'Container',    
  (SELECT ContainerNo FROM OrderDetail WITH(NOLOCK) WHERE OrderDetailKey=@OrderDetailKey),null,'Text',@Comment,@OrderDetailKey)    
    
 SET @Status=1    
 SET @Reason = 'Success'
    
END
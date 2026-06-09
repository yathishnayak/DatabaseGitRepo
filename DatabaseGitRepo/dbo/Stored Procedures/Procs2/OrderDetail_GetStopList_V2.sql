
/*
DECLARE @UserKey INT=953,
	@JSONString NVARCHAR(MAX)='{OrderDetailKey" : 47709}',
	@Status BIT=0,
	@IsDebug		BIT = 0, 
	@JsonOutput nvarchar(max) ='', 	
	@Reason VARCHAR(100)=''
EXEC ShiftWiseData @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
SELECT @JsonOutput, @Status, @Reason
*/
CREATE PROC [dbo].[OrderDetail_GetStopList_V2]
(
	@UserKey			int,
	@JsonString			nvarchar(max) = '',
	@JsonOutput			nvarchar(max) ='' OUTPUT,
	@Status				bit = 0 output,
	@Reason				varchar(500) = '' OUTPUT,
	@IsDebug			bit = 0
)
As
BEGIN

	DECLARE @OrderDetailKey INT, @IsExists BIT

	SELECT @OrderDetailKey = JSON_Value(@JsonString, '$.OrderDetailKey')
	if (@IsDebug = 1)
	BEGIN
		SELECT @OrderDetailKey as OrderDetailKey
	END

	IF ISNULL(@JSONString, '') = ''
    BEGIN
        SET @Status = 0;
        SET @Reason = 'Invalid JSON input';
        RETURN;
    END;

	Declare @Cnt int 
	select @cnt = count(1) from OrderDetailStops WITH (NOLOCK) where isnull(StopNumber,0) = 0

	if(@cnt = 0)
	Begin
		update A set StopNumber = B.NewStopNumber      
		from OrderDetailStops A      
		inner join (      
		select ROW_NUMBER() Over (Order by OrderDetailKey, SM.StoptypeKey,ODS.SchedulePickupDate) as NewStopNumber, SM.StopTypeShortcode, OrderDetailStopKey      
		from OrderDetailStops ODS      
		inner join StopsMaster SM on ODS.StopTypeKey = SM.StopTypeKey      
		where ODs.orderdetailkey = @OrderDetailKey      
		) B on A.OrderDetailStopKey = B.OrderDetailStopKey  
	End

	set @IsExists = case when (select count(1) from OrderDetailStops WITH (NOLOCK) where OrderDetailKey = @OrderDetailKey) > 0 then 1 else 0 end

	IF(@IsExists = 1)
	BEGIN
		update OrderdetailStops set
			SchedulePickupDate = Case when SchedulePickupDate is null and ActualPickupDate is not null
					then ActualPickupDate else SchedulePickupDate end,
			ScheduleDeliveryDate = Case when ScheduleDeliveryDate is null and ActualDeliveryDate is not null
					then ActualDeliveryDate else  ScheduleDeliveryDate end
		where OrderDetailKey = @OrderDetailKey

		Select OrderDetailStopKey, OrderStopKey, OS.StopTypeKey, StopTypeName, OrderDetailKey,StopAddrKey,
						StopTypeShortcode, 
						--StopName, 
						CASE WHEN ISNULL(OS.OrderDetailStopKey ,0) > 0 THEN isnull(StopName,'--')  ELSE StopName END AS StopName, 
						--, isnull(StopName,'--')  as StopName 
					A.AddrName as StopAddress, A.Address1 as AddressLine1, A.Address2 as AddressLine2, City, 
					State, ZipCode, Country, 
					StopNumber, LocationType, 
					--CONVERT(CHAR(10),SchedulePickupDate ,126) SchedulePickupDate,
					SchedulePickupDate,
					--CONVERT(CHAR(10),ActualPickupDate ,126) ActualPickupDate, 
					ActualPickupDate, 
					SchedulePickupUserKey, ActualPickupUserKey, SchedulePickupSetDateTime, ActualPickupSetDateTime, RefNo, 
					IsTMFChecked, IsCTFChecked, TMFCheckUserKey, CTFCheckUserKey, TMFCheckDate, CTFCheckDate, 
					ReasonCode, DropOrLive, DropOrLiveSetUserKey, DropOrLiveSetDatetime, 
					ExceptionReasonCode, ExceptionRCSetUserKey, ExceptionRCSetDateTime, StatusKey, IsFoundationStop, 
					OrderBy, OS.CreateDate, 
					UC.UserName as CreateUserName, OS.UpdateDate, UU.UserName as UpdateUserName, IsDeleted, 
					UD.UserName as DeleteUserName, DeleteDate,
					OS.IsDryRunPort, OS.DryRunPortSetDateTime, OS.DryRunPortSetUserKey, UR.UserName as DryRunUserName,
					IsBobTail,BobtailSetDateTime,BobtailSetUserKey,IsEmpty,EmptySetDateTime,EmptySetUserKey,IsStreetTurn,
					StreetSturnSetDateTime,StreetSturnSetUserKey,IsChassisSplit,ChassisSplitSetDateTime,ChassisSplitSetUserKey,
					--CONVERT(CHAR(10),ScheduleDeliveryDate, 126) ScheduleDeliverDate,
					ScheduleDeliveryDate AS ScheduleDeliverDate,
					ScheduleDeliveryUserKey,ScheduleDeliverySetDateTime,
					--CONVERT(CHAR(10), ActualDeliveryDate, 126) ActualDeliveryDate,
					ActualDeliveryDate,
					ActualDeliveryUserKey,ActualDeliverySetDateTime,
					CASE WHEN ISNULL(ScheduleDeliveryDate,'')='' THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END IsScheduleDeliveryDateExist,
					CASE WHEN ISNULL(OrderDetailStopKey,0)=0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END IsUpdate,
					CAST(SchedulePickupDateTo AS DATE) SchedulePickupToDate,CAST(ScheduleDeliveryDateTo AS DATE) ScheduleDeliverToDate,
					convert(char(5),SchedulePickupDate,108) SchedulePickupFromTime,
					--SchedulePickupDate AS SchedulePickupFromTime,
					convert(char(5),ScheduleDeliveryDate, 108) ScheduleDeliveryFromTime,
					--ScheduleDeliveryDate AS ScheduleDeliveryFromTime, 
					convert(char(5),SchedulePickupDateTo,108) SchedulePickupToTime,
					--SchedulePickupDateTo AS SchedulePickupToTime,
					convert(char(5),ScheduleDeliveryDateTo, 108) ScheduleDeliveryToTime,
					--ScheduleDeliveryDateTo AS ScheduleDeliveryToTime,
					CASE WHEN datediff(day, SchedulePickupDate, GETDATE()) > 0 AND ISNULL(ActualPickupDate,'')='' 
					THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END IsPastSchedulePickup,
					CASE WHEN datediff(day, ScheduleDeliveryDate, GETDATE()) > 0 AND ISNULL(ActualDeliveryDate,'')='' 
					THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END IsPastScheduleDelivery,
					Is247Pickup,Is247Delivery,
					CASE WHEN ActualDeliveryDate IS NULL AND ActualPickupDate IS NULL THEN CAST(0 AS BIT) 
					ELSE CAST(1 AS BIT) END IsActualDeliveryDateExist,
					IsDryRunCustomer,
					IsDryRunPortSFMarked=CASE WHEN (SELECT COUNT(1) FROM OrderDetailStops  WHERE OrderDetailKey=@OrderDetailKey AND ISNULL(IsDryRunPort,0)=1 AND StopTypeKey=1) >0
					THEN CAST(1 AS BIT)	ELSE CAST(0 AS BIT) END,
					LastDryrunPortSFDate=(SELECT 
										STUFF((
												SELECT ', ' + CONVERT(VARCHAR, DryRunPortSetDateTime, 101)
												FROM OrderDetailStops WITH (NOLOCK) where OrderDetailKey=@ORderDetailKey AND IsDryRunPort=1 AND StopTypeKey=1
												FOR XML PATH('')
											), 1, 1, '') AS LastDryrunPortDate),

					IsDryRunPortRTMarked=CASE WHEN (SELECT COUNT(1) FROM OrderDetailStops  WHERE OrderDetailKey=@OrderDetailKey AND ISNULL(IsDryRunPort,0)=1 AND StopTypeKey=5) >0
					THEN CAST(1 AS BIT)	ELSE CAST(0 AS BIT) END,
					LastDryrunPortRTDate=(SELECT 
										STUFF((
												SELECT ', ' + CONVERT(VARCHAR, DryRunPortSetDateTime, 101)
												FROM OrderDetailStops WITH (NOLOCK) where OrderDetailKey=@ORderDetailKey AND IsDryRunPort=1 AND StopTypeKey=5
												FOR XML PATH('')
											), 1, 1, '') AS LastDryrunPortDate),
					IsDryRunCustomerMarked=CASE WHEN (SELECT COUNT(1) FROM OrderDetailStops  WHERE OrderDetailKey=@OrderDetailKey AND ISNULL(IsDryRunCustomer,0)=1)>0
					THEN CAST(1 AS BIT)	ELSE CAST(0 AS BIT) END,
					LastDryrunCustomerDate=(SELECT 
											STUFF((
												SELECT ', ' + CONVERT(VARCHAR, DryRunCustomerSetDateTime, 101)
												FROM OrderDetailStops WITH (NOLOCK) where OrderDetailKey=@ORderDetailKey AND IsDryRunCustomer=1
												FOR XML PATH('')
											), 1, 1, '') AS LastDryrunCustomerDate)
		Into #StopRecs
		FROM		StopsMaster SM with (nolock) 
		LEFT JOIN	OrderDetailStops OS with (nolock) on OS.StopTypeKey = SM.StopTypeKey 
					and OS.OrderDetailKey = @OrderDetailKey
		LEFT JOIN	[Address] A with (nolock) on OS.StopAddrKey = A.AddrKey
		LEFT JOIN	[User] UC with (nolock) on OS.CreateUserKey = UC.UserKey
		LEFT JOIN	[User] UU with (nolock) on OS.UpdateUserKey = UU.UserKey
		LEFT JOIN	[User] UD with (nolock) on OS.DeleteUserKey = UD.UserKey
		LEFT JOIN	[User] UR with (nolock) on OS.DryRunPortSetUserKey = UD.UserKey
		--WHERE		OS.OrderDetailKey = OD.OrderDetailKey
		WHERE ISNULL(IsDryRunPort,0)=0 AND ISNULL(IsDryRunCustomer,0)=0
		Order By	OS.StopNumber ASC-- SM.OrderBy

	DELETE FROM #StopRecs WHERE StopTypeShortcode IN ('AF','AT') AND OrderDetailStopKey IS NULL

	-- CHECK IF SF STOPS - NEW EXIST - If not Exists, add one
	declare @SFcnt	smallint = 0
	select @SFcnt = count(1) from #StopRecs where StopTypeShortcode = 'SF'
	if(@SFcnt = 0)
	Begin
		insert into #StopRecs (StopTypeName, StopTypeShortcode, IsFoundationStop, OrderBy, SchedulePickupToTime)
		select StopTypeName, StopTypeShortcode, IsFoundationStop, OrderBy,convert(char(5),Getdate(), 108)
		from StopsMaster WITH (NOLOCK) 
		where  StopTypeShortcode = 'SF'
	End

	-- CHECK IF ST STOPS - NEW EXIST - If not Exists, add one
	declare @STcnt	smallint = 0
	select @STcnt = count(1) from #StopRecs where StopTypeShortcode = 'ST'
	if(@STcnt = 0)
	Begin
		insert into #StopRecs (StopTypeName, StopTypeShortcode, IsFoundationStop, OrderBy,SchedulePickupToTime)
		select StopTypeName, StopTypeShortcode, IsFoundationStop, OrderBy,convert(char(5),Getdate(), 108)
		from StopsMaster WITH (NOLOCK) 
		where  StopTypeShortcode = 'ST'
	End

	-- CHECK IF RT STOPS - NEW EXIST - If not Exists, add one
	--select '#StopRecs',* from #StopRecs
	declare @RTcnt	smallint = 0
	select @RTcnt = count(1) from #StopRecs where StopTypeShortcode = 'RT'
	--select '@RTcnt',@RTcnt
	if(@RTcnt = 0)
	Begin
		insert into #StopRecs (StopTypeName, StopTypeShortcode, IsFoundationStop, OrderBy,SchedulePickupToTime)
		select StopTypeName, StopTypeShortcode, IsFoundationStop, OrderBy,convert(char(5),Getdate(), 108)
		from StopsMaster WITH (NOLOCK) 
		where  StopTypeShortcode = 'RT'
	End

	--// CHECK IF AF STOPS - NEW EXIST - If not Exists, add one
	--declare @AFcnt	smallint = 0
	--select @AFcnt = count(1) from #StopRecs where StopTypeShortcode = 'AF' and Isnull(StopName,'') = ''
	--if(@AFcnt = 0)
	--Begin
	--	insert into #StopRecs (StopTypeName, StopTypeShortcode, IsFoundationStop, OrderBy)
	--	select StopTypeName, StopTypeShortcode, IsFoundationStop, OrderBy
	--	from StopsMaster 
	--	where  StopTypeShortcode = 'AF'
	--End

	----// CHECK IF AT STOPS - NEW EXIST - If not Exists, add one
	--declare @ATcnt	smallint = 0
	--select @AFcnt = count(1) from #StopRecs where StopTypeShortcode = 'AT' and Isnull(StopName,'') = ''
	--if(@AFcnt = 0)
	--Begin
	--	insert into #StopRecs (StopTypeName, StopTypeShortcode, IsFoundationStop, OrderBy)
	--	select StopTypeName, StopTypeShortcode, IsFoundationStop, OrderBy
	--	from StopsMaster 
	--	where  StopTypeShortcode = 'AT'
	--End
		--Select * from #StopRecs Order by ORderBy 
	Select OrderStops = (
			SELECT OrderKey, OrderDetailKey, 
						StopDetails = (	Select * from #StopRecs Order by OrderBy,StopNumber FOR JSON PATH ) 
	FROM	Orderdetail OD with (nolock)
	WHERE	OrderDetailKey  =  @OrderDetailKey

	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	) 
	
	Drop table #StopRecs

	set @Status = 1
	SEt @Reason = 'Success'
	END
	ELSE
	BEGIN
	SET @Status = 0
	SEt @Reason = 'Data doesn''t exists for the OrderDetailKey passed'
	END
END


/****** Object:  StoredProcedure [dbo].[Scheduler_InsertStopsAuditLogs]    Script Date: 6/24/2025 7:11:12 PM ******/

CREATE PROCEDURE [dbo].[Scheduler_InsertStopsAuditLogs]
(
	@UserKey		INT=512,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;

	DECLARE @UserName NVARCHAR(100)=''
	SELECT @UserName=ISNULL(UserName,'') FROM [User] WHERE UserKey=@UserKey

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',(SELECT TOP 1 ContainerNo FROM OrderDetail WHERE OrderDetailKey=OD.OrderDetailKey) ,OD.OrderDetailStopKey,
			 null,'Text','Stop Name is changed from '+ISNULL(OD.StopName,'') +' to '+ISNULL(TD.StopName, '') +', by '+@UserName
	FROM	OrderDetailStops OD 
	INNER JOIN	#tempstopsdata TD ON OD.OrderDetailStopKey = TD.OrderDetailStopKey
	WHERE TD.StopName is NOT null AND OD.StopName<>TD.StopName

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',(SELECT TOP 1 ContainerNo FROM OrderDetail WHERE OrderDetailKey=OD.OrderDetailKey) ,OD.OrderDetailStopKey,
			 null,'Text','SchedulePickUp From is changed from '+FORMAT(OD.SchedulePickupDate, 'MM/dd/yyyy HH:mm:ss') +' to '+FORMAT(TD.SchedulePickUp, 'MM/dd/yyyy HH:mm:ss') +', by '+@UserName
	FROM	OrderDetailStops OD 
	INNER JOIN	#tempstopsdata TD ON OD.OrderDetailStopKey = TD.OrderDetailStopKey
	WHERE TD.SchedulePickUp is NOT null AND OD.SchedulePickupDate<>TD.SchedulePickUp

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',(SELECT TOP 1 ContainerNo FROM OrderDetail WHERE OrderDetailKey=OD.OrderDetailKey) ,OD.OrderDetailStopKey,
			 null,'Text','SchedulePickUp To is changed from '+FORMAT(OD.SchedulePickupDateTo, 'MM/dd/yyyy HH:mm:ss') +' to '+FORMAT(TD.SchedulePickupToDate, 'MM/dd/yyyy HH:mm:ss') +', by '+@UserName
	FROM	OrderDetailStops OD 
	INNER JOIN	#tempstopsdata TD ON OD.OrderDetailStopKey = TD.OrderDetailStopKey
	WHERE TD.SchedulePickupToDate is NOT null AND OD.SchedulePickupDateTo<>TD.SchedulePickupToDate

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',(SELECT TOP 1 ContainerNo FROM OrderDetail WHERE OrderDetailKey=OD.OrderDetailKey) ,OD.OrderDetailStopKey,
			 null,'Text','ActualPickUp To is changed from '+FORMAT(OD.ActualPickupDate, 'MM/dd/yyyy HH:mm:ss') +' to '+FORMAT(TD.ActualPickUp, 'MM/dd/yyyy HH:mm:ss') +', by '+@UserName
	FROM	OrderDetailStops OD 
	INNER JOIN	#tempstopsdata TD ON OD.OrderDetailStopKey = TD.OrderDetailStopKey
	WHERE TD.ActualPickUp is NOT null AND OD.ActualPickupDate<>TD.ActualPickUp

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',(SELECT TOP 1 ContainerNo FROM OrderDetail WHERE OrderDetailKey=OD.OrderDetailKey) ,OD.OrderDetailStopKey,
			 null,'Text','ScheduleDelivery To is changed from '+FORMAT(OD.ScheduleDeliveryDate, 'MM/dd/yyyy HH:mm:ss') +' to '+FORMAT(TD.ScheduleDelivery, 'MM/dd/yyyy HH:mm:ss') +', by '+@UserName
	FROM	OrderDetailStops OD 
	INNER JOIN	#tempstopsdata TD ON OD.OrderDetailStopKey = TD.OrderDetailStopKey
	WHERE TD.ScheduleDelivery is NOT null AND OD.ScheduleDeliveryDate<>TD.ScheduleDelivery

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',(SELECT TOP 1 ContainerNo FROM OrderDetail WHERE OrderDetailKey=OD.OrderDetailKey) ,OD.OrderDetailStopKey,
			 null,'Text','ScheduleDeliveryDateTo To is changed from '+FORMAT(OD.ScheduleDeliveryDateTo, 'MM/dd/yyyy HH:mm:ss') +' to '+FORMAT(TD.ScheduleDeliverToDate, 'MM/dd/yyyy HH:mm:ss') +', by '+@UserName
	FROM	OrderDetailStops OD 
	INNER JOIN	#tempstopsdata TD ON OD.OrderDetailStopKey = TD.OrderDetailStopKey
	WHERE TD.ScheduleDeliverToDate is NOT null AND OD.ScheduleDeliveryDateTo<>TD.ScheduleDeliverToDate

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',(SELECT TOP 1 ContainerNo FROM OrderDetail WHERE OrderDetailKey=OD.OrderDetailKey) ,OD.OrderDetailStopKey,
			 null,'Text','ActualDeliveryDate To is changed from '+FORMAT(OD.ActualDeliveryDate, 'MM/dd/yyyy HH:mm:ss') +' to '+FORMAT(TD.ActualDelivery, 'MM/dd/yyyy HH:mm:ss') +', by '+@UserName
	FROM	OrderDetailStops OD 
	INNER JOIN	#tempstopsdata TD ON OD.OrderDetailStopKey = TD.OrderDetailStopKey
	WHERE TD.ActualDelivery is NOT null AND OD.ActualDeliveryDate<>TD.ActualDelivery

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',(SELECT TOP 1 ContainerNo FROM OrderDetail WHERE OrderDetailKey=OD.OrderDetailKey) ,OD.OrderDetailStopKey,
			 null,'Text','StopName is changed from '+OD.StopName +' to '+TD.StopName +', by '+@UserName
	FROM	OrderDetailStops OD 
	INNER JOIN	#tempstopsdata TD ON OD.OrderDetailStopKey = TD.OrderDetailStopKey
	WHERE TD.StopName is NOT null AND OD.StopName<>TD.StopName

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',(SELECT TOP 1 ContainerNo FROM OrderDetail WHERE OrderDetailKey=OD.OrderDetailKey) ,OD.OrderDetailStopKey,
			 null,'Text','DropOrLive is changed from '+OD.DropOrLive +' to '+TD.DropOrLive +', by '+@UserName
	FROM	OrderDetailStops OD 
	INNER JOIN	#tempstopsdata TD ON OD.OrderDetailStopKey = TD.OrderDetailStopKey
	WHERE TD.DropOrLive is NOT null AND OD.DropOrLive<>TD.DropOrLive

	--INSERT INTO AuditLogDetail
	--		(DateCreated,CreateUser,RefType,RefId,RefKey,
	--		 Stage,CommentType,Comments)
	--SELECT   GETDATE(),@UserName,'Container',(SELECT TOP 1 ContainerNo FROM OrderDetail WHERE OrderDetailKey=OD.OrderDetailKey) ,OD.OrderDetailStopKey,
	--		 null,'Text','DropOrLive is changed from '+OD.DropOrLive +' to '+TD.DropOrLive +', by '+@UserName
	--FROM	OrderDetailStops OD 
	--INNER JOIN	#tempstopsdata TD ON OD.OrderDetailStopKey = TD.OrderDetailStopKey
	--WHERE OD.DropOrLive<>TD.DropOrLive

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',(SELECT TOP 1 ContainerNo FROM OrderDetail WHERE OrderDetailKey=OD.OrderDetailKey) ,OD.OrderDetailStopKey,
			 null,'Text','Is247Pickup is changed from '+IIF(ISNULL(OD.Is247Pickup,0)=0,'False','True') +' to '+IIF(ISNULL(TD.Is247Pickup,0)=0,'False','True') +', by '+@UserName
	FROM	OrderDetailStops OD 
	INNER JOIN	#tempstopsdata TD ON OD.OrderDetailStopKey = TD.OrderDetailStopKey
	WHERE TD.Is247Pickup is NOT null AND OD.Is247Pickup<>TD.Is247Pickup

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',(SELECT TOP 1 ContainerNo FROM OrderDetail WHERE OrderDetailKey=OD.OrderDetailKey) ,OD.OrderDetailStopKey,
			 null,'Text','IsDryRunPort is changed from '+IIF(ISNULL(OD.IsDryRunPort,0)=0,'False','True') +' to '+IIF(ISNULL(TD.IsDryRunPort,0)=0,'False','True') +', by '+@UserName
	FROM	OrderDetailStops OD 
	INNER JOIN	#tempstopsdata TD ON OD.OrderDetailStopKey = TD.OrderDetailStopKey
	WHERE TD.IsDryRunPort is NOT null AND OD.IsDryRunPort<>TD.IsDryRunPort

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',(SELECT TOP 1 ContainerNo FROM OrderDetail WHERE OrderDetailKey=OD.OrderDetailKey) ,OD.OrderDetailStopKey,
			 null,'Text','IsDryRunCustomer is changed from '+IIF(ISNULL(OD.IsDryRunCustomer,0)=0,'False','True') +' to '+IIF(ISNULL(TD.IsDryRunCustomer,0)=0,'False','True') +', by '+@UserName
	FROM	OrderDetailStops OD 
	INNER JOIN	#tempstopsdata TD ON OD.OrderDetailStopKey = TD.OrderDetailStopKey
	WHERE TD.IsDryRunCustomer is NOT null AND OD.IsDryRunCustomer<>TD.IsDryRunCustomer

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',(SELECT TOP 1 ContainerNo FROM OrderDetail WHERE OrderDetailKey=OD.OrderDetailKey) ,OD.OrderDetailStopKey,
			 null,'Text','IsBobtail is changed from '+IIF(ISNULL(OD.IsBobtail,0)=0,'False','True') +' to '+IIF(ISNULL(TD.IsBobtail,0)=0,'False','True') +', by '+@UserName
	FROM	OrderDetailStops OD 
	INNER JOIN	#tempstopsdata TD ON OD.OrderDetailStopKey = TD.OrderDetailStopKey
	WHERE TD.IsBobtail is NOT null AND OD.IsBobtail<>TD.IsBobtail

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',(SELECT TOP 1 ContainerNo FROM OrderDetail WHERE OrderDetailKey=OD.OrderDetailKey) ,OD.OrderDetailStopKey,
			 null,'Text','IsEmptyReady is changed from '+IIF(ISNULL(OD.IsEmpty,0)=0,'False','True') +' to '+IIF(ISNULL(TD.IsEmptyReady,0)=0,'False','True') +', by '+@UserName
	FROM	OrderDetailStops OD 
	INNER JOIN	#tempstopsdata TD ON OD.OrderDetailStopKey = TD.OrderDetailStopKey
	WHERE TD.IsEmptyReady is NOT null AND OD.IsEmpty<>TD.IsEmptyReady

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',(SELECT TOP 1 ContainerNo FROM OrderDetail WHERE OrderDetailKey=OD.OrderDetailKey) ,OD.OrderDetailStopKey,
			 null,'Text','IsStreetTurn is changed from '+IIF(ISNULL(OD.IsStreetTurn,0)=0,'False','True') +' to '+IIF(ISNULL(TD.IsStreetTurn,0)=0,'False','True') +', by '+@UserName
	FROM	OrderDetailStops OD 
	INNER JOIN	#tempstopsdata TD ON OD.OrderDetailStopKey = TD.OrderDetailStopKey
	WHERE TD.IsStreetTurn is NOT null AND OD.IsStreetTurn<>TD.IsStreetTurn

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',(SELECT TOP 1 ContainerNo FROM OrderDetail WHERE OrderDetailKey=OD.OrderDetailKey) ,OD.OrderDetailStopKey,
			 null,'Text','IsChassisSplit is changed from '+IIF(ISNULL(OD.IsChassisSplit,0)=0,'False','True') +' to '+IIF(ISNULL(TD.IsChassisSplit,0)=0,'False','True') +', by '+@UserName
	FROM	OrderDetailStops OD 
	INNER JOIN	#tempstopsdata TD ON OD.OrderDetailStopKey = TD.OrderDetailStopKey
	WHERE TD.IsChassisSplit is NOT null AND OD.IsChassisSplit<>TD.IsChassisSplit

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',(SELECT TOP 1 ContainerNo FROM OrderDetail WHERE OrderDetailKey=OD.OrderDetailKey) ,OD.OrderDetailStopKey,
			 null,'Text','Is247Delivery is changed from '+IIF(ISNULL(OD.Is247Delivery,0)=0,'False','True') +' to '+IIF(ISNULL(TD.Is247Delivery,0)=0,'False','True') +', by '+@UserName
	FROM	OrderDetailStops OD 
	INNER JOIN	#tempstopsdata TD ON OD.OrderDetailStopKey = TD.OrderDetailStopKey
	WHERE TD.Is247Delivery is NOT null AND OD.Is247Delivery<>TD.Is247Delivery
END
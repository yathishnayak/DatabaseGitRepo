


CREATE PROCEDURE [dbo].[TMS_integration_ConfirmOrder_ACER]
(
	@SiteId				varchar(50),
	@TMS_OrderKey		int,
	@JsonText			varchar(max),
	@UserKey			int = 0,
	@IsSaved			bit = 0 OUTPUT,
	@Reason				varchar(500)='' output
)
AS
BEGIN

	SET NOCOUNT ON
	SET FMTONLY OFF

	if(ISNULL(@SiteId,'') = '')
	Begin
		set @IsSaved = 0
		set @Reason = 'SiteID not found'
		return
	End
	if(ISNULL(@TMS_OrderKey,0) = 0 OR ISNULL(@UserKey,0) = 0)
	Begin
		set @IsSaved = 0
		set @Reason = 'No Order/user Information'
		return
	end

	if(ISNULL(@JsonText,'') = '')
	Begin
		set @IsSaved = 0
		set @Reason = 'Content not found'
		return
	End
	
	create table #Header
	(
		SiteId			varchar(20),
		DataKey			int,	
		WorkOrdernumber	varchar	(50),
		TMS_OrderKey	int,	
		ContainerJson	nvarchar(max)
	)

	create table #Container
	(
		SiteID				varchar	(50),
		DataKey				int,
		ContainerKey		int,
		ContainerNo			varchar(50),
		TMS_OrderDetailKey	int,
		Routes_Json			nvarchar(max)
	)
	
	create Table #Routes
	(
		SiteID			varchar	(50),
		DataKey			int,
		ContainerKey	int,
		StopKey			int,
		TMS_RouteKey	int,
		TMS_LegKey		int
	)

	insert into #Header(SiteId, DataKey, WorkOrdernumber, TMS_OrderKey, ContainerJson)
	select @SiteId, DataKey, WorkOrdernumber, TMS_OrderKey, ContainerJson
	from OpenJSON(@JsonText,'$')
	with 
	(
		DataKey			int				'$.DataKey',
		WorkOrdernumber	varchar	(50)	'$.workOrderNumber',
		TMS_OrderKey	int				'$.TMS_OrderKey',
		ContainerJson	nvarchar(max)	'$.Container' as JSON
	)
	--select * from #Header
	

	declare @ContJson nvarchar(max)
	declare _contCurs Cursor LOCAL for select ContainerJson from #Header
	Open _contCurs
	fetch next from _contCurs into @ContJson

	while @@FETCH_STATUS = 0
	Begin
		select @ContJson = ContainerJson from #Header
		insert into #Container(SiteId, DataKey, ContainerKey, ContainerNo, TMS_OrderDetailKey,Routes_Json )
		select @SiteId, DataKey, ContainerKey, ContainerNo, TMS_OrderDetailKey,Routes_Json
		from OpenJSON(@ContJson,'$')
		with 
		(
			DataKey				int			'$.DataKey',
			ContainerKey		int			'$.ContainerKey',
			ContainerNo			varchar(50)	'$.equipmentNumber',
			TMS_OrderDetailKey	int			'$.TMSOrderDetailKey',
			Routes_Json			nvarchar(max) '$.Route' as JSON
		)
		fetch next from _contCurs into @ContJson
	end
	close _contCurs
	deallocate _contCurs
	--select * from #Container


	declare @RoutJson nvarchar(max)
	declare _routCurs Cursor LOCAL for select Routes_Json from #Container
	Open _routCurs
	fetch next from _routCurs into @RoutJson

	while @@FETCH_STATUS = 0
	Begin
		insert into #Routes(SiteID, DataKey, ContainerKey, StopKey, TMS_RouteKey, TMS_LegKey)
		select @SiteId, DataKey, ContainerKey, StopKey, TMS_RouteKey, TMS_LegKey
		from OpenJSON(@RoutJson,'$')
		with 
		(
			StopKey				int		'$.StopKey',
			TMS_RouteKey		int		'$.TMS_RouteKey',
			TMS_LegKey			int		'$.TMS_LegKey',
			DataKey				int		'$.DataKey',
			ContainerKey		int		'$.ContainerKey'
		)
		fetch next from _routCurs into @RoutJson
	end
	close _routCurs
	deallocate _routCurs
	
	--Select * from #Routes

	declare @RecCount int = 0
	select @RecCount = COUNT(1) 
	from TMS_Integration_Header TH
	inner join #Header H on TH.DataKey = H.DataKey and TH.SiteID  = H.SiteId

	if(isnull(@RecCount,0) = 0)
	Begin
		Begin Transaction
		Begin Try
				insert into TMS_Integration_Header (SiteID, DataKey, WorkOrdernumber, TMS_OrderKey)
				select @SiteId,DataKey, WorkOrdernumber, TMS_OrderKey  from #Header 
		
				insert into TMS_Integration_Container (SiteID, DataKey, ContainerKey, ContainerNo, TMS_OrderDetailKey)
				select @SiteId, DataKey, ContainerKey, ContainerNo, TMS_OrderDetailKey from #Container

				insert into TMS_Integration_Routes (SiteID, DataKey, ContainerKey, StopKey, TMS_RouteKey, TMS_LegKey)
				select @SiteId, DataKey, ContainerKey, StopKey, TMS_RouteKey, TMS_LegKey from #Routes

				Commit Transaction

			set @IsSaved = 1
			set @Reason = 'Saved Successfully'
	
		End Try
		Begin Catch
			Rollback Transaction
		
			Set @IsSaved = 0
			Set @Reason = ERROR_MESSAGE()
			print @Reason
		End Catch
	END
	else
	Begin
		Set @IsSaved = 0
		Set @Reason = 'Record already exists'
	End
END

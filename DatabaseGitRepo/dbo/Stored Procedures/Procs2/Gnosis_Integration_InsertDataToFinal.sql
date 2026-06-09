
--Gnosis_Integration_InsertDataToFinal '5e196243-9e67-4ab1-9f8d-5721d9d98c36'

CREATE Proc [dbo].[Gnosis_Integration_InsertDataToFinal] -- Gnosis_Integration_InsertDataToFinal '95b481fe-9589-4bf5-b03c-0a69b6d49895'
(
	@UUID		varchar(50),
	@LastDataKey	int =0
)
as
BEGIN
	set nocount on
	set FMTONLY OFF
	Set @LastDataKey = 0 -- Last datakey is set considering the latest record from Update_dt
	declare @cnt int,  @IsFoundinFinal bit, @UUIDCount	int,
		@CustCount	int,
		@HoldCount	int,
		@MBLCount	int,
		@ShipmentsCount	int,
		@ContainerStatus	varchar(50),
		@HoldStatus		varchar(20),
		@Holds			varchar(50)
			
	select @cnt = count(1) from Gnosis_Integration_Container where UUID = @UUID
	if(isnull(@LastDataKey,0) = 0)
	Begin
		select top 1 @LastDataKey = DataKey
		from Gnosis_Integration_Container WITH (NOLOCK)
		where UUID = @UUID
		order by convert(Datetime,Updated_dt) desc
	End
	SET @IsFoundinFinal = Case when (isnull((Select count(1)
	from Gnosis_Integration_Container_Final WITH (NOLOCK) where UUID = @UUID and LastDataKey = @LastDataKey),0)) =  0 then 0 else 1 end
	Select @UUIDCount = count(1) from Gnosis_Integration_Container_Final WITH (NOLOCK) where UUID = @UUID 

	Print '------------------------'
	print @UUID
	print @LastDataKey
	Select @CustCount = Count(1) from Gnosis_Integration_ContainerCustomer_Final WITH (NOLOCK) where UUID = @UUID
	Select @MBLCount = Count(1) from Gnosis_Integration_MBL_FINAL WITH (NOLOCK) where UUID = @UUID
	Select @HoldCount = Count(1) from Gnosis_Integration_Holds_Final WITH (NOLOCK) where UUID = @UUID
	Select @ShipmentsCount = Count(1) from Gnosis_Integration_Shipments_Final WITH (NOLOCK) where UUID = @UUID
	print @CustCount
	print @MBLCount
	Print @Holdcount
	print @ShipmentsCount

	Declare @ClosedArea VARCHAR(10) = ''

	SELECT @ClosedArea = CASE WHEN Location_at_terminal = 'Closed Area' THEN 'true' ELSE 'false' END  FROM 
	Gnosis_Integration_Container where UUID = @UUID and Datakey = @LastDataKey


	SElect @HoldStatus = Case when CTF = 'true' OR TMF = 'true' 
			OR Line = 'true' OR Other = 'true' OR Customs = 'true' OR Freight = 'True' then 'Yes' else 'No' end
		from Gnosis_Integration_Holds WITH (NOLOCK) where Datakey = @LastDataKey
	select @Holds = 
		Case when CTF = 'true' then 'CTF:' else '' end + 
		Case when TMF = 'true' then 'TMF:' else '' end + 
		Case when Line = 'true' then 'LINE:' else '' end + 
		Case when Other = 'true' then 'OTHER:' else '' end + 
		Case when Customs = 'true' then 'CUSTOMS:' else '' end +
		Case when Freight = 'true' then 'FREIGHT:' else '' end +
		Case when @ClosedArea = 'true' then 'CLOSEDAREA:' else '' end
	from Gnosis_Integration_Holds WITH (NOLOCK) where Datakey = @LastDataKey

	UPDATE		HF
	SET			ClosedArea = @ClosedArea
	FROM		Gnosis_Integration_Holds_final HF
	WHERE		HF.UUID = @UUID


	if(@cnt > 0 and isnull(@UUIDCount,0) = 0)
	Begin
		insert into Gnosis_Integration_Container_Final
		(UUID,container_number,container_journey_start_key,seal_no,container_type,length,empty_out_dt,in_gate_dt,early_receive_dt,cut_off_dt,out_gate_dt,port_eta_dt,gnosis_vessel_eta_dt
		,gnosis_estimated_discharge_dt,gnosis_rail_eta_dt,vessel_eta_dt,vessel_etd_dt,vessel_ata_dt,vessel_atd_dt,discharged_dt,empty_returned_dt,pod_locode,pod_city
		,pod_terminal_name,pod_terminal_firms_code,pol_locode,pol_city,pol_terminal_name,pol_terminal_firms_code,por_locode,por_city,ocean_carrier_name,ocean_carrier_scac
		,mother_vessel,mother_vessel_imo,mother_voyage,motherload_dt,current_vessel,current_vessel_imo,first_vessel,first_vessel_imo,location_at_terminal,is_railing,rail_eta_dt
		,rail_ata_dt,rail_departed_dt,rail_discharged_dt,rail_terminal,rail_terminal_firms_code,rail_notify_dt,pickup_number,available_dt,final_dest_locode,final_dest_city,last_free_demurrage_day_dt
		,last_free_detention_day_dt,estd_last_free_demurrage_day_dt,demurrage_amount,estd_demurrage_amount,estd_last_free_detention_day_dt,estd_detention_amount,carrier_release_dt,customs_clearance_dt
		,available_for_pickup,loaded_on_vessel_dt,pickup_appointment_dt,Updated_dt,chassis_number,customer_tag,carrier_contract,distribution_center,drayage_carrier, LastUpdateDate, LastDataKey,
		ContainerStatus, HoldStatus, Holds, gnosis_estimated_demurrage_amount,RailOutGateDate)
		select UUID,container_number,container_journey_start_key,seal_no,container_type,length,empty_out_dt,in_gate_dt,early_receive_dt,cut_off_dt,out_gate_dt,port_eta_dt,gnosis_vessel_eta_dt
		,gnosis_estimated_discharge_dt,gnosis_rail_eta_dt,vessel_eta_dt,vessel_etd_dt,vessel_ata_dt,vessel_atd_dt,discharged_dt,empty_returned_dt,pod_locode,pod_city
		,pod_terminal_name,pod_terminal_firms_code,pol_locode,pol_city,pol_terminal_name,pol_terminal_firms_code,por_locode,por_city,ocean_carrier_name,ocean_carrier_scac
		,mother_vessel,mother_vessel_imo,mother_voyage,motherload_dt,current_vessel,current_vessel_imo,first_vessel,first_vessel_imo,location_at_terminal,is_railing,rail_eta_dt
		,rail_ata_dt,rail_departed_dt,rail_discharged_dt,rail_terminal,rail_terminal_firms_code,rail_notify_dt,pickup_number,available_dt,final_dest_locode,final_dest_city,last_free_demurrage_day_dt
		,last_free_detention_day_dt,estd_last_free_demurrage_day_dt,demurrage_amount,estd_demurrage_amount,estd_last_free_detention_day_dt,estd_detention_amount,carrier_release_dt,customs_clearance_dt
		,available_for_pickup,loaded_on_vessel_dt,pickup_appointment_dt,Updated_dt,chassis_number,customer_tag,carrier_contract,distribution_center,drayage_carrier, GetDate(), @LastDataKey,
		@ContainerStatus, @HoldStatus, @Holds, gnosis_estimated_demurrage_amount,RailOutGateDate
		from Gnosis_Integration_Container where UUID = @UUID and Datakey = @LastDataKey

		
	End
	Else
	Begin
		Update A SET
			Container_number			=B.Container_number,
			Container_journey_start_key	=B.Container_journey_start_key,
			Seal_no						=B.Seal_no,
			Container_type				=B.Container_type,
			Length						=B.Length,
			Weight						=B.Weight,
			Empty_out_dt				=B.Empty_out_dt,
			In_gate_dt					=B.In_gate_dt,
			Early_receive_dt			=B.Early_receive_dt,
			Cut_off_dt					=B.Cut_off_dt,
			Out_gate_dt					=B.Out_gate_dt,
			Port_eta_dt					=B.Port_eta_dt,
			Gnosis_vessel_eta_dt		=B.Gnosis_vessel_eta_dt,
			Gnosis_estimated_discharge_dt=B.Gnosis_estimated_discharge_dt,
			Gnosis_rail_eta_dt			=B.Gnosis_rail_eta_dt,
			Vessel_eta_dt				=B.Vessel_eta_dt,
			Vessel_etd_dt				=B.Vessel_etd_dt,
			Vessel_ata_dt				=B.Vessel_ata_dt,
			Vessel_atd_dt				=B.Vessel_atd_dt,
			Discharged_dt				=B.Discharged_dt,
			Empty_returned_dt			=B.Empty_returned_dt,
			Pod_locode					=B.Pod_locode,
			Pod_city					=B.Pod_city,
			Pod_terminal_name			=B.Pod_terminal_name,
			Pod_terminal_firms_code		=B.Pod_terminal_firms_code,
			Pol_locode					=B.Pol_locode,
			Pol_city					=B.Pol_city,
			Pol_terminal_name			=B.Pol_terminal_name,
			Pol_terminal_firms_code		=B.Pol_terminal_firms_code,
			Por_locode					=B.Por_locode,
			Por_city					=B.Por_city,
			Ocean_carrier_name			=B.Ocean_carrier_name,
			Ocean_carrier_scac			=B.Ocean_carrier_scac,
			Mother_vessel				=B.Mother_vessel,
			Mother_vessel_imo			=B.Mother_vessel_imo,
			Mother_voyage				=B.Mother_voyage,
			Motherload_dt				=B.Motherload_dt,
			Current_vessel				=B.Current_vessel,
			Current_vessel_imo			=B.Current_vessel_imo,
			First_vessel				=B.First_vessel,
			First_vessel_imo			=B.First_vessel_imo,
			Location_at_terminal		=B.Location_at_terminal,
			Is_railing					=B.Is_railing,
			Rail_eta_dt					=B.Rail_eta_dt,
			Rail_ata_dt					=B.Rail_ata_dt,
			Rail_departed_dt			=B.Rail_departed_dt,
			Rail_discharged_dt			=B.Rail_discharged_dt,
			Rail_terminal				=B.Rail_terminal,
			Rail_terminal_firms_code	=B.Rail_terminal_firms_code,
			Rail_notify_dt				=B.Rail_notify_dt,
			Pickup_number				=B.Pickup_number,
			Available_dt				=B.Available_dt,
			Final_dest_locode			=B.Final_dest_locode,
			Final_dest_city				=B.Final_dest_city,
			Last_free_demurrage_day_dt	=B.Last_free_demurrage_day_dt,
			Last_free_detention_day_dt	=B.Last_free_detention_day_dt,
			Estd_last_free_demurrage_day_dt=B.Estd_last_free_demurrage_day_dt,
			Demurrage_amount			=B.Demurrage_amount,
			Estd_demurrage_amount		=B.Estd_demurrage_amount,
			Estd_last_free_detention_day_dt=B.Estd_last_free_detention_day_dt,
			Estd_detention_amount		=B.Estd_detention_amount,
			Carrier_release_dt			=B.Carrier_release_dt,
			Customs_clearance_dt		=B.Customs_clearance_dt,
			Available_for_pickup		=B.Available_for_pickup,
			Loaded_on_vessel_dt			=B.Loaded_on_vessel_dt,
			Pickup_appointment_dt		=B.Pickup_appointment_dt,
			Updated_dt					=B.Updated_dt,
			Chassis_number				=B.Chassis_number,
			Customer_tag				=B.Customer_tag,
			Carrier_contract			=B.Carrier_contract,
			Distribution_center			=B.Distribution_center,
			Drayage_carrier				=B.Drayage_carrier,
			LastUpdateDate				=GetDate(),
			LastDataKey					= @LastDataKey,
			ContainerStatus				= @ContainerStatus,
			HoldStatus					= @HoldStatus,
			Holds						= @Holds,
			gnosis_estimated_demurrage_amount = B.gnosis_estimated_demurrage_amount,
			RailOutGateDate				= B.RailOutGateDate
		from Gnosis_Integration_Container_Final A
		inner join Gnosis_Integration_Container B WITH (NOLOCK) on A.UUID = B.uuid 
		where b.datakey = @LastDataKey

		
	End
	
	Update F set ContainerStatus = CS.ContainerStatus
	from Gnosis_Integration_Container_Final F
	inner join  vGnosis_Container_Status CS WITH (NOLOCK) on CS.DataKey = f.LastDataKey
	where  Datakey = @LastDataKey

	EXEC Gnosis_Update_PortOutGateDate_FromTMS

	update A set orderdetailkey = OD.OrderDetailKey
	--Select *
	from Gnosis_Integration_Container_Final A
	inner join Gnosis_Integration_MBL_FINAL  M WITH (NOLOCK) on A.UUID = M.UUID
	inner join OrderDetail OD WITH (NOLOCK) on A.Container_number = OD.ContainerNo
	inner join OrderHeader OH WITH (NOLOCK) on OD.orderkey = OH.OrderKey and M.MBL_number = OH.BillOfLading
	where A.UUID = @UUID
	

	IF(isnull(@CustCount,0) = 0)
	Begin
		insert into Gnosis_Integration_ContainerCustomer_Final
		(UUID, Field_name, Field_value, Field_value_str)
		Select @UUID, Field_name, Field_value, Field_value_str 
		from Gnosis_Integration_ContainerCustomer where datakey = @LastDataKey
	End
	Else
	Begin
		Update A set
			Field_name		= B.Field_name,
			Field_value		= B.Field_value,
			Field_value_str	= b.Field_value_str
		from Gnosis_Integration_ContainerCustomer_Final A
		inner join Gnosis_Integration_ContainerCustomer  B WITH (NOLOCK)
			on B.DataKey = @LastDataKey and A.Field_name = b.Field_name
		where A.UUID = @UUID
	End

	IF(isnull(@HoldCount,0) = 0)
	Begin
		insert into Gnosis_Integration_Holds_Final (UUID, CTF, TMF, Line, Other, Customs,Freight,ClosedArea)
		select distinct @UUID,CTF, TMF, Line, Other, Customs,Freight,'false'
		from Gnosis_Integration_Holds WITH (NOLOCK)
		where DataKey = @LastDataKey
	End
	Else
	Begin
		update A SET 
			CTF			= b.CTF,
			TMF			= b.TMF,
			Line		= b.Line,
			Other		= b.Other,
			Customs		= b.Customs,
			Freight		= b.Freight
		from Gnosis_Integration_Holds_Final A
		inner join Gnosis_Integration_Holds B on B.DataKey = @LastDataKey
		where a.UUID = @UUID
	End

	IF(isnull(@MBLCount,0) = 0)
	Begin
		insert into Gnosis_Integration_MBL_FINAL (UUID, MBL_number, Dropped )
		select UUID, MBL_number, Dropped 
		from Gnosis_Integration_MBL WITH (NOLOCK)
		where UUID = @UUID and DataKey = @LastDataKey
	End
	ELSE
	BEGIN
		Update A set 
			MBL_number	= B.MBL_number,
			Dropped		= B.Dropped
		From Gnosis_Integration_MBL_FINAL A
		inner join Gnosis_Integration_MBL B WITH (NOLOCK)  on A.UUID = B.UUID and B.DataKey = @LastDataKey
		Where A.uuid = @UUID
	END

	IF(isnull(@ShipmentsCount,0) = 0)
	Begin
		insert into Gnosis_Integration_Shipments_Final (UUID, incoming_vessel, incoming_voyage, in_vessel_eta_dt, 
			in_vessel_ata_dt, pod_locode, pod_city, outgoing_vessel, outgoing_voyage, out_vessel_etd_dt, 
			out_vessel_atd_dt, loaded_on_vessel_dt, discharged_dt )
		select distinct @UUID, incoming_vessel, incoming_voyage, in_vessel_eta_dt, 
			in_vessel_ata_dt, pod_locode, pod_city, outgoing_vessel, outgoing_voyage, out_vessel_etd_dt, 
			out_vessel_atd_dt, loaded_on_vessel_dt, discharged_dt
		from Gnosis_Integration_Shipments WITH (NOLOCK)
		where  datakey = @LastDataKey
	END
	ELSE
	BEGIN
		Update A SET
			incoming_vessel		= B.incoming_vessel	,
			incoming_voyage		= B.incoming_voyage,
			in_vessel_eta_dt	= B.in_vessel_eta_dt,
			in_vessel_ata_dt	= B.in_vessel_ata_dt,
			pod_locode			= B.pod_locode,
			pod_city			= B.pod_city,
			outgoing_vessel		= B.outgoing_vessel,
			outgoing_voyage		= B.outgoing_voyage,
			out_vessel_etd_dt	= B.out_vessel_etd_dt,
			out_vessel_atd_dt	= B.out_vessel_atd_dt,
			loaded_on_vessel_dt	= B.loaded_on_vessel_dt,
			discharged_dt		= B.discharged_dt
		From Gnosis_Integration_Shipments_Final A
		inner join Gnosis_Integration_Shipments B on  B.Datakey = @LastDataKey
		where A.UUID = @UUID
	END

	insert into gnosis_integration_mbl_final (UUID, MBL_number, Dropped )
	select distinct A.UUID, M.MBL_number, M.dropped from Gnosis_Integration_Container_Final A
	inner join Gnosis_Integration_MBL M WITH (NOLOCK) on a.LastDataKey = M.DataKey
	Left join gnosis_integration_mbl_final  F WITH (NOLOCK) on A.UUID = F.UUID
	where F.UUID is null

	
	--update RT set ActualDeparture = A.Out_gate_dt,
		
	select A.UUID, A.Container_number, OD.OrderDetailKey, RT.RouteKey, L.LegID,
	A.Out_gate_dt, RT.ActualDeparture,RT.ActualDepartureUpdateMethod
	into #PortOutgateUpdate
	from Gnosis_Integration_Container_Final A WITH (NOLOCK)
	inner join Gnosis_Integration_MBL_FINAL M WITH (NOLOCK) on A.UUID = M.UUID
	inner join OrderDetail OD WITH (NOLOCK) on A.OrderDetailKey = OD.OrderDetailKey
	inner join OrderHeader OH WITH (NOLOCK) on OD.orderkey = OH.OrderKey and M.MBL_number = OH.BillOfLading
	inner join routes RT WITH (NOLOCK) on OD.OrderDetailKey  = RT.OrderDetailKey
	inner join Leg L WITH (NOLOCK) on RT.LegKey = L.LegKey
	where A.UUID= @UUID and L.FromLocation = 'PORT' and A.ContainerStatus = 'Out for Delivery' 
		--and RT.ActualDeparture is null 
		and (RT.ActualDeparture is null  OR RT.ActualDeparture<>A.Out_gate_dt)
		and isnull(RT.IsDryRun,0) = 0

	IF((Select count(1) from #PortOutgateUpdate) > 0)
	Begin
		Update Routes set ActualDeparture = POU.Out_gate_dt, ActualDepartureUpdateMethod = 'Gnosis'
		from Routes RT
		inner join #PortOutgateUpdate POU on RT.RouteKey = POU.RouteKey

		Update OrderDetailStops set ActualPickupDate = POU.Out_gate_dt
		from OrderDetailStops ODS
		inner join #PortOutgateUpdate POU on ODS.FromRouteKey = POU.RouteKey
		---***** Status Update with date    ***---
		IF(SELECT COUNT(1) FROM Routes RT
		inner join #PortOutgateUpdate POU on RT.RouteKey = POU.RouteKey
		AND RT.Status NOT IN (3,5)
		AND ISNULL(RT.driverKey ,0) > 0 AND ISNULL(RT.ChassisNo,'') <> ''  AND 
			ISNULL(RT.ActualDeparture,'1970-01-01 00:00:00.000') <>  '1970-01-01 00:00:00.000')=0
		BEGIN
			Update Routes set [Status]=2
			from Routes RT
			inner join #PortOutgateUpdate POU on RT.RouteKey = POU.RouteKey
			WHERE RT.Status NOT IN (3,5)
		END

		insert into AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey,  CommentType, Comments)
		select Getdate(), 'Gnosis', 'Container', POU.Container_number, POU.OrderDetailKey, 'Text', 
			'Container Leg ' + isnull(POU.LegID,'') + ' Actual pickup updated ' + 
			case when isnull(POU.Out_gate_dt ,'') = '' then 'NA' else 
				FORMAT(convert(Datetime,POU.Out_gate_dt ),'MMM dd, yyyy') + ' ' + 
					+ FORMAT(convert(Datetime,POU.Out_gate_dt ),'hh:mm tt') end
				+' from Gnosis Integration'
		from #PortOutgateUpdate POU
	End
	drop table #PortOutgateUpdate



	select A.UUID, A.Container_number, OD.OrderDetailKey, RT.RouteKey, L.LegID,
	A.Empty_returned_dt, RT.ActualArrival,RT.ActualArrivalUpdateMethod
	into #PortIngateUpdate
	from Gnosis_Integration_Container_Final A WITH (NOLOCK)
	inner join Gnosis_Integration_MBL_FINAL M WITH (NOLOCK) on A.UUID = M.UUID
	inner join OrderDetail OD WITH (NOLOCK) on A.Container_number = OD.ContainerNo 
	inner join OrderHeader OH WITH (NOLOCK) on OD.orderkey = OH.OrderKey and M.MBL_number = OH.BillOfLading
	inner join routes RT WITH (NOLOCK) on OD.OrderDetailKey  = RT.OrderDetailKey
	inner join Leg L WITH (NOLOCK) on RT.LegKey = L.LegKey
	where  A.UUID= @UUID and L.ToLocation = 'PORT' and A.ContainerStatus = 'Empty Returned' 
	--and RT.ActualArrival is null  
	and (RT.ActualArrival is null  OR RT.ActualArrival<>A.Empty_returned_dt)
	and isnull(RT.IsDryRun,0) = 0

	IF((Select count(1) from #PortIngateUpdate) > 0)
	Begin
		Update Routes set ActualArrival = POU.Empty_returned_dt, ActualArrivalUpdateMethod = 'Gnosis'
		from Routes RT
		inner join #PortIngateUpdate POU on RT.RouteKey = POU.RouteKey

		Update OrderDetailStops set ActualDeliveryDate = POU.Empty_returned_dt
		from OrderDetailStops ODS
		inner join #PortIngateUpdate POU on ODS.ToRouteKey = POU.RouteKey

		---***** Status Update with date    ***---
		IF(SELECT COUNT(1) FROM Routes RT
		inner join #PortOutgateUpdate POU on RT.RouteKey = POU.RouteKey
		AND RT.Status <>5
		AND ISNULL(RT.driverKey ,0) > 0 AND ISNULL(RT.ChassisNo,'') <> ''  AND 
			ISNULL(RT.ActualDeparture,'1970-01-01 00:00:00.000') <>  '1970-01-01 00:00:00.000' AND
			ISNULL(RT.ActualArrival,'1970-01-01 00:00:00.000') <> '1970-01-01 00:00:00.000')=0
		BEGIN
			Update Routes set [Status]=3
			from Routes RT
			inner join #PortOutgateUpdate POU on RT.RouteKey = POU.RouteKey
			WHERE RT.Status <>5
		END

		insert into AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey,  CommentType, Comments)
		select Getdate(), 'Gnosis', 'Container', POU.Container_number, POU.OrderDetailKey, 'Text', 
			'Container Leg ' + isnull(POU.LegID,'') + ' Actual Delivery updated ' + 
			case when isnull(POU.Empty_returned_dt ,'') = '' then 'NA' else 
				FORMAT(convert(Datetime,POU.Empty_returned_dt ),'MMM dd, yyyy') + ' ' + 
					+ FORMAT(convert(Datetime,POU.Empty_returned_dt ),'hh:mm tt') end
				+' from Gnosis Integration'
		from #PortIngateUpdate POU
	End


	UPDATE		CF 
	SET			OrderDetailkey = OD.OrderDetailKey
	FROM		Gnosis_Integration_Container_Final CF
	INNER JOIN	Gnosis_Integration_MBL_FINAL MF WITH (NOLOCK) ON CF.UUID = MF.UUID 
	INNER JOIN	OrderDetail OD WITH (NOLOCK) ON CF.Container_number = LTRIM(RTRIM(OD.ContainerNo))  
	INNER JOIN	OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey 
	AND			REPLACE(LTRIM(RTRIM(OH.BillOfLading)),' ','') = LTRIM(RTRIM(MF.MBL_number))
	WHERE		CF.OrderDetailKey IS NULL


	UPDATE		CF 
	SET			OrderDetailKey = OD.OrderDetailKey
	FROM		Gnosis_Integration_Container_Final CF
	INNER JOIN	Gnosis_Integration_MBL_FINAL MF WITH (NOLOCK) ON CF.UUID = MF.UUID 
	INNER JOIN	(SELECT		B.*
				FROM		(SELECT		ContainerNo, MAX(OrderDetailkey) OrderDetailkey
							FROM		OrderDetail WITH (NOLOCK)
							WHERE		Status NOT IN (10,13,12,14,15) AND ISNULL(ContainerNo,'') <> ''
							GROUP BY	ContainerNo) A
				INNER JOIN	OrderDetail B WITH (NOLOCK) On A.OrderDetailkey = B.OrderDetailKey) OD ON CF.Container_number = LTRIM(RTRIM(OD.ContainerNo))  
	INNER JOIN	OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey 
				AND	REPLACE(LTRIM(RTRIM(OH.BillOfLading)),' ','') = LTRIM(RTRIM(MF.MBL_number))
	WHERE		CF.OrderDetailKey <> OD.OrderDetailKey




	DROP TABLE #PortIngateUpdate
END

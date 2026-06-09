/*
Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
set @JsonString = '{"ContainerNo":"HAMU1621223"}'
exec Gnosis_GetContainerAuditLog @UserKey, @JSONString, @Status output, @Reason output
select @Status Status, @Reason Reason
*/

CREATE proc [dbo].[Gnosis_GetContainerAuditLog]
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
)	
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	Declare @OrderDetailKey	int,
			@ContainerNo	varchar(20),
			@UUID			varchar(50),
			@IsDebug		bit = 0

	Declare @SQLReturn varchar(max) = ''

	if(isnull(@JSONString,'') = '')
	Begin
		set @Status = 0
		SET @Reason = 'No Parameter found'
		Return
	End
	
	Select @ContainerNo = ContainerNo
	from OpenJSON(@JsonString, '$')
	WITH (
		ContainerNo				varchar(20)	'$.ContainerNo'
	)

	if(isnull(@ContainerNo,'') = '')
	Begin
		set @Status = 0
		SET @Reason = 'No Parameter found'
		Return
	End

	select @OrderDetailKey = OrderDetailKey
	from OrderDetail WITH (NOLOCK)
	Where ContainerNo = @ContainerNo

	

	select @UUID = UUID 
	from Gnosis_Integration_Container_Final WITH (NOLOCK)
	where Container_number = @ContainerNo

	if Isnull(@UUID,'') <> ''
	Begin
	
		Declare @ContainerStatusChange		varchar(500) = '',
				@ContainerStatus			varchar(500) = '',
				@HoldStatus					varchar(500) = '',
				@HoldStatusCleared			varchar(500) = '',
				@AvailableForPickup			varchar(500) = '',
				@LFDChanged					varchar(500) = '',
				@LFD						varchar(500) = '',
				@LocationTerminalChanged	varchar(500) = '',
				@LocationTerminal			varchar(500) = '',
				@VesselETAChanged			varchar(500) = '',
				@VesselETA					varchar(500) = '',
				@EstimatedDiscDateChanged	varchar(500) = '',
				@VesselATA					varchar(500) = '',
				@DischargeDate				varchar(500) = '',
				@ContainerInTMS				varchar(500) = '',
				@CustomsClearanceDate		varchar(500) = '',
				@OutGateDate				varchar(500) = '',
				@ReturnDate					varchar(500) = ''

		if(isnull(@OrderDetailKey,0) = 0)
		Begin
			SET @ContainerInTMS = 'Container No Not found in TMS'
		End

		--///// Log Fetch
		--// ContainerStatus change

		select ContainerStatus, convert(Datetime, ChangeDate) as changeDate,
		ROW_NUMBER() Over (order by convert(Datetime, ChangeDate) Desc) as RowNum
		into #CSChange
		from (
		Select ContainerStatus, min(Updated_dt) as ChangeDate 
		from Gnosis_Integration_Container C WITH (NOLOCK)
		inner join vGnosis_Container_Status_ALL S WITH (NOLOCK) on C.datakey = S.DataKey
		where C.UUID = @UUID
		group by ContainerStatus
		) A

		IF(@IsDebug =1)
		Begin
			select '#CSChange',* from #CSChange order by RowNum
		End
		if((SElect Count(1) from #CSChange) >= 2)
		Begin
			SElect @ContainerStatusChange = ' from "' + 
			C2.ContainerStatus + '" to : "' + C1.ContainerStatus + '" on ' +  
				FORMAT(C1.ChangeDate,'MMM dd, yyyy') + ', at ' +
				FORMAT(C1.ChangeDate,'hh:mm tt') 
			From #CSChange C1
			inner join #CSChange C2 on 1=1 and C2. rownum = 2
			where C1.Rownum = 1
		End
		Else
		Begin
			SEt @ContainerStatusChange = 'NA'
		End

		if((SElect Count(1) from #CSChange) >= 1)
		Begin
			SElect top 1 @ContainerStatus = ' is "' + ContainerStatus + '" on ' +  
				FORMAT(ChangeDate,'MMM dd, yyyy') + ', at ' +
				FORMAT(ChangeDate,'hh:mm tt') 
			From #CSChange order by Rownum Desc
		End
		Else
		Begin
			SEt @ContainerStatus = 'NA'
		End

		--// Hold Status change
		select HoldStatus, convert(Datetime, ChangeDate) as changeDate, 
			ROW_NUMBER() Over (order by convert(Datetime, ChangeDate) Desc) as RowNum
		into #HSChange
		from (
		Select HoldStatus, min(C.Updated_dt) as ChangeDate 
		from Gnosis_Integration_Container C WITH (NOLOCK)
		inner join vGnosis_Container_HoldStatus H  WITH (NOLOCK) on C.datakey = H.DataKey
		where C.UUID = @UUID
		group by HoldStatus 
		) A

		select HoldTypes, convert(Datetime, ChangeDate) as changeDate, 
			ROW_NUMBER() Over (order by convert(Datetime, ChangeDate) Desc) as RowNum
		into #HTChange
		from (
		Select HoldTypes, min(C.Updated_dt) as ChangeDate 
		from Gnosis_Integration_Container C WITH (NOLOCK)
		inner join vGnosis_Container_HoldStatus H WITH (NOLOCK) on C.datakey = H.DataKey
		where C.UUID = @UUID
		group by HoldTypes 
		) A

		IF(@IsDebug =1)
		Begin
			select '#HSChange',* from #HSChange order by RowNum
			select '#HTChange',* from #HTChange order by RowNum
		End

		if((SElect Count(1) from #HSChange) >= 2)
		Begin
			SElect @HoldStatus = ' from "' + 
			C2.HoldStatus + '" to : "' + C1.HoldStatus + '" on ' +  
				FORMAT(C1.ChangeDate,'MMM dd, yyyy') + ', at ' +
				FORMAT(C1.ChangeDate,'hh:mm tt') 
			From #HSChange C1
			inner join #HSChange C2 on 1=1 and C2. rownum = 2
			where C1.Rownum = 1
		End
		Else
		Begin
			SEt @HoldStatus = 'NA'
		End

		if((SElect Count(1) from #HTChange) >= 2)
		Begin
			SElect @HoldStatusCleared = ' from "' + 
			C2.HoldTypes + '" to : "' + C1.HoldTypes + '" on ' +  
				FORMAT(C1.ChangeDate,'MMM dd, yyyy') + ', at ' +
				FORMAT(C1.ChangeDate,'hh:mm tt') 
			From #HTChange C1
			inner join #HTChange C2 on 1=1 and C2. rownum = 2
			where C1.Rownum = 1
		End
		Else
		Begin
			SEt @HoldStatusCleared = 'NA'
		End

		--// Pickup Available change
		select Available_for_pickup, convert(Datetime, ChangeDate) as changeDate, 
			ROW_NUMBER() Over (order by convert(Datetime, ChangeDate) Desc) as RowNum
		into #PUChange
		from (
		Select Available_for_pickup, min(C.Updated_dt) as ChangeDate 
		from Gnosis_Integration_Container C WITH (NOLOCK)
		where C.UUID = @UUID
		group by Available_for_pickup 
		) A

		IF(@IsDebug =1)
		Begin
			Select '#PUChange',* from #PUChange
		End

		if((SElect Count(1) from #PUChange where Available_for_pickup = 'true' ) = 1)
		Begin
			SElect @AvailableForPickup =  '" on ' +  
				FORMAT(C1.ChangeDate,'MMM dd, yyyy') + ', at ' +
				FORMAT(C1.ChangeDate,'hh:mm tt') 
			From #PUChange C1
			where  Available_for_pickup = 'true'
		End
		Else
		Begin
			SEt @AvailableForPickup = 'NA'
		End

		--// LFD change
		select Last_free_demurrage_day_dt, convert(Datetime, ChangeDate) as changeDate,
		ROW_NUMBER() Over (order by convert(Datetime, ChangeDate) Desc) as RowNum
		into #LFDChange
		from (
		Select Last_free_demurrage_day_dt, min(Updated_dt) as ChangeDate 
		from Gnosis_Integration_Container C WITH (NOLOCK)
		where C.UUID = @UUID
		group by Last_free_demurrage_day_dt
		) A

		IF(@IsDebug =1)
		Begin
			select '#LFDChange',* from #LFDChange order by RowNum
		End
		if((SElect Count(1) from #LFDChange) >= 2)
		Begin
			SElect @LFDChanged = ' from "' + 
				case when isnull(C2.Last_free_demurrage_day_dt ,'') = '' then 'NA' else  
					FORMAT(convert(Datetime,C2.Last_free_demurrage_day_dt ),'MMM dd, yyyy') + ' ' 
					+ FORMAT(convert(Datetime,C2.Last_free_demurrage_day_dt ),'hh:mm tt') end
				+ '" to : "' +
				case when isnull(C1.Last_free_demurrage_day_dt ,'') = '' then 'NA' else  
					FORMAT(convert(Datetime,C1.Last_free_demurrage_day_dt ),'MMM dd, yyyy') + ' ' 
					+ FORMAT(convert(Datetime,C1.Last_free_demurrage_day_dt ),'hh:mm tt') end
				+ '" on ' +  
				FORMAT(C1.ChangeDate,'MMM dd, yyyy') + ', at ' +
				FORMAT(C1.ChangeDate,'hh:mm tt') 
			From #LFDChange C1
			inner join #LFDChange C2 on 1=1 and C2. rownum = 2
			where C1.Rownum = 1
		End
		Else
		Begin
			SEt @LFDChanged = 'NA'
		End

		if((SElect Count(1) from #CSChange) >= 1)
		Begin
			SElect top 1 @LFD = ' is "' + 
				case when isnull(C2.Last_free_demurrage_day_dt ,'') = '' then 'NA' else  
					FORMAT(convert(Datetime,C2.Last_free_demurrage_day_dt ),'MMM dd, yyyy') + ' ' 
					+ FORMAT(convert(Datetime,C2.Last_free_demurrage_day_dt ),'hh:mm tt') end
				+ '" on ' +  
				FORMAT(ChangeDate,'MMM dd, yyyy') + ', at ' +
				FORMAT(ChangeDate,'hh:mm tt') 
			From #LFDChange C2 order by Rownum Desc
		End
		Else
		Begin
			SEt @LFD = 'NA'
		End

		--// Location Terminal change

		select Location_at_terminal, convert(Datetime, ChangeDate) as changeDate,
		ROW_NUMBER() Over (order by convert(Datetime, ChangeDate) Desc) as RowNum
		into #LTChange
		from (
		Select Location_at_terminal, min(Updated_dt) as ChangeDate 
		from Gnosis_Integration_Container C WITH (NOLOCK)
		where C.UUID = @UUID
		group by Location_at_terminal
		) A

		IF(@IsDebug =1)
		Begin
			select '#LTChange',* from #LTChange order by RowNum
		End
		if((SElect Count(1) from #LFDChange) >= 2)
		Begin
			SElect @LocationTerminalChanged = ' from "' + 
			C2.Location_at_terminal + '" to : "' + C1.Location_at_terminal + '" on ' +  
				FORMAT(C1.ChangeDate,'MMM dd, yyyy') + ', at ' +
				FORMAT(C1.ChangeDate,'hh:mm tt') 
			From #LTChange C1
			inner join #LTChange C2 on 1=1 and C2. rownum = 2
			where C1.Rownum = 1
		End
		Else
		Begin
			SEt @LocationTerminalChanged = 'NA'
		End

		if((SElect Count(1) from #CSChange) >= 1)
		Begin
			SElect top 1 @LocationTerminal = ' is "' + isnull(Location_at_terminal,'') + '" on ' +  
				FORMAT(ChangeDate,'MMM dd, yyyy') + ', at ' +
				FORMAT(ChangeDate,'hh:mm tt') 
			From #LTChange order by Rownum Desc
		End
		Else
		Begin
			SEt @LocationTerminal = 'NA'
		End

		--// Vessel ETA change
		select Vessel_eta_dt, convert(Datetime, ChangeDate) as changeDate,
		ROW_NUMBER() Over (order by convert(Datetime, ChangeDate) Desc) as RowNum
		into #VEChange
		from (
		Select Vessel_eta_dt, min(Updated_dt) as ChangeDate 
		from Gnosis_Integration_Container C WITH (NOLOCK)
		where C.UUID = @UUID
		group by Vessel_eta_dt
		) A

		IF(@IsDebug =1)
		Begin
			select '#VEChange',* from #VEChange order by RowNum
		End
		if((SElect Count(1) from #LFDChange) >= 2)
		Begin
			SElect @VesselETAChanged = ' from "' + 
				case when isnull(C2.Vessel_eta_dt ,'') = '' then 'NULL' else  
					FORMAT(convert(Datetime,C2.Vessel_eta_dt ),'MMM dd, yyyy') + ' ' 
					+ FORMAT(convert(Datetime,C2.Vessel_eta_dt ),'hh:mm tt') end
				+ '" to : "' + 
				case when isnull(C1.Vessel_eta_dt ,'') = '' then 'NULL' else  
					FORMAT(convert(Datetime,C1.Vessel_eta_dt ),'MMM dd, yyyy') + ' ' 
					+ FORMAT(convert(Datetime,C1.Vessel_eta_dt ),'hh:mm tt') end
				+ '" on ' +  
				FORMAT(C1.ChangeDate,'MMM dd, yyyy') + ', at ' +
				FORMAT(C1.ChangeDate,'hh:mm tt') 
			From #VEChange C1
			inner join #VEChange C2 on 1=1 and C2. rownum = 2
			where C1.Rownum = 1
		End
		Else
		Begin
			SEt @VesselETAChanged = 'NA'
		End

		if((SElect Count(1) from #VEChange) >= 1)
		Begin
			SElect top 1 @VesselETA = ' is "' + 
				case when isnull(C2.Vessel_eta_dt,'') = '' then 'NULL' else  
					FORMAT(convert(Datetime,C2.Vessel_eta_dt),'MMM dd, yyyy') + ' ' 
					+ FORMAT(convert(Datetime,C2.Vessel_eta_dt),'hh:mm tt') end
				+ '" on ' +  
				FORMAT(ChangeDate,'MMM dd, yyyy') + ', at ' +
				FORMAT(ChangeDate,'hh:mm tt') 
			From #VEChange C2 order by Rownum Desc
		End
		Else
		Begin
			SEt @VesselETA = 'NA'
		End

		--// Estimated Discharge Date change
		select Gnosis_estimated_discharge_dt, convert(Datetime, ChangeDate) as changeDate,
		ROW_NUMBER() Over (order by convert(Datetime, ChangeDate) Desc) as RowNum
		into #ETDChange
		from (
		Select Gnosis_estimated_discharge_dt, min(Updated_dt) as ChangeDate 
		from Gnosis_Integration_Container C WITH (NOLOCK)
		where C.UUID = @UUID
		group by Gnosis_estimated_discharge_dt
		) A

		IF(@IsDebug =1)
		Begin
			select '#ETDChange',* from #ETDChange order by RowNum
		End

		if((SElect Count(1) from #ETDChange) >= 2)
		Begin
			SElect @EstimatedDiscDateChanged = ' from "' +
			case when isnull(C2.Gnosis_estimated_discharge_dt,'') = '' then 'NULL' else  
					FORMAT(convert(Datetime,C2.Gnosis_estimated_discharge_dt),'MMM dd, yyyy') + ' ' 
					+ FORMAT(convert(Datetime,C2.Gnosis_estimated_discharge_dt),'hh:mm tt') end
			+ '" to : "' + 
				case when isnull(C1.Gnosis_estimated_discharge_dt,'') = '' then 'NULL' else  
					FORMAT(convert(Datetime,C1.Gnosis_estimated_discharge_dt),'MMM dd, yyyy') + ' ' 
					+ FORMAT(convert(Datetime,C1.Gnosis_estimated_discharge_dt),'hh:mm tt') end
				+ '" on ' +  
				FORMAT(C1.ChangeDate,'MMM dd, yyyy') + ', at ' +
				FORMAT(C1.ChangeDate,'hh:mm tt') 
			From #ETDChange C1
			inner join #ETDChange C2 on 1=1 and C2. rownum = 2
			where C1.Rownum = 1
		End
		Else
		Begin
			SEt @EstimatedDiscDateChanged = 'NA'
		End


		--// Discharge Date 
		select Discharged_dt, convert(Datetime, ChangeDate) as changeDate,
		ROW_NUMBER() Over (order by convert(Datetime, ChangeDate) Desc) as RowNum
		into #DiscDtChange
		from (
		Select Discharged_dt, min(Updated_dt) as ChangeDate 
		from Gnosis_Integration_Container C WITH (NOLOCK)
		where C.UUID = @UUID
		group by Discharged_dt
		) A

		IF(@IsDebug =1)
		Begin
			select '#DiscDtChange', * from #DiscDtChange order by RowNum
		End

		if((SElect Count(1) from #VEChange) >= 1)
		Begin
			SElect top 1 @DischargeDate = ' is "' +
				case when isnull(Discharged_dt,'') = '' then 'NULL' else  
					FORMAT(convert(Datetime,Discharged_dt),'MMM dd, yyyy') + ' ' 
					+ FORMAT(convert(Datetime,Discharged_dt),'hh:mm tt') end
			+ '" on ' +  
				FORMAT(ChangeDate,'MMM dd, yyyy') + ', at ' +
				FORMAT(ChangeDate,'hh:mm tt') 
			From #DiscDtChange order by Rownum 
		End
		Else
		Begin
			SEt @DischargeDate = 'NA'
		End

		--// Vessel ETA Date 
		select Vessel_ata_dt, convert(Datetime, ChangeDate) as changeDate,
		ROW_NUMBER() Over (order by convert(Datetime, ChangeDate) Desc) as RowNum
		into #VETADtChange
		from (
		Select Vessel_ata_dt, min(Updated_dt) as ChangeDate 
		from Gnosis_Integration_Container C WITH (NOLOCK)
		where C.UUID = @UUID
		group by Vessel_ata_dt
		) A

		IF(@IsDebug =1)
		Begin
			select '#VETADtChange', * from #VETADtChange order by RowNum
		End
		
		if((SElect Count(1) from #VETADtChange) >= 1)
		Begin
			SElect top 1 @VesselATA = ' is "' 
				+ case when isnull(Vessel_ata_dt,'') = '' then 'NULL' else  
					FORMAT(convert(Datetime,Vessel_ata_dt),'MMM dd, yyyy') + ' ' 
					+ FORMAT(convert(Datetime,Vessel_ata_dt),'hh:mm tt') end
				+ '" on ' +  
				FORMAT(ChangeDate,'MMM dd, yyyy') + ', at ' +
				FORMAT(ChangeDate,'hh:mm tt') 
			From #VETADtChange order by Rownum 
		End
		Else
		Begin
			SEt @VesselATA = 'NA'
		End

		--// Customs Clearance Date
		select Customs_clearance_dt, convert(Datetime, ChangeDate) as changeDate,
		ROW_NUMBER() Over (order by convert(Datetime, ChangeDate) Desc) as RowNum
		into #CCDChange
		from (
		Select Customs_clearance_dt, min(Updated_dt) as ChangeDate 
		from Gnosis_Integration_Container C WITH (NOLOCK)
		where C.UUID = @UUID
		group by Customs_clearance_dt
		) A

		IF(@IsDebug =1)
		Begin
			select '#CCDChange',* from #CCDChange order by RowNum
		End

		if((SElect Count(1) from #CCDChange) >= 1)
		Begin
			SElect top 1 @CustomsClearanceDate = ' is "' + 
				case when isnull(C2.Customs_clearance_dt ,'') = '' then 'NA' else  
					FORMAT(convert(Datetime,C2.Customs_clearance_dt ),'MMM dd, yyyy') + ' ' 
					+ FORMAT(convert(Datetime,C2.Customs_clearance_dt ),'hh:mm tt') end
				+ '" on ' +  
				FORMAT(ChangeDate,'MMM dd, yyyy') + ', at ' +
				FORMAT(ChangeDate,'hh:mm tt') 
			From #CCDChange C2 order by Rownum Desc
		End
		Else
		Begin
			SEt @CustomsClearanceDate = 'NA'
		End

		--// Out Gate Date
		select Out_gate_dt, convert(Datetime, ChangeDate) as changeDate,
		ROW_NUMBER() Over (order by convert(Datetime, ChangeDate) Desc) as RowNum
		into #OutDtChange
		from (
		Select Out_gate_dt, min(Updated_dt) as ChangeDate 
		from Gnosis_Integration_Container C WITH (NOLOCK)
		where C.UUID = @UUID
		group by Out_gate_dt
		) A

		IF(@IsDebug =1)
		Begin
			select '#OutDtChange',* from #OutDtChange order by RowNum
		End

		if((SElect Count(1) from #OutDtChange) >= 1)
		Begin
			SElect top 1 @OutGateDate = ' is "' + 
				case when isnull(C2.Out_gate_dt ,'') = '' then 'NA' else  
					FORMAT(convert(Datetime,C2.Out_gate_dt ),'MMM dd, yyyy') + ' ' 
					+ FORMAT(convert(Datetime,C2.Out_gate_dt ),'hh:mm tt') end
				+ '" on ' +  
				FORMAT(ChangeDate,'MMM dd, yyyy') + ', at ' +
				FORMAT(ChangeDate,'hh:mm tt') 
			From #OutDtChange C2 order by Rownum Desc
		End
		Else
		Begin
			SEt @OutGateDate = 'NA'
		End

		--// Return Date
		select Empty_returned_dt, convert(Datetime, ChangeDate) as changeDate,
		ROW_NUMBER() Over (order by convert(Datetime, ChangeDate) Desc) as RowNum
		into #ReturnDtChange
		from (
		Select Empty_returned_dt, min(Updated_dt) as ChangeDate 
		from Gnosis_Integration_Container C WITH (NOLOCK)
		where C.UUID = @UUID
		group by Empty_returned_dt
		) A

		IF(@IsDebug =1)
		Begin
			select '#ReturnDtChange',* from #ReturnDtChange order by RowNum
		End

		if((SElect Count(1) from #OutDtChange) >= 1)
		Begin
			SElect top 1 @ReturnDate = ' is "' + 
				case when isnull(C2.Empty_returned_dt ,'') = '' then 'NA' else  
					FORMAT(convert(Datetime,C2.Empty_returned_dt ),'MMM dd, yyyy') + ' ' 
					+ FORMAT(convert(Datetime,C2.Empty_returned_dt ),'hh:mm tt') end
				+ '" on ' +  
				FORMAT(ChangeDate,'MMM dd, yyyy') + ', at ' +
				FORMAT(ChangeDate,'hh:mm tt') 
			From #ReturnDtChange C2 order by Rownum Desc
		End
		Else
		Begin
			SEt @ReturnDate = 'NA'
		End


		drop table #CSChange
		drop table #HSChange 
		drop table #HTChange
		drop table #LFDChange
		drop table #LTChange
		drop table #PUChange
		drop table #DiscDtChange
		drop table #ETDChange
		drop table #VEChange
		drop table #VETADtChange
		drop table #CCDChange

		set @Status = 1
		SEt @Reason = 'SUCCESS'
		Select	@ContainerStatusChange		as ContainerStatusChange,
				@ContainerStatus			as ContainerStatus,
				@HoldStatus					as HoldStatus,
				@HoldStatusCleared			as HoldStatusCleared,	
				@AvailableForPickup			as AvailableForPickup,
				@LFDChanged					as LFDChanged,
				@LFD						as LFD,
				@LocationTerminalChanged	as LocationTerminalChanged,
				@LocationTerminal			as LocationTerminal,
				@VesselETAChanged			as VesselETAChanged,
				@VesselETA					as VesselETA,
				@EstimatedDiscDateChanged	as EstimatedDiscDateChanged,
				@VesselATA					as VesselATA,
				@DischargeDate				as DischargeDate,
				@CustomsClearanceDate		as CustomsClearanceDate,
				@ContainerInTMS				As ContainerInTMS,
				@ReturnDate					As EmptyReturnDate,
				@OutGateDate				As OutGateDate
		FOR JSON PATH
	end
	else
	Begin
		set @Status = 0
		SET @Reason = 'Container No Not found in GNOSIS'
		Return
	End
End
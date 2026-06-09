


CREATE View [dbo].[vGnosis_Container_Status_ALL]
as
select  
		Case wHEN Dropped = 'true' THEN 'Dropped'
		When isnull(Vessel_atd_dt,'') = '' and isnull(Empty_returned_dt,'')= '' 
			and isnull(Out_gate_dt,'') = ''   then 'At Origin'
		When Loaded_on_vessel_dt = MaxDate then 'Loaded on Vessel'
		when Empty_returned_dt = MaxDate then 'Empty Returned' -- Return Date
		When Out_gate_dt = MaxDate then 'Out for Delivery' -- Pickup Date
		when Rail_ata_dt = MaxDate then 'At Rail Terminal'
		when Rail_departed_dt = MaxDate then 'On Rail'
		When Discharged_dt = MaxDate then 'At Ocean Terminal'
		when Vessel_ata_dt = MaxDate then 'Awaiting Discharge' --OR Vessel_eta_dt = MaxDate then 'Awaiting Discharge'
		When Vessel_etd_dt = MaxDate OR Vessel_atd_dt = MaxDate then 'On Water' --
		When In_gate_dt  = MaxDate then 'Ready to Load'
		else 'NA' end as ContainerStatus, A.*
From (
SELECT distinct C.UUID, C.DataKey, C.Empty_returned_dt, c.Out_gate_dt, c.Rail_ata_dt, Rail_departed_dt,
				c.Discharged_dt, c.Vessel_ata_dt,  C.Loaded_on_vessel_dt, C.In_gate_dt,Vessel_atd_dt,
				C.Vessel_etd_dt,   Maxdate, m.Dropped
FROM			Gnosis_Integration_Container C with (NOLOCK)
LEft join		Gnosis_Integration_MBL M with (NOLOCK) on C.DataKey = M.DataKey
INNER JOIN		(SELECT  DataKey, MAX(UpdateDate) MaxDate
				FROM Gnosis_Integration_Container with (NOLOCK)
				UNPIVOT ( UpdateDate FOR DateVal IN ( Empty_returned_dt, Out_gate_dt, Rail_ata_dt, Rail_departed_dt,
					Discharged_dt, Vessel_ata_dt, Loaded_on_vessel_dt, In_gate_dt,Vessel_atd_dt,
					 Vessel_etd_dt
				) ) AS u
				Group by DataKey
				) B On C.DataKey = B.DataKey
) A

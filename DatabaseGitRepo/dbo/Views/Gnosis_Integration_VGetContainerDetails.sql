CREATE VIEW [dbo].[Gnosis_Integration_VGetContainerDetails] -- SELECT * FROM Gnosis_Integration_VGetContainerDetails WHERE Container_Number = 'GAOU6974889'
AS
SELECT			DataKey,A.RecordKey,A.UUID,A.Container_number,Container_journey_start_key,Seal_no,Container_type,Length,Weight,Empty_out_dt,In_gate_dt,Early_receive_dt
				,Cut_off_dt,Out_gate_dt,Port_eta_dt,Gnosis_vessel_eta_dt,Gnosis_estimated_discharge_dt
				Gnosis_rail_eta_dt,Vessel_eta_dt,Vessel_etd_dt,Vessel_ata_dt,Vessel_atd_dt,Discharged_dt,Empty_returned_dt,Pod_locode,Pod_city,Pod_terminal_name,Pod_terminal_firms_code,Pol_locode
				,Pol_city,Pol_terminal_name,Pol_terminal_firms_code,Por_locode,Por_city,Ocean_carrier_name,Ocean_carrier_scac,Mother_vessel,Mother_vessel_imo
				,Mother_voyage,Motherload_dt,Current_vessel,Current_vessel_imo,First_vessel
				,First_vessel_imo,Location_at_terminal,Is_railing,Rail_eta_dt,Rail_ata_dt,Rail_departed_dt,Rail_discharged_dt,Rail_terminal
				,Rail_terminal_firms_code,Rail_notify_dt,Pickup_number,Available_dt,Final_dest_locode
				,Final_dest_city,Last_free_demurrage_day_dt,Last_free_detention_day_dt,Estd_last_free_demurrage_day_dt,Demurrage_amount,Estd_demurrage_amount,Estd_last_free_detention_day_dt,Estd_detention_amount
				,Carrier_release_dt,Customs_clearance_dt,Available_for_pickup,Loaded_on_vessel_dt,Pickup_appointment_dt,A.Updated_dt,Chassis_number,Customer_tag,Carrier_contract,Gnosis_estimated_discharge_dt
				,Custom_detention_demurrage_calc,Distribution_center,Drayage_carrier
FROm			Gnosis_Integration_Container A WITH (NOLOCK) 
INNER JOIN		(SELECT	 UUID,	Container_Number, MAX(RecordKey) RecordKey, MAX(Updated_dt)Updated_dt 
				FROM		Gnosis_Integration_Container  WITH (NOLOCK)
				GROUP By	UUID, Container_Number) B 
				ON A.UUID = B.UUID AND A.Container_Number = B. Container_Number  AND A.RecordKey = B.RecordKey
				AND A.Updated_dt = B.Updated_dt

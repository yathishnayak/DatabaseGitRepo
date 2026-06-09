


CREATE PROCEDURE [dbo].[Gnosis_Export_Insert_BookingDetails_MovetoFinal]

AS

BEGIN
	

	INSERT INTO Gnosis_Export_BookingDetails_Final
				(uuid,booking_number,num_of_supplier_containers,num_containers,por_cargo_cut_off_dt,por_early_receive_dt,cargo_cut_off_dt,doc_cut_off,early_receive_dt,first_vessel
				,First_voyage,vessel_etb_pol_dt,vessel_eta_pol_dt,vessel_etd_pol_dt,pol_locode,pol_city,pol_terminal_name,pol_terminal_firms_code,cancelled,custom_columns,containers
				,carrier_scac,carrier_name,carrier_type,CreatedDate )
	SELECT		A.uuid,A.booking_number,A.num_of_supplier_containers,A.num_containers,A.por_cargo_cut_off_dt,A.por_early_receive_dt,A.cargo_cut_off_dt,A.doc_cut_off,A.early_receive_dt,A.first_vessel
				,A.First_voyage,A.vessel_etb_pol_dt,A.vessel_eta_pol_dt,A.vessel_etd_pol_dt,A.pol_locode,A.pol_city,A.pol_terminal_name,A.pol_terminal_firms_code,A.cancelled,A.custom_columns,A.containers
				,A.carrier_scac,A.carrier_name,A.carrier_type,GETDATE() 
	FROM		Gnosis_Export_BookingDetails A  WITH (NOLOCK)
	LEFT JOIN	Gnosis_Export_BookingDetails_Final B  WITH (NOLOCK) On A.uuid = B.uuid
	WHERE		B.uuid IS NULL

END

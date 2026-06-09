


CREATE PROCEDURE [dbo].[Gnosis_Export_Insert_TrackingRequestBookingStatus]
(
		-- @JsonData NVARCHAR(MAX) = '[{"uuid":"485a7ea2-024f-45aa-a8d3-eb902f8aa43e","booking_number":"DALA32094500","num_of_supplier_containers":null,"tracking_status":"Successful","created_dt":"2024-07-11T15:50:30","booking":{"uuid":"485a7ea2-024f-45aa-a8d3-eb902f8aa43e","booking_number":"DALA32094500","num_of_supplier_containers":null,"num_containers":1,"cargo_cut_off_dt":"2024-07-19T16:00:00","doc_cut_off":null,"early_receive_dt":"2024-07-16T07:00:00","first_vessel":"MOL CREATION","first_voyage":"092W","vessel_etb_pol_dt":"2024-07-21T04:00:00","vessel_eta_pol_dt":null,"vessel_etd_pol_dt":"2024-07-26T05:00:00","vessel_eta_pod_dt":null,"pol_locode":"USLAX","pol_city":"Los Angeles, US","pol_terminal_name":"TraPac Terminal","pol_terminal_firms_code":"Y258","created_dt":"2024-07-11T15:50:30"}},{"uuid":"74d0bb00-5914-4141-9932-7308d051ebed","booking_number":"RICEZ5397700","num_of_supplier_containers":null,"tracking_status":"Failure","created_dt":"2024-07-11T09:04:50","booking":{"uuid":"74d0bb00-5914-4141-9932-7308d051ebed","booking_number":"RICEZ5397700","num_of_supplier_containers":null,"num_containers":null,"cargo_cut_off_dt":null,"doc_cut_off":null,"early_receive_dt":null,"first_vessel":null,"first_voyage":null,"vessel_etb_pol_dt":null,"vessel_eta_pol_dt":null,"vessel_etd_pol_dt":null,"vessel_eta_pod_dt":null,"pol_locode":null,"pol_city":null,"pol_terminal_name":null,"pol_terminal_firms_code":null,"created_dt":"2024-07-11T09:04:50"}}]'
	@requestSent NVARCHAR(MAX) = '' ,
	@responseRcvd	NVARCHAR(MAX) = '[{"uuid":"485a7ea2-024f-45aa-a8d3-eb902f8aa43e","booking_number":"DALA32094500","num_of_supplier_containers":null,"tracking_status":"Successful","created_dt":"2024-07-11T15:50:30","booking":{"uuid":"485a7ea2-024f-45aa-a8d3-eb902f8aa43e","booking_number":"DALA32094500","num_of_supplier_containers":null,"num_containers":1,"cargo_cut_off_dt":"2024-07-19T16:00:00","doc_cut_off":null,"early_receive_dt":"2024-07-16T07:00:00","first_vessel":"MOL CREATION","first_voyage":"092W","vessel_etb_pol_dt":"2024-07-21T04:00:00","vessel_eta_pol_dt":null,"vessel_etd_pol_dt":"2024-07-26T05:00:00","vessel_eta_pod_dt":null,"pol_locode":"USLAX","pol_city":"Los Angeles, US","pol_terminal_name":"TraPac Terminal","pol_terminal_firms_code":"Y258","created_dt":"2024-07-11T15:50:30"}},{"uuid":"74d0bb00-5914-4141-9932-7308d051ebed","booking_number":"RICEZ5397700","num_of_supplier_containers":null,"tracking_status":"Failure","created_dt":"2024-07-11T09:04:50","booking":{"uuid":"74d0bb00-5914-4141-9932-7308d051ebed","booking_number":"RICEZ5397700","num_of_supplier_containers":null,"num_containers":null,"cargo_cut_off_dt":null,"doc_cut_off":null,"early_receive_dt":null,"first_vessel":null,"first_voyage":null,"vessel_etb_pol_dt":null,"vessel_eta_pol_dt":null,"vessel_etd_pol_dt":null,"vessel_eta_pod_dt":null,"pol_locode":null,"pol_city":null,"pol_terminal_name":null,"pol_terminal_firms_code":null,"created_dt":"2024-07-11T09:04:50"}}]'

)

AS

BEGIN

	DECLARE @TrackingBookingStatusKey INT = 0

	INSERT INTO		Gnosis_Export_TrackingBookingStatusRequestResponse
					(RequestSent,ResponseRcvd,CreatedDate)
	SELECT			@requestSent,@responseRcvd, GETDATE()

	SET @TrackingBookingStatusKey = @@IDENTITY


	
	CREATE TABLE #TrackingRequestBookingStatus
(
	uuid						VARCHAR(50),
	booking_number				VARCHAR(50),
	num_of_supplier_containers	VARCHAR(20),
	tracking_status				VARCHAR(20),
	num_containers				VARCHAR(20),
	cargo_cut_off_dt			VARCHAR(50),
	doc_cut_off					VARCHAR(20),
	early_receive_dt			VARCHAR(20),
	first_vessel				VARCHAR(20),
	first_voyage				VARCHAR(20),
	vessel_etb_pol_dt			VARCHAR(20),
	vessel_eta_pol_dt			VARCHAR(20),
	vessel_etd_pol_dt			VARCHAR(20),
	vessel_eta_pod_dt			VARCHAR(20),
	pol_locode					VARCHAR(20),
	pol_city					VARCHAR(20),
	pol_terminal_name			VARCHAR(50),
	pol_terminal_firms_code		VARCHAR(20),
	created_dt					VARCHAR(20)

)



	INSERT INTO		#TrackingRequestBookingStatus
					(uuid,booking_number,num_of_supplier_containers,tracking_status,num_containers,cargo_cut_off_dt,doc_cut_off,early_receive_dt,first_vessel,first_voyage
					,vessel_etb_pol_dt,vessel_eta_pol_dt,vessel_etd_pol_dt,vessel_eta_pod_dt,pol_locode,pol_city,pol_terminal_name,pol_terminal_firms_code,created_dt)
	SELECT			uuid,booking_number,num_of_supplier_containers,tracking_status,num_containers,cargo_cut_off_dt,doc_cut_off,early_receive_dt,first_vessel,first_voyage
					,vessel_etb_pol_dt,vessel_eta_pol_dt,vessel_etd_pol_dt,vessel_eta_pod_dt,pol_locode,pol_city,pol_terminal_name,pol_terminal_firms_code,created_dt
	FROM			OPENJSON(@responseRcvd, '$')
					WITH	(uuid						VARCHAR(50)		'$.uuid',
							booking_number				VARCHAR(50)		'$.booking_number',
							num_of_supplier_containers	VARCHAR(20)		'$.num_of_supplier_containers',
							tracking_status				VARCHAR(20)		'$.tracking_status',
							num_containers				VARCHAR(20)		'$.booking.num_containers',
							cargo_cut_off_dt			VARCHAR(50)		'$.booking.cargo_cut_off_dt',
							doc_cut_off					VARCHAR(20)		'$.booking.doc_cut_off',
							early_receive_dt			VARCHAR(20)		'$.booking.early_receive_dt',
							first_vessel				VARCHAR(20)		'$.booking.first_vessel',
							first_voyage				VARCHAR(20)		'$.booking.first_voyage',
							vessel_etb_pol_dt			VARCHAR(20)		'$.booking.vessel_etb_pol_dt',
							vessel_eta_pol_dt			VARCHAR(20)		'$.booking.vessel_eta_pol_dt',
							vessel_etd_pol_dt			VARCHAR(20)		'$.booking.vessel_etd_pol_dt',
							vessel_eta_pod_dt			VARCHAR(20)		'$.booking.vessel_eta_pod_dt',
							pol_locode					VARCHAR(20)		'$.booking.pol_locode',
							pol_city					VARCHAR(20)		'$.booking.pol_city',
							pol_terminal_name			VARCHAR(50)		'$.booking.pol_terminal_name',
							pol_terminal_firms_code		VARCHAR(20)		'$.booking.pol_terminal_firms_code',
							created_dt					VARCHAR(20)		'$.booking.created_dt'
							)
	


	INSERT INTO		Gnosis_Export_TrackingRequestBookingStatus
					(TrackingBookingStatusKey,uuid,booking_number,num_of_supplier_containers,tracking_status,num_containers,cargo_cut_off_dt,doc_cut_off,early_receive_dt,first_vessel,first_voyage
					,vessel_etb_pol_dt,vessel_eta_pol_dt,vessel_etd_pol_dt,vessel_eta_pod_dt,pol_locode,pol_city,pol_terminal_name,pol_terminal_firms_code,created_dt, Createddate)
	SELECT			@TrackingBookingStatusKey,A.uuid,A.booking_number,A.num_of_supplier_containers,A.tracking_status,A.num_containers,A.cargo_cut_off_dt,A.doc_cut_off,A.early_receive_dt,A.first_vessel,A.first_voyage
					,A.vessel_etb_pol_dt,A.vessel_eta_pol_dt,A.vessel_etd_pol_dt,A.vessel_eta_pod_dt,A.pol_locode,A.pol_city,A.pol_terminal_name,A.pol_terminal_firms_code,A.created_dt, GETDATE()
	FROM			#TrackingRequestBookingStatus A 
	LEFT JOIN		Gnosis_Export_TrackingRequestBookingStatus B  WITH (NOLOCK) ON A.booking_number = B.booking_number AND A.uuid = B.uuid
	WHERE			B.booking_number IS NULL

	-- SELECT * FROM Gnosis_Export_TrackingRequestBookingStatus

	-- TRUNCATE TABLE Gnosis_Export_TrackingRequestBookingStatus

END

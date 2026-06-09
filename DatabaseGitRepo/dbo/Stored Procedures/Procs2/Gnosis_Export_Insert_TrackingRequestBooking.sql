


CREATE PROCEDURE [dbo].[Gnosis_Export_Insert_TrackingRequestBooking]
(
	-- @JsonData NVARCHAR(MAX) = '{"created_booking_tracking_requests":[{"tracking_request_uuid":"74d0bb00-5914-4141-9932-7308d051ebed","booking_number":"RICEZ5397700","booking_uuid":"74d0bb00-5914-4141-9932-7308d051ebed","export_containers_uuids":[],"num_of_supplier_containers":null,"message":"Tracking request for booking number: RICEZ5397700 already exists","carrier_scac":"ONEY","pol_locode":null,"pol_firms_code":null,"por_locode":null,"por_terminal_code":null,"por_cargo_cut_off_dt":null,"por_early_receiving_dt":null},{"tracking_request_uuid":"f1e68cb7-0d4f-4d66-93bd-043329e00e40","booking_number":"YCH24122154","booking_uuid":"f1e68cb7-0d4f-4d66-93bd-043329e00e40","export_containers_uuids":[],"num_of_supplier_containers":null,"message":"Tracking request for booking number: YCH24122154 already exists","carrier_scac":"ONEY","pol_locode":null,"pol_firms_code":null,"por_locode":null,"por_terminal_code":null,"por_cargo_cut_off_dt":null,"por_early_receiving_dt":null}]}'
	-- @JsonData NVARCHAR(MAX) = '{"created_booking_tracking_requests":[{"tracking_request_uuid":"b1a97867-cb67-4840-aba9-ebf3a938e373","booking_number":"NAM6742143","booking_uuid":"b1a97867-cb67-4840-aba9-ebf3a938e373","export_containers_uuids":[],"num_of_supplier_containers":null,"message":"Success","carrier_scac":"COSU","pol_locode":null,"pol_firms_code":null,"por_locode":null,"por_terminal_code":null,"por_cargo_cut_off_dt":null,"por_early_receiving_dt":null}]}'
	--@JsonData NVARCHAR(MAX) = '{"created_booking_tracking_requests":[{"tracking_request_uuid":"b1a97867-cb67-4840-aba9-ebf3a938e373","booking_number":"NAM6742143","booking_uuid":"b1a97867-cb67-4840-aba9-ebf3a938e373","export_containers_uuids":[],"num_of_supplier_containers":null,"message":"Tracking request for booking number: NAM6742143 already exists","carrier_scac":"COSU","pol_locode":null,"pol_firms_code":null,"por_locode":null,"por_terminal_code":null,"por_cargo_cut_off_dt":null,"por_early_receiving_dt":null}]}'
	@requestSent NVARCHAR(MAX) = '' ,
	@responseRcvd	NVARCHAR(MAX) = '{"created_booking_tracking_requests":[{"tracking_request_uuid":"b1a97867-cb67-4840-aba9-ebf3a938e373","booking_number":"NAM6742143","booking_uuid":"b1a97867-cb67-4840-aba9-ebf3a938e373","export_containers_uuids":[],"num_of_supplier_containers":null,"message":"Tracking request for booking number: NAM6742143 already exists","carrier_scac":"COSU","pol_locode":null,"pol_firms_code":null,"por_locode":null,"por_terminal_code":null,"por_cargo_cut_off_dt":null,"por_early_receiving_dt":null}]}'

)

AS

BEGIN
	
	DECLARE @TrackingBookingKey INT = 0

	INSERT INTO		Gnosis_Export_TrackingBookingRequestResponse
					(RequestSent,ResponseRcvd,CreatedDate)
	SELECT			@requestSent,@responseRcvd, GETDATE()

	SET @TrackingBookingKey = @@IDENTITY
	
	CREATE TABLE #TrackingRequestBookingTemp
	(
		Tracking_request_uuid	VARCHAR(50) NULL,
		Booking_number			VARCHAR(50) NULL,
		Booking_uuid			VARCHAR(50) NULL,
		Returnmessage			VARCHAR(500) NULL,
		Carrier_scac			VARCHAR(20) NULL
	)


	INSERT INTO		#TrackingRequestBookingTemp
					(Tracking_request_uuid,Booking_number,Booking_uuid,Returnmessage,Carrier_scac)
	SELECT			tracking_request_uuid,booking_number,Booking_uuid,RTNMessage,carrier_scac
	FROM			OPENJSON(@responseRcvd, '$.created_booking_tracking_requests')
					WITH	(tracking_request_uuid		VARCHAR(50)		'$.tracking_request_uuid',
							booking_number				VARCHAR(50)		'$.booking_number',
							Booking_uuid				VARCHAR(50)		'$.booking_uuid',
							RTNMessage					VARCHAR(500)	'$.message',
							carrier_scac				VARCHAR(20)		'$.carrier_scac')
	


	INSERT INTO		Gnosis_Export_TrackingRequestBooking
					(TrackingBookingKey,Tracking_request_uuid,Booking_number,Booking_uuid,Returnmessage,Carrier_scac, CreatedDate)
	SELECT			@TrackingBookingKey, A.Tracking_request_uuid,A.Booking_number,A.Booking_uuid,A.Returnmessage,A.Carrier_scac, GETDATE() 
	FROM			#TrackingRequestBookingTemp A
	LEFT JOIN		Gnosis_Export_TrackingRequestBooking B  WITH (NOLOCK) ON A.Tracking_request_uuid = B.Tracking_request_uuid AND A.Booking_number = B.Booking_number AND A.Carrier_scac = B.Carrier_scac
					AND	ISNULL(A.Returnmessage,'') = ISNULL(B.Returnmessage,'')
	WHERE			B.Returnmessage IS NULL

	-- SELECT * FROM Gnosis_Export_TrackingRequestBooking

	-- TRUNCATE TABLE Gnosis_Export_TrackingRequestBooking

END

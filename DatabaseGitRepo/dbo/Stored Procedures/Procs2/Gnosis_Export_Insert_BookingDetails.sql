


CREATE PROCEDURE [dbo].[Gnosis_Export_Insert_BookingDetails]
(
	-- @JsonData NVARCHAR(MAX) = '[{"uuid":"300191bc-4c83-4fdc-8e8e-396e7692780d","booking_number":"038VC9177288","num_of_supplier_containers":null,"num_containers":null,"por_cargo_cut_off_dt":null,"por_early_receive_dt":null,"cargo_cut_off_dt":null,"doc_cut_off":null,"early_receive_dt":null,"first_vessel":null,"first_voyage":null,"vessel_etb_pol_dt":null,"vessel_eta_pol_dt":null,"vessel_etd_pol_dt":null,"pol_locode":null,"pol_city":null,"pol_terminal_name":null,"pol_terminal_firms_code":null,"cancelled":false,"custom_columns":[],"containers":[],"carrier":null},{"uuid":"f1e68cb7-0d4f-4d66-93bd-043329e00e40","booking_number":"YCH24122154","num_of_supplier_containers":null,"num_containers":null,"por_cargo_cut_off_dt":null,"por_early_receive_dt":null,"cargo_cut_off_dt":null,"doc_cut_off":null,"early_receive_dt":null,"first_vessel":null,"first_voyage":null,"vessel_etb_pol_dt":null,"vessel_eta_pol_dt":null,"vessel_etd_pol_dt":null,"pol_locode":null,"pol_city":null,"pol_terminal_name":null,"pol_terminal_firms_code":null,"cancelled":false,"custom_columns":[],"containers":[],"carrier":{"carrier_scac":"ONEY","carrier_name":"Ocean Network Express","carrier_type":"ocean"}},{"uuid":"74d0bb00-5914-4141-9932-7308d051ebed","booking_number":"RICEZ5397700","num_of_supplier_containers":null,"num_containers":null,"por_cargo_cut_off_dt":null,"por_early_receive_dt":null,"cargo_cut_off_dt":null,"doc_cut_off":null,"early_receive_dt":null,"first_vessel":null,"first_voyage":null,"vessel_etb_pol_dt":null,"vessel_eta_pol_dt":null,"vessel_etd_pol_dt":null,"pol_locode":null,"pol_city":null,"pol_terminal_name":null,"pol_terminal_firms_code":null,"cancelled":false,"custom_columns":[],"containers":[],"carrier":{"carrier_scac":"ONEY","carrier_name":"Ocean Network Express","carrier_type":"ocean"}},{"uuid":"485a7ea2-024f-45aa-a8d3-eb902f8aa43e","booking_number":"DALA32094500","num_of_supplier_containers":null,"num_containers":1,"por_cargo_cut_off_dt":"2024-07-19T16:00:00","por_early_receive_dt":"2024-07-16T07:00:00","cargo_cut_off_dt":"2024-07-19T16:00:00","doc_cut_off":null,"early_receive_dt":"2024-07-16T07:00:00","first_vessel":"MOL CREATION","first_voyage":"092W","vessel_etb_pol_dt":"2024-07-21T04:00:00","vessel_eta_pol_dt":null,"vessel_etd_pol_dt":"2024-07-26T05:00:00","pol_locode":"USLAX","pol_city":"Los Angeles, US","pol_terminal_name":"TraPac Terminal","pol_terminal_firms_code":"Y258","cancelled":false,"custom_columns":[],"containers":[],"carrier":{"carrier_scac":"HDMU","carrier_name":"Hyundai Merchant Marine","carrier_type":"ocean"}},{"uuid":"fa6396a0-f59b-4b8a-91f2-8e998bf8cbc8","booking_number":"RICEAS071800","num_of_supplier_containers":null,"num_containers":1,"por_cargo_cut_off_dt":"2024-07-31T16:00:00","por_early_receive_dt":null,"cargo_cut_off_dt":"2024-07-31T16:00:00","doc_cut_off":null,"early_receive_dt":null,"first_vessel":"ONE CONTRIBUTION","first_voyage":"0057W","vessel_etb_pol_dt":null,"vessel_eta_pol_dt":null,"vessel_etd_pol_dt":"2024-08-06T04:00:00","pol_locode":"USLAX","pol_city":"Los Angeles, US","pol_terminal_name":"TraPac Terminal","pol_terminal_firms_code":"Y258","cancelled":false,"custom_columns":[],"containers":[],"carrier":{"carrier_scac":"ONEY","carrier_name":"Ocean Network Express","carrier_type":"ocean"}},{"uuid":"4934e48b-d254-43fd-a7d7-d6c2b735f7d1","booking_number":"RICEZ6229900","num_of_supplier_containers":null,"num_containers":1,"por_cargo_cut_off_dt":"2024-07-26T16:00:00","por_early_receive_dt":null,"cargo_cut_off_dt":"2024-07-26T16:00:00","doc_cut_off":null,"early_receive_dt":null,"first_vessel":"ONE CONTRIBUTION","first_voyage":"0057W","vessel_etb_pol_dt":null,"vessel_eta_pol_dt":null,"vessel_etd_pol_dt":"2024-08-06T04:00:00","pol_locode":"USLAX","pol_city":"Los Angeles, US","pol_terminal_name":"TraPac Terminal","pol_terminal_firms_code":"Y258","cancelled":false,"custom_columns":[],"containers":[],"carrier":{"carrier_scac":"ONEY","carrier_name":"Ocean Network Express","carrier_type":"ocean"}},{"uuid":"b1a97867-cb67-4840-aba9-ebf3a938e373","booking_number":"NAM6742143","num_of_supplier_containers":null,"num_containers":null,"por_cargo_cut_off_dt":null,"por_early_receive_dt":null,"cargo_cut_off_dt":null,"doc_cut_off":null,"early_receive_dt":null,"first_vessel":null,"first_voyage":null,"vessel_etb_pol_dt":null,"vessel_eta_pol_dt":null,"vessel_etd_pol_dt":null,"pol_locode":null,"pol_city":null,"pol_terminal_name":null,"pol_terminal_firms_code":null,"cancelled":false,"custom_columns":[],"containers":[],"carrier":{"carrier_scac":"COSU","carrier_name":"Cosco Shipping Lines","carrier_type":"ocean"}}]'
	@requestSent NVARCHAR(MAX) = '' ,
	@responseRcvd	NVARCHAR(MAX) = '[{"uuid":"485a7ea2-024f-45aa-a8d3-eb902f8aa43e","booking_number":"DALA32094500","num_of_supplier_containers":null,"num_containers":"1","por_cargo_cut_off_dt":"2024-07-19T16:00:00","por_early_receive_dt":"2024-07-16T07:00:00","cargo_cut_off_dt":"2024-07-19T16:00:00","doc_cut_off":null,"early_receive_dt":"2024-07-16T07:00:00","first_vessel":"MOL CREATION","first_voyage":"092W","vessel_etb_pol_dt":"2024-07-21T08:12:00","vessel_eta_pol_dt":null,"vessel_etd_pol_dt":"2024-07-26T05:00:00","pol_locode":"USLAX","pol_city":"Los Angeles, US","pol_terminal_name":"TraPac Terminal","pol_terminal_firms_code":"Y258","cancelled":"false","custom_columns":[],"containers":[{"uuid":"47afe993-43b8-4de6-b711-1a3020d0ec67","container_number":"KOCU4058497","empty_out_dt":"2024-07-18T13:53:00","in_gate_dt":"2024-07-19T14:02:00","container_type":"45G1","weight":null,"length":null,"provided_by_ssl":null,"provided_by_supplier":null,"booking_uuid":"485a7ea2-024f-45aa-a8d3-eb902f8aa43e","customer_tags":[],"seal_no":null,"custom_columns":[],"drayage":[]}],"carrier":{"carrier_scac":"HDMU","carrier_name":"Hyundai Merchant Marine","carrier_type":"ocean"}},{"uuid":"fa6396a0-f59b-4b8a-91f2-8e998bf8cbc8","booking_number":"RICEAS071800","num_of_supplier_containers":null,"num_containers":"1","por_cargo_cut_off_dt":"2024-07-31T16:00:00","por_early_receive_dt":null,"cargo_cut_off_dt":"2024-07-31T16:00:00","doc_cut_off":null,"early_receive_dt":null,"first_vessel":"ONE CONTRIBUTION","first_voyage":"0057W","vessel_etb_pol_dt":"2024-08-09T21:15:50","vessel_eta_pol_dt":"2024-08-09T20:36:57","vessel_etd_pol_dt":"2024-08-06T04:00:00","pol_locode":"USLAX","pol_city":"Los Angeles, US","pol_terminal_name":"TraPac Terminal","pol_terminal_firms_code":"Y258","cancelled":"false","custom_columns":[],"containers":[],"carrier":{"carrier_scac":"ONEY","carrier_name":"Ocean Network Express","carrier_type":"ocean"}},{"uuid":"4934e48b-d254-43fd-a7d7-d6c2b735f7d1","booking_number":"RICEZ6229900","num_of_supplier_containers":null,"num_containers":"1","por_cargo_cut_off_dt":"2024-07-31T16:00:00","por_early_receive_dt":null,"cargo_cut_off_dt":"2024-07-31T16:00:00","doc_cut_off":null,"early_receive_dt":null,"first_vessel":"ONE CONTRIBUTION","first_voyage":"0057W","vessel_etb_pol_dt":"2024-08-09T21:15:50","vessel_eta_pol_dt":"2024-08-09T20:36:57","vessel_etd_pol_dt":"2024-08-06T04:00:00","pol_locode":"USLAX","pol_city":"Los Angeles, US","pol_terminal_name":"TraPac Terminal","pol_terminal_firms_code":"Y258","cancelled":"false","custom_columns":[],"containers":[],"carrier":{"carrier_scac":"ONEY","carrier_name":"Ocean Network Express","carrier_type":"ocean"}}]'

)

AS

BEGIN


	DECLARE @BookingDetailsKey INT = 0

	INSERT INTO		Gnosis_Export_BookingDetailsRequestResponse
					(RequestSent,ResponseRcvd,CreatedDate)
	SELECT			@requestSent,@responseRcvd, GETDATE()

	SET @BookingDetailsKey = @@IDENTITY


	
	CREATE TABLE #BookingDetails
(
SlNo							INT,
	uuid						VARCHAR(50),
	booking_number				VARCHAR(20),
	num_of_supplier_containers	VARCHAR(20),
	num_containers				VARCHAR(20),
	por_cargo_cut_off_dt		VARCHAR(20),
	por_early_receive_dt		VARCHAR(20),
	cargo_cut_off_dt			VARCHAR(20),
	doc_cut_off					VARCHAR(100),
	early_receive_dt			VARCHAR(20),
	first_vessel				VARCHAR(200),
	first_voyage				VARCHAR(20),
	vessel_etb_pol_dt			VARCHAR(20),
	vessel_eta_pol_dt			VARCHAR(20),
	vessel_etd_pol_dt			VARCHAR(20),
	pol_locode					VARCHAR(20),
	pol_city					VARCHAR(20),
	pol_terminal_name			VARCHAR(100),
	pol_terminal_firms_code		VARCHAR(20),
	cancelled					VARCHAR(20),
	custom_columns				NVARCHAR(MAX),
	containers					NVARCHAR(MAX),
	carrier_scac				VARCHAR(20),
	carrier_name				VARCHAR(10),
	carrier_type				VARCHAR(20),
	CreatedDate					DATETIME

)



	INSERT INTO		#BookingDetails
					(uuid,booking_number,num_of_supplier_containers,num_containers,por_cargo_cut_off_dt,por_early_receive_dt,cargo_cut_off_dt,doc_cut_off,early_receive_dt,first_vessel,first_voyage
					,vessel_etb_pol_dt,vessel_eta_pol_dt,vessel_etd_pol_dt,pol_locode,pol_city,pol_terminal_name,pol_terminal_firms_code,cancelled,custom_columns,containers,carrier_scac,carrier_name
					,carrier_type)
	SELECT			uuid,booking_number,num_of_supplier_containers,num_containers,por_cargo_cut_off_dt,por_early_receive_dt,cargo_cut_off_dt,doc_cut_off,early_receive_dt,first_vessel,first_voyage
					,vessel_etb_pol_dt,vessel_eta_pol_dt,vessel_etd_pol_dt,pol_locode,pol_city,pol_terminal_name,pol_terminal_firms_code,cancelled,custom_columns,containers,carrier_scac,carrier_name
					,carrier_type
	FROM			OPENJSON(@responseRcvd, '$')
					WITH	(uuid						VARCHAR(50)		'$.uuid',
							booking_number				VARCHAR(20)		'$.booking_number',
							num_of_supplier_containers	VARCHAR(20)		'$.num_of_supplier_containers',
							num_containers				VARCHAR(20)		'$.num_containers',
							por_cargo_cut_off_dt		VARCHAR(20)		'$.por_cargo_cut_off_dt',
							por_early_receive_dt		VARCHAR(20)		'$.por_early_receive_dt',
							cargo_cut_off_dt			VARCHAR(20)		'$.cargo_cut_off_dt',
							doc_cut_off					VARCHAR(100)	'$.doc_cut_off',
							early_receive_dt			VARCHAR(20)		'$.early_receive_dt',
							first_vessel				VARCHAR(200)	'$.first_vessel',
							first_voyage				VARCHAR(20)		'$.first_voyage',
							vessel_etb_pol_dt			VARCHAR(20)		'$.vessel_etb_pol_dt',
							vessel_eta_pol_dt			VARCHAR(20)		'$.vessel_eta_pol_dt',
							vessel_etd_pol_dt			VARCHAR(20)		'$.vessel_etd_pol_dt',
							pol_locode					VARCHAR(20)		'$.pol_locode',
							pol_city					VARCHAR(20)		'$.pol_city',
							pol_terminal_name			VARCHAR(100)	'$.pol_terminal_name',
							pol_terminal_firms_code		VARCHAR(20)		'$.pol_terminal_firms_code',
							cancelled					VARCHAR(20)		'$.cancelled',
							custom_columns				NVARCHAR(MAX)	'$.custom_columns',
							containers					NVARCHAR(MAX)	'$.containers' AS JSON,
							carrier_scac				VARCHAR(20)		'$.carrier.carrier_scac',
							carrier_name				VARCHAR(10)		'$.carrier.carrier_name',
							carrier_type				VARCHAR(20)		'$.carrier.carrier_type'
							)
	

	
	INSERT INTO		Gnosis_Export_BookingDetails
					(BookingDetailsKey,uuid,booking_number,num_of_supplier_containers,num_containers,por_cargo_cut_off_dt,por_early_receive_dt,cargo_cut_off_dt,doc_cut_off,early_receive_dt,first_vessel,first_voyage
					,vessel_etb_pol_dt,vessel_eta_pol_dt,vessel_etd_pol_dt,pol_locode,pol_city,pol_terminal_name,pol_terminal_firms_code,cancelled,custom_columns,containers,carrier_scac,carrier_name
					,carrier_type,CreatedDate)
	SELECT			@BookingDetailsKey,A.uuid,A.booking_number,A.num_of_supplier_containers,A.num_containers,A.por_cargo_cut_off_dt,A.por_early_receive_dt,A.cargo_cut_off_dt,A.doc_cut_off,A.early_receive_dt,A.first_vessel,A.first_voyage
					,A.vessel_etb_pol_dt,A.vessel_eta_pol_dt,A.vessel_etd_pol_dt,A.pol_locode,A.pol_city,A.pol_terminal_name,A.pol_terminal_firms_code,A.cancelled,A.custom_columns,A.containers,A.carrier_scac,A.carrier_name
					,A.carrier_type, GETDATE()
	FROM			#BookingDetails A
	LEFT JOIN		Gnosis_Export_BookingDetails B  WITH (NOLOCK) ON A.booking_number = B.booking_number AND A.uuid = B.uuid
	WHERE			B.booking_number IS NULL


	-- SELECT			A.SL, B.SlNo
	UPDATE			B SET SlNo = A.SL
	FROM			(SELECT			ROW_NUMBER() OVER (ORDER BY UUID ) SL, UUID
					FROM			#BookingDetails) A 
	INNER JOIN		#BookingDetails B ON A.uuid = B.uuid
	WHERE			REPLACE(ISNULL(B.containers,''),'[]','') <> ''



	CREATE TABLE #ContainerList
	(uuid					VARCHAR(50)	,	
	container_number		VARCHAR(20),		
	empty_out_dt			VARCHAR(20)	,	
	in_gate_dt				VARCHAR(20),		
	container_type			VARCHAR(20),		
	Conweight				VARCHAR(20),		
	Conlength				VARCHAR(20),		
	provided_by_ssl			VARCHAR(100),	
	provided_by_supplier	VARCHAR(100),	
	booking_uuid			VARCHAR(100),	
	customer_tags			NVARCHAR(MAX),	
	seal_no					VARCHAR(100),	
	custom_columns			NVARCHAR(MAX),	
	drayage					NVARCHAR(MAX)	)

	DECLARE @ContainerList NVARCHAR(MAX)

	DECLARE @i INT = 1 , @n INT = (SELECT COUNT(*) FROM #BookingDetails WHERE ISNULL(SlNo,0) > 0)

	WHILE(@i <= @n)
		BEGIN
			SET @ContainerList = (SELECT containers FROM #BookingDetails WHERE SlNo = @i )			
			
			INSERT INTO		#ContainerList
							(uuid,container_number,empty_out_dt,in_gate_dt,container_type,Conweight,Conlength,provided_by_ssl,provided_by_supplier,booking_uuid,customer_tags,seal_no,custom_columns,drayage)
			SELECT			uuid,container_number,empty_out_dt,in_gate_dt,container_type,Conweight,Conlength,provided_by_ssl,provided_by_supplier,booking_uuid,customer_tags,seal_no,custom_columns,drayage
			FROM			OPENJSON(@ContainerList, '$')
							WITH	(uuid					VARCHAR(50)		'$.uuid',
									container_number		VARCHAR(20)		'$.container_number',
									empty_out_dt			VARCHAR(20)		'$.empty_out_dt',
									in_gate_dt				VARCHAR(20)		'$.in_gate_dt',
									container_type			VARCHAR(20)		'$.container_type',
									Conweight				VARCHAR(20)		'$.weight',
									Conlength				VARCHAR(20)		'$.length',
									provided_by_ssl			VARCHAR(100)	'$.provided_by_ssl',
									provided_by_supplier	VARCHAR(100)	'$.provided_by_supplier',
									booking_uuid			VARCHAR(100)	'$.booking_uuid',
									customer_tags			NVARCHAR(MAX)	'$.customer_tags' AS JSON,
									seal_no					VARCHAR(100)	'$.seal_no' ,
									custom_columns			NVARCHAR(MAX)	'$.custom_columns'  AS JSON,
									drayage					NVARCHAR(MAX)	'$.drayage'  AS JSON)
			SET @i = @i + 1
		END

	INSERT INTO				Gnosis_Export_BookingDetails_Containers
							(uuid,container_number,empty_out_dt,in_gate_dt,container_type,Conweight,Conlength,provided_by_ssl,provided_by_supplier
							,booking_uuid,customer_tags,seal_no,custom_columns,drayage, CreatedDate)
	SELECT					A.uuid,A.container_number,A.empty_out_dt,A.in_gate_dt,A.container_type,A.Conweight,A.Conlength,A.provided_by_ssl,A.provided_by_supplier
							,A.booking_uuid,A.customer_tags,A.seal_no,A.custom_columns,A.drayage,GETDATE()
	FROM					#ContainerList A 
	LEFT JOIN				Gnosis_Export_BookingDetails_Containers B  WITH (NOLOCK) On A.uuid = B.uuid
	WHERE					B.uuid IS NULL


	EXEC		Gnosis_Export_Insert_BookingDetails_MovetoFinal
	EXEC		Gnosis_Export_Insert_BookingDetails_Containers_MovetoFinal

	--SELECT * FROM Gnosis_Export_BookingDetails
	--SELECT * FROM Gnosis_Export_BookingDetails_Containers

	-- TRUNCATE TABLE Gnosis_Export_BookingDetails

END

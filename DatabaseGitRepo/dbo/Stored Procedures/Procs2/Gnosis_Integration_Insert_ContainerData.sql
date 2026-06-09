
-- SELECT GroupRecordID, COUNT(*) FROM Gnosis_Integration_ContainerDataJson GROUP BY GroupRecordID
-- TRUNCATE TABLE Gnosis_Integration_ContainerDataJson
/*
TRUNCATE TABLE Gnosis_Integration_Container
TRUNCATE TABLE Gnosis_Integration_Holds
TRUNCATE TABLE Gnosis_Integration_MBL
TRUNCATE TABLE Gnosis_Integration_Shipments
TRUNCATE TABLE Gnosis_Integration_ContainerCustomer
*/
CREATE PROCEDURE [dbo].[Gnosis_Integration_Insert_ContainerData]
(
		-- @RecordID		VARCHAR(100) = 'af71b3f5-168c-4dad-9398-dd64a370f843'
		@RecordID		VARCHAR(100) = '7698cbcba-6d52-4d7c-8aa9-86f2d2326a2a'
)

AS

BEGIN
	SELECT		*
	INTO		#TMPDATA
	FROM		Gnosis_Integration_ContainerDataJson WITH (NOLOCK)
	WHERE		GroupRecordID = @RecordID

	DECLARE @i INT = 0, @n INT = (SELECT COUNT(*) FROM Gnosis_Integration_ContainerDataJson WHERE GroupRecordID = @RecordID )
	DECLARE @JSONDATA NVARCHAR(MAX) = ''
	DECLARE @RecordKey INT = 0

	CREATE TABLE #ContainerHeader
			(
				SLNO							INT				,
				RecordKey						INT				,
				Datakey							INT				,
				UUID							VARCHAR(50)		,
				Container_number				VARCHAR(50)		,
				Container_journey_start_key		VARCHAR(50)		,
				Seal_no							VARCHAR(50)		,
				Container_type					VARCHAR(50)		,
				Length							VARCHAR(50)		,
				Weight							VARCHAR(50)		,
				Empty_out_dt					VARCHAR(50)		,
				In_gate_dt						VARCHAR(50)		,
				Early_receive_dt				VARCHAR(50)		,
				Cut_off_dt						VARCHAR(50)		,
				Out_gate_dt						VARCHAR(50)		,
				Port_eta_dt						VARCHAR(50)		,
				Gnosis_vessel_eta_dt			VARCHAR(50)		,
				Gnosis_estimated_discharge_dt	VARCHAR(50)		,
				Gnosis_rail_eta_dt				VARCHAR(50)		,
				Vessel_eta_dt					VARCHAR(50)		,
				Vessel_eta_dt_history			NVARCHAR(MAX)	,
				Vessel_etd_dt					VARCHAR(50)		,
				Vessel_ata_dt					VARCHAR(50)		,
				Vessel_atd_dt					VARCHAR(50)		,
				Discharged_dt					VARCHAR(50)		,
				Empty_returned_dt				VARCHAR(50)		,
				Pod_locode						VARCHAR(50)		,
				Pod_city						VARCHAR(50)		,
				Pod_terminal_name				VARCHAR(50)		,
				Pod_terminal_firms_code			VARCHAR(50)		,
				Pol_locode						VARCHAR(50)		,
				Pol_city						VARCHAR(50)		,
				Pol_terminal_name				VARCHAR(50)		,
				Pol_terminal_firms_code			VARCHAR(50)		,
				Por_locode						VARCHAR(50)		,
				Por_city						VARCHAR(50)		,
				Ocean_carrier_name				VARCHAR(50)		,
				Ocean_carrier_scac				VARCHAR(50)		,
				Mother_vessel					VARCHAR(50)		,
				Mother_vessel_imo				VARCHAR(50)		,
				Mother_voyage					VARCHAR(50)		,
				Motherload_dt					VARCHAR(50)		,
				Current_vessel					VARCHAR(50)		,
				Current_vessel_imo				VARCHAR(50)		,
				First_vessel					VARCHAR(50)		,
				First_vessel_imo				VARCHAR(50)		,
				Location_at_terminal			VARCHAR(50)		,
				Is_railing						VARCHAR(50)		,
				Rail_eta_dt						VARCHAR(50)		,
				Rail_ata_dt						VARCHAR(50)		,
				Rail_departed_dt				VARCHAR(50)		,
				Rail_discharged_dt				VARCHAR(50)		,
				Rail_terminal					VARCHAR(50)		,
				Rail_terminal_firms_code		VARCHAR(50)		,
				Rail_notify_dt					VARCHAR(50)		,
				Pickup_number					VARCHAR(50)		,
				Available_dt					VARCHAR(50)		,
				Final_dest_locode				VARCHAR(50)		,
				Final_dest_city					VARCHAR(50)		,
				Last_free_demurrage_day_dt		VARCHAR(50)		,
				Last_free_detention_day_dt		VARCHAR(50)		,
				Estd_last_free_demurrage_day_dt	VARCHAR(50)		,
				Demurrage_amount				VARCHAR(50)		,
				Estd_demurrage_amount			VARCHAR(50)		,
				Estd_last_free_detention_day_dt	VARCHAR(50)		,
				Estd_detention_amount			VARCHAR(50)		,
				Carrier_release_dt				VARCHAR(50)		,
				Customs_clearance_dt			VARCHAR(50)		,
				Available_for_pickup			VARCHAR(50)		,
				Loaded_on_vessel_dt				VARCHAR(50)		,
				Holds							NVARCHAR(MAX)	,
				Pickup_appointment_dt			VARCHAR(50)		,
				Updated_dt						VARCHAR(50)		,
				Chassis_number					VARCHAR(50)		,
				Mbl								NVARCHAR(MAX)	,
				Customer_tag					VARCHAR(50)		,
				Carrier_contract				VARCHAR(50)		,
				Custom_detention_demurrage_calc	NVARCHAR(MAX)	,
				Transshipments					NVARCHAR(MAX)	,
				Import_drayage					NVARCHAR(MAX)	,
				Purchase_orders					NVARCHAR(MAX)	,
				Container_customer_fields		NVARCHAR(MAX)	,
				Rail_milestones					NVARCHAR(MAX)	,
				Line_items_fulfilled			NVARCHAR(MAX)	,
				Distribution_center				VARCHAR(50)		,
				drayage_carrier					VARCHAR(50)		,
				gnosis_estimated_demurrage_amount VARCHAR(50), 
				IsDelete						BIT			
			)

	WHILE(@i <= @n)
		BEGIN
			SET @JSONDATA = (SELECT ContainerDataJson FROM Gnosis_Integration_ContainerDataJson WHERE PageNo = @i  AND GroupRecordID = @RecordID)
			SET @RecordKey = (SELECT RecordKey FROM Gnosis_Integration_ContainerDataJson WHERE PageNo = @i  AND GroupRecordID = @RecordID)

			INSERT INTO	#ContainerHeader
						(RecordKey,UUID,container_number,container_journey_start_key,seal_no,container_type,length,empty_out_dt,in_gate_dt,early_receive_dt,cut_off_dt,out_gate_dt,port_eta_dt,gnosis_vessel_eta_dt
						,gnosis_estimated_discharge_dt,gnosis_rail_eta_dt,vessel_eta_dt,vessel_eta_dt_history,vessel_etd_dt,vessel_ata_dt,vessel_atd_dt,discharged_dt,empty_returned_dt,pod_locode,pod_city
						,pod_terminal_name,pod_terminal_firms_code,pol_locode,pol_city,pol_terminal_name,pol_terminal_firms_code,por_locode,por_city,ocean_carrier_name,ocean_carrier_scac
						,mother_vessel,mother_vessel_imo,mother_voyage,motherload_dt,current_vessel,current_vessel_imo,first_vessel,first_vessel_imo,location_at_terminal,is_railing,rail_eta_dt
						,rail_ata_dt,rail_departed_dt,rail_discharged_dt,rail_terminal,rail_terminal_firms_code,rail_notify_dt,pickup_number,available_dt,final_dest_locode,final_dest_city,last_free_demurrage_day_dt
						,last_free_detention_day_dt,estd_last_free_demurrage_day_dt,demurrage_amount,estd_demurrage_amount,estd_last_free_detention_day_dt,estd_detention_amount,carrier_release_dt,customs_clearance_dt
						,available_for_pickup,loaded_on_vessel_dt,holds,pickup_appointment_dt,Updated_dt,chassis_number,mbl,customer_tag,carrier_contract,custom_detention_demurrage_calc,transshipments,import_drayage
						,purchase_orders,container_customer_fields,rail_milestones,line_items_fulfilled,distribution_center,drayage_carrier,gnosis_estimated_demurrage_amount,IsDelete)
			SELECT		@RecordKey,UUID,container_number,container_journey_start_key,seal_no,container_type,length,empty_out_dt,in_gate_dt,early_receive_dt,cut_off_dt,out_gate_dt,port_eta_dt,gnosis_vessel_eta_dt
						,gnosis_estimated_discharge_dt,gnosis_rail_eta_dt,vessel_eta_dt,vessel_eta_dt_history,vessel_etd_dt,vessel_ata_dt,vessel_atd_dt,discharged_dt,empty_returned_dt,pod_locode,pod_city
						,pod_terminal_name,pod_terminal_firms_code,pol_locode,pol_city,pol_terminal_name,pol_terminal_firms_code,por_locode,por_city,ocean_carrier_name,ocean_carrier_scac
						,mother_vessel,mother_vessel_imo,mother_voyage,motherload_dt,current_vessel,current_vessel_imo,first_vessel,first_vessel_imo,location_at_terminal,is_railing,rail_eta_dt
						,rail_ata_dt,rail_departed_dt,rail_discharged_dt,rail_terminal,rail_terminal_firms_code,rail_notify_dt,pickup_number,available_dt,final_dest_locode,final_dest_city,last_free_demurrage_day_dt
						,last_free_detention_day_dt,estd_last_free_demurrage_day_dt,demurrage_amount,estd_demurrage_amount,estd_last_free_detention_day_dt,estd_detention_amount,carrier_release_dt,customs_clearance_dt
						,available_for_pickup,loaded_on_vessel_dt,holds,pickup_appointment_dt,updated_dt,chassis_number,mbl,customer_tag,carrier_contract,custom_detention_demurrage_calc,transshipments,import_drayage
						,purchase_orders,container_customer_fields,rail_milestones,line_items_fulfilled,distribution_center,drayage_carrier,gnosis_estimated_demurrage_amount,1
			FROM	OPENJSON(@JSONDATA, '$.containers')
					WITH (
						UUID							VARCHAR(50)		'$.uuid',
						container_number				VARCHAR(50)		'$.container_number',
						container_journey_start_key		VARCHAR(50)		'$.container_journey_start_key',
						seal_no							VARCHAR(50)		'$.seal_no',
						container_type					VARCHAR(50)		'$.container_type',
						length							VARCHAR(50)		'$.length',
						weight							VARCHAR(50)		'$.weight',
						empty_out_dt					VARCHAR(50)		'$.empty_out_dt',
						in_gate_dt						VARCHAR(50)		'$.in_gate_dt',
						early_receive_dt				VARCHAR(50)		'$.early_receive_dt',
						cut_off_dt						VARCHAR(50)		'$.cut_off_dt',
						out_gate_dt						VARCHAR(50)		'$.out_gate_dt',
						port_eta_dt						VARCHAR(50)		'$.port_eta_dt',
						gnosis_vessel_eta_dt			VARCHAR(50)		'$.gnosis_vessel_eta_dt',
						gnosis_estimated_discharge_dt	VARCHAR(50)		'$.gnosis_estimated_discharge_dt',
						gnosis_rail_eta_dt				VARCHAR(50)		'$.gnosis_rail_eta_dt',
						vessel_eta_dt					VARCHAR(50)		'$.vessel_eta_dt',
						vessel_eta_dt_history			NVARCHAR(MAX)	'$.vessel_eta_dt_history' AS JSON,
						vessel_etd_dt					VARCHAR(50)		'$.vessel_etd_dt',
						vessel_ata_dt					VARCHAR(50)		'$.vessel_ata_dt',
						vessel_atd_dt					VARCHAR(50)		'$.vessel_atd_dt',
						discharged_dt					VARCHAR(50)		'$.discharged_dt',
						empty_returned_dt				VARCHAR(50)		'$.empty_returned_dt',
						pod_locode						VARCHAR(50)		'$.pod_locode',
						pod_city						VARCHAR(50)		'$.pod_city',
						pod_terminal_name				VARCHAR(50)		'$.pod_terminal_name',
						pod_terminal_firms_code			VARCHAR(50)		'$.pod_terminal_firms_code',
						pol_locode						VARCHAR(50)		'$.pol_locode',
						pol_city						VARCHAR(50)		'$.pol_city',
						pol_terminal_name				VARCHAR(50)		'$.pol_terminal_name',
						pol_terminal_firms_code			VARCHAR(50)		'$.pol_terminal_firms_code',
						por_locode						VARCHAR(50)		'$.por_locode',
						por_city						VARCHAR(50)		'$.por_city',
						ocean_carrier_name				VARCHAR(50)		'$.ocean_carrier_name',
						ocean_carrier_scac				VARCHAR(50)		'$.ocean_carrier_scac',
						mother_vessel					VARCHAR(50)		'$.mother_vessel',
						mother_vessel_imo				VARCHAR(50)		'$.mother_vessel_imo',
						mother_voyage					VARCHAR(50)		'$.mother_voyage',
						motherload_dt					VARCHAR(50)		'$.motherload_dt',
						current_vessel					VARCHAR(50)		'$.current_vessel',
						current_vessel_imo				VARCHAR(50)		'$.current_vessel_imo',
						first_vessel					VARCHAR(50)		'$.first_vessel',
						first_vessel_imo				VARCHAR(50)		'$.first_vessel_imo',
						location_at_terminal			VARCHAR(50)		'$.location_at_terminal',
						is_railing						VARCHAR(50)		'$.is_railing',
						rail_eta_dt						VARCHAR(50)		'$.rail_eta_dt',
						rail_ata_dt						VARCHAR(50)		'$.rail_ata_dt',
						rail_departed_dt				VARCHAR(50)		'$.rail_departed_dt',
						rail_discharged_dt				VARCHAR(50)		'$.rail_discharged_dt',
						rail_terminal					VARCHAR(50)		'$.rail_terminal',
						rail_terminal_firms_code		VARCHAR(50)		'$.rail_terminal_firms_code',
						rail_notify_dt					VARCHAR(50)		'$.rail_notify_dt',
						pickup_number					VARCHAR(50)		'$.pickup_number',
						available_dt					VARCHAR(50)		'$.available_dt',
						final_dest_locode				VARCHAR(50)		'$.final_dest_locode', 
						final_dest_city					VARCHAR(50)		'$.final_dest_city',
						last_free_demurrage_day_dt		VARCHAR(50)		'$.last_free_demurrage_day_dt',
						last_free_detention_day_dt		VARCHAR(50)		'$.last_free_detention_day_dt',
						estd_last_free_demurrage_day_dt	VARCHAR(50)		'$.estd_last_free_demurrage_day_dt',
						demurrage_amount				VARCHAR(50)		'$.demurrage_amount',
						estd_demurrage_amount			VARCHAR(50)		'$.estd_demurrage_amount',
						estd_last_free_detention_day_dt	VARCHAR(50)		'$.estd_last_free_detention_day_dt',
						estd_detention_amount			VARCHAR(50)		'$.estd_detention_amount',
						carrier_release_dt				VARCHAR(50)		'$.carrier_release_dt',
						customs_clearance_dt			VARCHAR(50)		'$.customs_clearance_dt',
						available_for_pickup			VARCHAR(50)		'$.available_for_pickup',
						loaded_on_vessel_dt				VARCHAR(50)		'$.loaded_on_vessel_dt',
						holds							NVARCHAR(MAX)	'$.holds' AS JSON,
						pickup_appointment_dt			VARCHAR(50)		'$.pickup_appointment_dt',
						updated_dt						VARCHAR(50)		'$.updated_dt',
						chassis_number					VARCHAR(50)		'$.chassis_number',
						mbl								NVARCHAR(MAX)	'$.mbl' AS JSON,
						customer_tag					VARCHAR(50)		'$.customer_tag',
						carrier_contract				VARCHAR(50)		'$.carrier_contract',
						custom_detention_demurrage_calc	NVARCHAR(MAX)	'$.custom_detention_demurrage_calc' AS JSON,
						transshipments					NVARCHAR(MAX)	'$.transshipments' AS JSON,
						import_drayage					NVARCHAR(MAX)	'$.import_drayage' AS JSON,
						purchase_orders					NVARCHAR(MAX)	'$.purchase_orders' AS JSON,
						container_customer_fields		NVARCHAR(MAX)	'$.container_customer_fields' AS JSON,
						rail_milestones					NVARCHAR(MAX)	'$.rail_milestones' AS JSON,
						line_items_fulfilled			NVARCHAR(MAX)	'$.line_items_fulfilled' AS JSON,
						distribution_center				VARCHAR(50)		'$.distribution_center',
						drayage_carrier					VARCHAR(50)		'$.drayage_carrier',
						gnosis_estimated_demurrage_amount VARCHAR(50)		'$.gnosis_estimated_demurrage_amount'
					)
			SET		@i = @i + 1
		END


		UPDATE				A
		SET					IsDelete = 0
		FROM				#ContainerHeader A
		LEFT OUTER JOIN		(SELECT Container_Number, MAX(CAST(Updated_dt AS DATETIME))Updated_dt FROm Gnosis_Integration_Container WITH (NOLOCK)
							GROUP BY  Container_Number) B On A.Container_Number = B.Container_Number
		WHERE				((CAST(A.Updated_dt AS DATETIME) >  CAST(B.Updated_dt AS DATETIME)) OR (ISNULL(B.Updated_dt,'') = ''))


		INSERT INTO  Gnosis_Integration_Container_Deleted
					(RecordKey,UUID,container_number,container_journey_start_key,seal_no,container_type,length,empty_out_dt,in_gate_dt,early_receive_dt,cut_off_dt,out_gate_dt,port_eta_dt,gnosis_vessel_eta_dt
					,gnosis_estimated_discharge_dt,gnosis_rail_eta_dt,vessel_eta_dt,vessel_eta_dt_history,vessel_etd_dt,vessel_ata_dt,vessel_atd_dt,discharged_dt,empty_returned_dt,pod_locode,pod_city
					,pod_terminal_name,pod_terminal_firms_code,pol_locode,pol_city,pol_terminal_name,pol_terminal_firms_code,por_locode,por_city,ocean_carrier_name,ocean_carrier_scac
					,mother_vessel,mother_vessel_imo,mother_voyage,motherload_dt,current_vessel,current_vessel_imo,first_vessel,first_vessel_imo,location_at_terminal,is_railing,rail_eta_dt
					,rail_ata_dt,rail_departed_dt,rail_discharged_dt,rail_terminal,rail_terminal_firms_code,rail_notify_dt,pickup_number,available_dt,final_dest_locode,final_dest_city,last_free_demurrage_day_dt
					,last_free_detention_day_dt,estd_last_free_demurrage_day_dt,demurrage_amount,estd_demurrage_amount,estd_last_free_detention_day_dt,estd_detention_amount,carrier_release_dt,customs_clearance_dt
					,available_for_pickup,loaded_on_vessel_dt,holds,pickup_appointment_dt,Updated_dt,chassis_number,mbl,customer_tag,carrier_contract,custom_detention_demurrage_calc,transshipments,import_drayage
					,purchase_orders,container_customer_fields,rail_milestones,line_items_fulfilled,distribution_center,drayage_carrier,gnosis_estimated_demurrage_amount)
		SELECT		RecordKey, UUID,container_number,container_journey_start_key,seal_no,container_type,length,empty_out_dt,in_gate_dt,early_receive_dt,cut_off_dt,out_gate_dt,port_eta_dt,gnosis_vessel_eta_dt
					,gnosis_estimated_discharge_dt,gnosis_rail_eta_dt,vessel_eta_dt,vessel_eta_dt_history,vessel_etd_dt,vessel_ata_dt,vessel_atd_dt,discharged_dt,empty_returned_dt,pod_locode,pod_city
					,pod_terminal_name,pod_terminal_firms_code,pol_locode,pol_city,pol_terminal_name,pol_terminal_firms_code,por_locode,por_city,ocean_carrier_name,ocean_carrier_scac
					,mother_vessel,mother_vessel_imo,mother_voyage,motherload_dt,current_vessel,current_vessel_imo,first_vessel,first_vessel_imo,location_at_terminal,is_railing,rail_eta_dt
					,rail_ata_dt,rail_departed_dt,rail_discharged_dt,rail_terminal,rail_terminal_firms_code,rail_notify_dt,pickup_number,available_dt,final_dest_locode,final_dest_city,last_free_demurrage_day_dt
					,last_free_detention_day_dt,estd_last_free_demurrage_day_dt,demurrage_amount,estd_demurrage_amount,estd_last_free_detention_day_dt,estd_detention_amount,carrier_release_dt,customs_clearance_dt
					,available_for_pickup,loaded_on_vessel_dt,holds,pickup_appointment_dt,Updated_dt,chassis_number,mbl,customer_tag,carrier_contract,custom_detention_demurrage_calc,transshipments,import_drayage
					,purchase_orders,container_customer_fields,rail_milestones,line_items_fulfilled,distribution_center,drayage_carrier , gnosis_estimated_demurrage_amount
		FROM		#ContainerHeader
		where		IsDelete = 1

		DELETE FROM #ContainerHeader WHERE IsDelete = 1

		SELECT COUNT(*) FROM #ContainerHeader

		INSERT INTO  Gnosis_Integration_Container
					(RecordKey,UUID,container_number,container_journey_start_key,seal_no,container_type,length,empty_out_dt,in_gate_dt,early_receive_dt,cut_off_dt,out_gate_dt,port_eta_dt,gnosis_vessel_eta_dt
					,gnosis_estimated_discharge_dt,gnosis_rail_eta_dt,vessel_eta_dt,vessel_eta_dt_history,vessel_etd_dt,vessel_ata_dt,vessel_atd_dt,discharged_dt,empty_returned_dt,pod_locode,pod_city
					,pod_terminal_name,pod_terminal_firms_code,pol_locode,pol_city,pol_terminal_name,pol_terminal_firms_code,por_locode,por_city,ocean_carrier_name,ocean_carrier_scac
					,mother_vessel,mother_vessel_imo,mother_voyage,motherload_dt,current_vessel,current_vessel_imo,first_vessel,first_vessel_imo,location_at_terminal,is_railing,rail_eta_dt
					,rail_ata_dt,rail_departed_dt,rail_discharged_dt,rail_terminal,rail_terminal_firms_code,rail_notify_dt,pickup_number,available_dt,final_dest_locode,final_dest_city,last_free_demurrage_day_dt
					,last_free_detention_day_dt,estd_last_free_demurrage_day_dt,demurrage_amount,estd_demurrage_amount,estd_last_free_detention_day_dt,estd_detention_amount,carrier_release_dt,customs_clearance_dt
					,available_for_pickup,loaded_on_vessel_dt,holds,pickup_appointment_dt,Updated_dt,chassis_number,mbl,customer_tag,carrier_contract,custom_detention_demurrage_calc,transshipments,import_drayage
					,purchase_orders,container_customer_fields,rail_milestones,line_items_fulfilled,distribution_center,drayage_carrier,gnosis_estimated_demurrage_amount)
		SELECT		RecordKey, UUID,container_number,container_journey_start_key,seal_no,container_type,length,empty_out_dt,in_gate_dt,early_receive_dt,cut_off_dt,out_gate_dt,port_eta_dt,gnosis_vessel_eta_dt
					,gnosis_estimated_discharge_dt,gnosis_rail_eta_dt,vessel_eta_dt,vessel_eta_dt_history,vessel_etd_dt,vessel_ata_dt,vessel_atd_dt,discharged_dt,empty_returned_dt,pod_locode,pod_city
					,pod_terminal_name,pod_terminal_firms_code,pol_locode,pol_city,pol_terminal_name,pol_terminal_firms_code,por_locode,por_city,ocean_carrier_name,ocean_carrier_scac
					,mother_vessel,mother_vessel_imo,mother_voyage,motherload_dt,current_vessel,current_vessel_imo,first_vessel,first_vessel_imo,location_at_terminal,is_railing,rail_eta_dt
					,rail_ata_dt,rail_departed_dt,rail_discharged_dt,rail_terminal,rail_terminal_firms_code,rail_notify_dt,pickup_number,available_dt,final_dest_locode,final_dest_city,last_free_demurrage_day_dt
					,last_free_detention_day_dt,estd_last_free_demurrage_day_dt,demurrage_amount,estd_demurrage_amount,estd_last_free_detention_day_dt,estd_detention_amount,carrier_release_dt,customs_clearance_dt
					,available_for_pickup,loaded_on_vessel_dt,holds,pickup_appointment_dt,Updated_dt,chassis_number,mbl,customer_tag,carrier_contract,custom_detention_demurrage_calc,transshipments,import_drayage
					,purchase_orders,container_customer_fields,rail_milestones,line_items_fulfilled,distribution_center,drayage_carrier,gnosis_estimated_demurrage_amount 
		FROM		#ContainerHeader


		SELECT		ROW_NUMBER() OVER (ORDER BY UUID) SL,UUID
		INTO		#TmpSL
		FROM		#ContainerHeader A


		UPDATE		A
		SET			SLNo = B.SL
		FROM		#ContainerHeader A
		INNER JOIN	#TmpSL B ON A.UUID = B.UUID


		UPDATE		A
		SET			Datakey = B.DataKey 
		FROM		#ContainerHeader A
		INNER JOIN  Gnosis_Integration_Container B ON A.RecordKey = B.RecordKey AND A.UUID = B.UUID

		CREATE TABLE #RailMileStones
		(
			 Datakey		INT
			,container_number	VARCHAR(50)
			,event_location		VARCHAR(100)
			,event_desc			VARCHAR(50)
			,event_dt			VARCHAR(50)
			,lat				VARCHAR(50)
			,long				VARCHAR(50)
			,rail_carrier		VARCHAR(50)
		)


		Print 1

		IF(SELECT COUNT(*) FROM #ContainerHeader) > 0
		BEGIN
			SET @i = 1
			SET @n = (SELECT COUNT(*) FROM #ContainerHeader)

			DECLARE	@HOLDJSON NVARCHAR(MAX), @MBLJSON NVARCHAR(MAX), @ShipJSON NVARCHAR(MAX),@CCJSON NVARCHAR(MAX), @UUID VARCHAR(50), @DataKey INT , @ReailMileSTones NVARCHAR(MAX)

			WHILE (@i <= @n)
				BEGIN
					SELECT	@HOLDJSON = holds, @MBLJSON = MBL, @ShipJSON = transshipments,
						@CCJSON = container_customer_fields,   @UUID = UUID, @RecordKey = RecordKey, 
						@Datakey = Datakey  
					FROM #ContainerHeader 
					WHERE SLNO = @i
					-- SET		@Datakey = (SELECT DataKey FROM Gnosis_Integration_Container WHERE UUID = @UUID AND RecordKey = @RecordKey)

					IF(REPLACE(ISNULL(@HOLDJSON,''),'[]','') <> '')
						BEGIN
							INSERT INTO	Gnosis_Integration_Holds
										(DataKey,CTF,TMF,Line,Other,Customs,Freight)
							SELECT		@Datakey,CTF, TMF,Line,Other,Customs,Freight
							FROM		OPENJSON(@HOLDJSON, '$')
										WITH (
											CTF			VARCHAR(50)		'$.CTF',
											TMF			VARCHAR(50)		'$.TMF',
											Line		VARCHAR(50)		'$.Line',
											Other		VARCHAR(50)		'$.Other',
											Customs		VARCHAR(50)		'$.Customs',
											Freight		VARCHAR(50)		'$.Freight'
										)
						END

					IF(REPLACE(ISNULL(@MBLJSON,''),'[]','') <> '')
						BEGIN
							INSERT INTO	Gnosis_Integration_MBL
										(DataKey,uuid,mbl_number,dropped)
							SELECT		@Datakey,uuid, mbl_number,dropped
							FROM		OPENJSON(@MBLJSON, '$')
										WITH (
											UUID		VARCHAR(50)		'$.uuid',
											MBL_number	VARCHAR(50)		'$.mbl_number',
											Dropped		VARCHAR(50)		'$.dropped'
										)
						END

					IF(REPLACE(ISNULL(@ShipJSON,''),'[]','') <> '')
						BEGIN
							INSERT INTO	Gnosis_Integration_Shipments
										(DataKey,incoming_vessel,incoming_voyage,in_vessel_eta_dt,in_vessel_ata_dt,pod_locode,outgoing_voyage,out_vessel_etd_dt,out_vessel_atd_dt,loaded_on_vessel_dt,discharged_dt)
							SELECT		@Datakey,incoming_vessel, incoming_voyage,in_vessel_eta_dt,in_vessel_ata_dt,pod_locode,outgoing_voyage,out_vessel_etd_dt,out_vessel_atd_dt,loaded_on_vessel_dt,discharged_dt
							FROM		OPENJSON(@ShipJSON, '$')
										WITH (
											incoming_vessel		VARCHAR(50)		'$.incoming_vessel',
											incoming_voyage		VARCHAR(50)		'$.incoming_voyage',
											in_vessel_eta_dt	VARCHAR(50)		'$.in_vessel_eta_dt',
											in_vessel_ata_dt	VARCHAR(50)		'$.in_vessel_ata_dt',
											pod_locode			VARCHAR(50)		'$.pod_locode',
											pod_city			VARCHAR(50)		'$.pod_city',
											outgoing_vessel		VARCHAR(50)		'$.outgoing_vessel',
											outgoing_voyage		VARCHAR(50)		'$.outgoing_voyage',
											out_vessel_etd_dt	VARCHAR(50)		'$.out_vessel_etd_dt',
											out_vessel_atd_dt	VARCHAR(50)		'$.out_vessel_atd_dt',
											loaded_on_vessel_dt	VARCHAR(50)		'$.loaded_on_vessel_dt',
											discharged_dt		VARCHAR(50)		'$.discharged_dt'
										)
						END


					IF(REPLACE(ISNULL(@CCJSON,''),'[]','') <> '')
						BEGIN
							INSERT INTO	Gnosis_Integration_ContainerCustomer
										(DataKey,field_name,field_value,field_value_str)
							SELECT		@Datakey,field_name,field_value,field_value_str
							FROM		OPENJSON(@CCJSON, '$')
										WITH (
											Field_name		VARCHAR(50)		'$.field_name',
											Field_value		VARCHAR(50)		'$.field_value',
											Field_value_str	VARCHAR(50)		'$.field_value_str'
										)
						END
					
					IF(REPLACE(ISNULL(@ReailMileSTones,''),'[]','') <> '')
						BEGIN
							INSERT INTO	#RailMileStones
										(DataKey,container_number,event_location,event_desc,event_dt,lat,long,rail_carrier)
							SELECT		@Datakey,container_number,event_location,event_desc,event_dt,lat,long,rail_carrier
							FROM		OPENJSON(@ReailMileSTones, '$')
										WITH (
											container_number	VARCHAR(50)		'$.container_number',
											event_location		VARCHAR(50)		'$.event_location',
											event_desc			VARCHAR(50)		'$.event_desc',
											event_dt			VARCHAR(50)		'$.event_dt',
											lat					VARCHAR(50)		'$.lat',
											long				VARCHAR(50)		'$.long',
											rail_carrier		VARCHAR(50)		'$.rail_carrier'
										)
						END



					SET		@i = @i + 1
				END
			END	
	
	UPDATE		B
	SET			RailOutGateDate = A.event_dt
	FROM		#RailMileStones A
	INNER JOIN	Gnosis_Integration_Container B WITH (NOLOCK) ON A.Datakey = B.DataKey
	WHERE		event_desc = 'OUT-GATE'

	DROP TABLE #ContainerHeader
	DROP TABLE #TMPDATA
	DROP TABLE #TmpSL

	
END


/*
CREATE TABLE Gnosis_Integration_ContainerCustomer
(
Field_name		VARCHAR(50)	,
Field_value		VARCHAR(50)	,
Field_value_str	VARCHAR(50)	
)

SELECT * FROm Gnosis_Integration_Container WHERE Recordkey = 2
SELECT * FROM Gnosis_Integration_Holds
SELECT * FROM Gnosis_Integration_MBL
SELECT * FROM Gnosis_Integration_Shipments
SELECT * FROM Gnosis_Integration_ContainerCustomer
SELECT Datakey, COUNT(*) FROM Gnosis_Integration_ContainerCustomer GROUP BY Datakey


SELECT Datakey, COUNT(*) FROm Gnosis_Integration_Container  GROUP BY Datakey
SELECT Datakey, COUNT(*) FROM Gnosis_Integration_Holds  GROUP BY Datakey
SELECT Datakey, COUNT(*) FROM Gnosis_Integration_MBL  GROUP BY Datakey
SELECT Datakey, COUNT(*) FROM Gnosis_Integration_Shipments  GROUP BY Datakey
SELECT Datakey, COUNT(*) FROM Gnosis_Integration_ContainerCustomer GROUP BY Datakey
*/

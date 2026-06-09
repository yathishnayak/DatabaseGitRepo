
CREATE PROC [dbo].[Integration_DataInsert] -- Integration_DataInsert  '{"RouteKey":576158,"ContainerNo":"GCXU5066723","OrderKey":143130,"OrderDetailKey":175626,"FacilityCode":"SF","IsRouteRecordUpdate":false,"IsSuccess":false,"RequestSent":"{\"event_classifier\":\"PLN\",\"event_date_time\":\"2024-12-10T15:00:00\",\"equipment_event\":{\"equipment_reference\":\"GCXU5066723\",\"event_type\":\"GTOT\",\"transport_mode\":\"TRUCK\",\"facility_type\":\"POTE\",\"empty_indicator\":\"EMPTY\"},\"transport_event\":{\"event_type\":\"GTOT\",\"event_date_time\":\"2024-12-10T15:00:00\",\"transport_mode\":\"TRUCK\",\"facility_type\":\"POTE\"},\"location\":{\"address_location\":{\"name\":\"ITS\",\"address_line_1\":\"1281 Pier G Way # 90802\",\"address_line_2\":null,\"city\":\"Long Beach\",\"state\":\"CA\",\"postal_code\":\"90802\",\"country_code\":\"US \"}}}","ResponseReceived":"{\"error\":\"Validation failed: Event type is not included in the list\"}"}'
(
	@JsonString NVARCHAR(MAX)
) 

AS 
BEGIN
	
	DECLARE		
        @RouteKey INT = 0,
        @ContainerNo VARCHAR(20) = '', 
        @OrderKey INT = 0,
        @OrderDetailKey INT = 0,
        @FacilityCode VARCHAR(10) = 0,
        @IsRouteRecordUpdate BIT = 0, 
        @IsSuccess BIT = 0, 
        @RequestSent NVARCHAR(MAX), 
        @ResponseReceived NVARCHAR(MAX),
        @Id VARCHAR(50), 
        @RefDatakey	INT = 0, 
        @ScheduleActual VARCHAR(20) = '',
        @OrderNo VARCHAR(50), 
        @EventDate DATETIME,
        @StopKey INT = 0

	SELECT		
        @RouteKey = RouteKey,
        @ContainerNo = ContainerNo, 
        @OrderKey = OrderKey, 
        @OrderDetailKey = OrderDetailKey, 
        @FacilityCode = FacilityCode, 
        @IsRouteRecordUpdate = IsRouteRecordUpdate, 
        @IsSuccess = IsSuccess, 
        @RequestSent = RequestSent, 
        @ResponseReceived = ResponseReceived, 
        @RefDatakey = RefDatakey,
        @ScheduleActual = ScheduleActual, 
        @OrderNo = orderNo, 
        @EventDate = EventDate,
        @StopKey = StopKey
	FROM		
        OPENJSON(@JsonString, '$')
        WITH (
                RouteKey				INT				'$.RouteKey',
                RefDatakey				INT				'$.RefDataKey',
                StopKey                 INT             '$.StopKey',
                ContainerNo				VARCHAR(20)		'$.ContainerNo',
                ScheduleActual			VARCHAR(20)		'$.ScheduleActual',
                OrderKey				INT				'$.OrderKey',
                OrderDetailKey			INT				'$.OrderDetailKey',
                FacilityCode			VARCHAR(10)		'$.FacilityCode',
                IsRouteRecordUpdate		BIT				'$.IsRouteRecordUpdate',
                IsSuccess				BIT				'$.IsSuccess',
                OrderNo					VARCHAR(50)		'$.OrderNo',
                EventDate				DATETIME		'$.EventDate',
                RequestSent				NVARCHAR(MAX)	'$.RequestSent',
                ResponseReceived		NVARCHAR(MAX)	'$.ResponseReceived'
            )
	
	SELECT @ResponseReceived, @RequestSent 

	SELECT		@Id		= Id
	FROM		OPENJSON(@ResponseReceived, '$')
				WITH (
						Id				VARCHAR(50)				'$.id'
					)

	INSERT INTO Integration_Data
		(
            RouteKey,
            RefDatakey,
            StopKey,
            OrderNo,
            ContainerNo,
            ScheduleActual,
            OrderKey,
            EventDate,
            OrderDetailKey,
            FacilityCode,
            UserKey,
            IsRouteRecordUpdate,
            Id,
            IsSuccess,
            RequestSent,
            ResponseReceived,
            CreatedDate
        )
	VALUES
		(
            @RouteKey,
            @RefDatakey,
            @StopKey,
            @OrderNo,
            @ContainerNo,
            @ScheduleActual,
            @OrderKey,
            @EventDate,
            @OrderDetailKey,
            @FacilityCode,
            0,
            @IsRouteRecordUpdate,
            @Id,
            @IsSuccess,
            @RequestSent,
            @ResponseReceived,
            GETDATE()
        )

END

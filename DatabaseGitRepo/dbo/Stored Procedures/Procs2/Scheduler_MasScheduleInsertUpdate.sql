/*
DECLARE @UserKey INT = 486, @JSONString NVARCHAR(MAX) = '',@Status BIT = 0,@Reason VARCHAR(100) = ''
SET @JSONString = '[{"Identification":"SP","OrderDetailKey":226364,"OrderDetailStopKey":678097,"RefNo":"Test 452"},{"Identification":"SP","OrderDetailKey":226364,"OrderDetailStopKey":678098,"RefNo":"P900"},{"Identification":"SP","OrderDetailKey":226364,"OrderDetailStopKey":678099,"RefNo":"Compare"},{"Identification":"SP","OrderDetailKey":226366,"OrderDetailStopKey":678107},{"Identification":"SP","OrderDetailKey":226367,"OrderDetailStopKey":678118}]'
EXEC Scheduler_MasScheduleInsertUpdate @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT
Select @Reason, @Status
*/

CREATE procedure [dbo].[Scheduler_MasScheduleInsertUpdate]
(
	@UserKey	  INT ,
	@JSONString	  NVARCHAR(MAX) = '',
	@Status		  BIT = 0 OUTPUT,
	@Reason		  VARCHAR(100) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF(ISNULL(@JSONString,'') = '')
	BEGIN
		SET @Status = 0;
		SET	@Reason = 'Parameter missing'
	END

	CREATE TABLE #InputTemp(
	                        RowNo INT IDENTITY(1,1),
							Identification VARCHAR(5),
	                        OrderDetailKey INT,
	                        OrderDetailStopKey INT,
	                        SchedulePickupDate DATETIME,
	                        SchedulePickupDateTo DATETIME,
	                        ScheduleDeliveryDate DATETIME,
	                        ScheduleDeliveryDateTo DATETIME,
	                        DropOrLive CHAR,
	                        RefNo VARCHAR(50),
	                        TMFCheckOff BIT,
	                        CTFCheckOff BIT,
	                        SizeCheckOff BIT,
	                        IsTMFJCTPaid BIT,
	                        IsTMFCustomerPaid BIT,
	                        IsCTFJCTPaid BIT,
	                        IsCTFCustomerPaid BIT,
							StopAddrKey  INT,
							StopName VARCHAR(100)
	                       );
	
	INSERT INTO #InputTemp(Identification,OrderDetailKey, OrderDetailStopKey, SchedulePickupDate, SchedulePickupDateTo, ScheduleDeliveryDate, ScheduleDeliveryDateTo, 
	                       DropOrLive, RefNo, TMFCheckOff, CTFCheckOff, SizeCheckOff, IsTMFJCTPaid, IsTMFCustomerPaid, IsCTFJCTPaid, IsCTFCustomerPaid,StopAddrKey,StopName
	                      )
	SELECT Identification, OrderDetailKey, OrderDetailStopKey, SchedulePickupDate, SchedulePickupDateTo, ScheduleDeliveryDate, ScheduleDeliveryDateTo, DropOrLive,
	       RefNo, TMFCheckOff, CTFCheckOff, SizeCheckOff, IsTMFJCTPaid, IsTMFCustomerPaid, IsCTFJCTPaid, IsCTFCustomerPaid,StopAddrKey,StopName
	FROM OPENJSON(@JSONString)
	WITH (
	    Identification          VARCHAR(5)  '$.Identification',
	    OrderDetailKey          INT         '$.OrderDetailKey',
	    OrderDetailStopKey      INT         '$.OrderDetailStopKey',
	    SchedulePickupDate      DATETIME    '$.SchedulePickupDate',
	    SchedulePickupDateTo    DATETIME    '$.SchedulePickupDateTo',
	    ScheduleDeliveryDate    DATETIME    '$.ScheduleDeliveryDate',
	    ScheduleDeliveryDateTo  DATETIME    '$.ScheduleDeliveryDateTo',
	    DropOrLive              CHAR(1)     '$.DropOrLive',
	    RefNo                   VARCHAR(50) '$.RefNo',
	    TMFCheckOff             BIT         '$.TMFCheckOff',
	    CTFCheckOff             BIT         '$.CTFCheckOff',
	    SizeCheckOff            BIT         '$.SizeCheckOff',
	    IsTMFJCTPaid            BIT         '$.IsTMFJCTPaid',
	    IsTMFCustomerPaid       BIT         '$.IsTMFCustomerPaid',
	    IsCTFJCTPaid            BIT         '$.IsCTFJCTPaid',
	    IsCTFCustomerPaid       BIT         '$.IsCTFCustomerPaid',
		StopAddrKey            INT			'$.StopAddrKey',
		StopName			  VARCHAR(100)	'$.StopName'
	);
	

	--DECLARE @Comments nvarchar(max),@UserName varchar(100),@ContainerNo varchar(100);
	--SET @Comments = ISNULL(@Comments, '');

	--SELECT @UserName = UserName FROM [User] WHERE UserKey = @UserKey;


	DECLARE @Row INT = 1, @MaxRow INT
	SELECT @MaxRow = COUNT(*) FROM #InputTemp

   
	WHILE @Row <= @MaxRow
	BEGIN
	    DECLARE @Identification VARCHAR(5), @OrderDetailKey INT, @OrderDetailStopKey INT,
	            @SchedulePickupDate DATETIME, @SchedulePickupDateTo DATETIME,
	            @ScheduleDeliveryDate DATETIME, @ScheduleDeliveryDateTo DATETIME,
	            @DropOrLive CHAR, @RefNo VARCHAR(50),
	            @TMFCheckOff BIT, @CTFCheckOff BIT, @SizeCheckOff BIT,
	            @IsTMFJCTPaid BIT, @IsTMFCustomerPaid BIT,
	            @IsCTFJCTPaid BIT, @IsCTFCustomerPaid BIT,
				@StopAddrKey INT,@StopName VARCHAR(100)

				DECLARE @CurrentPickupStopNumber INT,@CurrentDeliveryStopNumber INT,@CurrentReturnStopNumber INT,@CurrentEmptyPickupStopNumber INT ;

	
	    SELECT  @Identification = Identification,
		        @OrderDetailKey = OrderDetailKey,
	            @OrderDetailStopKey = OrderDetailStopKey,
	            @SchedulePickupDate = SchedulePickupDate,
	            @SchedulePickupDateTo = SchedulePickupDateTo,
	            @ScheduleDeliveryDate = ScheduleDeliveryDate,
	            @ScheduleDeliveryDateTo = ScheduleDeliveryDateTo,
	            @DropOrLive = DropOrLive,
	            @RefNo = RefNo,
	            @TMFCheckOff = TMFCheckOff,
	            @CTFCheckOff = CTFCheckOff,
	            @SizeCheckOff = SizeCheckOff,
	            @IsTMFJCTPaid = IsTMFJCTPaid,
	            @IsTMFCustomerPaid = IsTMFCustomerPaid,
	            @IsCTFJCTPaid = IsCTFJCTPaid,
	            @IsCTFCustomerPaid = IsCTFCustomerPaid,
				@StopAddrKey=StopAddrKey,
				@StopName=StopName	
	    FROM #InputTemp 
		WHERE RowNo = @Row;

			

			SELECT @CurrentPickupStopNumber = StopNumber FROM OrderDetailStops WHERE OrderDetailStopKey = @OrderDetailStopKey AND StopTypeKey = 1  AND OrderDetailKey = @OrderDetailKey;
			SET @CurrentPickupStopNumber = @CurrentPickupStopNumber + 1;


			SELECT @CurrentDeliveryStopNumber= StopNumber FROM OrderDetaiLSTops WHERE OrderDEtailStopKey=@OrderDetailStopKey And StopTypeKey = 3 AND @Identification='SD' AND  OrderDetailKey = @OrderDetailKey;
			SET @CurrentDeliveryStopNumber = @CurrentDeliveryStopNumber -1;

			SELECT @CurrentEmptyPickupStopNumber=StopNumber FROM OrderDetaiLSTops WHERE  OrderDetailStopKey = @OrderDetailStopKey AND StopTypeKey = 3 AND @Identification='EP'  AND  OrderDetailKey = @OrderDetailKey;
			SET @CurrentEmptyPickupStopNumber = @CurrentEmptyPickupStopNumber +1;

			SELECT @CurrentReturnStopNumber= StopNumber FROM OrderDetaiLSTops 	WHERE OrderDEtailStopKey=@OrderDetailStopKey And StopTypeKey = 5  AND OrderDetailKey = @OrderDetailKey;
			SET @CurrentReturnStopNumber = @CurrentReturnStopNumber - 1;
					   
		
  --  SELECT @ContainerNo = ContainerNo FROM OrderDetail WHERE OrderDetailKey = @OrderDetailKey;

     
		--IF OBJECT_ID('tempdb..#olddata_ODS') IS NOT NULL
		--DROP TABLE #olddata_ODS;


		--SELECT SchedulePickupDate, SchedulePickupDateTo,ScheduleDeliveryDate, ScheduleDeliveryDateTo,DropOrLive, RefNo
		--INTO #olddata_ODS
		--FROM OrderDetailStops
		--WHERE OrderDetailStopKey = @OrderDetailStopKey AND OrderDetailKey = @OrderDetailKey;
			

		--AUDILOOG 
		--SchedulePickupDate
		--IF EXISTS (SELECT 1 FROM #olddata_ODS WHERE SchedulePickupDate IS NULL) AND @SchedulePickupDate IS NOT NULL
		--BEGIN
		--	INSERT INTO AuditLogDetail(DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		--	VALUES(GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, NULL, 'Text','Pickup Date added by ' + @UserName);
		--END

		--ELSE IF @SchedulePickupDate IS NOT NULL AND ISNULL(@SchedulePickupDate,'') <> ISNULL((SELECT SchedulePickupDate FROM #olddata_ODS),'')
		--BEGIN
		--	INSERT INTO AuditLogDetail(DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		--	VALUES(GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, NULL, 'Text','Pickup Date updated by ' + @UserName);
		--END

		----SchedulePickupDateTo
		--IF EXISTS (SELECT 1 FROM #olddata_ODS WHERE SchedulePickupDateTo IS NULL) AND @SchedulePickupDateTo IS NOT NULL
		--BEGIN
		--	INSERT INTO AuditLogDetail(DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		--	VALUES(GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, NULL, 'Text','Pickup Date To added by ' + @UserName);
		--END

		--ELSE IF
		--	@SchedulePickupDateTo IS NOT NULL
		--	AND EXISTS (SELECT 1
		--		FROM #olddata_ODS
		--		WHERE SchedulePickupDateTo IS NOT NULL AND CONVERT(TIME, SchedulePickupDateTo) <> CONVERT(TIME, @SchedulePickupDateTo))
		--BEGIN
		--	INSERT INTO AuditLogDetail(DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		--	VALUES(GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, NULL, 'Text','Pickup Date To updated by ' + @UserName);
		--END


		----ScheduleDeliveryDate
		--IF EXISTS (SELECT 1 FROM #olddata_ODS WHERE ScheduleDeliveryDate IS NULL) AND @ScheduleDeliveryDate IS NOT NULL
		--BEGIN
		--	INSERT INTO AuditLogDetail(DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		--	VALUES(GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, NULL, 'Text','Delivery Date added by ' + @UserName);
		--END

		--ELSE IF @ScheduleDeliveryDate IS NOT NULL AND ISNULL(@ScheduleDeliveryDate,'') <> ISNULL((SELECT ScheduleDeliveryDate FROM #olddata_ODS),'')
		--BEGIN
		--	INSERT INTO AuditLogDetail(DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		--	VALUES(GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, NULL, 'Text','Delivery Date updated by ' + @UserName);
		--END

		----ScheduleDeliveryDateTo
		--IF EXISTS (SELECT 1 FROM #olddata_ODS WHERE ScheduleDeliveryDateTo IS NULL) AND @ScheduleDeliveryDateTo IS NOT NULL
		--BEGIN
		--	INSERT INTO AuditLogDetail(DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		--	VALUES(GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, NULL, 'Text', 'Delivery Date To added by ' + @UserName);
		--END

		--	ELSE IF
		--		@ScheduleDeliveryDateTo IS NOT NULL AND EXISTS (
		--			SELECT 1 FROM #olddata_ODS
		--			WHERE ScheduleDeliveryDateTo IS NOT NULL AND CONVERT(TIME, ScheduleDeliveryDateTo) <> CONVERT(TIME, @ScheduleDeliveryDateTo))
		--	BEGIN
		--		INSERT INTO AuditLogDetail(DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		--		VALUES(GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, NULL, 'Text','Delivery Date To updated by ' + @UserName);
		--	END


		----Drop/Live
		--IF EXISTS (SELECT 1 FROM #olddata_ODS WHERE DropOrLive IS NULL) AND @DropOrLive IS NOT NULL
		--BEGIN
		--	INSERT INTO AuditLogDetail(DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		--	VALUES(GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, NULL, 'Text','Drop/Live added by ' + @UserName);
		--END

		--ELSE IF @DropOrLive IS NOT NULL AND ISNULL(@DropOrLive,'') <> ISNULL((SELECT DropOrLive FROM #olddata_ODS),'')
		--BEGIN
		--	INSERT INTO AuditLogDetail(DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		--	VALUES(GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, NULL, 'Text','Drop/Live updated by ' + @UserName);
		--END

		-----REFNO
		--IF EXISTS (SELECT 1 FROM #olddata_ODS WHERE RefNo IS NULL) AND @RefNo IS NOT NULL
		--BEGIN
		--	INSERT INTO AuditLogDetail(DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		--	VALUES(GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, NULL, 'Text','RefNo added by ' + @UserName);
		--END

		--ELSE IF @RefNo IS NOT NULL AND ISNULL(@RefNo,'') <>ISNULL((SELECT RefNo FROM #olddata_ODS),'')
		--BEGIN
		--	INSERT INTO AuditLogDetail(DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		--	VALUES(GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, NULL, 'Text','RefNo updated by ' + @UserName);
		--END
		
	    UPDATE OrderDetailStops
	    SET SchedulePickupDate = CASE WHEN ISNULL(@SchedulePickupDate, '') <> '' THEN @SchedulePickupDate ELSE SchedulePickupDate END,
	        SchedulePickupDateTo = DATEADD(MINUTE, DATEPART(HOUR, @SchedulePickupDateTo) * 60 + DATEPART(MINUTE, @SchedulePickupDateTo),     
									CAST(CONVERT(DATE, @SchedulePickupDate) AS DATETIME)),

	        ScheduleDeliveryDate = CASE WHEN ISNULL(@ScheduleDeliveryDate, '') <> '' THEN @ScheduleDeliveryDate ELSE ScheduleDeliveryDate END,
	        ScheduleDeliveryDateTo = DATEADD(MINUTE,DATEPART(HOUR,@ScheduleDeliveryDateTo) * 60 + DATEPART(MINUTE, @ScheduleDeliveryDateTo),
			                          CAST(CONVERT(DATE,@ScheduleDeliveryDate) AS DATETIME)),

	        DropOrLive = CASE WHEN ISNULL(@DropOrLive, '') <> '' THEN @DropOrLive ELSE DropOrLive END,
	        RefNo = @RefNo ,
			StopAddrKey= CASE WHEN ISNULL(@StopAddrKey,0) <> 0 THEN @StopAddrKey ELSE  StopAddrKey END,
			StopName=CASE WHEN ISNULL(@StopName,'')<>''  THEN @StopName  ELSE StopName END
	    WHERE OrderDetailStopKey = @OrderDetailStopKey AND OrderDetailKey = @OrderDetailKey;

	/*  SCHEDULE DELIVERY TAB ----StopTypeKey = 3  -------- IF Live is selected  → SET  PickupDate = DeliveryDate */

		 IF (@Identification = 'SD' AND @DropOrLive = 'L' AND @ScheduleDeliveryDate IS NOT NULL)
					BEGIN
						UPDATE OrderDetailStops
						SET
							SchedulePickupDate = @ScheduleDeliveryDate,
							SchedulePickupDateTo = DATEADD(MINUTE,
							DATEPART(HOUR, @ScheduleDeliveryDateTo) * 60
							 + DATEPART(MINUTE, @ScheduleDeliveryDateTo),
							CAST(CONVERT(DATE, @ScheduleDeliveryDate) AS DATETIME)
							)
						WHERE OrderDetailStopKey = @OrderDetailStopKey AND OrderDetailKey = @OrderDetailKey  AND StopTypeKey = 3;
					END

		
		--IF OBJECT_ID('tempdb..#olddata_OD') IS NOT NULL
		-- DROP TABLE #olddata_OD;
				
		--SELECT TMFCheckOff, CTFCheckOff,SizeCheckOff, IsTMFJCTPaid,IsTMFCustomerPaid, IsCTFJCTPaid,IsCTFCustomerPaid
		--INTO #olddata_OD
		--FROM OrderDetail WHERE OrderDetailKey = @OrderDetailKey;
			   		 
			IF (@SchedulePickupDate IS NOT NULL AND @CurrentPickupStopNumber IS NOT NULL )
			BEGIN
				UPDATE ODS
				SET ODS.ScheduleDeliveryDate = @SchedulePickupDate,
					ODS.ScheduleDeliveryDateTo = DATEADD(MINUTE,DATEPART(HOUR, @SchedulePickupDateTo) * 60+ DATEPART(MINUTE, @SchedulePickupDateTo),
						CAST(CONVERT(DATE, @SchedulePickupDate) AS DATETIME) )
				FROM OrderDetailStops ODS
				WHERE ODS.StopNumber = @CurrentPickupStopNumber AND  OrderDetailKey = @OrderDetailKey AND StopTypeKey<>3 ;
			END


			IF (@ScheduleDeliveryDate IS NOT NULL AND @CurrentDeliveryStopNumber IS NOT NULL)
			BEGIN
				UPDATE ODS
				SET ODS.SchedulePickupDate = @ScheduleDeliveryDate,
					ODS.SchedulePickupDateTo = DATEADD(
						MINUTE,DATEPART(HOUR, @ScheduleDeliveryDateTo) * 60+ DATEPART(MINUTE, @ScheduleDeliveryDateTo),
						CAST(CONVERT(DATE, @ScheduleDeliveryDate) AS DATETIME) )
				FROM OrderDetailStops ODS
				WHERE ODS.StopNumber = @CurrentDeliveryStopNumber  AND  OrderDetailKey = @OrderDetailKey AND StopTypeKey<>1 AND StopTypeKey<>5 ;
			END

			IF (@SchedulePickupDate IS NOT NULL AND @CurrentEmptyPickupStopNumber IS NOT NULL)
			BEGIN
				UPDATE ODS
				SET ODS.ScheduleDeliveryDate = @SchedulePickupDate,
					ODS.ScheduleDeliveryDateTo = DATEADD(MINUTE,DATEPART(HOUR, @SchedulePickupDateTo) * 60 + DATEPART(MINUTE,  @SchedulePickupDateTo),CAST(CONVERT(DATE, @SchedulePickupDate) AS DATETIME) )
				FROM OrderDetailStops ODS
				WHERE ODS.StopNumber = @CurrentEmptyPickupStopNumber  AND  OrderDetailKey = @OrderDetailKey AND   StopTypeKey<>1 AND StopTypeKey<>5  ;
			END


			IF (@ScheduleDeliveryDate IS NOT NULL AND @CurrentReturnStopNumber IS NOT NULL)
			BEGIN
				UPDATE ODS
				SET ODS.SchedulePickupDate = @ScheduleDeliveryDate,
					ODS.SchedulePickupDateTo = DATEADD(
						MINUTE,DATEPART(HOUR, @ScheduleDeliveryDateTo) * 60+ DATEPART(MINUTE,  @ScheduleDeliveryDateTo),
						CAST(CONVERT(DATE, @ScheduleDeliveryDate) AS DATETIME) )
				FROM OrderDetailStops ODS
				WHERE ODS.StopNumber = @CurrentReturnStopNumber  AND  OrderDetailKey = @OrderDetailKey AND StopTypeKey<>3 AND StopTypeKey<>5 ;
			END

			



	    IF(@Identification = 'SP')
		BEGIN
	      UPDATE OrderDetail
	      SET TMFCheckOff       = isnull(@TMFCheckOff,0),
	          CTFCheckOff       = isnull(@CTFCheckOff,0),
	          SizeCheckOff      = isnull(@SizeCheckOff,0),
	          IsTMFJCTPaid      = isnull(@IsTMFJCTPaid,0),
	          IsTMFCustomerPaid = isnull(@IsTMFCustomerPaid,0),
	          IsCTFJCTPaid      = isnull(@IsCTFJCTPaid,0),
			  IsCTFCustomerPaid = isnull(@IsCTFCustomerPaid,0)
	      WHERE OrderDetailKey = @OrderDetailKey;
		  
				--DECLARE @Comments1 nvarchar(max);
				--SET @Comments1 = ISNULL(@Comments1, '');

				--SELECT @UserName = UserName FROM [User] WHERE UserKey = @UserKey;

				--SELECT @ContainerNo = ContainerNo FROM OrderDetail WHERE OrderDetailKey = @OrderDetailKey;

				--					SET @Comments1 =
				--CASE  WHEN @TMFCheckOff = 1 AND ISNULL((SELECT TMFCheckOff FROM #olddata_OD), 0) = 0
				--	THEN 'TMF CheckOff Ticked, ' ELSE '' END +
				--CASE 
				--	WHEN @CTFCheckOff = 1  AND ISNULL((SELECT CTFCheckOff FROM #olddata_OD), 0) = 0
				--	THEN 'CTF CheckOff Ticked, ' ELSE '' END +
				--CASE 
				--	WHEN @SizeCheckOff = 1   AND ISNULL((SELECT SizeCheckOff FROM #olddata_OD), 0) = 0
				--	THEN 'Container Size CheckOff Ticked, ' ELSE '' END +
				--CASE 
				--	WHEN @IsTMFJCTPaid = 1  AND ISNULL((SELECT IsTMFJCTPaid FROM #olddata_OD), 0) = 0
				--	THEN 'TMF JCT Paid Ticked, ' ELSE '' END +
				--CASE 
				--	WHEN @IsTMFCustomerPaid = 1  AND ISNULL((SELECT IsTMFCustomerPaid FROM #olddata_OD), 0) = 0
				--	THEN 'TMF Customer Paid Ticked, ' ELSE '' END +
				--CASE 
				--	WHEN @IsCTFJCTPaid = 1 AND ISNULL((SELECT IsCTFJCTPaid FROM #olddata_OD), 0) = 0
				--	THEN 'CTF JCT Paid Ticked, '  ELSE '' END +
				--CASE 
				--	WHEN @IsCTFCustomerPaid = 1 AND ISNULL((SELECT IsCTFCustomerPaid FROM #olddata_OD), 0) = 0
				--	THEN 'CTF Customer Paid Ticked, ' ELSE '' END;

				--IF(LEN(@Comments1) > 0 AND @Identification = 'SP' )
				--BEGIN
				--	INSERT INTO dbo.AuditLogDetail
				--		(DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				--	SELECT DISTINCT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,NULL, 'Text',@Comments1
				--END
		END

	    SET @Row += 1;
	END

	CREATE TABLE #OrderDetailKeys
	(
	    RowNo INT IDENTITY(1,1),
	    OrderDetailKey INT
	);
	
	INSERT INTO #OrderDetailKeys (OrderDetailKey)
	SELECT DISTINCT OrderDetailKey
	FROM #InputTemp
	WHERE OrderDetailKey IS NOT NULL;
	
	DECLARE 
	    @TotalKeys INT,
	    @Idx INT = 1,
	    @CurrentOrderDetailKey INT;
	
	SELECT @TotalKeys = COUNT(*) FROM #OrderDetailKeys;
	
	WHILE @Idx <= @TotalKeys
	BEGIN
	    SELECT @CurrentOrderDetailKey = OrderDetailKey
	    FROM #OrderDetailKeys
	    WHERE RowNo = @Idx;

		DECLARE 
		    @MarketLocationKey INT,
		    @OrderTypeKey INT,
		    @ContainerSizeKey INT,
		    @TMF BIT,
		    @CTF BIT,
		    @Size BIT;
		
		SELECT 
		    @MarketLocationKey = ML.MarketLocationKey,
		    @OrderTypeKey = OD.OrderTypeKey,
		    @ContainerSizeKey = ISNULL(CGD.Size_Type,OD.ContainerSizeKey),
		    @TMF = OD.TMFCheckOff,
		    @CTF = OD.CTFCheckOff,
		    @Size = OD.SizeCheckOff
		FROM OrderDetail OD
		LEFT JOIN OrderHeader OH WITH (NOLOCK) ON OD.OrderKey=OH.OrderKey
		LEFT JOIN MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey=ML.MarketLocationKey
		LEFT JOIN Container_GnosisData CGD WITH (NOLOCK) ON OD.OrderDetailKey=CGD.OrderDetailKey
		WHERE OD.OrderDetailKey=@CurrentOrderDetailKey

		IF NOT
		(
		    (
		        @MarketLocationKey = 2
		        AND @OrderTypeKey = 1
		        AND (
		             ISNULL(@TMF, 0) = 0
		             OR ISNULL(@CTF, 0) = 0
		             OR ISNULL(@Size, 0) = 0
		            )
		    )		
		    OR
		    (
		        @MarketLocationKey = 3
		        AND @ContainerSizeKey = 86
		        AND ISNULL(@Size, 0) = 0
		    )
		)
		BEGIN
	
			IF NOT EXISTS (
			    SELECT 1
			    FROM dbo.OrderDetailStops WITH (NOLOCK)
			    WHERE OrderDetailKey = @CurrentOrderDetailKey
			      AND (
			            (StopTypeKey = 3 AND ISNULL(DropOrLive, '') = '')
			            OR StopAddrKey = 38953
			          )
			)
			BEGIN
			    EXEC [RoutesAndStopsLinking] @CurrentOrderDetailKey, 0, 0;
			    EXEC Scheduler_RecreateLegID @CurrentOrderDetailKey;
	
			    UPDATE RT  
			    SET   
			        SourceAddrKey = ODs.StopAddrKey,  
					PickupDateFrom = ODS.SchedulePickupDate ,  
					PickupDateTo = ODS.SchedulePickupDateTo ,  
					ScheduledPickupDate =  ODS.SchedulePickupDate ,  
					ActualDeparture = ODs.ActualPickupDate,  
					ConfirmationNo = ODS.RefNo,  
					LastUpdateDate = GETDATE(),  
					UpdateUserKey = @UserKey  
			    FROM dbo.Routes RT    
			    INNER JOIN dbo.OrderDetailStops ODS WITH (NOLOCK) ON RT.RouteKey = ODS.FromRouteKey  
			    WHERE ODS.OrderDetailKey = @CurrentOrderDetailKey;    
	
			    UPDATE RT  
			    SET   
			        DestinationAddrKey = ODs.StopAddrKey,  
					DeliveryDateFrom = ODS.ScheduleDeliveryDate ,  
					DeliveryDateTo = ODS.ScheduleDeliveryDateTo ,  
					LastUpdateDate = GETDATE(),  
					ActualArrival = ODS.ActualDeliveryDate,  
					UpdateUserKey = @UserKey,  
					IsBobtail = ODS.IsBobTail,  
					BobtailSetUser = ODs.BobtailSetUserKey,  
					BobtailSetDate = ODs.BobtailSetDateTime,  
					ISEmpty = ODs.IsEmpty,  
					EmptySetUser = ODs.EmptySetUserKey,  
					EmptySetDate = ODs.EmptySetDateTime,  
					isStreetTurn = ODs.IsStreetTurn,  
					StreetTurnSetUser = ODs.StreetSturnSetUserKey,  
					StreetTurnSetDate = ODS.StreetSturnSetDateTime,  
					DelConfirmationNo = ODS.RefNo,  
					IsChassisSplit = ODS.IsChassisSplit,  
					ChassisSplitBy = ODS.ChassisSplitSetUserKey,  
					ChassisSplitDate = ODS.ChassisSplitSetDateTime,  
			        LegType = CASE 
			                    WHEN ODS.DropOrLive = 'L' THEN 'Live'   
			                    WHEN ODS.DropOrLive = 'D' THEN 'Drop'  
			                    ELSE NULL 
			                  END  
			    FROM dbo.Routes RT  
			    INNER JOIN dbo.OrderDetailStops ODS WITH (NOLOCK) ON RT.RouteKey = ODS.ToRouteKey  
			    WHERE ODS.OrderDetailKey = @CurrentOrderDetailKey;
			END

		END
	
	    SET @Idx += 1;
	END
	
	DROP TABLE #OrderDetailKeys;

	SET @Status = 1;
	SET @Reason = 'Success';
END
--SELECT * FROM OrderDetailStops where OrderDetailStopKey = 677951
--SELECT * FROM OrderDetail
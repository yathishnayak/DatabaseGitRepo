

/*
DECLARE @UserKey INT = 714, @JSOnString NVARCHAR(MAX) = '', @Status BIT, @IntError NVARCHAR(MAX), @Reason VARCHAR(1000), @IsDebug BIT = 1
SET @JSONString = '{"DriverKey":1680,"OrderDetailKey":175225,"RouteKey":584517,"DocumentTypeDesc":"Container","ChassisKey":"0","ChassisNo":"DDDD23456","ChassisCategory":"OTHER","OrderType":"Export","ContainerNo":"AGAE2408600","Latitude":"13.3459788","Longitude":"74.7625864","DocDetails":null}'
EXEC [DA_DocumentsUpload] @UserKey,@JSOnString,@Status OUTPUT, @IntError OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status,@IntError,@Reason
*/

CREATE PROCEDURE	[dbo].[DA_DocumentsUpload]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '{"DriverKey":802,"OrderDetailKey":49348,"RouteKey":181871,"DocumentTypeDesc":"PickupDocs","ChassisKey":"","ChassisNo":"","ChassisCategory":"","OrderType":"Import","ContainerNo":"MRKU6122186","Latitude":"13.3460105","Longitude":"74.7625798","DocDetails":[{"DocumentType":15,"OriginalFileName":"Pickup_Documents_MRKU6122186_20241025_122600.pdf","OriginalFileType":"pdf","FileSizeinMB":"0.17","FilePath":"39\\38019/","Base64String":""}]}',
	@Status			BIT	= 0 OUTPUT,
	@IntError		NVARCHAR(MAX) = '' OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0,
	@FirebaseID		VARCHAR(500) = '',
	@IsLogout		BIT = 0 OUTPUT
)

AS
BEGIN
	SET @IsLogout = 0

	-- validate
	DECLARE @ValidateUser BIT = 0, @FBInternalError NVARCHAR(MAX), @FBExternalError  VARCHAR(1000)
	EXEC DA_ValidateUserFireBaseID @UserKey,@FirebaseID, @ValidateUser OUTPUT, @FBInternalError OUTPUT, @FBExternalError OUTPUT

	DECLARE @LogKey INT
	DECLARE	@UserName VARCHAR(50) = (SELECT UserName FROM [User] WHERE UserKey = @UserKey )

	INSERT INTO DA_RequestResponseLogs (ProcedureName,UserKey,RequestJSONString,FirebaseID,IsDebug,CreatedDate)
	SELECT  OBJECT_NAME(@@PROCID),@UserKey,@JSONString,@FirebaseID,@IsDebug,GETDATE()

	SET @LogKey = @@IDENTITY

	IF(@IsDebug = 1)
		BEGIN
			SET @ValidateUser = 1
		END

	IF(@ValidateUser = 0)
		BEGIN
			SET @Status = 0
			SET @IntError = @FBInternalError
			SET @Reason = @FBExternalError
			SET @IsLogout = 1

			UPDATE DA_RequestResponseLogs
			SET OutputStatus = @Status, OutputInternalError = @IntError, OutputExternallError= @Reason, IsLogout = @IsLogout, UpdatedDate = GETDATE(), ReponseJSONString = NULL
			WHERE LogKey = @LogKey


			RETURN
		END
	-- validate
	

	BEGIN TRY
	BEGIN TRANSACTION

		DECLARE		@DriverKey			INT,
					@OrderDetailKey		INT,
					@RouteKey			INT,
					@DocumentTypeDesc	VARCHAR(20),
					@DocDetailsJSOn			NVARCHAR(MAX),
					@DocumentType		INT,
					@OriginalFileName	VARCHAR(500),
					@OriginalFileType	VARCHAR(20),
					@FileSizeinMB		DECIMAL(18,2),
					@FilePath			VARCHAR(50),
					@ChassisKey			INT,
					@ChassisNo			VARCHAR(50),
					@ChassisCategory	VARCHAR(20),
					@ChassisCategoryKey	INT,
					@OrderType			VARCHAR(20),
					@ContainerNo		VARCHAR(50),
					@Latitude			FLOAT,
					@Longitude			FLOAT

		DECLARE		 @ConfirmPickup BIT, @ConfirmEquipments  BIT, @PickUpDocs  BIT, @ConfirmDelivery  BIT, @DeliveryDocs  BIT
							, @PairContainer  BIT, @Charges  BIT, @Complete  BIT 

		DECLARE @GenError		VARCHAR(200) = 'Something Went Wrong, Contact System Administrator; '
		DECLARE @InternalError	VARCHAR(1000) = ''		
		SET		@Status = 1

		IF (ISNULL(@JSONString,'') = '')
			BEGIN
				SET	@Status = 0
				SET @InternalError = 'JSON String Cannot be Blank; '
			END
		ELSE IF(ISNULL(@UserKey,0) = 0)
			BEGIN
				SET	@Status = 0
				SET @InternalError = 'UserKey Cannot be Blank'
			END
		ELSE
			BEGIN
				DECLARE  @IsDocUploaded INT = 0

				SELECT		@DriverKey = DriverKey, @OrderDetailKey = OrderDetailKey, @RouteKey = RouteKey, @DocumentTypeDesc = DocumentTypeDesc, @DocDetailsJSOn = DocDetails
							,@ChassisKey  = ChassisKey, @ChassisNo = ChassisNo, @ChassisCategory = ChassisCategory, @OrderType = OrderType, @ContainerNo = ContainerNo
							,@Latitude = Latitude, @Longitude = Longitude
				FROM		OPENJSON(@JSONString, '$')
							WITH (
									DriverKey			INT				'$.DriverKey',
									OrderDetailKey		INT				'$.OrderDetailKey',
									RouteKey			INT				'$.RouteKey',
									DocumentTypeDesc	VARCHAR(20)		'$.DocumentTypeDesc',
									ChassisKey			INT				'$.ChassisKey',
									ChassisNo			VARCHAR(50)		'$.ChassisNo',
									ChassisCategory		VARCHAR(20)		'$.ChassisCategory',
									OrderType			VARCHAR(20)		'$.OrderType',
									ContainerNo			VARCHAR(50)		'$.ContainerNo',
									Latitude			FLOAT			'$.Latitude',
									Longitude			FLOAT			'$.Longitude',
									DocDetails			NVARCHAR(MAX)	'$.DocDetails' AS JSON
									)

				
				SET			@ChassisKey			= ISNULL(@ChassisKey, 0)
				SET			@ChassisNo			= ISNULL(@ChassisNo, '')
				SET			@ChassisCategory	= ISNULL(@ChassisCategory,'')
				SET			@OrderType			= ISNULL(@OrderType,'')
				SET			@ContainerNo		= ISNULL(@ContainerNo,'')

				SET @OrderType = (SELECT OT.OrderType FROM OrderHeader OH WITH (NOLOCK) 
									INNER JOIN OrderDetail OD ON OH.OrderKey = OD.OrderKey
									INNER JOIN OrderType OT ON OH.OrderTypeKey = OT.OrderTypeKey
									WHERE OrderDetailKey = @OrderDetailKey
									)

				CREATE TABLE #TempDocList
				(
					SL					INT,
					DocumentType		INT,
					OriginalFileName	VARCHAR(200),
					OriginalFileType	VARCHAR(20),
					FileSizeinMB		VARCHAR(20),
					FilePath			VARCHAR(20),
					IsError				BIT ,
					ErrorMessage		VARCHAR(200)
				)

				INSERT INTO		#TempDocList
								(Sl,DocumentType,OriginalFileName,OriginalFileType,FileSizeinMB,FilePath)
				SELECT			ROW_NUMBER() OVER (ORDER BY OriginalFileName),*
				FROM			OPENJSON(@DocDetailsJSOn, '$')
								WITH (
										DocumentType			INT				'$.DocumentType',
										OriginalFileName		VARCHAR(200)	'$.OriginalFileName',
										OriginalFileType		VARCHAR(20)		'$.OriginalFileType',
										FileSizeinMB			VARCHAR(20)		'$.FileSizeinMB',
										FilePath				VARCHAR(20)		'$.FilePath' 
										)

				SELECT		*
				INTO		#TempDataList
				FROM		#TempDocList
				WHERE		ISNULL(DocumentType,0) > 0 AND ISNULL(OriginalFileName,'') <> '' AND ISNULL(OriginalFileType,'') <> '' AND ISNULL(FilePath,'') <> ''


				DECLARE @IsChassisData		BIT	= CASE WHEN @DocumentTypeDesc = 'Container' THEN 1 ELSE 0 END				
				DECLARE @IsContainerData	BIT	= CASE WHEN @DocumentTypeDesc = 'Container' THEN 1 ELSE 0 END
				DECLARE @IsPickupDocsData	BIT	= CASE WHEN @DocumentTypeDesc = 'PickupDocs' THEN 1 ELSE 0 END
				DECLARE @IsDeliveryDocsData BIT	= CASE WHEN @DocumentTypeDesc = 'DeliveryDocs' THEN 1 ELSE 0 END
				DECLARE @ExtraDocsData		BIT	= CASE WHEN @DocumentTypeDesc = 'ExtraDocs' THEN 1 ELSE 0 END
				DECLARE @RecordExists		INT	= (SELECT COUNT(1) FROM #TempDataList )

				-- SET @DocumentType = (SELECT DocumentType FROM #TempDataList)

				SELECT		@ConfirmPickup = ISNULL(ConfirmPickup,0), @ConfirmEquipments = ISNULL(ConfirmEquipments,0)
							, @PickUpDocs = ISNULL(PickUpDocs,0), @ConfirmDelivery = ISNULL(ConfirmDelivery,0), @DeliveryDocs = ISNULL(DeliveryDocs,0) 
							, @PairContainer = ISNULL(PairContainer,0), @Charges = ISNULL(Charges,0), @Complete = ISNULL(Complete,0) 
				FROM		DA_AppDriverScreenDetails  WITH (NOLOCK)
				WHERE		RouteKey = @RouteKey

				--IF(@IsChassisData = 1 OR @IsContainerData = 1)
				--	BEGIN
				--		UPDATE #TempDataList SET DocumentType = 9
				--	END
				--ELSE IF(@IsPickupDocsData = 1)
				--	BEGIN
				--		UPDATE #TempDataList SET DocumentType = 16
				--	END
				--ELSE IF(@IsDeliveryDocsData = 1)
				--	BEGIN
				--		UPDATE #TempDataList SET DocumentType = 15
				--	END

				SET @Status = 1

				SELECT * INTO #MultiImages FROM(
				SELECT		DocumentType, COUNT(*) tt
				FROM		#TempDataList
				GROUP BY	DocumentType
				HAVING COUNT(*) > 1) A

				IF(@IsDebug = 1)
					BEGIN
						SELECT 'Multiple Images for DocumentType', * FROM #MultiImages
					END

				DECLARE @MultipleImages INT = (SELECT COUNT(*) FROM #MultiImages )

				DECLARE @ii INT = 1 , @nn INT = (SELECT COUNT(*) FROM #TempDataList)

				WHILE (@ii <= @nn AND @MultipleImages = 0)
					BEGIN
					-- SELECT @ii
						SET		@DocumentType = (SELECT DocumentType FROM #TempDataList WHERE SL = @ii )

						SET @IsDocUploaded =(SELECT		COUNT(*)
											FROM		Document DO WITH (NOLOCK) 
											INNER JOIN	ContainerLegDocuments DT WITH (NOLOCK) ON DT.DocumentKey=DO.DocumentKey
											INNER JOIN	DriverDocuments DD WITH (NOLOCK) ON DD.DocumentKey = DO.DocumentKey
											WHERE		DO.DocumentType = @DocumentType AND DocumentTypeDesc = @DocumentTypeDesc AND RouteKey = @RouteKey )
								
						IF(@IsDebug = 1)
							BEGIN
								SELECT @DocumentType,@DocumentTypeDesc,@RouteKey,@IsDocUploaded
							END
						
						IF(@IsDocUploaded > 0)
							BEGIN
								--SET	@Status = 0
								SET @InternalError =  'Already Uploaded the Document to this Document Type, delete and Upload again'
								--SET	@GenError = @InternalError

								UPDATE	#TempDataList
								SET		IsError = 1, ErrorMessage = @InternalError
								WHERE	SL = @ii
							END
						SET @ii = @ii + 1
					END
				--IF(@IsContainerData = 1 AND @ContainerScreen = 1)
				--	BEGIN
				--		SET	@Status = 0
				--		SET @InternalError = 'Container Details Already Updated'
				--		SET	@GenError = @InternalError
				--	END
				--ELSE IF(@IsChassisData = 1 AND @ChassisScreen = 1)
				--	BEGIN
				--		SET	@Status = 0
				--		SET @InternalError = 'Chassis Details Already Updated'
				--		SET	@GenError = @InternalError
				--	END
				--ELSE IF(@IsPickupDocsData = 1 AND @PickupScreen = 1)
				--	BEGIN
				--		SET	@Status = 0
				--		SET @InternalError = 'Pickup Details is Already Updated'
				--		SET	@GenError = @InternalError
				--	END
				--ELSE IF(@IsDeliveryDocsData = 1 AND @DeliveryScreen = 1)
				--	BEGIN
				--		SET	@Status = 0
				--		SET @InternalError = 'Delivery Details Already Updated'
				--		SET	@GenError = @InternalError
				--	END
				
				--ELSE


				--IF(SELECT COUNT(*) FROM #TempDataList WHERE ISNULL(DocumentType,0) = 0) > 0
				--	BEGIN
				--		SET	@Status = 0
				--		SET @InternalError =  'DocumentType Cannot Be 0'
				--	END
				IF(@MultipleImages > 0)
					BEGIN
						SET	@Status = 0
						SET @InternalError =  'Single File can be uploaded to a single Document Type'
						SET	@GenError = @InternalError
					END
				ELSE IF((SELECT COUNT(*) FROM #TempDataList WHERE IsError = 1) > 0)
					BEGIN
						SET	@Status = 0
						SET @InternalError = (SELECt STRING_AGG(CAST(DT.Description AS VARCHAR(MAX)) + ' - ' + CAST(ErrorMessage AS VARCHAR(MAX)), '; ')  
						FROM #TempDataList T
						INNER JOIN DocumenType  DT ON T.DocumentType = DT. DocumentTypeKey
						WHERE IsError = 1 )
						SET	@GenError = @InternalError
					END
				ELSE
					BEGIN				
						IF(@DriverKey = 0 OR @OrderDetailKey = 0 OR @RouteKey = 0)
							BEGIN
								SET	@Status = 0
								SET @InternalError = @InternalError + '; Check DriverKey Or OrderDetailkey Or RouteKey'
							END

						IF(@DocumentTypeDesc NOT IN ('Container','Chassis','PickupDocs','DeliveryDocs','ExtraDocs'))
							BEGIN
								SET	@Status = 0
								SET @InternalError = @InternalError + '; Check Document Type Desc Values'
							END

						IF(@OrderType = '' OR (@OrderType NOT IN ('Import','Export','Door to Door','Empty')))
							BEGIN
								SET	@Status = 0
								SET @InternalError = @InternalError + '; Check Order Type'
							END
						ELSE
							BEGIN
								IF(@OrderType = 'Export' AND @ContainerNo = '')
									BEGIN
										SET	@Status = 0
										SET @InternalError = @InternalError + '; Container No Cannot Be Blank'
									END
							END

						IF((@IsPickupDocsData = 1 OR @IsDeliveryDocsData = 1) AND ISNULL(@RecordExists,0) > 0 AND (SELECT COUNT(1) FROM #TempDataList WHERE ISNULL(DocumentType,0) = 0) > 0)
							BEGIN
								SET	@Status = 0
								SET @InternalError = @InternalError + '; Check Document Type Values'
							END

						IF(@ChassisCategory = '' AND @IsChassisData = 1)
							BEGIN
								SET	@Status = 0
								SET @InternalError = @InternalError + '; Chassis Category Cannot be Blank'
							END
						ELSE IF (@IsChassisData = 1)
							BEGIN
								-- SELECT @ChassisCategory
								
								IF(@ChassisCategory NOT IN ('JCT','OTHER'))
									BEGIN
										SET	@Status = 0
										SET @InternalError = @InternalError + '; Check Chassis Category Values' 
									END		
								ELSE
									BEGIN
										IF(@ChassisCategory = 'OTHER')
											BEGIN
												SET @ChassisCategory  = CASE WHEN LEFT(LTRIM(RTRIM(@ChassisNo)),4) = 'AIMZ' THEN 'Customer' ELSE 'Port' END
											END

										SET @ChassisCategoryKey = (SELECT ChassisCategoryKey FROM ChassisCategory WHERE ChassisCategory = @ChassisCategory )
									END
							END
						--SELECT @ChassisCategoryKey ,ISNULL(@ChassisNo,'') ,@IsChassisData 

						IF(@IsDebug = 1)
							BEGIN
								SELECT 'Chassiskey', @Chassiskey, @IsChassisData, @ChassisCategoryKey
							END

						IF(@IsChassisData = 1 AND @ChassisCategoryKey IN (2,3))
							BEGIN
								IF(ISNULL(@ChassisNo,'') = '' )
									BEGIN
										SET	@Status = 0
										SET @InternalError = @InternalError + '; Chassis No Cannot be Blank' 
									END
								ELSE
									BEGIN
										SET @ChassisKey = 591
									END
							END

						IF(@ChassisCategoryKey IN (1) AND ISNULL(@ChassisKey,0) = 0 AND @IsChassisData = 1)
							BEGIN
								SET	@Status = 0
								SET @InternalError = @InternalError + '; Chassis Key cannot be null' 
							END
					END
			END
		
		IF(@IsDebug = 1)
			BEGIN
				SELECT 'Chassiskey', @Chassiskey, @IsChassisData, @ChassisCategoryKey
			END

		IF(@Status = 0)
			BEGIN
				SET		@IntError = (SELECT dbo.DA_ReplaceStartSemicolon (@InternalError))
				SET		@Reason = @GenError
			END
		ELSE IF((SELECT COUNT(*) FROM ROutes WITH (NOLOCK) WHERE RouteKey = @RouteKey AND Status = 5) > 0)
			BEGIN
				SET		@IntError = 'This Leg is already Completed'
				SET		@Reason = @GenError
			END
		ELSE
			BEGIN					
				
				DECLARE @OldChassisCategory VARCHAR(20) = '',  @OldChassisNo VARCHAR(50) = '', @LegID VARCHAR(50), @FromLocation VARCHAR(50) = ''

				INSERT INTO		DA_GeographyDetails(Routekey,Latitude,Longitude,CreatedDate)
				SELECT			@RouteKey,@Latitude,@Longitude,GETDATE()

				SET			@DocumentType		= ISNULL(@DocumentType,0)
				SET			@OriginalFileName	= ISNULL(@OriginalFileName, '')
				SET			@OriginalFileType	= ISNULL(@OriginalFileType, '')
				SET			@FileSizeinMB		= ISNULL(@FileSizeinMB, 0)
				SET			@FilePath			= ISNULL(@FilePath, '')

				SELECT		@OldChassisCategory = ISNULL(CC.ChassisCategory,''),@OldChassisNo = ISNULL(ChassisNo,0)
							,@LegID = ISNULL(L.LegID,''), @FromLocation = L.FromLocation
				FROM		Routes  R   WITH (NOLOCK)
				LEFT JOIN	ChassisCategory CC  WITH (NOLOCK) ON R.ChassisCategoryKey = CC.ChassisCategoryKey
				INNER JOIN	Leg L  WITH (NOLOCK) ON R.LegKey = L.LegKey
				WHERE		RouteKey = @RouteKey
					

				IF(@IsChassisData = 1 AND ISNULL(@OldChassisNo,'') <> ISNULL(@ChassisNo,''))
					BEGIN
						UPDATE		R
						SET			ChassisCategoryKey = @ChassisCategoryKey, ChassisKey = @ChassisKey, ChassisSource = 'Driver Edit – Chassis', ChassisChangedDate = GETDATE()
									, ChassisChangedUser = @UserKey
									--,ChassisNo = CASE WHEN @DocumentTypeDesc = 'Chassis' AND @ChassisCategory IN ('Port','Customer') THEN @ChassisNo ELSE ChassisNo END
									,ChassisNo = CASE WHEN @IsChassisData = 1 THEN @ChassisNo ELSE ChassisNo END
						FROM		Routes R
						WHERE		RouteKey = @RouteKey

						--UPDATE		Routes
						--SET			ChassisNo=   CASE WHEN ISNULL(ChassisNo,'')<>'' THEN ChassisNo ELSE @ChassisNo END,
						--			-- ChassisType= CASE WHEN ISNULL(ChassisType,'')<>'' THEN ChassisType ELSE @ChassisType END,
						--			ChassisKey=  CASE WHEN ISNULL(ChassisKey,0)<>0 THEN ChassisKey ELSE @ChassisKey END,
						--			ChassisCategoryKey= CASE WHEN ISNULL(ChassisCategoryKey,0)<>0 THEN ChassisCategoryKey ELSE @ChassisCategoryKey END
						--WHERE		OrderDetailKey= @OrderDetailKey AND RouteKey<>@RouteKey
						--			AND  [Status] NOT IN (  
						--									SELECT [Status] 
						--									FROM dbo.RouteStatus 
						--									WHERE [Description]='Leg Completed'
						--								 )


						UPDATE Routes
							SET 
								ChassisNo = COALESCE(NULLIF(ChassisNo, ''), @ChassisNo),
								-- ChassisType = COALESCE(NULLIF(ChassisType, ''), @ChassisType),
								ChassisKey = COALESCE(NULLIF(ChassisKey, 0), @ChassisKey),
								ChassisCategoryKey = COALESCE(NULLIF(ChassisCategoryKey, 0), @ChassisCategoryKey)
							WHERE 
								OrderDetailKey = @OrderDetailKey 
								AND RouteKey <> @RouteKey
								AND [Status] NOT IN (
									SELECT [Status] 
									FROM dbo.RouteStatus 
									WHERE [Description] = 'Leg Completed'
								)
						
						------------------------Update AuditLogDetail-------------------------------------
						IF(@OldChassisCategory <> @ChassisCategory AND @OldChassisCategory <> '')
							BEGIN
								INSERT INTO		AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
								SELECT			GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, 'DriverApp', 'Text'
												, 'Chassis Category Changed from ' + @OldChassisCategory + ' to ' + @ChassisCategory + ' For Leg - ' + @LegID
							END

						IF(@OldChassisCategory <> @ChassisCategory AND @OldChassisCategory = '')
							BEGIN
								INSERT INTO		AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
								SELECT			GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, 'DriverApp', 'Text'
												, 'Chassis Category was Blank, Updated to ' + @ChassisCategory + ' For Leg - ' + @LegID
							END

						IF(@OldChassisNo <> @ChassisNo AND @OldChassisNo <> '' )
							BEGIN
								INSERT INTO		AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
								SELECT			GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, 'DriverApp', 'Text'
												, 'Chassis No Changed from ' + @OldChassisNo + ' to ' + @ChassisNo  + ' For Leg - ' + @LegID
							END

						IF(@OldChassisNo <> @ChassisNo AND @OldChassisNo = '')
							BEGIN
								INSERT INTO		AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
								SELECT			GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, 'DriverApp', 'Text'
												, 'Chassis Category was Blank, Updated to ' + @ChassisNo  + ' For Leg - ' + @LegID
							END
						-------------------------------------------------------------------------------------------------------------
					END

				IF(@IsDebug = 1)
					BEGIN
						SELECT '@OrderType',@OrderType
					END

				IF(@OrderType = 'Export' AND @IsContainerData = 1 )
					BEGIN
						DECLARE		@OldContainerNo VARCHAR(50)= ''
						
						UPDATE		OD
						SET			@OldContainerNo = ISNULL(ContainerNo,'')
						FROM		OrderDetail OD  
						WHERE		OrderDetailKey = @OrderDetailKey

						IF(@IsDebug = 1)
							BEGIN
								SELECT @OldContainerNo ,  @ContainerNo, @OrderDetailKey
							END

						------------------------Update AuditLogDetail-------------------------
						IF(@OldContainerNo <> @ContainerNo)
							BEGIN
								UPDATE		OD
								SET			ContainerNo = @ContainerNo, ContainerNoSource = 'Driver Edit – Container', ContainerNoDate = GETDATE(), ContainerNoUser = @UserKey
								FROM		OrderDetail OD  
								WHERE		OrderDetailKey = @OrderDetailKey

								IF(@OldContainerNo = '')
									BEGIN
										INSERT INTO	AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
										SELECT		GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, 'DriverApp', 'Text'
													, 'Container No was Blank, Updated to ' + @ContainerNo
									END
								ELSE
									BEGIN
										INSERT INTO	AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
										SELECT		GETDATE(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, 'DriverApp', 'Text'
													, 'Container No Changed from ' + @OldContainerNo + ' to ' + @ContainerNo
									END

							END
						-------------------------------------------------------------------------------------
					END

				
				DECLARE @i INT = 1 , @n INT = (SELECT COUNT(*) FROM #TempDataList), @DocumentKey INT
				WHILE(@i <= @n)
					BEGIN
						SELECT			@DocumentType = DocumentType, @OriginalFileName = OriginalFileName,@OriginalFileType = OriginalFileType,@FilePath = FileSizeinMB,@FilePath = FilePath
						FROM			#TempDataList
						WHERE			SL = @i AND ISNULL(IsError,0) = 0
		
						INSERT INTO		Document
										(DocumentType,CreateDate,CreateUserKey,OriginalFileName,OriginalFileType,FileSizeinMB,IsDeleted,DeletedDate,DeletedUserKey,FilePath)
						SELECT			@DocumentType,GETDATE(),@UserKey,@OriginalFileName,@OriginalFileType,@FileSizeinMB,0,NULL,NULL,@FilePath
						SET				@DocumentKey = @@IDENTITY

						INSERT INTO		DriverDocuments (DocumentKey,DriverKey,DocumentTypeDesc, DocSource)
						SELECT			@DocumentKey,@DriverKey,@DocumentTypeDesc,'DriverApp'

						INSERT INTO		OrderDetailDocuments (OrderDetailKey,DocumentKey)
						SELECT			@OrderDetailKey,@DocumentKey 

						INSERT INTO		ContainerLegDocuments (RouteKey,DocumentKey)
						SELECT			@RouteKey,@DocumentKey 

						SET @i = @i + 1
					END
				--------------------------------------------SCREEN COMPLETED DETAILS ------------------------------
				IF(SELECT COUNT(*) FROM DA_AppDriverScreenDetails WHERE RouteKey = @RouteKey) = 0
					BEGIN
						INSERT INTO DA_AppDriverScreenDetails
									(DriverKey,UserKey,RouteKey,ConfirmPickup,ConfirmEquipments,PickUpDocs,ConfirmDelivery,DeliveryDocs,PairContainer
									,Charges,Complete,CreatedDate,UpdatedDate)
						SELECT		@DriverKey,@UserKey,@RouteKey,0,@IsContainerData,@IsPickupDocsData,0,@IsDeliveryDocsData,0,0,0,GETDATE(),GETDATE()
					END
				ELSE
					BEGIN
						IF(@IsContainerData = 1)
							BEGIN
								UPDATE		A
								SET			ConfirmEquipments = @IsContainerData
								FROM		DA_AppDriverScreenDetails A
								WHERE		Routekey = @RouteKey
							END
						--ELSE IF (@IsChassisData = 1)
						--	BEGIN
						--		UPDATE		A
						--		SET			ChassisScreen = @IsChassisData
						--		FROM		DA_AppDriverScreenDetails A
						--		WHERE		Routekey = @RouteKey
						--	END
						ELSE IF (@IsPickupDocsData = 1)
							BEGIN
								UPDATE		A
								SET			PickUpDocs = @IsPickupDocsData
								FROM		DA_AppDriverScreenDetails A
								WHERE		Routekey = @RouteKey
							END
						ELSE IF (@IsDeliveryDocsData = 1)
							BEGIN
								UPDATE		A
								SET			DeliveryDocs = @IsDeliveryDocsData
								FROM		DA_AppDriverScreenDetails A
								WHERE		Routekey = @RouteKey
							END
					END
				-----------------------------------------------------------------------------------------------	
				
				--IF(@DocumentTypeDesc = 'PickupDocs')
				--	BEGIN
				--		UPDATE	Routes
				--		SET		ActualDeparture = GETDATE()
				--		WHERE	RouteKey = @RouteKey
				--	END
				
				--IF(@DocumentTypeDesc = 'DeliveryDocs')
				--	BEGIN
				--		UPDATE	Routes
				--		SET		ActualArrival = GETDATE()
				--		WHERE	RouteKey = @RouteKey
				--	END
				
				SET		@IntError = 'Success'
				SET		@Reason = 'Success'
				
			END

	If(@IsDebug = 1)
		BEGIN
			SELECT @DocumentTypeDesc, @RouteKey 
		END

	DECLARE @JsonRes NVARCHAR(MAX), @FileUploadURL	VARCHAR(200)
	SET @FileUploadURL = (SELECT ConfigValue1 FROM DA_ConfigValues WHERE ConfigKey = 1 )



	SET @JsonRes =	(Select  OD.ContainerNo as ContainerNo,@FileUploadURL AS BaseFilePath, CC.ChassisCategory as ChassisCategory
					, RT.ChassisKey AS ChassisKey, ChassisNo AS ChassisNo 
					
					, DocDetails = (SELECT * FROM
										(SELECT			DT.Description DocType, REPLACE(DO.FilePath,'\','/')FilePath , DO.OriginalFileName AS DocFileName
														,DD.DocumentTypeDesc, DocumentType AS DocTypeKey, DO.DocumentKey
										FROM			ContainerLegDocuments CLD WITH (NOLOCK)
										INNER JOIN		Document DO WITH (NOLOCK) ON DO.DocumentKey=CLD.DocumentKey
										INNER JOIN		DocumenType DT WITH (NOLOCK) ON DT.DocumentTypeKey=DO.DocumentType
										INNER JOIN		DriverDocuments DD ON DO.DocumentKey = DD.DocumentKey
										WHERE			CLD.RouteKey = RT.RouteKey AND DD.DocumentTypeDesc = @DocumentTypeDesc AND CLD.RouteKey = RT.RouteKey
											)	A FOR JSON PATH) 
					FROM			Routes RT 
					INNER JOIN		OrderDetail OD WITH (NOLOCK)   ON RT.OrderDetailKey = OD.OrderDetailKey
					LEFT JOIN		ChassisCategory CC WITH (NOLOCK) ON RT.ChassisCategoryKey = CC.ChassisCategoryKey
					WHERE			RT.RouteKey = @RouteKey 
						FOR JSON PATH)

	SELECT ISNULL(@JsonRes,'')

	--DROP TABLE #MultiImages
	--DROP TABLE #TempDataList
	--DROP TABLE #TempDocList

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
        ROLLBACK TRANSACTION

		SET		@Status = 0
		SET		@IntError = 'Procedure Name : ' + ERROR_PROCEDURE() + '. Error Message : ' +  ERROR_MESSAGE() 
		SET		@Reason = 'Data Exception Error'
	END CATCH

	UPDATE DA_RequestResponseLogs
	SET OutputStatus = @Status, OutputInternalError = @IntError, OutputExternallError= @Reason, UpdatedDate = GETDATE(), ReponseJSONString = ISNULL(@JsonRes,''), IsLogout = @IsLogout
	WHERE LogKey = @LogKey

END

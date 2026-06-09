/*
exec [dbo].[COSTACC_InsertFileProcessData] @FileProcesskey=52,@JSOnData=N'[{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":52,"SlNo":0,"Group":"Warehouse","Line Item":"Transload","Terminal":"LA/LB","Truck Type":null,"Yard Port":null,"Zone":null,"Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"211.33"," Effective Date ":"1/1/2021 12:00:00 AM","Effective Date From":"Order Creation","Free Per":null,"Split_Percent":null},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Warehouse","Line Item":"Devanning Fee","Terminal":"LA/LB","Truck Type":null,"Yard Port":null,"Zone":null,"Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"461.24"," Effective Date ":"1/1/2021 12:00:00 AM","Effective Date From":"Order Creation","Free Per":null,"Split_Percent":null},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Re-Spot","Terminal":"LA/LB","Truck Type":null,"Yard Port":null,"Zone":null,"Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"15"," Effective Date ":"1/1/2021 12:00:00 AM","Effective Date From":"Order Creation","Free Per":null,"Split_Percent":null},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Clean Truck Fee","Terminal":"LA/LB","Truck Type":null,"Yard Port":null,"Zone":null,"Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"15"," Effective Date ":"1/1/2021 12:00:00 AM","Effective Date From":"Order Creation","Free Per":null,"Split_Percent":null},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"WAREHOUSE","Line Item":"FORK LIFT/STORAGE","Terminal":"LA/LB","Truck Type":null,"Yard Port":null,"Zone":null,"Fixed vs Non Fixed":"Fixed","Per":"Occurence"," Unit Cost ":"10"," Effective Date ":"1/1/2021 12:00:00 AM","Effective Date From":"Order Creation","Free Per":null,"Split_Percent":null},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"WAREHOUSE","Line Item":"Re-load","Terminal":"LA/LB","Truck Type":null,"Yard Port":null,"Zone":null,"Fixed vs Non Fixed":"Fixed","Per":"Occurence"," Unit Cost ":"100"," Effective Date ":"1/1/2021 12:00:00 AM","Effective Date From":"Order Creation","Free Per":null,"Split_Percent":null},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Clean Truck Fee- 20 ft","Terminal":"LA/LB","Truck Type":null,"Yard Port":null,"Zone":null,"Fixed vs Non Fixed":"Fixed","Per":"Occurence"," Unit Cost ":"10"," Effective Date ":"1/1/2021 12:00:00 AM","Effective Date From":"Order Creation","Free Per":null,"Split_Percent":null},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Clean Truck Fee- 40 ft","Terminal":"LA/LB","Truck Type":null,"Yard Port":null,"Zone":null,"Fixed vs Non Fixed":"Fixed","Per":"Occurence"," Unit Cost ":"20"," Effective Date ":"1/1/2021 12:00:00 AM","Effective Date From":"Order Creation","Free Per":null,"Split_Percent":null},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Pier Pass- 20 ft","Terminal":"LA/LB","Truck Type":null,"Yard Port":null,"Zone":null,"Fixed vs Non Fixed":"Fixed","Per":"Occurence"," Unit Cost ":"35.54"," Effective Date ":"1/1/2021 12:00:00 AM","Effective Date From":"Order Creation","Free Per":null,"Split_Percent":null},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Pier Pass- 40 ft","Terminal":"LA/LB","Truck Type":null,"Yard Port":null,"Zone":null,"Fixed vs Non Fixed":"Fixed","Per":"Occurence"," Unit Cost ":"71.14"," Effective Date ":"1/1/2021 12:00:00 AM","Effective Date From":"Order Creation","Free Per":null,"Split_Percent":null},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Chassis Split","Terminal":"LA/LB","Truck Type":"Broker Carrier","Yard Port":null,"Zone":null,"Fixed vs Non Fixed":"Fixed","Per":"Occurence"," Unit Cost ":"50"," Effective Date ":"4/1/2024 12:00:00 AM","Effective Date From":"Order Creation","Free Per":null,"Split_Percent":null},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Chassis Split","Terminal":"LA/LB","Truck Type":"Company - Asset","Yard Port":null,"Zone":null,"Fixed vs Non Fixed":"Fixed","Per":"Occurence"," Unit Cost ":"65"," Effective Date ":"4/1/2024 12:00:00 AM","Effective Date From":"Order Creation","Free Per":null,"Split_Percent":null}]'
*/

CREATE PROCEDURE [dbo].[COSTACC_InsertFileProcessData] -- COSTACC_InsertFileProcessData 6,'[{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":5,"SlNo":0,"Group":"Drayage","Line Item":"Chassis- JCT","Fixed vs Non Fixed":"Fixed","Per":"Day"," Unit Cost ":"10"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Chicago","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Chassis- JCT","Fixed vs Non Fixed":"Fixed","Per":"Day"," Unit Cost ":"10"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Chassis- Port","Fixed vs Non Fixed":"Fixed","Per":"Day"," Unit Cost ":"34"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Chicago","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Chassis- Port","Fixed vs Non Fixed":"Fixed","Per":"Day"," Unit Cost ":"28"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Chassis Split","Fixed vs Non Fixed":"Fixed","Per":"Occurence"," Unit Cost ":"60"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Chicago","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Chassis Split","Fixed vs Non Fixed":"Fixed","Per":"Occurence"," Unit Cost ":"60"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Clean Truck Fee- 20 ft","Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"10"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Clean Truck Fee- 40 ft","Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"20"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Dry Run- Export","Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"204.87"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Chicago","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Dry Run- Export","Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"100"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Dry Run- Import","Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"97.55"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Chicago","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Dry Run- Import","Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"100"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Genset","Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"75"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Chicago","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Genset","Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"75"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Hazmat Surcharge","Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"75"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Chicago","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Hazmat Surcharge","Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"75"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Overweight Surcharge","Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"50"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Chicago","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Overweight Surcharge","Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"50"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Pier Pass- 20 ft","Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"34.21"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Pier Pass- 40 ft","Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"68.42"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Residential Fee","Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"25"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Chicago","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Residential Fee","Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"25"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Scaling Fee","Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"97.55"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Chicago","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Scaling Fee","Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"97.55"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Tanker Endorsement","Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"50"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Chicago","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Tanker Endorsement","Fixed vs Non Fixed":"Fixed","Per":"Container"," Unit Cost ":"50"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Chicago","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Tri-axle","Fixed vs Non Fixed":"Fixed","Per":"Day"," Unit Cost ":"75"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Tri-axle ","Fixed vs Non Fixed":"Fixed","Per":"Day"," Unit Cost ":"10"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Wait time- Consignee","Fixed vs Non Fixed":"Fixed","Per":"Hour"," Unit Cost ":"63.15"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Chicago","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Wait time- Consignee","Fixed vs Non Fixed":"Fixed","Per":"Hour"," Unit Cost ":"63.15"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Wait time- Port","Fixed vs Non Fixed":"Fixed","Per":"Hour"," Unit Cost ":"63.15"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Chicago","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Wait time- Port","Fixed vs Non Fixed":"Fixed","Per":"Hour"," Unit Cost ":"63.15"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Yard Storage- Empty","Fixed vs Non Fixed":"Fixed","Per":"Day"," Unit Cost ":"25"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Chicago","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Yard Storage- Empty","Fixed vs Non Fixed":"Fixed","Per":"Day"," Unit Cost ":"25"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Long Beach","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Yard Storage- Loaded","Fixed vs Non Fixed":"Fixed","Per":"Day"," Unit Cost ":"25"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"},{"FileName":null,"Market":"Chicago","UserKey":0,"FileProcessKey":0,"SlNo":0,"Group":"Drayage","Line Item":"Yard Storage- Loaded","Fixed vs Non Fixed":"Fixed","Per":"Day"," Unit Cost ":"25"," Effective Date ":"9/1/2023 12:00:00 AM","Effective Date From":"Order Creation"}]'
(
	@FileProcesskey		INT,
	@JSOnData			NVARCHAR(MAX),
	@Status				BIT=1 OUTPUT
)
AS
BEGIN
	SET @Status=1;
	SELECT * INTO #Yard FROM (
	SELECT DISTINCT YardType FROM Yard
	UNION ALL
	SELECT 'Port' ) A

	Declare @Debug bit = 0


	if((Select count(1) from COSTACC_FILECONTENT where FileProcessKey = @FileProcesskey)>0)
	Begin
		Delete from COSTACC_FILECONTENT where FileProcessKey = @FileProcesskey
	End

	insert into COSTACC_FILECONTENT(FileProcessKey, JCONContent, DateCreated)
	select @FileProcesskey, @JSOnData, Getdate()

	DECLARE		@RecordStatus BIT = 1, 
				@RecordRemarks VARCHAR(MAX) = 'Correct'
	DECLARE		@ISSuccess BIT = 1, 
				@Remarks VARCHAR(100) = 'Record Uploaded Successfully', 
				@ErrorMessage VARCHAR(100) = 'Something went wrong, Contact System Administrator. Error Code : '


	set @JSOnData = REPLACE(@JSOnData,'"Line Item"','"LineItem"')
	set @JSOnData = REPLACE(@JSOnData,'"Fixed vs Non Fixed"','"FixedvsNonFixed"')
	set @JSOnData = REPLACE(@JSOnData,'"Unit Cost"','"UnitCost"')
	set @JSOnData = REPLACE(@JSOnData,'" Unit Cost "','"UnitCost"')
	set @JSOnData = REPLACE(@JSOnData,'"Unit Cost "','"UnitCost"')
	set @JSOnData = REPLACE(@JSOnData,'" Unit Cost"','"UnitCost"')
	set @JSOnData = REPLACE(@JSOnData,'"Effective Date"','"EffectiveDate"')
	set @JSOnData = REPLACE(@JSOnData,'" Effective Date"','"EffectiveDate"')
	set @JSOnData = REPLACE(@JSOnData,'"Effective Date "','"EffectiveDate"')
	set @JSOnData = REPLACE(@JSOnData,'" Effective Date "','"EffectiveDate"')
	set @JSOnData = REPLACE(@JSOnData,'"Truck Type"','"TruckType"')
	set @JSOnData = REPLACE(@JSOnData,'"Yard Port"','"YardPort"')
	set @JSOnData = REPLACE(@JSOnData,'"Free Per"','"FreePer"')
	set @JSOnData = REPLACE(@JSOnData,'"Effective Date From"','"EffectiveDateFrom"')
	set @JSOnData = REPLACE(@JSOnData,'"Split_Percent"','"SplitPercent"')

	CREATE TABLE #TEMPPROCESS
	(
		TextValue VARCHAR(100)
	)

	CREATE TABLE #FileUploadData
	(	
		SlNo						INT,
		[LineItem]					[varchar](100) NULL,
		[Market]					[varchar](100) NULL,
		Terminal					[varchar](100) NULL,
		TruckType					[varchar](100) NULL,
		YardPort					[varchar](100) NULL,
		[Zone]						[varchar](100) NULL,
		[Group]						[varchar](100) NULL,
		[FixVsNonFix]				[varchar](100) NULL,
		[Per]						[varchar](100) NULL,
		[UnitCost]					[varchar](100) NULL,
		[EffectiveDate]				[varchar](100) NULL,
		[EffectiveDateFrom]			[varchar](100) NULL,
		FreePer						[varchar](100) NULL,
		SplitPercent				[varchar](100) NULL,
		[RecordStatus]				[bit] NULL,
		[RecordRemarks]				[varchar](500) NULL
	)

	INSERT INTO				#FileUploadData
							(SlNo,LineItem,Market,Terminal,TruckType, YardPort, [Zone],[Group],FixVsNonFix,Per,UnitCost,EffectiveDate,EffectiveDateFrom,FreePer,SplitPercent)
	SELECT					ROW_NUMBER() OVER(ORDER BY Lineitem, Market,Terminal,TruckType, YardPort, [Zone], [Group], [FixVsNonFix]),
							[Lineitem], [market],Terminal,TruckType, YardPort, [Zone],[Group],[FixVsNonFix],[Per]
							,CASE WHEN [UnitCost] = '0.0' THEN '' ELSE [UnitCost] END,
							EffectiveDate,EffectiveDateFrom,FreePer,SplitPercent
	FROM OPENJSON			(@JSOnData, '$')
							with (	LineItem					VARCHAR(100)	'$.LineItem',
									Market						VARCHAR(100)	'$.Market',
									Terminal					VARCHAR(100)	'$.Terminal',
									TruckType					VARCHAR(100)	'$.TruckType',
									YardPort					VARCHAR(100)	'$.YardPort',
									[Zone]						VARCHAR(100)	'$.Zone',
									[Group]						VARCHAR(100)	'$.Group',
									[FixVsNonFix]				VARCHAR(100)	'$.FixedvsNonFixed',
									Per							VARCHAR(100)	'$.Per',
									UnitCost					VARCHAR(100)	'$.UnitCost',
									EffectiveDate				VARCHAR(100)	'$.EffectiveDate',
									EffectiveDateFrom			VARCHAR(100)	'$.EffectiveDateFrom',
									FreePer						VARCHAR(100)	'$.FreePer',
									SplitPercent				VARCHAR(100)	'$.SplitPercent')
	
	if (@Debug = 1)
	Begin
		SELECT '#FileUploadData', * FROM #FileUploadData
	End

	DECLARE @i INT = 1,  @n INT = (SELECT COUNT(*) FROM #FileUploadData )

	DECLARE		@LineItem					varchar(100)	,
				@Market						varchar(100)	,
				@Terminal					VARCHAR(100),
				@TruckType					VARCHAR(100),
				@YardPort					VARCHAR(100),
				@Zone						VARCHAR(100),
				@Group						varchar(100)	,
				@FixVsNonFix				varchar(100)	,
				@Per						varchar(100)	,
				@UnitCost					varchar(100)	,
				@EffectiveDate				VARCHAR(50)		,
				@EffectiveDateFrom			VARCHAR(100)	,
				@FreePer					VARCHAR(100),
				@SplitPercent				VARCHAR(100)
	
	
	DECLARE @TempRemarks VARCHAR(100) = ''

	WHILE(@i < = @n)
		BEGIN
			print '------------------------------------------------'
			print @i
			SELECT	 @LineItem	 = Lineitem,		
					 @Market	 =Market,
					 @Terminal	 = Terminal,
					@TruckType	 = TruckType,
					@YardPort	 = YardPort,
					@Zone		 = [Zone],
					 @Group		 = [Group],		
					 @FixVsNonFix = FixVsNonFix,		
					 @Per		 = Per,		
					 @UnitCost	 = UnitCost,	
					 @EffectiveDate = EffectiveDate,
					 @EffectiveDateFrom = EffectiveDateFrom, 
					 @FreePer = FreePer,
					 @SplitPercent = SplitPercent
			FROM	#FileUploadData
			WHERE	SlNo = @i

			SET	@RecordRemarks = ''
			SET	@RecordStatus = 1
			
			IF(ISNULL(@Market,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Market Cannot be blank;'
				END
			ELSE
				BEGIN

					DELETE FROM #TEMPPROCESS
					SET @TempRemarks = ''

					INSERT INTO #TEMPPROCESS
					SELECT RTRIM(LTRIM(value))
					FROM STRING_SPLIT(@market, ',')

					SET @TempRemarks = (SELECT DISTINCT 'Verify Market Details;' FROM #TEMPPROCESS TP
					LEFT OUTER JOIN MarketLocation ML ON TP.Textvalue = ML.marketLocation
					WHERE ML.marketLocation is NULL)

					IF(@TempRemarks <> '')
						BEGIN
							SET @ISSuccess = 0
							SET	@RecordStatus = 0
							SET	@RecordRemarks = @RecordRemarks + @TempRemarks
						END

				END
			
			IF(ISNULL(@LineItem,'') = '')
			BEGIN
				SET @ISSuccess = 0
				SET	@RecordStatus = 0
				SET	@RecordRemarks = @RecordRemarks + 'Line Item Cannot be blank;'
			END
			ELSE
			BEGIN
				IF((SELECT COUNT(*) FROM Item WHERE LTRIM(RTRIM(REPLACE(REPLACE(Description,CHAR(10),''),CHAR(13),''))) = LTRIM(RTRIM(@LineItem))) = 0 )
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Line Item does not exists in Masters;'
				END
			END


			IF(@Terminal <> '')
				BEGIN
					DELETE FROM #TEMPPROCESS
					SET @TempRemarks = ''

					INSERT INTO #TEMPPROCESS
					SELECT RTRIM(LTRIM(value))
					FROM STRING_SPLIT(@Terminal, ',')

					SET @TempRemarks = (SELECT DISTINCT 'Verify Terminal Price Grouping Details;' FROM #TEMPPROCESS TP
					LEFT OUTER JOIN PriceGrouping PG ON TP.Textvalue = PG.PriceGrouping
					WHERE PG.PriceGrouping is NULL)

					IF(@TempRemarks <> '')
						BEGIN
							SET @ISSuccess = 0
							SET	@RecordStatus = 0
							SET	@RecordRemarks = @RecordRemarks + @TempRemarks
						END
				END

			IF(@TruckType <> '')
				BEGIN
					DELETE FROM #TEMPPROCESS
					SET @TempRemarks = ''

					INSERT INTO #TEMPPROCESS
					SELECT RTRIM(LTRIM(value))
					FROM STRING_SPLIT(@TruckType, ',')

					SET @TempRemarks = (SELECT DISTINCT 'Verify Truck Type Details;' FROM #TEMPPROCESS TP
					LEFT OUTER JOIN TruckType TT ON TP.Textvalue = TT.TruckType
					WHERE TT.TruckType is NULL)

					IF(@TempRemarks <> '')
						BEGIN
							SET @ISSuccess = 0
							SET	@RecordStatus = 0
							SET	@RecordRemarks = @RecordRemarks + @TempRemarks
						END
				END

			IF(ISNULL(@YardPort,'') <> '')				
				BEGIN					
					DELETE FROM #TEMPPROCESS
					SET @TempRemarks = ''

					INSERT INTO #TEMPPROCESS
					SELECT RTRIM(LTRIM(value))
					FROM STRING_SPLIT(@YardPort, ',')

					SET @TempRemarks = (SELECT DISTINCT 'Verify Yard Port Details;' FROM #TEMPPROCESS TP
					LEFT OUTER JOIN #Yard Y ON ( TP.Textvalue = Y.YardType )
					WHERE YardType is NULL)

					IF(@TempRemarks <> '')
						BEGIN
							SET @ISSuccess = 0
							SET	@RecordStatus = 0
							SET	@RecordRemarks = @RecordRemarks + @TempRemarks
						END
				END


			IF(ISNULL(@Group,'') = '')
			BEGIN
				SET @ISSuccess = 0
				SET	@RecordStatus = 0
				SET	@RecordRemarks = @RecordRemarks + 'Group Cannot be blank;'
			END




			IF(ISNULL(@FixVsNonFix,'') = '')
			BEGIN
				SET @ISSuccess = 0
				SET	@RecordStatus = 0
				SET	@RecordRemarks = @RecordRemarks + 'Fixed Vs Non-Fixed column Cannot be blank;'
			END


			IF(ISNULL(@FixVsNonFix,'') = 'Fixed' and Isnull(@Per,'') = '')
			BEGIN
				SET @ISSuccess = 0
				SET	@RecordStatus = 0
				SET	@RecordRemarks = @RecordRemarks + 'Per column Cannot be blank;'
			END
			ELSE IF(ISNULL(@FixVsNonFix,'') = 'Fixed' and Isnull(@Per,'') not in ('Container','Occurence','Day','Hour'))
			BEGIN
				SET @ISSuccess = 0
				SET	@RecordStatus = 0
				SET	@RecordRemarks = @RecordRemarks + 'Per column allowed values - Day,Container,Hour,Occurence;'
			END

			IF(ISNULL(@FixVsNonFix,'') = 'Fixed' and Isnull(@Per,'') = '')
			BEGIN
				SET @ISSuccess = 0
				SET	@RecordStatus = 0
				SET	@RecordRemarks = @RecordRemarks + 'Per column Cannot be blank;'
			END
			ELSE IF(ISNULL(@FixVsNonFix,'') = 'Fixed' and Isnull(@Per,'') not in ('Container','Occurence','Day','Hour'))
			BEGIN
				SET @ISSuccess = 0
				SET	@RecordStatus = 0
				SET	@RecordRemarks = @RecordRemarks + 'Per column allowed values - Day,Container,Hour,Occurence;'
			END

			
			IF(ISNULL(@FixVsNonFix,'') = 'Fixed' and Isnull(@UnitCost,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'UnitCost 1 Cannot be blank;'
				END
			ELSE IF(ISNULL(@FixVsNonFix,'') = 'Fixed' and ISNUMERIC(@UnitCost) = 0)
			BEGIN
				SET @ISSuccess = 0
				SET	@RecordStatus = 0
				SET	@RecordRemarks = @RecordRemarks + 'Unit Cost Should have value;'
			END
			ELSE
			BEGIN
				SET @UnitCost = CAST(@UnitCost AS DECIMAL(18,2))
			END
			
			IF(ISNULL(@FixVsNonFix,'') = 'Fixed' and ISNULL(@EffectiveDate ,'') = '' )
			BEGIN
				SET @ISSuccess = 0
				SET	@RecordStatus = 0
				SET	@RecordRemarks = @RecordRemarks + 'Effective Date Cannot be blank;'
			END
			ELSE IF (ISNULL(@FixVsNonFix,'') = 'Fixed' and ISDATE(@EffectiveDate) = 0)
			BEGIN
				SET @ISSuccess = 0
				SET	@RecordStatus = 0
				SET	@RecordRemarks = @RecordRemarks + 'Date Format is not Correct;'
			END

			BEGIN
				SET @ISSuccess = 0
				SET	@RecordStatus = 0
				SET	@RecordRemarks = @RecordRemarks + 'Effective Date From Cannot be blank;'
			END


			IF(ISNULL(@FreePer,'') <> '' AND ISNUMERIC(@FreePer) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Free Per Must be a Number;'
				END

			IF(ISNULL(@SplitPercent,'') <> '' AND ISNUMERIC(@SplitPercent) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Split Percent Must be a Number;'
				END

		Print 3
		print @LineItem

		if(@Debug = 1)
		Begin
			select @LineItem
			select * from #FileUploadData WHERE	SlNo = @i
		End

		INSERT INTO				COSTACC_FileUploadData
								(FileProcesskey,RecordSL,LineItem, Market,Terminal,TruckType,YardPort,Zone, [Group], FixVsNonFix, Per, UnitCost, 
								EffectiveDate, EffectiveDateFrom,FreePer,SplitPercent,RecordStatus,RecordRemarks)
		SELECT					@FileProcesskey,SlNo,@LineItem, @Market, @Terminal,@TruckType,@YardPort,@Zone, @Group, @FixVsNonFix, @Per, @UnitCost,
								@EffectiveDate, @EffectiveDateFrom,@FreePer,@SplitPercent,@RecordStatus,@RecordRemarks
		FROM					#FileUploadData
		WHERE					SlNo = @i

		SET @i = @i  + 1

	END

	
	IF(@ISSuccess = 0)
		BEGIN
			SET @Remarks = 'File Not Uploaded'
		END

	--SELECT					A.*, FileProcesskey
	--						,RecordStatus,RecordRemarks
	--						,RecordSL, LineItem, Market, Terminal, TruckType, YardPort, Zone [Group], FixVsNonFix, Per, UnitCost,EffectiveDate,EffectiveDateFrom, FreePer, SplitPercent
	--						-- ,RecordStatus,RecordRemarks
	--FROM					(SELECT @ISSuccess AS ISSuccess, @Remarks AS Remarks ) A
	--LEFT OUTER JOIN			(SELECT	 *
	--						FROM	COSTACC_FileUploadData
	--						WHERE	FileProcesskey = @FileProcesskey							
	--						) B ON 1 = CASE WHEN @ISSuccess = 1 THEN 0 ELSE 1 END
	--ORDER BY RecordSL

	UPDATE					FP
	SET						FileUploadStatus = 1, FileProcessStatus = @ISSuccess, IsFileDownloaded = 0
	FROM					COSTACC_FileProcessInfo FP
	WHERE					FileProcessKey = @FileProcesskey
 	

	IF(@ISSuccess = 1)
		BEGIN
			EXEC [COSTACC_MoveAccessorialItemOutputData] @FileProcessKey = @FileProcesskey
		END
	ELSE
	BEGIN
		SET @Status=0;
	END
	
END



/*
COST_InsertFileProcessData_Chicago 3,'[{"Markey":"Long Beach","Terminal":"","City":"ARTESIA","State":"CA","Zip Code":"","Zone":"A","Pre pull location 1":"Local","Pre pull cost 1":"$97.55 ","Pre pull location 2":"","Pre pull cost 2":"","Stop off location 1":"Local",
"Stop off cost 1":"$97.55 ","Stop off location 2":"","Stop off cost 2":"","Yard shuttle direction TO 1":"","Yard shuttle direction FROM 1":"","Yard shuttle cost 1":"","Yard shuttle direction TO 2":"","Yard shuttle direction FROM 2":"",
"Yard shuttle cost 2":"","Truck Type A":"Company - Asset","Truck Type A Base Cost 1":"$182.27 ","Truck Type A FSF 1":"","FROM":"Local, Port","Truck Type A Base Cost 2":"","Truck Type A FSF 2":"","Truck Type A FROM 2":"",
"Truck Type B":"Broker Carrier","Truck Type B Base Cost 1":"$150.00","Truck Type B FSF 1":"0.33","Truck Type B FROM 1":"Local, Port","Truck Type B Base Cost 2":"","Truck Type B FSF 2":"","Truck Type B FROM 2":"",
"Truck Type C":"","Truck Type C Base Cost 1":"","Truck Type C FSF 1":"","Truck Type C FROM 1":"","Truck Type C Base Cost 2":"","Truck Type C FSF 2":"","Truck Type C FROM 2":"","Effective Date":"44935",
"Effective Date From":"Order Creation"}]'



*/


CREATE PROCEDURE [dbo].[COST_InsertFileProcessData_Chicago_20012025_Base] -- COST_InsertFileProcessData_Chicago 3,'[{"Market":"Market","Terminal":"Terminal","City":"City","State":"State","ZipCode":"ZipCode","Zone":"Zone","Prepulllocation1":"Prepulllocation1","Prepullcost1":"97.5453016591252","Prepulllocation2":"Prepulllocation2","Prepullcost2":"2","Stopofflocation1":"Stopofflocation1","Stopoffcost1":"3","Stopofflocation2":"Stopofflocation2","Stopoffcost2":"4","YardshuttledirectionTO1":"YardshuttledirectionTO1","YardshuttledirectionFROM1":"YardshuttledirectionFROM1","Yardshuttlecost1":"5","YardshuttledirectionTO2":"YardshuttledirectionTO2","YardshuttledirectionFROM2":"YardshuttledirectionFROM2","Yardshuttlecost2":"6","TruckType1":"TruckType1","TruckType1BaseCost":"7","TruckType1FSF":"8","TruckType2":"TruckType2","TruckType2BaseCost":"9","TruckType2FSC":"10","TruckType3":"TruckType3","TruckType3BaseCost":"11","TruckType3FSC":"12","EffectiveDate":"20-11-2023","EffectiveDateFrom":"EffectiveDateFrom"}]'
(
	@FileProcesskey		INT,
	@JSOnData			NVARCHAR(MAX)
)

AS

BEGIN
	
	DECLARE		@RecordStatus BIT = 1, @RecordRemarks VARCHAR(MAX) = 'Correct'
	DECLARE		@ISSuccess BIT = 1, @Remarks VARCHAR(100) = 'Record Uploaded Successfully', @ErrorMessage VARCHAR(100) = 'Something went wrong, Contact System Administrator. Error Code : '

	-- SELECT * FROM COST_FileContent

	INSERT INTO COST_FileContent
				(FileProcesskey	, FileContent, CreatedDate)
	SELECT		@FileProcesskey, @JSOnData, GETDATE()


	SELECT * INTO #Yard FROM (
	SELECT DISTINCT YardType FROM Yard
	UNION ALL
	SELECT 'Port' ) A



	CREATE TABLE #TEMPPROCESS
	(
		TextValue VARCHAR(100)
	)

	CREATE TABLE #FileUploadData
(	SlNo						INT,
	Market						VARCHAR(100),
	Terminal					VARCHAR(100),
	City						VARCHAR(100),
	State						VARCHAR(100),
	ZipCode						VARCHAR(100),
	Zone						VARCHAR(100),
	Prepulllocation1			VARCHAR(100),
	Prepullcost1				VARCHAR(100),
	Prepulllocation2			VARCHAR(100),
	Prepullcost2				VARCHAR(100),
	Prepulllocation3			VARCHAR(100),
	Prepullcost3				VARCHAR(100),
	Prepulllocation4			VARCHAR(100),
	Prepullcost4				VARCHAR(100),
	Prepulllocation5			VARCHAR(100),
	Prepullcost5				VARCHAR(100),
	Stopofflocation1			VARCHAR(100),
	Stopoffcost1				VARCHAR(100),
	Stopofflocation2			VARCHAR(100),
	Stopoffcost2				VARCHAR(100),
	Stopofflocation3			VARCHAR(100),
	Stopoffcost3				VARCHAR(100),
	Stopofflocation4			VARCHAR(100),
	Stopoffcost4				VARCHAR(100),
	Stopofflocation5			VARCHAR(100),
	Stopoffcost5				VARCHAR(100),
	YardshuttledirectionTO1		VARCHAR(100),
	YardshuttledirectionFROM1	VARCHAR(100),
	Yardshuttlecost1			VARCHAR(100),
	YardshuttledirectionTO2		VARCHAR(100),
	YardshuttledirectionFROM2	VARCHAR(100),
	Yardshuttlecost2			VARCHAR(100),
	TruckTypeA					VARCHAR(100),
	TruckTypeABaseCost1			VARCHAR(100),
	TruckTypeAFSF1				VARCHAR(100),
	TruckTypeAFROM1				VARCHAR(100),
	TruckTypeABaseCost2			VARCHAR(100),
	TruckTypeAFSF2				VARCHAR(100),
	TruckTypeAFROM2				VARCHAR(100),
	TruckTypeB					VARCHAR(100),
	TruckTypeBBaseCost1			VARCHAR(100),
	TruckTypeBFSC1				VARCHAR(100),
	TruckTypeBFROM1				VARCHAR(100),
	TruckTypeBBaseCost2			VARCHAR(100),
	TruckTypeBFSC2				VARCHAR(100),
	TruckTypeBFROM2				VARCHAR(100),
	TruckTypeC					VARCHAR(100),
	TruckTypeCBaseCost1			VARCHAR(100),
	TruckTypeCFSC1				VARCHAR(100),
	TruckTypeCFROM1				VARCHAR(100),
	TruckTypeCBaseCost2			VARCHAR(100),
	TruckTypeCFSC2				VARCHAR(100),
	TruckTypeCFROM2				VARCHAR(100),
	TruckTypeD					VARCHAR(100),
	TruckTypeDBaseCost1			VARCHAR(100),
	TruckTypeDFSC1				VARCHAR(100),
	TruckTypeE					VARCHAR(100),
	TruckTypeEBaseCost1			VARCHAR(100),
	TruckTypeEFSC1				VARCHAR(100),
	EffectiveDate				VARCHAR(100),
	EffectiveDateFrom			VARCHAR(100)
	)

	INSERT INTO				#FileUploadData
							(SlNo,Market,Terminal,City,State,ZipCode,Zone,Prepulllocation1,Prepullcost1,Prepulllocation2,Prepullcost2,Prepulllocation3,Prepullcost3,Prepulllocation4,Prepullcost4,Prepulllocation5
							,Prepullcost5,Stopofflocation1,Stopoffcost1,Stopofflocation2,Stopoffcost2,Stopofflocation3,Stopoffcost3,Stopofflocation4,Stopoffcost4,Stopofflocation5,Stopoffcost5,YardshuttledirectionTO1
							,YardshuttledirectionFROM1,Yardshuttlecost1,YardshuttledirectionTO2,YardshuttledirectionFROM2,Yardshuttlecost2
							,TruckTypeA,TruckTypeABaseCost1,TruckTypeAFSF1,TruckTypeAFROM1,TruckTypeABaseCost2,TruckTypeAFSF2,TruckTypeAFROM2
							,TruckTypeB,TruckTypeBBaseCost1,TruckTypeBFSC1,TruckTypeBFROM1,TruckTypeBBaseCost2,TruckTypeBFSC2,TruckTypeBFROM2
							,TruckTypeC,TruckTypeCBaseCost1,TruckTypeCFSC1,TruckTypeCFROM1,TruckTypeCBaseCost2,TruckTypeCFSC2,TruckTypeCFROM2
							,EffectiveDate,EffectiveDateFrom)
	SELECT					ROW_NUMBER() OVER(ORDER BY City),Market,Terminal,City,State,ZipCode,Zone,Prepulllocation1
							,CASE WHEN ISNULL(Prepulllocation1,'') = '' AND  Prepullcost1 = '0.0' THEN '' ELSE Prepullcost1 END,Prepulllocation2
							,CASE WHEN ISNULL(Prepulllocation2,'') = '' AND  Prepullcost2 = '0.0' THEN '' ELSE Prepullcost2 END,Prepulllocation3
							,CASE WHEN ISNULL(Prepulllocation3,'') = '' AND  Prepullcost3 = '0.0' THEN '' ELSE Prepullcost3 END,Prepulllocation4
							,CASE WHEN ISNULL(Prepulllocation4,'') = '' AND  Prepullcost4 = '0.0' THEN '' ELSE Prepullcost4 END,Prepulllocation5
							,CASE WHEN ISNULL(Prepulllocation5,'') = '' AND  Prepullcost5 = '0.0' THEN '' ELSE Prepullcost5 END,Stopofflocation1
							,CASE WHEN ISNULL(Stopofflocation1,'') = '' AND  Stopoffcost1 = '0.0' THEN '' ELSE Stopoffcost1 END,Stopofflocation2
							,CASE WHEN ISNULL(Stopofflocation2,'') = '' AND  Stopoffcost2 = '0.0' THEN '' ELSE Stopoffcost2 END,Stopofflocation3
							,CASE WHEN ISNULL(Stopofflocation3,'') = '' AND  Stopoffcost3 = '0.0' THEN '' ELSE Stopoffcost3 END,Stopofflocation4
							,CASE WHEN ISNULL(Stopofflocation4,'') = '' AND  Stopoffcost4 = '0.0' THEN '' ELSE Stopoffcost4 END,Stopofflocation5
							,CASE WHEN ISNULL(Stopofflocation5,'') = '' AND  Stopoffcost5 = '0.0' THEN '' ELSE Stopoffcost5 END,YardshuttledirectionTO1	,YardshuttledirectionFROM1
							,CASE WHEN ISNULL(YardshuttledirectionTO1,'') = '' AND ISNULL(YardshuttledirectionFROM1,'') = '' AND Yardshuttlecost1 = '0.0' THEN '' ELSE Yardshuttlecost1 END,YardshuttledirectionTO2,YardshuttledirectionFROM2
							,CASE WHEN ISNULL(YardshuttledirectionTO2,'') = '' AND ISNULL(YardshuttledirectionFROM2,'') = '' AND Yardshuttlecost2 = '0.0' THEN '' ELSE Yardshuttlecost2 END
							,TruckTypeA
							,CASE WHEN TruckTypeABaseCost1 = '0.0' THEN '' ELSE TruckTypeABaseCost1 END
							,CASE WHEN TruckTypeAFSF1 = '0.0' THEN '' ELSE TruckTypeAFSF1 END
							,TruckTypeAFROM1 
							,CASE WHEN TruckTypeABaseCost2 = '0.0' THEN '' ELSE TruckTypeABaseCost2 END
							,CASE WHEN TruckTypeAFSF2 = '0.0' THEN '' ELSE TruckTypeAFSF2 END
							,TruckTypeAFROM2
							,TruckTypeB
							,CASE WHEN TruckTypeBBaseCost1 = '0.0' THEN '' ELSE TruckTypeBBaseCost1 END
							,CASE WHEN TruckTypeBFSC1 = '0.0' THEN '' ELSE TruckTypeBFSC1 END
							,TruckTypeBFROM1 
							,CASE WHEN TruckTypeBBaseCost2 = '0.0' THEN '' ELSE TruckTypeBBaseCost2 END
							,CASE WHEN TruckTypeBFSC2 = '0.0' THEN '' ELSE TruckTypeBFSC2 END
							,TruckTypeBFROM2	
							,TruckTypeC
							,CASE WHEN TruckTypeCBaseCost1 = '0.0' THEN '' ELSE TruckTypeCBaseCost1 END
							,CASE WHEN TruckTypeCFSC1 = '0.0' THEN '' ELSE TruckTypeCFSC1 END
							,TruckTypeCFROM1 
							,CASE WHEN TruckTypeCBaseCost2 = '0.0' THEN '' ELSE TruckTypeCBaseCost2 END
							,CASE WHEN TruckTypeCFSC2 = '0.0' THEN '' ELSE TruckTypeCFSC2 END
							,TruckTypeCFROM2	
							,EffectiveDate,EffectiveDateFrom
	FROM OPENJSON			(@JSOnData, '$')
							with (	Market						VARCHAR(100)	'$.Market',
									Terminal					VARCHAR(100)	'$.Terminal',
									City						VARCHAR(100)	'$.City',
									State						VARCHAR(100)	'$.State',
									ZipCode						VARCHAR(100)	'$.ZipCode',
									Zone						VARCHAR(100)	'$.Zone',
									Prepulllocation1			VARCHAR(100)	'$.Prepulllocation1',
									Prepullcost1				VARCHAR(100)	'$.Prepullcost1',
									Prepulllocation2			VARCHAR(100)	'$.Prepulllocation2',
									Prepullcost2				VARCHAR(100)	'$.Prepullcost2',
									Prepulllocation3			VARCHAR(100)	'$.Prepulllocation3',
									Prepullcost3				VARCHAR(100)	'$.Prepullcost3',
									Prepulllocation4			VARCHAR(100)	'$.Prepulllocation4',
									Prepullcost4				VARCHAR(100)	'$.Prepullcost4',
									Prepulllocation5			VARCHAR(100)	'$.Prepulllocation5',
									Prepullcost5				VARCHAR(100)	'$.Prepullcost5',
									Stopofflocation1			VARCHAR(100)	'$.Stopofflocation1',
									Stopoffcost1				VARCHAR(100)	'$.Stopoffcost1',
									Stopofflocation2			VARCHAR(100)	'$.Stopofflocation2',
									Stopoffcost2				VARCHAR(100)	'$.Stopoffcost2',
									Stopofflocation3			VARCHAR(100)	'$.Stopofflocation3',
									Stopoffcost3				VARCHAR(100)	'$.Stopoffcost3',
									Stopofflocation4			VARCHAR(100)	'$.Stopofflocation4',
									Stopoffcost4				VARCHAR(100)	'$.Stopoffcost4',
									Stopofflocation5			VARCHAR(100)	'$.Stopofflocation5',
									Stopoffcost5				VARCHAR(100)	'$.Stopoffcost5',
									YardshuttledirectionTO1		VARCHAR(100)	'$.YardshuttledirectionTO1',
									YardshuttledirectionFROM1	VARCHAR(100)	'$.YardshuttledirectionFROM1',
									Yardshuttlecost1			VARCHAR(100)	'$.Yardshuttlecost1',
									YardshuttledirectionTO2		VARCHAR(100)	'$.YardshuttledirectionTO2',
									YardshuttledirectionFROM2	VARCHAR(100)	'$.YardshuttledirectionFROM2',
									Yardshuttlecost2			VARCHAR(100)	'$.Yardshuttlecost2',
									TruckTypeA 					VARCHAR(100)	'$.TruckTypeA',
									TruckTypeABaseCost1 		VARCHAR(100)	'$.TruckTypeABaseCost1',
									TruckTypeAFSF1 				VARCHAR(100)	'$.TruckTypeAFSF1',
									TruckTypeAFROM1 			VARCHAR(100)	'$.TruckTypeAFROM1',
									TruckTypeABaseCost2 		VARCHAR(100)	'$.TruckTypeABaseCost2',
									TruckTypeAFSF2 				VARCHAR(100)	'$.TruckTypeAFSF2',
									TruckTypeAFROM2 			VARCHAR(100)	'$.TruckTypeAFROM2',
									TruckTypeB 					VARCHAR(100)	'$.TruckTypeB',
									TruckTypeBBaseCost1 		VARCHAR(100)	'$.TruckTypeBBaseCost1',
									TruckTypeBFSC1 				VARCHAR(100)	'$.TruckTypeBFSC1',
									TruckTypeBFROM1 			VARCHAR(100)	'$.TruckTypeBFROM1',
									TruckTypeBBaseCost2 		VARCHAR(100)	'$.TruckTypeBBaseCost2',
									TruckTypeBFSC2 				VARCHAR(100)	'$.TruckTypeBFSC2',
									TruckTypeBFROM2 			VARCHAR(100)	'$.TruckTypeBFROM2',
									TruckTypeC 					VARCHAR(100)	'$.TruckTypeC',
									TruckTypeCBaseCost1 		VARCHAR(100)	'$.TruckTypeCBaseCost1',
									TruckTypeCFSC1 				VARCHAR(100)	'$.TruckTypeCFSC1',
									TruckTypeCFROM1 			VARCHAR(100)	'$.TruckTypeCFROM1',
									TruckTypeCBaseCost2 		VARCHAR(100)	'$.TruckTypeCBaseCost2',
									TruckTypeCFSC2 				VARCHAR(100)	'$.TruckTypeCFSC2',
									TruckTypeCFROM2 			VARCHAR(100)	'$.TruckTypeCFROM2',
									TruckTypeD 					VARCHAR(100)	'$.TruckTypeD',
									TruckTypeDBaseCost1 		VARCHAR(100)	'$.TruckTypeDBaseCost1',
									TruckTypeDFSC1 				VARCHAR(100)	'$.TruckTypeDFSC1',
									TruckTypeE 					VARCHAR(100)	'$.TruckTypeE',
									TruckTypeEBaseCost1 		VARCHAR(100)	'$.TruckTypeEBaseCost1',
									TruckTypeEFSC1  			VARCHAR(100)	'$.TruckTypeEFSC1',
									EffectiveDate				VARCHAR(100)	'$.EffectiveDate',
									EffectiveDateFrom			VARCHAR(100)	'$.EffectiveDateFrom' )
	

	-- SELECT * FROM #FileUploadData

	DECLARE @i INT = 1,  @n INT = (SELECT COUNT(*) FROM #FileUploadData )

	DECLARE		@Market VARCHAR(50) ,@Terminal VARCHAR(100) ,@City VARCHAR(100) ,@State VARCHAR(100) ,@ZipCode VARCHAR(20) ,@Zone VARCHAR(10) ,@Prepulllocation1 VARCHAR(100) ,@Prepullcost1 VARCHAR(100) 
				,@Prepulllocation2 VARCHAR(100) ,@Prepullcost2 VARCHAR(100) ,@Prepulllocation3 VARCHAR(100) ,@Prepullcost3 VARCHAR(100) ,@Prepulllocation4 VARCHAR(100)	,@Prepullcost4 VARCHAR(100) 
				,@Prepulllocation5 VARCHAR(100) ,@Prepullcost5 VARCHAR(100) ,@Stopofflocation1 VARCHAR(100) ,@Stopoffcost1 VARCHAR(100) ,@Stopofflocation2 VARCHAR(100) ,@Stopoffcost2 VARCHAR(100) 
				,@Stopofflocation3 VARCHAR(100) ,@Stopoffcost3 VARCHAR(100) ,@Stopofflocation4 VARCHAR(100) ,@Stopoffcost4 VARCHAR(100) ,@Stopofflocation5 VARCHAR(100) ,@Stopoffcost5 VARCHAR(100) ,@YardshuttledirectionTO1		VARCHAR(100) 
				,@YardshuttledirectionFROM1	VARCHAR(100) ,@Yardshuttlecost1		VARCHAR(100) ,@YardshuttledirectionTO2		VARCHAR(100) ,@YardshuttledirectionFROM2	VARCHAR(100) ,@Yardshuttlecost2 VARCHAR(100) 
				,@TruckTypeA 				VARCHAR(100),@TruckTypeABaseCost1 	VARCHAR(100),@TruckTypeAFSF1 	VARCHAR(100),@TruckTypeAFROM1 	VARCHAR(100)
				,@TruckTypeABaseCost2 		VARCHAR(100),@TruckTypeAFSF2 		VARCHAR(100),@TruckTypeAFROM2 	VARCHAR(100)
				,@TruckTypeB 				VARCHAR(100),@TruckTypeBBaseCost1 	VARCHAR(100),@TruckTypeBFSC1 	VARCHAR(100),@TruckTypeBFROM1 	VARCHAR(100)
				,@TruckTypeBBaseCost2 		VARCHAR(100),@TruckTypeBFSC2 		VARCHAR(100),@TruckTypeBFROM2 	VARCHAR(100)
				,@TruckTypeC 				VARCHAR(100),@TruckTypeCBaseCost1 	VARCHAR(100),@TruckTypeCFSC1 	VARCHAR(100),@TruckTypeCFROM1 	VARCHAR(100)
				,@TruckTypeCBaseCost2 		VARCHAR(100),@TruckTypeCFSC2 		VARCHAR(100),@TruckTypeCFROM2 	VARCHAR(100)
				,@TruckTypeD 				VARCHAR(100),@TruckTypeDBaseCost1 	VARCHAR(100),@TruckTypeDFSC1 	VARCHAR(100)
				,@TruckTypeE 				VARCHAR(100),@TruckTypeEBaseCost1 	VARCHAR(100),@TruckTypeEFSC1  	VARCHAR(100)
				,@EffectiveDate				VARCHAR(50) ,@EffectiveDateFrom		VARCHAR(100) 
	
	DECLARE @SelectedMarket VARCHAR(50) = (SELECT ISNULL(MarketLocation,'') FROM COST_FileProcessInfo WHERE FileProcessKey = @FileProcesskey)
	SET @SelectedMarket = ISNULL(@SelectedMarket,'')

	DECLARE @TempRemarks VARCHAR(100) = ''

	WHILE(@i < = @n)
		BEGIN
			SELECT	 @Market = Market,@Terminal = Terminal,@City = City , @State = State, @ZipCode = ZipCode,@Zone = Zone
					,@Prepulllocation1 = Prepulllocation1, @Prepullcost1 = Prepullcost1, @Prepulllocation2 = Prepulllocation2, @Prepullcost2 = Prepullcost2
					,@Stopofflocation1 = Stopofflocation1, @Stopoffcost1 = Stopoffcost1, @Stopofflocation2 = Stopofflocation2, @Stopoffcost2 = Stopoffcost2
					,@YardshuttledirectionTO1 = YardshuttledirectionTO1, @YardshuttledirectionFROM1 = YardshuttledirectionFROM1, @Yardshuttlecost1 = Yardshuttlecost1
					,@YardshuttledirectionTO2 = YardshuttledirectionTO2, @YardshuttledirectionFROM2 = YardshuttledirectionFROM2, @Yardshuttlecost2 = Yardshuttlecost2
					,@TruckTypeA = TruckTypeA,@TruckTypeABaseCost1 = TruckTypeABaseCost1,@TruckTypeAFSF1 = TruckTypeAFSF1,@TruckTypeAFROM1 = TruckTypeAFROM1
					,@TruckTypeABaseCost2 = TruckTypeABaseCost2,@TruckTypeAFSF2 = TruckTypeAFSF2,@TruckTypeAFROM2 = TruckTypeAFROM2
					,@TruckTypeB = TruckTypeB,@TruckTypeBBaseCost1 = TruckTypeBBaseCost1,@TruckTypeBFSC1 = TruckTypeBFSC1,@TruckTypeBFROM1 = TruckTypeBFROM1
					,@TruckTypeBBaseCost2 = TruckTypeBBaseCost2,@TruckTypeBFSC2 = TruckTypeBFSC2,@TruckTypeBFROM2 = TruckTypeBFROM2
					,@TruckTypeC = TruckTypeC,@TruckTypeCBaseCost1 = TruckTypeCBaseCost1,@TruckTypeCFSC1 = TruckTypeCFSC1,@TruckTypeCFROM1 = TruckTypeCFROM1
					,@TruckTypeCBaseCost2 = TruckTypeCBaseCost2,@TruckTypeCFSC2 = TruckTypeCFSC2,@TruckTypeCFROM2 = TruckTypeCFROM2
					,@EffectiveDate = EffectiveDate,@EffectiveDateFrom = EffectiveDateFrom
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
			ELSE IF (@Market <> @SelectedMarket)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Market does not match selected Market Location;'
				END
			ELSE
				BEGIN
					IF((SELECT COUNT(*) FROM MarketLocation WHERE marketLocation = @Market) = 0 )
						BEGIN
							SET @ISSuccess = 0
							SET	@RecordStatus = 0
							SET	@RecordRemarks = @RecordRemarks + 'Market does not exists in Masters;'
						END
				END
			

			IF(ISNULL(@Terminal,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Terminal Cannot be blank;'
				END
			ELSE IF(@Terminal <> '')
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


			IF(ISNULL(@City,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'City Cannot be blank;'
				END
			ELSE
				BEGIN
					IF((SELECT COUNT(*) FROM locationdata WHERE City = RTRIM(LTRIM(@City)) AND State = RTRIM(LTRIM(@State))) = 0 )
						BEGIN
							SET @ISSuccess = 0
							SET	@RecordStatus = 0
							SET	@RecordRemarks = @RecordRemarks + 'City does not exists in Masters;'
						END
					ELSE IF ((SELECT COUNT(*) FROM locationdata WHERE City = @City AND State = @State) = 1 )
						BEGIN
							SET @Zipcode = (SELECT ZipCode FROM locationdata WHERE City =  RTRIM(LTRIM(@City)) AND State = RTRIM(LTRIM(@State)))
						END
				END


			IF(ISNULL(@State,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'State Cannot be blank;'
				END

			IF(@Zipcode <> '' AND (SELECT COUNT(*) FROM locationdata WHERE Zipcode = @Zipcode) = 0  )
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Zipcode does not exists in Masters;'
				END


			IF(ISNULL(@Zone,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Zone Cannot be blank;'
				END

			IF(ISNULL(@Prepulllocation1,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Pre Pull Location 1 Cannot be blank;'
				END
			ELSE 
				BEGIN					
					DELETE FROM #TEMPPROCESS
					SET @TempRemarks = ''

					INSERT INTO #TEMPPROCESS
					SELECT RTRIM(LTRIM(value))
					FROM STRING_SPLIT(@Prepulllocation1, ',')

					SET @TempRemarks = (SELECT DISTINCT 'Verify Pre Pull Location 1 Yard Details;' FROM #TEMPPROCESS TP
					--LEFT OUTER JOIN YARD Y ON ( TP.Textvalue = RTRIM(LTRIM(REPLACE(REPLACE(Y.ShortName,'JCT',''),'-','')))  OR RTRIM(LTRIM(TP.Textvalue)) = RTRIM(LTRIM(Y.ShortName)))
					LEFT OUTER JOIN #Yard Y ON ( TP.Textvalue = Y.YardType )
					WHERE YardType is NULL)

					IF(@TempRemarks <> '')
						BEGIN
							SET @ISSuccess = 0
							SET	@RecordStatus = 0
							SET	@RecordRemarks = @RecordRemarks + @TempRemarks
						END
				END

			IF(ISNULL(@Prepullcost1,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Pre Pull Cost 1 Cannot be blank;'
				END
			ELSE IF(ISNUMERIC(@Prepullcost1) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Pre Pull Cost 1 Should be a Number;'
				END
			ELSE
				BEGIN
					SET @Prepullcost1 = CAST(@Prepullcost1 AS DECIMAL(18,2))
				END
			

			IF(ISNULL(@Prepulllocation2,'') <> '' AND ISNULL(@Prepullcost2,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Pre Pull Cost 2 Cannot be blank;'
				END
			ELSE IF(ISNULL(@Prepullcost2,'') <> '' AND ISNULL(@Prepulllocation2,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Pre Pull Location 2 Cannot be blank;'
				END
			
			IF (ISNULL(@Prepulllocation2,'') <> '')
				BEGIN					
					DELETE FROM #TEMPPROCESS
					SET @TempRemarks = ''

					INSERT INTO #TEMPPROCESS
					SELECT RTRIM(LTRIM(value))
					FROM STRING_SPLIT(@Prepulllocation2, ',')

					SET @TempRemarks = (SELECT DISTINCT 'Verify Pre Pull Location 2 Yard Details;' FROM #TEMPPROCESS TP
					--LEFT OUTER JOIN YARD Y ON ( TP.Textvalue = RTRIM(LTRIM(REPLACE(REPLACE(Y.ShortName,'JCT',''),'-','')))  OR RTRIM(LTRIM(TP.Textvalue)) = RTRIM(LTRIM(Y.ShortName)))
					LEFT OUTER JOIN #Yard Y ON ( TP.Textvalue = Y.YardType )
					WHERE YardType is NULL)

					IF(@TempRemarks <> '')
						BEGIN
							SET @ISSuccess = 0
							SET	@RecordStatus = 0
							SET	@RecordRemarks = @RecordRemarks + @TempRemarks
						END
				END

		
			IF(ISNULL(@Prepullcost2,'') <> '' AND ISNUMERIC(@Prepullcost2) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Pre Pull Cost 2 Should be a Number;'
				END
			ELSE IF (ISNUMERIC(@Prepullcost2) = 1)
				BEGIN
					SET @Prepullcost2 = CAST(@Prepullcost2 AS DECIMAL(18,2))
				END




			IF(ISNULL(@Stopofflocation1,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Stop Off Location 1 Cannot be blank;'
				END
			ELSE 
				BEGIN					
					DELETE FROM #TEMPPROCESS
					SET @TempRemarks = ''

					INSERT INTO #TEMPPROCESS
					SELECT RTRIM(LTRIM(value))
					FROM STRING_SPLIT(@Stopofflocation1, ',')

					SET @TempRemarks = (SELECT DISTINCT 'Verify Stop Off Location 1 Yard Details;' FROM #TEMPPROCESS TP
					--LEFT OUTER JOIN YARD Y ON (TP.Textvalue = RTRIM(LTRIM(REPLACE(REPLACE(Y.ShortName,'JCT',''),'-','')))  OR RTRIM(LTRIM(TP.Textvalue)) = RTRIM(LTRIM(Y.ShortName)))
					LEFT OUTER JOIN #Yard Y ON ( TP.Textvalue = Y.YardType )
					WHERE YardType is NULL)

					IF(@TempRemarks <> '')
						BEGIN
							SET @ISSuccess = 0
							SET	@RecordStatus = 0
							SET	@RecordRemarks = @RecordRemarks + @TempRemarks
						END
				END

			IF(ISNULL(@Stopoffcost1,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Stop Off Cost 1 Cannot be blank;'
				END
			ELSE IF(ISNUMERIC(@Stopoffcost1) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Stop Off Cost 1 Should be a Number;'
				END
			ELSE IF (ISNUMERIC(@Stopoffcost1) = 1)
				BEGIN
					SET @Stopoffcost1 = CAST(@Stopoffcost1 AS DECIMAL(18,2))
				END

			IF(ISNULL(@Stopofflocation2,'') <> '' AND ISNULL(@Stopoffcost2,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Stop off Cost 2 Cannot be blank;'
				END
			ELSE IF(ISNULL(@Stopoffcost2,'') <> '' AND ISNULL(@Stopofflocation2,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Stop off Location 2 Cannot be blank;'
				END
			
			IF (ISNULL(@Stopofflocation2,'') <> '')
				BEGIN					
					DELETE FROM #TEMPPROCESS
					SET @TempRemarks = ''

					INSERT INTO #TEMPPROCESS
					SELECT RTRIM(LTRIM(value))
					FROM STRING_SPLIT(@Stopofflocation2, ',')

					SET @TempRemarks = (SELECT DISTINCT 'Verify Stop Off Location 2 Yard Details;' FROM #TEMPPROCESS TP
					--LEFT OUTER JOIN YARD Y ON ( TP.Textvalue = RTRIM(LTRIM(REPLACE(REPLACE(Y.ShortName,'JCT',''),'-','')))  OR RTRIM(LTRIM(TP.Textvalue)) = RTRIM(LTRIM(Y.ShortName)))
					LEFT OUTER JOIN #Yard Y ON ( TP.Textvalue = Y.YardType )
					WHERE YardType is NULL)

					IF(@TempRemarks <> '')
						BEGIN
							SET @ISSuccess = 0
							SET	@RecordStatus = 0
							SET	@RecordRemarks = @RecordRemarks + @TempRemarks
						END
				END
			
			
			IF(ISNULL(@Stopoffcost2,'') <> '' AND ISNUMERIC(@Stopoffcost2) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Stop Off Cost 2 Should be a Number;'
				END
			ELSE IF (ISNUMERIC(@Stopoffcost2) = 1)
				BEGIN
					SET @Stopoffcost2 = CAST(@Stopoffcost2 AS DECIMAL(18,2))
				END
				

			IF(ISNULL(@Yardshuttlecost1 ,'') <> '' AND ISNULL(@YardshuttledirectionFROM1,'') = '' AND ISNULL(@YardshuttledirectionTO1,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Yard Shuttle Direction FROM 1 AND Yard Shuttle Direction TO 1 Cannot be blank;'
				END
			ELSE IF(ISNULL(@YardshuttledirectionFROM1 ,'') <> '' AND ISNULL(@YardshuttledirectionTO1,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Yard Shuttle Direction TO 1 Cannot be blank;'
				END
			ELSE IF(ISNULL(@YardshuttledirectionTO1 ,'') <> '' AND ISNULL(@YardshuttledirectionFROM1,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Yard Shuttle Direction FROM 1 Cannot be blank;'
				END
			ELSE IF(ISNULL(@YardshuttledirectionTO1 ,'') <> '' AND ISNULL(@YardshuttledirectionFROM1,'') <> '' AND ISNULL(@Yardshuttlecost1,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Yard Shuttle Cost 1 Cannot be blank;'
				END

			IF (ISNULL(@YardshuttledirectionTO1,'') <> '')
				BEGIN					
					DELETE FROM #TEMPPROCESS
					SET @TempRemarks = ''

					INSERT INTO #TEMPPROCESS
					SELECT RTRIM(LTRIM(value))
					FROM STRING_SPLIT(@YardshuttledirectionTO1, ',')

					SET @TempRemarks = (SELECT DISTINCT 'Verify Yard Shuttle Direction TO 1 Yard Details;' FROM #TEMPPROCESS TP
					--LEFT OUTER JOIN YARD Y ON ( TP.Textvalue = RTRIM(LTRIM(REPLACE(REPLACE(Y.ShortName,'JCT',''),'-','')))  OR RTRIM(LTRIM(TP.Textvalue)) = RTRIM(LTRIM(Y.ShortName)))
					LEFT OUTER JOIN #Yard Y ON ( TP.Textvalue = Y.YardType )
					WHERE YardType is NULL)

					IF(@TempRemarks <> '')
						BEGIN
							SET @ISSuccess = 0
							SET	@RecordStatus = 0
							SET	@RecordRemarks = @RecordRemarks + @TempRemarks
						END
				END

			IF (ISNULL(@YardshuttledirectionFROM1,'') <> '')
				BEGIN					
					DELETE FROM #TEMPPROCESS
					SET @TempRemarks = ''

					INSERT INTO #TEMPPROCESS
					SELECT RTRIM(LTRIM(value))
					FROM STRING_SPLIT(@YardshuttledirectionFROM1, ',')

					SET @TempRemarks = (SELECT DISTINCT 'Verify Yard Shuttle Direction FROM 1 Yard Details;' FROM #TEMPPROCESS TP
					--LEFT OUTER JOIN YARD Y ON ( TP.Textvalue = RTRIM(LTRIM(REPLACE(REPLACE(Y.ShortName,'JCT',''),'-','')))  OR RTRIM(LTRIM(TP.Textvalue)) = RTRIM(LTRIM(Y.ShortName)))
					LEFT OUTER JOIN #Yard Y ON ( TP.Textvalue = Y.YardType )
					WHERE YardType is NULL)

					IF(@TempRemarks <> '')
						BEGIN
							SET @ISSuccess = 0
							SET	@RecordStatus = 0
							SET	@RecordRemarks = @RecordRemarks + @TempRemarks
						END
				END


			IF(ISNULL(@Yardshuttlecost1,'') <> '' AND  ISNUMERIC(@Yardshuttlecost1) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Yard Shuttle Cost 1 Should be a Number;'
				END
			ELSE IF (ISNUMERIC(@Yardshuttlecost1) = 1)
				BEGIN
					SET @Yardshuttlecost1 = CAST(@Yardshuttlecost1 AS DECIMAL(18,2))
				END



			IF(ISNULL(@Yardshuttlecost2 ,'') <> '' AND ISNULL(@YardshuttledirectionFROM2,'') = '' AND ISNULL(@YardshuttledirectionTO2,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Yard Shuttle Direction FROM 2 AND Yard Shuttle Direction TO 1 Cannot be blank;'
				END
			ELSE IF(ISNULL(@YardshuttledirectionFROM2 ,'') <> '' AND ISNULL(@YardshuttledirectionTO2,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Yard Shuttle Direction TO 2 Cannot be blank;'
				END
			ELSE IF(ISNULL(@YardshuttledirectionTO2 ,'') <> '' AND ISNULL(@YardshuttledirectionFROM2,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Yard Shuttle Direction FROM 2 Cannot be blank;'
				END
			ELSE IF(ISNULL(@YardshuttledirectionTO2 ,'') <> '' AND ISNULL(@YardshuttledirectionFROM2,'') <> '' AND ISNULL(@Yardshuttlecost2,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Yard Shuttle Cost 2 Cannot be blank;'
				END

			IF (ISNULL(@YardshuttledirectionTO2,'') <> '')
				BEGIN					
					DELETE FROM #TEMPPROCESS
					SET @TempRemarks = ''

					INSERT INTO #TEMPPROCESS
					SELECT RTRIM(LTRIM(value))
					FROM STRING_SPLIT(@YardshuttledirectionTO2, ',')

					SET @TempRemarks = (SELECT DISTINCT 'Verify Yard Shuttle Direction TO 2 Yard Details;' FROM #TEMPPROCESS TP
					--LEFT OUTER JOIN YARD Y ON ( TP.Textvalue = RTRIM(LTRIM(REPLACE(REPLACE(Y.ShortName,'JCT',''),'-','')))  OR RTRIM(LTRIM(TP.Textvalue)) = RTRIM(LTRIM(Y.ShortName)))
					LEFT OUTER JOIN #Yard Y ON ( TP.Textvalue = Y.YardType )
					WHERE YardType is NULL)

					IF(@TempRemarks <> '')
						BEGIN
							SET @ISSuccess = 0
							SET	@RecordStatus = 0
							SET	@RecordRemarks = @RecordRemarks + @TempRemarks
						END
				END

			IF (ISNULL(@YardshuttledirectionFROM2,'') <> '')
				BEGIN					
					DELETE FROM #TEMPPROCESS
					SET @TempRemarks = ''

					INSERT INTO #TEMPPROCESS
					SELECT RTRIM(LTRIM(value))
					FROM STRING_SPLIT(@YardshuttledirectionFROM2, ',')

					SET @TempRemarks = (SELECT DISTINCT 'Verify Yard Shuttle Direction FROM 2 Yard Details;' FROM #TEMPPROCESS TP
					--LEFT OUTER JOIN YARD Y ON ( TP.Textvalue = RTRIM(LTRIM(REPLACE(REPLACE(Y.ShortName,'JCT',''),'-','')))  OR RTRIM(LTRIM(TP.Textvalue)) = RTRIM(LTRIM(Y.ShortName)))
					LEFT OUTER JOIN #Yard Y ON ( TP.Textvalue = Y.YardType )
					WHERE YardType is NULL)

					IF(@TempRemarks <> '')
						BEGIN
							SET @ISSuccess = 0
							SET	@RecordStatus = 0
							SET	@RecordRemarks = @RecordRemarks + @TempRemarks
						END
				END


			IF(ISNULL(@Yardshuttlecost2,'') <> '' AND  ISNUMERIC(@Yardshuttlecost2) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Yard Shuttle Cost 2 Should be a Number;'
				END
			ELSE IF (ISNUMERIC(@Yardshuttlecost2) = 1)
				BEGIN
					SET @Yardshuttlecost2 = CAST(@Yardshuttlecost2 AS DECIMAL(18,2))
				END
			
			IF(	(ISNULL(@TruckTypeA,'') = ISNULL(@TruckTypeB,'') AND ISNULL(@TruckTypeA,'')  <> '' AND ISNULL(@TruckTypeB,'') <> '')   OR 
				(ISNULL(@TruckTypeA,'') = ISNULL(@TruckTypeC,'') AND ISNULL(@TruckTypeA,'')  <> '' AND ISNULL(@TruckTypeC,'') <> '')  OR 
				(ISNULL(@TruckTypeB,'') = ISNULL(@TruckTypeC,'') AND ISNULL(@TruckTypeB,'')  <> '' AND ISNULL(@TruckTypeC,'') <> '') )
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck type A and Truck Type B  and Truck Type C cannot be same;'
				END
-------------------------------------------------------Truck Type A -------------------------------------
			-- SELECT @TruckTypeABaseCost1,@TruckTypeAFROM1

			IF(ISNULL(@TruckTypeA ,'') = '' )
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type A Cannot be blank;'
				END
			ELSE IF((ISNULL(@TruckTypeABaseCost1,'') <> '' OR @TruckTypeABaseCost1 <> '0.0' ) AND ISNULL(@TruckTypeAFROM1,'') <> '' AND ISNULL(@TruckTypeA,'') = '' )
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type A cannot be Blank;'
				END
			ELSE IF((ISNULL(@TruckTypeABaseCost2,'') <> ''  OR @TruckTypeABaseCost2 <> '0.0' ) AND ISNULL(@TruckTypeAFROM2,'') <> '' AND ISNULL(@TruckTypeA,'') = '' )
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type A cannot be Blank;'
				END
			ELSE IF ((SELECT COUNT(*) FROM TruckType WHERE TruckType = @TruckTypeA ) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type A does not exists in Masters;'
				END
			
			IF(ISNULL(@TruckTypeAFROM1,'') = ISNULL(@TruckTypeAFROM2,'') AND ISNULL(@TruckTypeAFROM1,'') <> '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type A From 1 and Truck Type A From 2 cannot be same;'
				END

			IF(ISNULL(@TruckTypeABaseCost1 ,'') = '' )
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type A Base Cost 1 Cannot be blank;'
				END
			ELSE IF(ISNUMERIC(REPLACE(@TruckTypeABaseCost1,'$','')) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type A Base Cost 1 Should be a Number;'
				END
			ELSE
				BEGIN
					SET @TruckTypeABaseCost1 = CAST(REPLACE(@TruckTypeABaseCost1,'$','') AS DECIMAL(18,2))
				END

			IF(ISNULL(@TruckTypeAFSF1,'') <> '' AND ISNUMERIC(REPLACE(@TruckTypeAFSF1,'$','')) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type A FSF 1 Should be a Number;'
				END
			ELSE IF (ISNUMERIC(@TruckTypeAFSF1) = 1)
				BEGIN
					SET @TruckTypeAFSF1 = CAST(REPLACE(@TruckTypeAFSF1,'$','') AS DECIMAL(18,2))
				END
			
			--SELECT @TruckTypeAFROM1

			IF(ISNULL(@TruckTypeAFROM1,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type A From 1 Cannot be blank;'
				END
			ELSE 
				BEGIN					
					DELETE FROM #TEMPPROCESS
					SET @TempRemarks = ''

					INSERT INTO #TEMPPROCESS
					SELECT RTRIM(LTRIM(value))
					FROM STRING_SPLIT(@TruckTypeAFROM1, ',')

					SET @TempRemarks = (SELECT DISTINCT 'Truck Type A From 1 Yard Details;' FROM #TEMPPROCESS TP
					LEFT OUTER JOIN #Yard Y ON ( TP.Textvalue = Y.YardType )
					WHERE YardType is NULL)

					IF(@TempRemarks <> '')
						BEGIN
							SET @ISSuccess = 0
							SET	@RecordStatus = 0
							SET	@RecordRemarks = @RecordRemarks + @TempRemarks
						END
				END

-----------------------------
	IF(ISNULL(@TruckTypeABaseCost2,'') <> '' AND ISNULL(@TruckTypeAFROM2,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type A From 2 cannot be Blank;'
				END
			ELSE IF(ISNULL(@TruckTypeAFROM2,'') <> '' AND ISNULL(@TruckTypeABaseCost2,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type A Base Cost 2 cannot be Blank;'
				END					


			IF( ISNULL(@TruckTypeABaseCost2,'') <> '' AND ISNUMERIC(REPLACE(@TruckTypeABaseCost2,'$','')) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type A Base Cost 2 Should be a Number;'
				END
			ELSE IF (ISNUMERIC(@TruckTypeABaseCost2) = 1)
				BEGIN
					SET @TruckTypeABaseCost2 = CAST(REPLACE(@TruckTypeABaseCost2,'$','') AS DECIMAL(18,2))
				END


			IF(ISNULL(@TruckTypeAFSF2,'') <> '' AND ISNUMERIC(REPLACE(@TruckTypeAFSF2,'$','')) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type A FSF 2 Should be a Number;'
				END
			ELSE IF (ISNUMERIC(@TruckTypeAFSF2) = 1)
				BEGIN
					SET @TruckTypeAFSF2 = CAST(REPLACE(@TruckTypeAFSF2,'$','') AS DECIMAL(18,2))
				END


			IF(ISNULL(@TruckTypeAFROM2,'') <> '')
				BEGIN					
					DELETE FROM #TEMPPROCESS
					SET @TempRemarks = ''

					INSERT INTO #TEMPPROCESS
					SELECT RTRIM(LTRIM(value))
					FROM STRING_SPLIT(@TruckTypeAFROM2, ',')

					SET @TempRemarks = (SELECT DISTINCT 'Verify Truck Type A From 2 Details;' FROM #TEMPPROCESS TP
					LEFT OUTER JOIN #Yard Y ON ( TP.Textvalue = Y.YardType )
					WHERE YardType is NULL)

					IF(@TempRemarks <> '')
						BEGIN
							SET @ISSuccess = 0
							SET	@RecordStatus = 0
							SET	@RecordRemarks = @RecordRemarks + @TempRemarks
						END
				END

-------------------------------------------------------Truck Type B -------------------------------------
			
			IF((ISNULL(@TruckTypeBBaseCost1,'') <> ''  OR @TruckTypeBBaseCost1 <> '0.0') AND ISNULL(@TruckTypeBFROM1,'') <> ''  AND ISNULL(@TruckTypeB,'') = '' )
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type B cannot be Blank;'
				END
			IF((ISNULL(@TruckTypeBBaseCost2,'') <> ''   OR @TruckTypeBBaseCost2 <> '0.0') AND ISNULL(@TruckTypeBFROM2,'') <> ''  AND ISNULL(@TruckTypeB,'') = '' )
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type B cannot be Blank;'
				END

			IF(ISNULL(@TruckTypeBFROM1,'') = ISNULL(@TruckTypeBFROM2,'') AND ISNULL(@TruckTypeBFROM1,'') <> '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type B From 1 and Truck Type B From 2 cannot be same;'
				END

			IF(ISNULL(@TruckTypeBBaseCost1,'') <> '' AND ISNULL(@TruckTypeBFROM1,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type B From 1 cannot be Blank;'
				END
			ELSE IF(ISNULL(@TruckTypeBFROM1,'') <> '' AND ISNULL(@TruckTypeBBaseCost1,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type B Base Cost 1 cannot be Blank;'
				END					


			IF( ISNULL(@TruckTypeBBaseCost1,'') <> '' AND ISNUMERIC(REPLACE(@TruckTypeBBaseCost1,'$','')) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type B Base Cost 1 Should be a Number;'
				END
			ELSE IF (ISNUMERIC(@TruckTypeBBaseCost1) = 1)
				BEGIN
					SET @TruckTypeBBaseCost1 = CAST(REPLACE(@TruckTypeBBaseCost1,'$','') AS DECIMAL(18,2))
				END


			IF(ISNULL(@TruckTypeBFSC1,'') <> '' AND ISNUMERIC(REPLACE(@TruckTypeBFSC1,'$','')) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type B FSF 1 Should be a Number;'
				END
			ELSE IF (ISNUMERIC(@TruckTypeBFSC1) = 1)
				BEGIN
					SET @TruckTypeBFSC1 = CAST(REPLACE(@TruckTypeBFSC1,'$','') AS DECIMAL(18,2))
				END


			IF(ISNULL(@TruckTypeBFROM1,'') <> '')
				BEGIN					
					DELETE FROM #TEMPPROCESS
					SET @TempRemarks = ''

					INSERT INTO #TEMPPROCESS
					SELECT RTRIM(LTRIM(value))
					FROM STRING_SPLIT(@TruckTypeBFROM1, ',')

					SET @TempRemarks = (SELECT DISTINCT 'Verify Truck Type 1 From 2 Details;' FROM #TEMPPROCESS TP
					LEFT OUTER JOIN #Yard Y ON ( TP.Textvalue = Y.YardType )
					WHERE YardType is NULL)

					IF(@TempRemarks <> '')
						BEGIN
							SET @ISSuccess = 0
							SET	@RecordStatus = 0
							SET	@RecordRemarks = @RecordRemarks + @TempRemarks
						END
				END

-----------------------------

			IF(ISNULL(@TruckTypeBBaseCost2,'') <> '' AND ISNULL(@TruckTypeBFROM2,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type B From 2 cannot be Blank;'
				END
			ELSE IF(ISNULL(@TruckTypeBFROM2,'') <> '' AND ISNULL(@TruckTypeBBaseCost2,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type B Base Cost 2 cannot be Blank;'
				END					


			IF( ISNULL(@TruckTypeBBaseCost2,'') <> '' AND ISNUMERIC(REPLACE(@TruckTypeBBaseCost2,'$','')) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type B Base Cost 2 Should be a Number;'
				END
			ELSE IF (ISNUMERIC(@TruckTypeBBaseCost2) = 1)
				BEGIN
					SET @TruckTypeBBaseCost2 = CAST(REPLACE(@TruckTypeBBaseCost2,'$','') AS DECIMAL(18,2))
				END


			IF(ISNULL(@TruckTypeBFSC2,'') <> '' AND ISNUMERIC(REPLACE(@TruckTypeBFSC2,'$','')) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type B FSF 2 Should be a Number;'
				END
			ELSE IF (ISNUMERIC(@TruckTypeBFSC2) = 1)
				BEGIN
					SET @TruckTypeBFSC2 = CAST(REPLACE(@TruckTypeBFSC2,'$','') AS DECIMAL(18,2))
				END


			IF(ISNULL(@TruckTypeBFROM2,'') <> '')
				BEGIN					
					DELETE FROM #TEMPPROCESS
					SET @TempRemarks = ''

					INSERT INTO #TEMPPROCESS
					SELECT RTRIM(LTRIM(value))
					FROM STRING_SPLIT(@TruckTypeBFROM2, ',')

					SET @TempRemarks = (SELECT DISTINCT 'Verify Truck Type B From 2 Details;' FROM #TEMPPROCESS TP
					LEFT OUTER JOIN #Yard Y ON ( TP.Textvalue = Y.YardType )
					WHERE YardType is NULL)

					IF(@TempRemarks <> '')
						BEGIN
							SET @ISSuccess = 0
							SET	@RecordStatus = 0
							SET	@RecordRemarks = @RecordRemarks + @TempRemarks
						END
				END


				----------------------------------------------------Truck Type C -------------------------------------

			IF((ISNULL(@TruckTypeCBaseCost1,'') <> ''  OR @TruckTypeCBaseCost1 <> '0.0' ) AND ISNULL(@TruckTypeCFROM1,'') <> ''   AND ISNULL(@TruckTypeC,'') = '' )
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type C cannot be Blank;'
				END
			IF((ISNULL(@TruckTypeCBaseCost2,'') <> ''  OR @TruckTypeCBaseCost2 <> '0.0' ) AND ISNULL(@TruckTypeCFROM2,'') <> ''   AND ISNULL(@TruckTypeC,'') = '' )
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type C cannot be Blank;'
				END

			IF(ISNULL(@TruckTypeCFROM1,'') = ISNULL(@TruckTypeCFROM2,'') AND ISNULL(@TruckTypeCFROM1,'') <> '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type C From 1 and Truck Type C From 2 cannot be same;'
				END

			IF(ISNULL(@TruckTypeCBaseCost1,'') <> '' AND ISNULL(@TruckTypeCFROM1,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type C From 1 cannot be Blank;'
				END
			ELSE IF(ISNULL(@TruckTypeCFROM1,'') <> '' AND ISNULL(@TruckTypeCBaseCost1,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type C Base Cost 1 cannot be Blank;'
				END					


			IF( ISNULL(@TruckTypeCBaseCost1,'') <> '' AND ISNUMERIC(REPLACE(@TruckTypeCBaseCost1,'$','')) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type C Base Cost 1 Should be a Number;'
				END
			ELSE IF (ISNUMERIC(@TruckTypeCBaseCost1) = 1)
				BEGIN
					SET @TruckTypeCBaseCost1 = CAST(REPLACE(@TruckTypeCBaseCost1,'$','') AS DECIMAL(18,2))
				END


			IF(ISNULL(@TruckTypeCFSC1,'') <> '' AND ISNUMERIC(REPLACE(@TruckTypeCFSC1,'$','')) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type C FSF 1 Should be a Number;'
				END
			ELSE IF (ISNUMERIC(@TruckTypeCFSC1) = 1)
				BEGIN
					SET @TruckTypeCFSC1 = CAST(REPLACE(@TruckTypeCFSC1,'$','') AS DECIMAL(18,2))
				END


			IF(ISNULL(@TruckTypeCFROM1,'') <> '')
				BEGIN					
					DELETE FROM #TEMPPROCESS
					SET @TempRemarks = ''

					INSERT INTO #TEMPPROCESS
					SELECT RTRIM(LTRIM(value))
					FROM STRING_SPLIT(@TruckTypeCFROM1, ',')

					SET @TempRemarks = (SELECT DISTINCT 'Verify Truck Type C From 2 Details;' FROM #TEMPPROCESS TP
					LEFT OUTER JOIN #Yard Y ON ( TP.Textvalue = Y.YardType )
					WHERE YardType is NULL)

					IF(@TempRemarks <> '')
						BEGIN
							SET @ISSuccess = 0
							SET	@RecordStatus = 0
							SET	@RecordRemarks = @RecordRemarks + @TempRemarks
						END
				END
-----------------
			IF(ISNULL(@TruckTypeCBaseCost2,'') <> '' AND ISNULL(@TruckTypeCFROM2,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type C From 2 cannot be Blank;'
				END
			ELSE IF(ISNULL(@TruckTypeCFROM2,'') <> '' AND ISNULL(@TruckTypeCBaseCost2,'') = '')
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type C Base Cost 2 cannot be Blank;'
				END					


			IF( ISNULL(@TruckTypeCBaseCost2,'') <> '' AND ISNUMERIC(REPLACE(@TruckTypeCBaseCost2,'$','')) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type C Base Cost 2 Should be a Number;'
				END
			ELSE IF (ISNUMERIC(@TruckTypeCBaseCost2) = 1)
				BEGIN
					SET @TruckTypeCBaseCost2 = CAST(REPLACE(@TruckTypeCBaseCost2,'$','') AS DECIMAL(18,2))
				END


			IF(ISNULL(@TruckTypeCFSC2,'') <> '' AND ISNUMERIC(REPLACE(@TruckTypeCFSC2,'$','')) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Truck Type C FSF 2 Should be a Number;'
				END
			ELSE IF (ISNUMERIC(@TruckTypeCFSC2) = 1)
				BEGIN
					SET @TruckTypeCFSC2 = CAST(REPLACE(@TruckTypeCFSC2,'$','') AS DECIMAL(18,2))
				END


			IF(ISNULL(@TruckTypeCFROM2,'') <> '')
				BEGIN					
					DELETE FROM #TEMPPROCESS
					SET @TempRemarks = ''

					INSERT INTO #TEMPPROCESS
					SELECT RTRIM(LTRIM(value))
					FROM STRING_SPLIT(@TruckTypeCFROM2, ',')

					SET @TempRemarks = (SELECT DISTINCT 'Verify Truck Type C From 2 Details;' FROM #TEMPPROCESS TP
					LEFT OUTER JOIN #Yard Y ON ( TP.Textvalue = Y.YardType )
					WHERE YardType is NULL)

					IF(@TempRemarks <> '')
						BEGIN
							SET @ISSuccess = 0
							SET	@RecordStatus = 0
							SET	@RecordRemarks = @RecordRemarks + @TempRemarks
						END
				END


				------------------------------------------------------------------------------------------------------------------------

			--IF(ISNULL(@TruckType2 ,'') <> '' AND ISNULL(@TruckType2BaseCost ,'') = '' )
			--	BEGIN
			--		SET @ISSuccess = 0
			--		SET	@RecordStatus = 0
			--		SET	@RecordRemarks = @RecordRemarks + 'Truck Type 2 Base Cost Cannot be blank;'
			--	END
			--ELSE IF(ISNULL(@TruckType2BaseCost ,'') <> '' AND ISNULL(@TruckType2,'') = '' )
			--	BEGIN
			--		SET @ISSuccess = 0
			--		SET	@RecordStatus = 0
			--		SET	@RecordRemarks = @RecordRemarks + 'Truck Type 2 Cannot be blank;'
			--	END
			--ELSE IF ((SELECT COUNT(*) FROM TruckType WHERE TruckType = @TruckType2 ) = 0)
			--	BEGIN
			--		SET @ISSuccess = 0
			--		SET	@RecordStatus = 0
			--		SET	@RecordRemarks = @RecordRemarks + 'Truck Type 2 does not exists in Masters;'
			--	END
			
			--IF(ISNULL(@TruckType2BaseCost ,'') <> '' AND ISNUMERIC(@TruckType2BaseCost) = 0)
			--	BEGIN
			--		SET @ISSuccess = 0
			--		SET	@RecordStatus = 0
			--		SET	@RecordRemarks = @RecordRemarks + 'Truck Type 2 Base Cost Should be a Number;'
			--	END
			--ELSE IF (ISNUMERIC(@TruckType2BaseCost) = 1)
			--	BEGIN
			--		SET @TruckType2BaseCost = CAST(@TruckType2BaseCost AS DECIMAL(18,2))
			--	END

			--IF(ISNULL(@TruckType2FSC,'') <> '' AND ISNUMERIC(@TruckType2FSC) = 0)
			--	BEGIN
			--		SET @ISSuccess = 0
			--		SET	@RecordStatus = 0
			--		SET	@RecordRemarks = @RecordRemarks + 'Truck Type 2 FSF Should be a Number;'
			--	END
			--ELSE IF (ISNUMERIC(@TruckType2FSC) = 1)
			--	BEGIN
			--		SET @TruckType2FSC = CAST(@TruckType2FSC AS DECIMAL(18,2))
			--	END


			--IF(ISNULL(@TruckType3 ,'') <> '' AND ISNULL(@TruckType3BaseCost ,'') = '' )
			--	BEGIN
			--		SET @ISSuccess = 0
			--		SET	@RecordStatus = 0
			--		SET	@RecordRemarks = @RecordRemarks + 'Truck Type 3 Base Cost Cannot be blank;'
			--	END
			--ELSE IF(ISNULL(@TruckType3BaseCost ,'') <> '' AND ISNULL(@TruckType3,'') = '' )
			--	BEGIN
			--		SET @ISSuccess = 0
			--		SET	@RecordStatus = 0
			--		SET	@RecordRemarks = @RecordRemarks + 'Truck Type 3 Cannot be blank;'
			--	END


			-- IF(ISNULL(@TruckType3BaseCost ,'') <> '' AND ISNUMERIC(@TruckType3BaseCost) = 0)
			--	BEGIN
			--		SET @ISSuccess = 0
			--		SET	@RecordStatus = 0
			--		SET	@RecordRemarks = @RecordRemarks + 'Truck Type 3 Base Cost Should be a Number;'
			--	END
			--ELSE IF (ISNUMERIC(@TruckType3BaseCost) = 1)
			--	BEGIN
			--		SET @TruckType3BaseCost = CAST(@TruckType3BaseCost AS DECIMAL(18,2))
			--	END

			--IF(ISNULL(@TruckType3FSC,'') <> '' AND ISNUMERIC(@TruckType3FSC) = 0)
			--	BEGIN
			--		SET @ISSuccess = 0
			--		SET	@RecordStatus = 0
			--		SET	@RecordRemarks = @RecordRemarks + 'Truck Type 3 FSF Should be a Number;'
			--	END
			--ELSE IF (ISNUMERIC(@TruckType3FSC) = 1)
			--	BEGIN
			--		SET @TruckType3FSC = CAST(@TruckType3FSC AS DECIMAL(18,2))
			--	END
			--	Print 1
			IF(ISNULL(@EffectiveDate ,'') = '' )
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Effective Date Cannot be blank;'
				END
			ELSE IF (ISDATE(@EffectiveDate) = 0)
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Date Format is not Correct;'
				END
Print 2
			IF(ISNULL(@EffectiveDateFrom ,'') = '' )
				BEGIN
					SET @ISSuccess = 0
					SET	@RecordStatus = 0
					SET	@RecordRemarks = @RecordRemarks + 'Effective Date From Cannot be blank;'
				END
	--SELECT @RecordRemarks
	Print 3
		INSERT INTO				COST_FileUploadData_Chicago
								(FileProcesskey,RecordSL,Market,Terminal,City,State,ZipCode,Zone,Prepulllocation1,Prepullcost1,Prepulllocation2,Prepullcost2,Prepulllocation3,Prepullcost3,Prepulllocation4,Prepullcost4,Prepulllocation5
								,Prepullcost5,Stopofflocation1,Stopoffcost1,Stopofflocation2,Stopoffcost2,Stopofflocation3,Stopoffcost3,Stopofflocation4,Stopoffcost4,Stopofflocation5,Stopoffcost5,YardshuttledirectionTO1
								,YardshuttledirectionFROM1,Yardshuttlecost1,YardshuttledirectionTO2,YardshuttledirectionFROM2,Yardshuttlecost2
								,TruckTypeA,TruckTypeABaseCost1,TruckTypeAFSF1,TruckTypeAFROM1,TruckTypeABaseCost2,TruckTypeAFSF2,TruckTypeAFROM2
								,TruckTypeB,TruckTypeBBaseCost1,TruckTypeBFSC1,TruckTypeBFROM1,TruckTypeBBaseCost2,TruckTypeBFSC2,TruckTypeBFROM2
								,TruckTypeC,TruckTypeCBaseCost1,TruckTypeCFSC1,TruckTypeCFROM1,TruckTypeCBaseCost2,TruckTypeCFSC2,TruckTypeCFROM2
								,TruckTypeD,TruckTypeDBaseCost1,TruckTypeDFSC1
								,TruckTypeE,TruckTypeEBaseCost1,TruckTypeEFSC1
								,EffectiveDate,EffectiveDateFrom
								,RecordStatus,RecordRemarks)
		SELECT					@FileProcesskey,SlNo,Market,Terminal,City,State,@ZipCode,Zone,Prepulllocation1,@Prepullcost1,Prepulllocation2,@Prepullcost2,Prepulllocation3,@Prepullcost3,Prepulllocation4,@Prepullcost4,Prepulllocation5
								,@Prepullcost5,Stopofflocation1,@Stopoffcost1,Stopofflocation2,@Stopoffcost2,Stopofflocation3,@Stopoffcost3,Stopofflocation4,@Stopoffcost4,Stopofflocation5,@Stopoffcost5,YardshuttledirectionTO1
								,YardshuttledirectionFROM1,@Yardshuttlecost1,YardshuttledirectionTO2,YardshuttledirectionFROM2,@Yardshuttlecost2
								,@TruckTypeA,@TruckTypeABaseCost1,@TruckTypeAFSF1,@TruckTypeAFROM1,@TruckTypeABaseCost2,@TruckTypeAFSF2,@TruckTypeAFROM2
								,@TruckTypeB,@TruckTypeBBaseCost1,@TruckTypeBFSC1,@TruckTypeBFROM1,@TruckTypeBBaseCost2,@TruckTypeBFSC2,@TruckTypeBFROM2
								,@TruckTypeC,@TruckTypeCBaseCost1,@TruckTypeCFSC1,@TruckTypeCFROM1,@TruckTypeCBaseCost2,@TruckTypeCFSC2,@TruckTypeCFROM2
								,@TruckTypeD,@TruckTypeDBaseCost1,@TruckTypeDFSC1
								,@TruckTypeE,@TruckTypeEBaseCost1,@TruckTypeEFSC1
								,EffectiveDate,EffectiveDateFrom
								,@RecordStatus,@RecordRemarks
		FROM					#FileUploadData
		WHERE					SlNo = @i

		SET @i = @i  + 1

		END


	IF(@ISSuccess = 0)
		BEGIN
			SET @Remarks = 'File Not Uploaded'
		END

	SELECT					A.*, FileProcesskey
							,RecordStatus,RecordRemarks
							,Market,Terminal,City,[State]	,ZipCode,[Zone],Prepulllocation1,Prepullcost1,Prepulllocation2,Prepullcost2,Prepulllocation3,
							Prepullcost3,Prepulllocation4,Prepullcost4,Prepulllocation5
							,Prepullcost5,Stopofflocation1,Stopoffcost1,Stopofflocation2,Stopoffcost2,Stopofflocation3,Stopoffcost3,Stopofflocation4,
							Stopoffcost4,Stopofflocation5,Stopoffcost5,YardshuttledirectionTO1
							,YardshuttledirectionFROM1,Yardshuttlecost1,YardshuttledirectionTO2,YardshuttledirectionFROM2,Yardshuttlecost2
							,TruckTypeA,TruckTypeABaseCost1 TruckTypeABaseCost1,TruckTypeAFSF1 TruckTypeAFSF1,TruckTypeAFROM1,
							TruckTypeABaseCost2 TruckTypeABaseCost2,TruckTypeAFSF2 TruckTypeAFSF2,TruckTypeAFROM2
							,TruckTypeB,TruckTypeBBaseCost1 TruckTypeBBaseCost1,TruckTypeBFSC1 TruckTypeBFSC1,TruckTypeBFROM1,
							TruckTypeBBaseCost2 TruckTypeBBaseCost2,TruckTypeBFSC2 TruckTypeBFSC2,TruckTypeBFROM2
							,TruckTypeC,TruckTypeCBaseCost1 TruckTypeCBaseCost1,TruckTypeCFSC1 TruckTypeCFSC1,TruckTypeCFROM1,
							TruckTypeCBaseCost2 TruckTypeCBaseCost2,TruckTypeCFSC2 TruckTypeCFSC2,TruckTypeCFROM2
							,TruckTypeD,TruckTypeDBaseCost1 TruckTypeDBaseCost1,TruckTypeDFSC1 TruckTypeDFSC1
							,TruckTypeE,TruckTypeEBaseCost1 TruckTypeEBaseCost1,TruckTypeEFSC1 TruckTypeEFSC1
							,EffectiveDate,EffectiveDateFrom
							-- ,RecordStatus,RecordRemarks
	FROM					(SELECT @ISSuccess AS ISSuccess, @Remarks AS Remarks ) A
	LEFT OUTER JOIN			(SELECT	 *
							FROM	COST_FileUploadData_Chicago WITH (NOLOCK)
							WHERE	FileProcesskey = @FileProcesskey							
							) B ON 1 = CASE WHEN @ISSuccess = 1 THEN 0 ELSE 1 END
	ORDER BY RecordSL

	UPDATE					FP
	SET						FileUploadStatus = 1, FileProcessStatus = @ISSuccess, IsFileDownloaded = 0
	FROM					COST_FileProcessInfo FP WITH (NOLOCK)
	WHERE					FileProcessKey = @FileProcesskey

	--SELECT @FileProcesskey

	IF(@ISSuccess = 1)
		BEGIN
			EXEC COST_MoveCostOutputData @FileProcesskey
			EXEC COST_MoveCostOutputData_PrePull @FileProcesskey
			EXEC COST_MoveCostOutputData_StopOff @FileProcesskey
			EXEC COST_MoveCostOutputData_YardShuttle @FileProcesskey
		END
 	

END


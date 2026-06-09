
CREATE PROCEDURE [dbo].[COSTACC_MoveAccessorialItemOutputData_Rosh]
AS
BEGIN
		DECLARE @FileProcessKey INT
		CREATE TABLE #SplitData 
		(
			FileProcessKey		INT,
			RecordSL			INT,
			Terminal			VARCHAR(100)
		)

		CREATE TABLE #SplitData_YardPort
		(
			FileProcessKey		INT,
			RecordSL			INT,
			YardPort			VARCHAR(100)
		)


		CREATE TABLE #SplitData_TruckType
		(
			FileProcessKey		INT,
			RecordSL			INT,
			TruckType			VARCHAR(100)
		)

		CREATE TABLE #SplitData_Market
		(
			FileProcessKey		INT,
			RecordSL			INT,
			Market			VARCHAR(100)
		)


		SELECT DISTINCT  LineItem, Market, Terminal, TruckType, yardPort, Zone, [Group], FixVsNonFix, EffectiveDate, 
						Max(A.FileProcesskey) Max_FileProcesskey, 10 as Max_RecordSL, FreePer, SplitPercent
		INTO			#TempItems
		FROM			COSTACC_FileUploadData A
		INNER JOIN		COSTACC_FileProcessInfo B on A.FileProcesskey = B.FileProcessKey
		WHERE			B.FileUploadStatus = 1 and RecordStatus = 1 -- and  B.IsFileDownloaded = 1
		GROUP BY		LineItem, Market,  Terminal, TruckType, yardPort, Zone, [Group], FixVsNonFix, EffectiveDate, FreePer, SplitPercent

		DECLARE			@i INT = 1, @n INT  = 0 ,   @RecordSL INT = 0,  @TruckType VARCHAR(50)

		----------------------------------------------Terminal----------------------------------------------------
		SELECT			ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,TERMINAL , RecordSL
		INTO			#DATA
		FROM			(SELECT DISTINCT Max_FileProcesskey FileProcesskey,TERMINAL, Max_RecordSL RecordSL FROM #TempItems WITH (NOLOCK) WHERE Terminal IS NOT NULL ) A

		SET @n = (SELECT COUNT(*) FROM #DATA)
		WHILE (@i <= @n)
			BEGIN
				SET @FileProcessKey = (SELECT FileProcessKey FROM #DATA WHERE SlNO = @i  )
				SET @RecordSL = (SELECT RecordSL FROM #DATA WHERE SlNO = @i  )
				-- SELECT @RecordSL
				INSERT INTO #SplitData
				SELECT *
				FROm	(SELECT @FileProcessKey AS FileProcessKey,  @RecordSL AS RecordSL ) A
				INNER JOIN (SELECT RTRIM(LTRIM(value) )Terminal
				FROM STRING_SPLIT((SELECT Terminal FROM #DATA WHERE SlNO = @i  ), ',') )	
				B ON 1 = 1
				SET @i = @i + 1
			END
		
		-----------------------------------YardPort------------------------------------------------------------------------
		SELECT			ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,YardPort , RecordSL
		INTO			#DATAYardPort
		FROM			(SELECT DISTINCT Max_FileProcesskey FileProcesskey,YardPort, Max_RecordSL RecordSL FROM #TempItems WITH (NOLOCK) WHERE ISNULL(YardPort,'') <> '' ) A

		-- SELECT * FROM #DATAYardPort

		SET	@i = 1
		SET @n = (SELECT COUNT(*) FROM #DATAYardPort)
		WHILE (@i <= @n)
			BEGIN
				SET @FileProcessKey = (SELECT FileProcessKey FROM #DATAYardPort WHERE SlNO = @i  )
				SET @RecordSL = (SELECT RecordSL FROM #DATAYardPort WHERE SlNO = @i  )
				-- SELECT @RecordSL
				INSERT INTO #SplitData_YardPort
				SELECT *
				FROm	(SELECT @FileProcessKey AS FileProcessKey,  @RecordSL AS RecordSL ) A
				INNER JOIN (SELECT RTRIM(LTRIM(value) )YardPort
				FROM STRING_SPLIT((SELECT YardPort FROM #DATAYardPort WHERE SlNO = @i  ), ',') )	
				B ON 1 = 1
				SET @i = @i + 1
			END
		

		-- SELECT * FROM #SplitData_YardPort

		-----------------------------------Truck Type------------------------------------------------------------------------
		SELECT			ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,TruckType , RecordSL
		INTO			#DATATruckType
		FROM			(SELECT DISTINCT Max_FileProcesskey FileProcesskey,TruckType, Max_RecordSL RecordSL FROM #TempItems WITH (NOLOCK) WHERE ISNULL(TruckType,'') <> '' ) A

		-- SELECT * FROM #DATATruckType

		SET	@i = 1
		SET @n = (SELECT COUNT(*) FROM #DATATruckType)
		WHILE (@i <= @n)
			BEGIN
				SET @FileProcessKey = (SELECT FileProcessKey FROM #DATATruckType WHERE SlNO = @i  )
				SET @RecordSL = (SELECT RecordSL FROM #DATATruckType WHERE SlNO = @i  )
				-- SELECT @RecordSL
				INSERT INTO #SplitData_TruckType
				SELECT *
				FROm	(SELECT @FileProcessKey AS FileProcessKey,  @RecordSL AS RecordSL ) A
				INNER JOIN (SELECT RTRIM(LTRIM(value) )TruckType
				FROM STRING_SPLIT((SELECT TruckType FROM #DATATruckType WHERE SlNO = @i  ), ',') )	
				B ON 1 = 1
				SET @i = @i + 1
			END

		-----------------------------------Market------------------------------------------------------------------------
		SELECT			ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,Market , RecordSL
		INTO			#DATAMarket
		FROM			(SELECT DISTINCT Max_FileProcesskey FileProcesskey,Market, Max_RecordSL RecordSL FROM #TempItems WITH (NOLOCK) WHERE ISNULL(Market,'') <> '' ) A

		-- SELECT * FROM #DATAMarket

		SET	@i = 1
		SET @n = (SELECT COUNT(*) FROM #DATAMarket)
		WHILE (@i <= @n)
			BEGIN
				SET @FileProcessKey = (SELECT FileProcessKey FROM #DATAMarket WHERE SlNO = @i  )
				SET @RecordSL = (SELECT RecordSL FROM #DATAMarket WHERE SlNO = @i  )
				-- SELECT @RecordSL
				INSERT INTO #SplitData_Market
				SELECT *
				FROm	(SELECT @FileProcessKey AS FileProcessKey,  @RecordSL AS RecordSL ) A
				INNER JOIN (SELECT RTRIM(LTRIM(value) )TruckType
				FROM STRING_SPLIT((SELECT Market FROM #DATAMarket WHERE SlNO = @i  ), ',') )	
				B ON 1 = 1
				SET @i = @i + 1
			END
		
		------------------------------------------------------------------------------------------------------------------------

			   		 	  	  
		--UPDATE			A 
		--SET				FileProcesskey = B.Max_FileProcesskey,
		--				RecordSL = B.Max_REcordSL,
		--				Per = C.Per,
		--				UnitCost = C.UnitCost,
		--				EffectiveDate = C.EffectiveDate,
		--				EffectiveDateFrom = C.EffectiveDateFrom, 
		--				Terminal = C.Terminal, TruckType = C.TruckType, yardPort = C.yardPort, Zone = C.Zone,
		--				FreePer = C.FreePer, SplitPercent = C.SplitPercent
		--FROM			[COSTACC_FinalDataOutput] A
		--INNER JOIN		#TempItems B on A.LineItem = B.LineItem and A.Market = B.Market and
		--				A.[Group] = B.[Group] and A.FixVsNonFix = B.FixVsNonFix
		--INNER JOIN		COSTACC_FileUploadData C on B.Max_FileProcesskey = C.FileProcesskey and B.Max_REcordSL = C.RecordSL

		SELECT			FileProcesskey = B.Max_FileProcesskey,
						A.RecordSL , B.Max_REcordSL,
						A.Per , C.Per,
						A.UnitCost , C.UnitCost,
						A.EffectiveDate , C.EffectiveDate,
						A.EffectiveDateFrom , C.EffectiveDateFrom, 
						A.Terminal , C.Terminal, A.TruckType , C.TruckType, A.yardPort , C.yardPort, Zone = C.Zone,
						A.FreePer , C.FreePer, A.SplitPercent , C.SplitPercent
		FROM			[COSTACC_FinalDataOutput] A
		INNER JOIN		#TempItems B on A.LineItem = B.LineItem and A.Market = B.Market and
						A.[Group] = B.[Group] and A.FixVsNonFix = B.FixVsNonFix
		INNER JOIN		COSTACC_FileUploadData C on B.Max_FileProcesskey = C.FileProcesskey and B.Max_REcordSL = C.RecordSL
		WHERE			B.LineItem LIKE 'Transload'


		--INSERT INTO		[COSTACC_FinalDataOutput] ( FileProcesskey, RecordSL, LineItem, Market, Terminal, TruckType, yardPort, Zone, [Group], FixVsNonFix, 
		--				Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer, SplitPercent)
		SELECT			c.FileProcesskey, C.RecordSL, C.LineItem, M.Market, SD.Terminal, TT.TruckType, YD.YardPort, C.Zone, C.[Group], C.FixVsNonFix,
						C.Per, C.UnitCost, C.EffectiveDate, C.EffectiveDateFrom, C.FreePer, C.SplitPercent 
		FROM			#TempItems B 
		INNER JOIN		COSTACC_FileUploadData C on B.Max_FileProcesskey = C.FileProcesskey and B.Max_REcordSL = C.RecordSL
		LEFT JOIN		[COSTACC_FinalDataOutput] A on A.LineItem = B.LineItem and A.Market = B.Market and
						A.[Group] = B.[Group] and A.FixVsNonFix = B.FixVsNonFix
		LEFT OUTER JOIN #SplitData SD ON B.Max_FileProcesskey = SD.FileProcessKey AND B.Max_RecordSL = SD.RecordSL 
		LEFT OUTER JOIN #SplitData_YardPort YD ON B.Max_FileProcesskey = YD.FileProcessKey AND B.Max_RecordSL = YD.RecordSL 
		LEFT OUTER JOIN #SplitData_TruckType TT ON B.Max_FileProcesskey = TT.FileProcessKey AND B.Max_RecordSL = TT.RecordSL 
		LEFT OUTER JOIN #SplitData_Market M ON B.Max_FileProcesskey = M.FileProcessKey AND B.Max_RecordSL = M.RecordSL 
		WHERE			A.FileProcesskey is null AND B.LineItem LIKE 'Transload'

		DROP TABLE		#TempItems
		DROP TABLE		#SplitData
		DROP TABLE		#SplitData_YardPort
		DROP TABLE		#SplitData_TruckType
End

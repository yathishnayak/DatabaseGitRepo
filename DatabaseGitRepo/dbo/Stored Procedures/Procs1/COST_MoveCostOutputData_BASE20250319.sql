

CREATE PROCEDURE [dbo].[COST_MoveCostOutputData_BASE20250319] -- COST_MoveCostOutputData 1
(
	@FileProcessKey		INT
)

AS


BEGIN

	-- SELECT * FROM #GetFileUploadDetails
	   	
	---------------------------- Spit Terminal String------------------------------------
	
		-- DROP TABLE #DATA


		CREATE TABLE #DATA 
		(
			SLNo				INT,
			FileProcesskey		INT,
			TextValue		    VARCHAR(100),
			RecordSL			INT,
			TruckType			VARCHAR(100)
	
		)



		CREATE TABLE #SplitData 
		(
			FileProcessKey		INT,
			TerminalString		VARCHAR(200),
			RecordSL			INT,
			Terminal			VARCHAR(100)
		)


		CREATE TABLE #SplitData_TruckTypeFrom
	(
		FileProcessKey			INT,
		RecordSL				INT,
		TruckType				VARCHAR(100),
		TruckTypeFromActual		VARCHAR(100),
		TruckTypeFrom			VARCHAR(100)
	)
		
		--SELECT			* 
		--FROM			COST_VGetFileUploadDetails 
		--WHERE			FileProcessKey = 5 


		SELECT			* 
		INTO			#GetFileUploadDetails 
		FROM			COST_VGetFileUploadDetails 
		WHERE			FileProcessKey = @FileProcessKey 

		-- SELECT 'Test', * FROM #GetFileUploadDetails

		TRUNCATE TABLE #DATA
		INSERT INTO		#DATA
		SELECT			ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,TERMINAL , RecordSL,''
		FROM			(SELECT DISTINCT FileProcesskey,TERMINAL, RecordSL FROM #GetFileUploadDetails WITH (NOLOCK) WHERE Terminal IS NOT NULL ) A

		DECLARE			@i INT = 1, @n INT  = (SELECT COUNT(*) FROM #DATA),  @TerminalString VARCHAR(200) = '', @RecordSL INT = 0,  @TruckType VARCHAR(50), @TruckTypeFrom VARCHAR(20)
		-- SELECT * FROM #DATA
		WHILE (@i <= @n)
			BEGIN
				SET @FileProcessKey = (SELECT FileProcessKey FROM #DATA WHERE SlNO = @i  )
				SET @RecordSL = (SELECT RecordSL FROM #DATA WHERE SlNO = @i  )
				-- SELECT @RecordSL
				INSERT INTO #SplitData
				SELECT *
				FROm	(SELECT @FileProcessKey AS FileProcessKey, @TerminalString AS TerminalString, @RecordSL AS RecordSL ) A
				INNER JOIN (SELECT RTRIM(LTRIM(value) )Terminal
				FROM STRING_SPLIT((SELECT TextValue FROM #DATA WHERE SlNO = @i  ), ',') )	
				B ON 1 = 1
				SET @i = @i + 1
			END


		---------------------------------------------Truck Type From---------------------------------------------------------------------------------
			DECLARE @MAXCOUNT INT = 0

			TRUNCATE TABLE	#DATA
			INSERT INTO		#DATA
			SELECT			ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,TruckTypeFrom , RecordSL, TruckType
			FROM			(SELECT DISTINCT FileProcesskey,TruckTypeAFrom1 AS TruckTypeFrom, RecordSL, TruckTypeA AS  TruckType  FROM #GetFileUploadDetails WITH (NOLOCK) WHERE ISNULL(TruckTypeAFrom1,'')<> '') A

			SET @MAXCOUNT = (SELECT MAX(SLNo) FROM #DATA)
			INSERT INTO		#DATA
			SELECT			@MAXCOUNT + ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,TruckTypeFrom , RecordSL, TruckType
			FROM			(SELECT DISTINCT FileProcesskey,TruckTypeAFrom2 AS TruckTypeFrom, RecordSL, TruckTypeA AS  TruckType   FROM #GetFileUploadDetails WITH (NOLOCK) WHERE ISNULL(TruckTypeAFrom2,'')<> '') A

			SET @MAXCOUNT = (SELECT MAX(SLNo) FROM #DATA)
			INSERT INTO		#DATA
			SELECT			@MAXCOUNT + ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,TruckTypeFrom , RecordSL, TruckType
			FROM			(SELECT DISTINCT FileProcesskey,TruckTypeAFrom3 AS TruckTypeFrom, RecordSL, TruckTypeA AS  TruckType   FROM #GetFileUploadDetails WITH (NOLOCK) WHERE ISNULL(TruckTypeAFrom3,'')<> '') A

			SET @MAXCOUNT = (SELECT MAX(SLNo) FROM #DATA)
			INSERT INTO		#DATA
			SELECT			@MAXCOUNT + ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,TruckTypeFrom , RecordSL, TruckType
			FROM			(SELECT DISTINCT FileProcesskey,TruckTypeBFROM1 AS TruckTypeFrom, RecordSL, TruckTypeB AS  TruckType  FROM #GetFileUploadDetails WITH (NOLOCK) WHERE ISNULL(TruckTypeBFROM1,'')<> '') A

			SET @MAXCOUNT = (SELECT MAX(SLNo) FROM #DATA)
			INSERT INTO		#DATA
			SELECT			@MAXCOUNT + ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,TruckTypeFrom , RecordSL, TruckType
			FROM			(SELECT DISTINCT FileProcesskey,TruckTypeBFROM2 AS TruckTypeFrom, RecordSL, TruckTypeB AS  TruckType  FROM #GetFileUploadDetails WITH (NOLOCK) WHERE ISNULL(TruckTypeBFROM2,'')<> '') A

			SET @MAXCOUNT = (SELECT MAX(SLNo) FROM #DATA)
			INSERT INTO		#DATA
			SELECT			@MAXCOUNT + ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,TruckTypeFrom , RecordSL, TruckType
			FROM			(SELECT DISTINCT FileProcesskey,TruckTypeBFrom3 AS TruckTypeFrom, RecordSL, TruckTypeB AS  TruckType   FROM #GetFileUploadDetails WITH (NOLOCK) WHERE ISNULL(TruckTypeBFrom3,'')<> '') A

			SET @MAXCOUNT = (SELECT MAX(SLNo) FROM #DATA)
			INSERT INTO		#DATA
			SELECT			@MAXCOUNT + ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,TruckTypeFrom , RecordSL, TruckType
			FROM			(SELECT DISTINCT FileProcesskey,TruckTypeCFROM1 AS TruckTypeFrom, RecordSL, TruckTypeC AS  TruckType  FROM #GetFileUploadDetails WITH (NOLOCK) WHERE ISNULL(TruckTypeCFROM1,'')<> '') A

			SET @MAXCOUNT = (SELECT MAX(SLNo) FROM #DATA)
			INSERT INTO		#DATA
			SELECT			@MAXCOUNT + ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,TruckTypeFrom , RecordSL, TruckType
			FROM			(SELECT DISTINCT FileProcesskey,TruckTypeCFROM2 AS TruckTypeFrom, RecordSL, TruckTypeC AS  TruckType  FROM #GetFileUploadDetails WITH (NOLOCK) WHERE ISNULL(TruckTypeCFROM2,'')<> '') A

			SET @MAXCOUNT = (SELECT MAX(SLNo) FROM #DATA)
			INSERT INTO		#DATA
			SELECT			@MAXCOUNT + ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,TruckTypeFrom , RecordSL, TruckType
			FROM			(SELECT DISTINCT FileProcesskey,TruckTypeCFrom3 AS TruckTypeFrom, RecordSL, TruckTypeC AS  TruckType   FROM #GetFileUploadDetails WITH (NOLOCK) WHERE ISNULL(TruckTypeCFrom3,'')<> '') A

			SET @MAXCOUNT = (SELECT MAX(SLNo) FROM #DATA)
			INSERT INTO		#DATA
			SELECT			@MAXCOUNT + ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,TruckTypeFrom , RecordSL, TruckType
			FROM			(SELECT DISTINCT FileProcesskey,TruckTypeDFROM1 AS TruckTypeFrom, RecordSL, TruckTypeD AS  TruckType  FROM #GetFileUploadDetails WITH (NOLOCK) WHERE ISNULL(TruckTypeDFROM1,'')<> '') A

			SET @MAXCOUNT = (SELECT MAX(SLNo) FROM #DATA)
			INSERT INTO		#DATA
			SELECT			@MAXCOUNT + ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,TruckTypeFrom , RecordSL, TruckType
			FROM			(SELECT DISTINCT FileProcesskey,TruckTypeDFROM2 AS TruckTypeFrom, RecordSL, TruckTypeD AS  TruckType  FROM #GetFileUploadDetails WITH (NOLOCK) WHERE ISNULL(TruckTypeDFROM2,'')<> '') A

			SET @MAXCOUNT = (SELECT MAX(SLNo) FROM #DATA)
			INSERT INTO		#DATA
			SELECT			@MAXCOUNT + ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,TruckTypeFrom , RecordSL, TruckType
			FROM			(SELECT DISTINCT FileProcesskey,TruckTypeDFrom3 AS TruckTypeFrom, RecordSL, TruckTypeD AS  TruckType   FROM #GetFileUploadDetails WITH (NOLOCK) WHERE ISNULL(TruckTypeDFrom3,'')<> '') A

			SET		@i = 1
			SET		@n  = (SELECT COUNT(*) FROM #DATA)
			SET		@FileProcessKey = 0
			SET		@RecordSL = 0

			SELECT * FROM #DATA WHERE RecordSL = 1
			WHILE (@i <= @n)
				BEGIN
					SET @FileProcessKey = (SELECT FileProcessKey FROM #DATA WHERE SlNO = @i  )
					SET @RecordSL = (SELECT RecordSL FROM #DATA WHERE SlNO = @i  )
					SET	@TruckType = (SELECT TruckType FROM #DATA WHERE SlNO = @i  )
					SET	@TruckTypeFrom = (SELECT TextValue FROM #DATA WHERE SlNO = @i  )
					-- SELECT @RecordSL
					INSERT INTO #SplitData_TruckTypeFrom
					SELECT *
					FROm	(SELECT @FileProcessKey AS FileProcessKey, @RecordSL AS RecordSL, @TruckType AS TruckType, @TruckTypeFrom AS TruckTypeFromActual  ) A
					INNER JOIN (SELECT RTRIM(LTRIM(value) )TruckTypeFrom
					FROM STRING_SPLIT((SELECT TextValue FROM #DATA WHERE SlNO = @i  ), ',') )	
					B ON 1 = 1
					SET @i = @i + 1

					SELECT * FROM #SplitData_TruckTypeFrom WHERE RecordSL = 1

				END
		
			---------------------------------------------------------------------------------------------------------------------------------------------------------------


	--SELECT		DISTINCT Market,Terminal,City,State,ZipCode,Zone, TruckType1 DriverType
	--							,CAST(CASE WHEN TruckType1BaseCost = '' THEN '0.00' ELSE TruckType1BaseCost END AS DECIMAL(18,2)) Cost
	--							,CAST(CASE WHEN TruckType1FSF = '' THEN '0.00' ELSE TruckType1FSF END AS DECIMAL(18,2))  FSF
	--							, 0.00 AS DrayBase, CAST(LEFT(EffectiveDate,10) AS DATETIME) EffectiveDate, EffectiveDateFrom 
	--				FROM		#GetFileUploadDetails

	-- COST_MoveCostOutputData 141

	DECLARE @CNT INT = 0
	SET @CNT = (SELECT COUNT(*) FROM #GetFileUploadDetails)


	--SELECT * FROm #GetFileUploadDetails
	--SELECT * FROM #SplitData
	--SELECT * FROm #SplitData_TruckTypeFrom


--	DROP TABLE #SplitData
--DROP TABLE #SplitData_TruckTypeFrom
--DROP TABLE #GetFileUploadDetails

-- COST_MoveCostOutputData 2

SELECT 'Çheck',* FROM #GetFileUploadDetails
SELECT * FROM #SplitData
SELECT * FROM #SplitData_TruckTypeFrom

SELECT		*
FROM		#GetFileUploadDetails  A WITH (NOLOCK)
-- INNER JOIN	#SplitData  B ON A.FileProcessKey = B.FileProcessKey AND A.RecordSL = B.RecordSL
-- INNER JOIN	#SplitData_TruckTypeFrom C ON B.FileProcessKey = C.FileProcessKey AND B.RecordSL = C.RecordSL AND A.TruckTypeB = C.TruckType
--WHERE		ISNULL(TruckTypeB,'') <> ''  AND ISNULL(TruckTypeBFROM1,'') <> ''


	IF(@CNT > 0)
		BEGIN
			SELECT			*
			INTO			#TMPDATA
			FROM			(SELECT		Market,B.Terminal,City,State,ZipCode,Zone, TruckTypeA DriverType
										,CAST(CASE WHEN REPLACE(ISNULL(TruckTypeABaseCost1,''),'','0.00') = '0.00' THEN 0.00 ELSE CAST(TruckTypeABaseCost1 AS DECIMAL(18,2)) END AS DECIMAL(18,2)) Cost
										,CAST(CASE WHEN REPLACE(TruckTypeAFSF1,'','0.00') = '0.00' THEN 0.00 ELSE CAST(TruckTypeAFSF1 AS DECIMAL(18,2)) END AS DECIMAL(18,2))  FSF
										,TruckTypeFROM
										, 0.00 AS DrayBase, CAST(LEFT(EffectiveDate,10) AS DATETIME) EffectiveDate, EffectiveDateFrom 
							FROM		#GetFileUploadDetails  A WITH (NOLOCK)
							INNER JOIN	#SplitData  B ON A.FileProcessKey = B.FileProcessKey AND A.RecordSL = B.RecordSL
							INNER JOIN	#SplitData_TruckTypeFrom C ON B.FileProcessKey = C.FileProcessKey AND B.RecordSL = C.RecordSL AND A.TruckTypeA = C.TruckType AND TruckTypeFromActual = A.TruckTypeAFROM1
							WHERE		ISNULL(TruckTypeA,'') <> '' AND ISNULL(TruckTypeAFROM1,'') <> ''
							UNION ALL
							SELECT		Market,B.Terminal,City,State,ZipCode,Zone, TruckTypeA DriverType
										,CAST(CASE WHEN REPLACE(TruckTypeABaseCost2,'','0.00') = '0.00' THEN 0.00 ELSE TruckTypeABaseCost2 END AS DECIMAL(18,2)) Cost
										,CAST(CASE WHEN REPLACE(TruckTypeAFSF2,'','0.00') = '0.00' THEN 0.00 ELSE TruckTypeAFSF2 END AS DECIMAL(18,2))  FSF
										,TruckTypeFROM
										, 0.00 AS DrayBase, CAST(LEFT(EffectiveDate,10) AS DATETIME) EffectiveDate, EffectiveDateFrom 
							FROM		#GetFileUploadDetails  A WITH (NOLOCK)
							INNER JOIN	#SplitData  B ON A.FileProcessKey = B.FileProcessKey AND A.RecordSL = B.RecordSL
							INNER JOIN	#SplitData_TruckTypeFrom C ON B.FileProcessKey = C.FileProcessKey AND B.RecordSL = C.RecordSL AND A.TruckTypeA = C.TruckType  AND TruckTypeFromActual = A.TruckTypeAFROM2
							WHERE		ISNULL(TruckTypeA,'') <> '' AND ISNULL(TruckTypeAFROM2,'') <> ''
							UNION ALL
							SELECT		Market,B.Terminal,City,State,ZipCode,Zone, TruckTypeA DriverType
										,CAST(CASE WHEN REPLACE(TruckTypeABaseCost3,'','0.00') = '0.00' THEN 0.00 ELSE TruckTypeABaseCost3 END AS DECIMAL(18,2)) Cost
										,CAST(CASE WHEN REPLACE(TruckTypeAFSF3,'','0.00') = '0.00' THEN 0.00 ELSE TruckTypeAFSF3 END AS DECIMAL(18,2))  FSF
										,TruckTypeFROM
										, 0.00 AS DrayBase, CAST(LEFT(EffectiveDate,10) AS DATETIME) EffectiveDate, EffectiveDateFrom 
							FROM		#GetFileUploadDetails  A WITH (NOLOCK)
							INNER JOIN	#SplitData  B ON A.FileProcessKey = B.FileProcessKey AND A.RecordSL = B.RecordSL
							INNER JOIN	#SplitData_TruckTypeFrom C ON B.FileProcessKey = C.FileProcessKey AND B.RecordSL = C.RecordSL AND A.TruckTypeA = C.TruckType  AND TruckTypeFromActual = A.TruckTypeAFROM3
							WHERE		ISNULL(TruckTypeA,'') <> '' AND ISNULL(TruckTypeAFROM3,'') <> ''


							UNION ALL
							SELECT		DISTINCT Market,B.Terminal,City,State,ZipCode,Zone, TruckTypeB DriverType
										,CAST(CASE WHEN REPLACE(TruckTypeBBaseCost1,'','0.00') = '0.00' THEN 0.00 ELSE TruckTypeBBaseCost1 END AS DECIMAL(18,2)) Cost
										,CAST(CASE WHEN REPLACE(TruckTypeBFSC1,'','0.00') = '0.00' THEN 0.00 ELSE TruckTypeBFSC1 END AS DECIMAL(18,2))  FSF
										,TruckTypeFROM
										, 0.00 AS DrayBase, CAST(LEFT(EffectiveDate,10) AS DATETIME) EffectiveDate, EffectiveDateFrom 
							FROM		#GetFileUploadDetails  A WITH (NOLOCK)
							INNER JOIN	#SplitData  B ON A.FileProcessKey = B.FileProcessKey AND A.RecordSL = B.RecordSL
							INNER JOIN	#SplitData_TruckTypeFrom C ON B.FileProcessKey = C.FileProcessKey AND B.RecordSL = C.RecordSL AND A.TruckTypeB = C.TruckType  AND TruckTypeFromActual = A.TruckTypeBFROM1
							WHERE		ISNULL(TruckTypeB,'') <> ''  AND ISNULL(TruckTypeBFROM1,'') <> ''
							UNION ALL
							SELECT		DISTINCT Market,B.Terminal,City,State,ZipCode,Zone, TruckTypeB DriverType
										,CAST(CASE WHEN REPLACE(TruckTypeBBaseCost2,'','0.00') = '0.00' THEN 0.00 ELSE TruckTypeBBaseCost2 END AS DECIMAL(18,2)) Cost
										,CAST(CASE WHEN REPLACE(TruckTypeBFSC2,'','0.00') = '0.00' THEN 0.00 ELSE TruckTypeBFSC2 END AS DECIMAL(18,2))  FSF
										,TruckTypeFROM
										, 0.00 AS DrayBase, CAST(LEFT(EffectiveDate,10) AS DATETIME) EffectiveDate, EffectiveDateFrom 
							FROM		#GetFileUploadDetails  A WITH (NOLOCK)
							INNER JOIN	#SplitData  B ON A.FileProcessKey = B.FileProcessKey AND A.RecordSL = B.RecordSL
							INNER JOIN	#SplitData_TruckTypeFrom C ON B.FileProcessKey = C.FileProcessKey AND B.RecordSL = C.RecordSL AND A.TruckTypeB = C.TruckType  AND TruckTypeFromActual = A.TruckTypeBFROM2
							WHERE		ISNULL(TruckTypeB,'') <> ''  AND ISNULL(TruckTypeBFROM2,'') <> ''
							UNION ALL
							SELECT		DISTINCT Market,B.Terminal,City,State,ZipCode,Zone, TruckTypeB DriverType
										,CAST(CASE WHEN REPLACE(TruckTypeBBaseCost3,'','0.00') = '0.00' THEN 0.00 ELSE TruckTypeBBaseCost3 END AS DECIMAL(18,2)) Cost
										,CAST(CASE WHEN REPLACE(TruckTypeBFSC3,'','0.00') = '0.00' THEN 0.00 ELSE TruckTypeBFSC3 END AS DECIMAL(18,2))  FSF
										,TruckTypeFROM
										, 0.00 AS DrayBase, CAST(LEFT(EffectiveDate,10) AS DATETIME) EffectiveDate, EffectiveDateFrom 
							FROM		#GetFileUploadDetails  A WITH (NOLOCK)
							INNER JOIN	#SplitData  B ON A.FileProcessKey = B.FileProcessKey AND A.RecordSL = B.RecordSL
							INNER JOIN	#SplitData_TruckTypeFrom C ON B.FileProcessKey = C.FileProcessKey AND B.RecordSL = C.RecordSL AND A.TruckTypeB = C.TruckType  AND TruckTypeFromActual = A.TruckTypeBFROM3
							WHERE		ISNULL(TruckTypeB,'') <> ''  AND ISNULL(TruckTypeBFROM3,'') <> ''

							UNION ALL
							SELECT		DISTINCT Market,B.Terminal,City,State,ZipCode,Zone, TruckTypeC DriverType
										,CAST(CASE WHEN REPLACE(TruckTypeCBaseCost1,'','0.00') = '0.00' THEN 0.00 ELSE TruckTypeCBaseCost1 END AS DECIMAL(18,2)) Cost
										,CAST(CASE WHEN REPLACE(TruckTypeCFSC1,'','0.00') = '0.00' THEN 0.00 ELSE TruckTypeCFSC1 END AS DECIMAL(18,2))  FSF
										,TruckTypeFROM
										, 0.00 AS DrayBase, CAST(LEFT(EffectiveDate,10) AS DATETIME) EffectiveDate, EffectiveDateFrom 
							FROM		#GetFileUploadDetails  A WITH (NOLOCK)
							INNER JOIN	#SplitData  B ON A.FileProcessKey = B.FileProcessKey AND A.RecordSL = B.RecordSL
							INNER JOIN	#SplitData_TruckTypeFrom C ON B.FileProcessKey = C.FileProcessKey AND B.RecordSL = C.RecordSL AND A.TruckTypeC = C.TruckType  AND TruckTypeFromActual = A.TruckTypeCFROM1
							WHERE		ISNULL(TruckTypeC,'') <> ''  AND ISNULL(TruckTypeCFROM1,'') <> ''
							UNION ALL
							SELECT		DISTINCT Market,B.Terminal,City,State,ZipCode,Zone, TruckTypeC DriverType
										,CAST(CASE WHEN REPLACE(TruckTypeCBaseCost2,'','0.00') = '0.00' THEN 0.00 ELSE TruckTypeCBaseCost2 END AS DECIMAL(18,2)) Cost
										,CAST(CASE WHEN REPLACE(TruckTypeCFSC2, '','0.00') = '0.00' THEN 0.00 ELSE TruckTypeCFSC2 END AS DECIMAL(18,2))  FSF
										,TruckTypeFROM
										, 0.00 AS DrayBase, CAST(LEFT(EffectiveDate,10) AS DATETIME) EffectiveDate, EffectiveDateFrom 
							FROM		#GetFileUploadDetails  A WITH (NOLOCK)
							INNER JOIN	#SplitData  B ON A.FileProcessKey = B.FileProcessKey AND A.RecordSL = B.RecordSL
							INNER JOIN	#SplitData_TruckTypeFrom C ON B.FileProcessKey = C.FileProcessKey AND B.RecordSL = C.RecordSL AND A.TruckTypeC = C.TruckType  AND TruckTypeFromActual = A.TruckTypeCFROM2
							WHERE		ISNULL(TruckTypeC,'') <> ''  AND ISNULL(TruckTypeCFROM2,'') <> ''
							UNION ALL
							SELECT		DISTINCT Market,B.Terminal,City,State,ZipCode,Zone, TruckTypeC DriverType
										,CAST(CASE WHEN REPLACE(TruckTypeCBaseCost3,'','0.00') = '0.00' THEN 0.00 ELSE TruckTypeCBaseCost3 END AS DECIMAL(18,2)) Cost
										,CAST(CASE WHEN REPLACE(TruckTypeCFSC3,'','0.00') = '0.00' THEN 0.00 ELSE TruckTypeCFSC3 END AS DECIMAL(18,2))  FSF
										,TruckTypeFROM
										, 0.00 AS DrayBase, CAST(LEFT(EffectiveDate,10) AS DATETIME) EffectiveDate, EffectiveDateFrom 
							FROM		#GetFileUploadDetails  A WITH (NOLOCK)
							INNER JOIN	#SplitData  B ON A.FileProcessKey = B.FileProcessKey AND A.RecordSL = B.RecordSL
							INNER JOIN	#SplitData_TruckTypeFrom C ON B.FileProcessKey = C.FileProcessKey AND B.RecordSL = C.RecordSL AND A.TruckTypeC = C.TruckType  AND TruckTypeFromActual = A.TruckTypeCFROM3
							WHERE		ISNULL(TruckTypeC,'') <> ''  AND ISNULL(TruckTypeCFROM3,'') <> ''

							UNION ALL
							SELECT		DISTINCT Market,B.Terminal,City,State,ZipCode,Zone, TruckTypeD DriverType
										,CAST(CASE WHEN REPLACE(TruckTypeDBaseCost1,'','0.00') = '0.00' THEN 0.00 ELSE TruckTypeDBaseCost1 END AS DECIMAL(18,2)) Cost
										,CAST(CASE WHEN REPLACE(TruckTypeDFSC1,'','0.00') = '0.00' THEN 0.00 ELSE TruckTypeDFSC1 END AS DECIMAL(18,2))  FSF
										,TruckTypeFROM
										, 0.00 AS DrayBase, CAST(LEFT(EffectiveDate,10) AS DATETIME) EffectiveDate, EffectiveDateFrom 
							FROM		#GetFileUploadDetails  A WITH (NOLOCK)
							INNER JOIN	#SplitData  B ON A.FileProcessKey = B.FileProcessKey AND A.RecordSL = B.RecordSL
							INNER JOIN	#SplitData_TruckTypeFrom C ON B.FileProcessKey = C.FileProcessKey AND B.RecordSL = C.RecordSL AND A.TruckTypeD = C.TruckType  AND TruckTypeFromActual = A.TruckTypeDFROM1
							WHERE		ISNULL(TruckTypeD,'') <> ''  AND ISNULL(TruckTypeDFROM1,'') <> ''
							UNION ALL
							SELECT		DISTINCT Market,B.Terminal,City,State,ZipCode,Zone, TruckTypeD DriverType
										,CAST(CASE WHEN REPLACE(TruckTypeDBaseCost2,'','0.00') = '0.00' THEN 0.00 ELSE TruckTypeDBaseCost2 END AS DECIMAL(18,2)) Cost
										,CAST(CASE WHEN REPLACE(TruckTypeDFSC2, '','0.00') = '0.00' THEN 0.00 ELSE TruckTypeDFSC2 END AS DECIMAL(18,2))  FSF
										,TruckTypeFROM
										, 0.00 AS DrayBase, CAST(LEFT(EffectiveDate,10) AS DATETIME) EffectiveDate, EffectiveDateFrom 
							FROM		#GetFileUploadDetails  A WITH (NOLOCK)
							INNER JOIN	#SplitData  B ON A.FileProcessKey = B.FileProcessKey AND A.RecordSL = B.RecordSL
							INNER JOIN	#SplitData_TruckTypeFrom C ON B.FileProcessKey = C.FileProcessKey AND B.RecordSL = C.RecordSL AND A.TruckTypeD = C.TruckType  AND TruckTypeFromActual = A.TruckTypeDFROM2
							WHERE		ISNULL(TruckTypeD,'') <> ''  AND ISNULL(TruckTypeDFROM2,'') <> ''
							UNION ALL
							SELECT		DISTINCT Market,B.Terminal,City,State,ZipCode,Zone, TruckTypeD DriverType
										,CAST(CASE WHEN REPLACE(TruckTypeDBaseCost3,'','0.00') = '0.00' THEN 0.00 ELSE TruckTypeDBaseCost3 END AS DECIMAL(18,2)) Cost
										,CAST(CASE WHEN REPLACE(TruckTypeDFSC3,'','0.00') = '0.00' THEN 0.00 ELSE TruckTypeDFSC3 END AS DECIMAL(18,2))  FSF
										,TruckTypeFROM
										, 0.00 AS DrayBase, CAST(LEFT(EffectiveDate,10) AS DATETIME) EffectiveDate, EffectiveDateFrom 
							FROM		#GetFileUploadDetails  A WITH (NOLOCK)
							INNER JOIN	#SplitData  B ON A.FileProcessKey = B.FileProcessKey AND A.RecordSL = B.RecordSL
							INNER JOIN	#SplitData_TruckTypeFrom C ON B.FileProcessKey = C.FileProcessKey AND B.RecordSL = C.RecordSL AND A.TruckTypeD = C.TruckType  AND TruckTypeFromActual = A.TruckTypeDFROM3
							WHERE		ISNULL(TruckTypeD,'') <> ''  AND ISNULL(TruckTypeDFROM3,'') <> ''


							) A 
			
			DELETE			CD
			FROM			#TMPDATA A
			INNER JOIN		COST_CostDataOutput  CD WITH (NOLOCK) ON CD.Market = A.Market AND ISNULL(CD.Terminal,'') = ISNULL(A.Terminal, '') 
							AND CD.City = A.City AND CD.State = A.State AND ISNULL(CD.ZipCode,'') = ISNULL(A.ZipCode,'')
							AND CD.Zone = A.Zone 
							-- AND CD.EffectiveDate = A.EffectiveDate AND CD.EffectiveDateFrom = A.EffectiveDateFrom
							AND CD.DriverType = A.DriverType -- AND A.TruckTypeFROM = CD.YardPortType
			
			SELECT DISTINCT * FROM #TMPDATA

			INSERT INTO		COST_CostDataOutput
							(Market,Terminal,City,State,ZipCode,Zone,DriverType,YardPortType,Cost,FSFCost,FSF,DrayBase,EffectiveDate,EffectiveDateFrom)
			SELECT			A.Market,A.Terminal,A.City,A.State,A.ZipCode,A.Zone,A.DriverType,TruckTypeFROM,A.Cost,A.FSF
							, CASE WHEN A.FSF = 0 THEN 0.00 ELSE CAST(A.Cost * A.FSF AS Decimal(18,2)) END
							-- ,CAST((A.Cost * CASE WHEN A.FSF = 0 THEN 1 ELSE cast(A.Cost * A.FSF as decimal(18,2)) + A.Cost END) AS DECIMAL(18,2))
							,CAST((A.Cost + (CASE WHEN A.FSF = 0 THEN 0 ELSE cast(A.Cost * A.FSF as decimal(18,2)) END)) AS DECIMAL(18,2))
							,A.EffectiveDate,A.EffectiveDateFrom  --  , CD.Cost
			FROM			#TMPDATA A
			LEFT OUTER JOIN	COST_CostDataOutput  CD WITH (NOLOCK) ON CD.Market = A.Market AND ISNULL(CD.Terminal,'') = ISNULL(A.Terminal, '') 
							AND CD.City = A.City AND CD.State = A.State AND ISNULL(CD.ZipCode,'') = ISNULL(A.ZipCode,'')
							AND CD.Zone = A.Zone 
							-- AND CD.EffectiveDate = A.EffectiveDate AND CD.EffectiveDateFrom = A.EffectiveDateFrom
							AND CD.DriverType = A.DriverType --  AND A.TruckTypeFROM = CD.YardPortType
			WHERE			CD.Cost IS NULL

			-- CODE TO CREATE TERMINAL ELWOOD DATA FROM TERMINAL JOLIET AS JOLIET = ELWOOD
			insert into COST_CostDataOutput (Market, Terminal, City, State, ZipCode, Zone, DriverType, YardPortType, 
					Cost, FSFCost, FSF, DrayBase, EffectiveDate,  EffectiveDateFrom, FromCostOutputDataKey)
			select  A.Market, 'Elwood', A.City, A.State, A.ZipCode, A.Zone, A.DriverType, A.YardPortType,
					A.Cost, A.FSFCost, A.FSF, A.DrayBase, A.EffectiveDate, A.EffectiveDateFrom, A.CostOutputDataKey
			from COST_CostDataOutput A 
			LEft join COST_CostDataOutput B on A.CostOutputDataKey = B.FromCostOutputDataKey
			where A.Terminal = 'Joliet' and B.CostOutputDataKey is null and A.FromCostOutputDataKey is null

		END

		DROP TABLE #GetFileUploadDetails
		DROP TABLE #SplitData


END


-- TRUNCATE TABLE COST_CostDataOutput

-- SELECT * FROM COST_CostDataOutput

-- EXEC COST_CostOutputReport

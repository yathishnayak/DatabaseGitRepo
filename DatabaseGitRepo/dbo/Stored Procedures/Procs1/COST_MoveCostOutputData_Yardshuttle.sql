
CREATE PROCEDURE [dbo].[COST_MoveCostOutputData_Yardshuttle] -- COST_MoveCostOutputData_Yardshuttle 13
(
	@FileProcessKey		INT
)
AS



BEGIN
	-- DROP TABLE #DATA

	-- SELECT * FROM COST_CostDataOutput_YardShuttle
	-- SELECT * FROM #GetFileUploadDetails

	CREATE TABLE #DATA 
	(
		SLNo				INT,
		FileProcesskey		INT,
		MapID				INT,
		TextValue		    VARCHAR(100),
		RecordSL			INT,
		YardCost			DECIMAL(18,2)
	
	)

	CREATE TABLE #SplitData_Terminal
	(
		FileProcessKey			INT,
		RecordSL				INT,
		Terminal				VARCHAR(100)
	)

	CREATE TABLE #SplitData_YardFrom
	(
		FileProcessKey			INT,
		RecordSL				INT,
		MapID					INT,
		YardCost				DECIMAL(18,2),
		YardFrom				VARCHAR(100)	
	)
		
	CREATE TABLE #SplitData_YardTo
	(
		FileProcessKey			INT,
		RecordSL				INT,
		MapID					INT,
		YardCost				DECIMAL(18,2),
		YardTo					VARCHAR(100)	
	)

	SELECT			* 
	INTO			#GetFileUploadDetails 
	FROM			COST_VGetFileUploadDetails 
	WHERE			FileProcessKey = @FileProcessKey 


			DECLARE			@i INT = 1, @n INT  = 0,  @RecordSL INT = 0, @YardCost DECIMAL(18,2), @MapID	INT = 0


			-------------------------------------------Terminal-------------------------------------------------------------
			
			TRUNCATE TABLE	#DATA
			INSERT INTO		#DATA
			SELECT			ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,1,TERMINAL , RecordSL, 0 AS COST
			FROM			(SELECT DISTINCT FileProcesskey,TERMINAL, RecordSL FROM #GetFileUploadDetails WITH (NOLOCK) WHERE Terminal IS NOT NULL ) A


			SET		@i = 1
			SET		@n  = (SELECT COUNT(*) FROM #DATA)
			SET		@FileProcessKey = 0
			SET		@RecordSL = 0

			WHILE (@i <= @n)
				BEGIN
					SET @FileProcessKey = (SELECT FileProcessKey FROM #DATA WHERE SlNO = @i  )
					SET @RecordSL = (SELECT RecordSL FROM #DATA WHERE SlNO = @i  )
					-- SELECT @RecordSL
					INSERT INTO #SplitData_Terminal
					SELECT *
					FROm	(SELECT @FileProcessKey AS FileProcessKey, @RecordSL AS RecordSL ) A
					INNER JOIN (SELECT RTRIM(LTRIM(value) )Terminal
					FROM STRING_SPLIT((SELECT TextValue FROM #DATA WHERE SlNO = @i  ), ',') )	
					B ON 1 = 1
					SET @i = @i + 1
				END


			---------------------------------------------Yard Shuttle From---------------------------------------------------------------------------------
			DECLARE @MAXCOUNT INT = 0
			TRUNCATE TABLE #DATA
			INSERT INTO		#DATA
			SELECT			ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,1,YardFrom , RecordSL, YardCost
			FROM			(SELECT DISTINCT FileProcesskey,YardshuttledirectionFROM1 AS YardFrom, RecordSL, Yardshuttlecost1 AS YardCost FROM #GetFileUploadDetails WITH (NOLOCK) WHERE ISNULL(YardshuttledirectionFROM1,'')<> '') A

			-- SELECT * FROm #DATA

			--SET		@i = 1
			--SET		@n  = (SELECT COUNT(*) FROM #DATA)
			--SET		@FileProcessKey = 0
			--SET		@RecordSL = 0
			--SET		@MapID = 0

			------ SELECT * FROM #DATA
		
			--WHILE (@i <= @n)
			--	BEGIN
			--		SET @FileProcessKey = (SELECT FileProcessKey FROM #DATA WHERE SlNO = @i  )
			--		SET @RecordSL = (SELECT RecordSL FROM #DATA WHERE SlNO = @i  )
			--		SET	@YardCost = (SELECT YardCost FROM #DATA WHERE SlNO = @i  )
			--		SET @MapID = (SELECT MapID FROM #DATA WHERE SlNO = @i  )
			--		-- SELECT @RecordSL
			--		INSERT INTO #SplitData_YardFrom
			--		SELECT *
			--		FROm	(SELECT @FileProcessKey AS FileProcessKey, @RecordSL AS RecordSL, @MapID AS MapID,@YardCost AS YardCost ) A
			--		INNER JOIN (SELECT RTRIM(LTRIM(value) )YardFrom
			--		FROM STRING_SPLIT((SELECT TextValue FROM #DATA WHERE SlNO = @i  ), ',') )	
			--		B ON 1 = 1
			--		SET @i = @i + 1
			--	END

			-- SELECT * FROm #SplitData_YardFrom 
			SET @MAXCOUNT = (SELECT MAX(SLNo) FROM #DATA)
			-- SELECT @MAXCOUNT

			--TRUNCATE TABLE	#DATA
			INSERT INTO		#DATA
			SELECT			@MAXCOUNT + ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,2,YardFrom , RecordSL, YardCost
			FROM			(SELECT DISTINCT FileProcesskey,YardshuttledirectionFROM2 AS YardFrom, RecordSL, Yardshuttlecost2 AS YardCost FROM #GetFileUploadDetails WITH (NOLOCK) WHERE ISNULL(YardshuttledirectionFROM2,'')<> '') A

			SET		@i = 1
			SET		@n  = (SELECT COUNT(*) FROM #DATA)
			SET		@FileProcessKey = 0
			SET		@RecordSL = 0
			SET		@MapID = 0


			-- SELECT * FROM #DATA

			-- SELECT @i
		
			WHILE (@i <= @n)
				BEGIN
					SET @FileProcessKey = (SELECT FileProcessKey FROM #DATA WHERE SlNO = @i  )
					SET @RecordSL = (SELECT RecordSL FROM #DATA WHERE SlNO = @i  )
					SET	@YardCost = (SELECT YardCost FROM #DATA WHERE SlNO = @i  )
					SET @MapID = (SELECT MapID FROM #DATA WHERE SlNO = @i  )
					-- SELECT @RecordSL
					INSERT INTO #SplitData_YardFrom
					SELECT *
					FROm	(SELECT @FileProcessKey AS FileProcessKey, @RecordSL AS RecordSL, @MapID AS  MapID, @YardCost AS YardCost ) A
					INNER JOIN (SELECT RTRIM(LTRIM(value) )YardFrom
					FROM STRING_SPLIT((SELECT TextValue FROM #DATA WHERE SlNO = @i  ), ',') )	
					B ON 1 = 1
					SET @i = @i + 1
				END
			-- SELECT * FROm #SplitData_YardFrom   WHERE RecordSL = 1
			---------------------------------------------Yard Shuttle To ---------------------------------------------------------------------------------
			SET  @MAXCOUNT = 0

			TRUNCATE TABLE  #DATA
			INSERT INTO		#DATA
			SELECT			ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,1,YardTo , RecordSL, YardCost
			FROM			(SELECT DISTINCT FileProcesskey,YardshuttledirectionTO1 AS YardTo, RecordSL, Yardshuttlecost1 AS YardCost FROM #GetFileUploadDetails WITH (NOLOCK) WHERE ISNULL(YardshuttledirectionTO1,'')<> '') A

			--SET		@i = 1
			--SET		@n  = (SELECT COUNT(*) FROM #DATA)
			--SET		@FileProcessKey = 0
			--SET		@RecordSL = 0
			--SET		@MapID = 0

			--WHILE (@i <= @n)
			--	BEGIN
			--		SET @FileProcessKey = (SELECT FileProcessKey FROM #DATA WHERE SlNO = @i  )
			--		SET @RecordSL = (SELECT RecordSL FROM #DATA WHERE SlNO = @i  )
			--		SET	@YardCost = (SELECT YardCost FROM #DATA WHERE SlNO = @i  )
			--		SET @MapID = (SELECT MapID FROM #DATA WHERE SlNO = @i  )

			--		-- SELECT @RecordSL
			--		INSERT INTO #SplitData_YardTo
			--		SELECT *
			--		FROm	(SELECT @FileProcessKey AS FileProcessKey, @RecordSL AS RecordSL, @MapID AS MapID, @YardCost AS YardCost ) A
			--		INNER JOIN (SELECT RTRIM(LTRIM(value) )YardTo
			--		FROM STRING_SPLIT((SELECT TextValue FROM #DATA WHERE SlNO = @i  ), ',') )	
			--		B ON 1 = 1
			--		SET @i = @i + 1
			--	END

			SET @MAXCOUNT = (SELECT MAX(SLNo) FROM #DATA)

			-- TRUNCATE TABLE	#DATA
			INSERT INTO		#DATA
			SELECT			@MAXCOUNT + ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,2,YardTo , RecordSL, YardCost
			FROM			(SELECT DISTINCT FileProcesskey,YardshuttledirectionTO2 AS YardTo, RecordSL, Yardshuttlecost2 AS YardCost FROM #GetFileUploadDetails WHERE ISNULL(YardshuttledirectionTO2,'')<> '') A

			SET		@i = 1
			SET		@n  = (SELECT COUNT(*) FROM #DATA)
			SET		@FileProcessKey = 0
			SET		@RecordSL = 0
			SET		@MapID = 0

			-- SELECT * FROM #DATA
		
			WHILE (@i <= @n)
				BEGIN
					SET @FileProcessKey = (SELECT FileProcessKey FROM #DATA WHERE SlNO = @i  )
					SET @RecordSL = (SELECT RecordSL FROM #DATA WHERE SlNO = @i  )
					SET	@YardCost = (SELECT YardCost FROM #DATA WHERE SlNO = @i  )
					SET @MapID = (SELECT MapID FROM #DATA WHERE SlNO = @i  )
					-- SELECT @RecordSL
					INSERT INTO #SplitData_YardTo
					SELECT *
					FROm	(SELECT @FileProcessKey AS FileProcessKey, @RecordSL AS RecordSL, @MapID AS MapID, @YardCost AS YardCost ) A
					INNER JOIN (SELECT RTRIM(LTRIM(value) )YardTo
					FROM STRING_SPLIT((SELECT TextValue FROM #DATA WHERE SlNO = @i  ), ',') )	
					B ON 1 = 1
					SET @i = @i + 1
				END

			-----------------------------------------------------------------------------------------------------------------------------------------------------------------
			-- SELECT * FROM #SplitData_YardTo    Where RecordSL = 1

			-- COST_MoveCostOutputData_Yardshuttle 13

			--SELECT * FROM #SplitData_Terminal
			--SELECT * FROM #SplitData_YardFrom
			--SELECT * FROM #SplitData_YardTo


			SELECT			*
			INTO			#TMPDATA
			FROM			(SELECT			Market,B.Terminal,City,State,ZipCode,Zone,C.YardFrom, D.YardTo,  C.YardCost,  CAST(LEFT(EffectiveDate,10) AS DATETIME) EffectiveDate, EffectiveDateFrom 
							FROM			#GetFileUploadDetails A WITH (NOLOCK)
							INNER JOIN		#SplitData_Terminal B  ON A.FileProcessKey = B.FileProcessKey AND A.RecordSL = B.RecordSL  
							INNER JOIN		#SplitData_YardFrom C ON A.FileProcessKey = C.FileProcessKey AND A.RecordSL = C.RecordSL
							INNER JOIN		#SplitData_YardTo D ON A.FileProcessKey = D.FileProcessKey AND A.RecordSL = D.RecordSL AND C.YardFrom <> D.YardTo  AND C.MapID  = D.MapID
							) A 
			ORDER BY City

			-- SELECT * FROM #TMPDATA

			SELECT			*
			FROM			#TMPDATA A
			INNER JOIN		COST_CostDataOutput_YardShuttle CD WITH (NOLOCK) ON CD.Market = A.Market AND ISNULL(CD.Terminal,'') = ISNULL(A.Terminal, '') 
							AND CD.City = A.City AND CD.State = A.State AND ISNULL(CD.ZipCode,'') = ISNULL(A.ZipCode,'')
							AND CD.Zone = A.Zone 
							-- AND CD.EffectiveDate = A.EffectiveDate AND CD.EffectiveDateFrom = A.EffectiveDateFrom
							AND CD.YardFrom = A.YardFrom AND CD.YardTO = A.YardTo

			

			INSERT INTO		COST_CostDataOutput_YardShuttle
							(Market,Terminal,City,State,ZipCode,Zone,YardFrom,YardTo,YardCost,EffectiveDate,EffectiveDateFrom)
			SELECT			A.Market,A.Terminal,A.City,A.State,A.ZipCode,A.Zone,A.YardFrom, A.YardTo, A.YardCost,A.EffectiveDate,A.EffectiveDateFrom  --  , CD.Cost
			FROM			#TMPDATA A
			LEFT OUTER JOIN	COST_CostDataOutput_YardShuttle CD WITH (NOLOCK) ON CD.Market = A.Market AND ISNULL(CD.Terminal,'') = ISNULL(A.Terminal, '') 
							AND CD.City = A.City AND CD.State = A.State AND ISNULL(CD.ZipCode,'') = ISNULL(A.ZipCode,'')
							AND CD.Zone = A.Zone  -- AND CD.EffectiveDate = A.EffectiveDate AND CD.EffectiveDateFrom = A.EffectiveDateFrom
							AND A.YardFrom = CD.yardFrom  AND CD.YardTO = A.YardTo
			WHERE			CD.YardCost IS NULL 

	
			--UPDATE			CD
			--SET				YardCost = A.YardCost 
			--FROM			COST_CostDataOutput_YardShuttle CD WITH (NOLOCK)
			--INNER JOIN		#TMPDATA A  ON CD.Market = A.Market AND ISNULL(CD.Terminal,'') = ISNULL(A.Terminal, '') 
			--				AND CD.City = A.City AND CD.State = A.State AND ISNULL(CD.ZipCode,'') = ISNULL(A.ZipCode,'')
			--				AND CD.Zone = A.Zone AND CD.EffectiveDate = A.EffectiveDate AND CD.EffectiveDateFrom = A.EffectiveDateFrom
			--				AND A.YardFrom = CD.yardFrom AND A.YardTo = CD.YardTO
			--WHERE			CD.YardCost <> A.YardCost 

			-- CODE TO CREATE TERMINAL ELWOOD DATA FROM TERMINAL JOLIET AS JOLIET = ELWOOD
			set identity_insert COST_CostDataOutput_YardShuttle on --Sumanth Added this to handle identity insert
			insert into COST_CostDataOutput_YardShuttle ( Market, Terminal, City, State, ZipCode, Zone, YardFrom, YardTo, YardCost, 
					EffectiveDate, EffectiveDateFrom, A.CostOutputDataKey)
			select   A.Market, 'Elwood', A.City, A.State, A.ZipCode, A.Zone, A.YardFrom, A.YardTo, A.YardCost, 
					A.EffectiveDate, A.EffectiveDateFrom, A.CostOutputDataKey
			from COST_CostDataOutput_YardShuttle A 
			LEft join COST_CostDataOutput_YardShuttle B on A.CostOutputDataKey = B.FromCostOutputDataKey
			where A.Terminal = 'Joliet' and B.CostOutputDataKey is null and A.FromCostOutputDataKey is null
			set identity_insert COST_CostDataOutput_YardShuttle off --Sumanth added this to handle identity insert

END



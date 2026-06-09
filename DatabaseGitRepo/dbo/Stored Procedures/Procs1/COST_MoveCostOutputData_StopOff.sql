
CREATE PROCEDURE [dbo].[COST_MoveCostOutputData_StopOff]
(
	@FileProcessKey		INT
)

AS



BEGIN
	-- DROP TABLE #DATA
	-- SELECT * FROM #GetFileUploadDetails
	-- SELECT * FROM COST_CostDataOutput_StopOff
	CREATE TABLE #DATA 
	(
		SLNo				INT,
		FileProcesskey		INT,
		TextValue		    VARCHAR(100),
		RecordSL			INT,
		PrepullCost			DECIMAL(18,2)
	
	)

	CREATE TABLE #SplitData_Terminal
	(
		FileProcessKey			INT,
		RecordSL				INT,
		Terminal				VARCHAR(100)
	)

	CREATE TABLE #SplitData_StopOff
	(
		FileProcessKey			INT,
		RecordSL				INT,
		StopOffCost				DECIMAL(18,2),
		StopOfflocation			VARCHAR(100)
	
	)
		
	SELECT			* 
	INTO			#GetFileUploadDetails 
	FROM			COST_VGetFileUploadDetails 
	WHERE			FileProcessKey = @FileProcessKey 


			DECLARE			@i INT = 1, @n INT  = 0,  @RecordSL INT = 0, @PrepullCost DECIMAL(18,2)


			-------------------------------------------Terminal-------------------------------------------------------------
			
			TRUNCATE TABLE #DATA
			INSERT INTO		#DATA
			SELECT			ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,TERMINAL , RecordSL, 0 AS COST
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


			---------------------------------------------StopOff---------------------------------------------------------------------------------
			DECLARE @MAXCOUNT INT = 0

			TRUNCATE TABLE #DATA
			INSERT INTO		#DATA
			SELECT			ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,StopOfflocation , RecordSL, StopOffCost
			FROM			(SELECT DISTINCT FileProcesskey,StopOfflocation1 AS StopOfflocation, RecordSL, StopOffCost1 AS StopOffCost FROM #GetFileUploadDetails WITH (NOLOCK) WHERE ISNULL(StopOfflocation1,'')<> '') A

			SET @MAXCOUNT = (SELECT MAX(SlNo) FROM #DATA)

			INSERT INTO		#DATA
			SELECT			@MAXCOUNT + ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,StopOfflocation , RecordSL, StopOffCost
			FROM			(SELECT DISTINCT FileProcesskey,StopOfflocation2 AS StopOfflocation, RecordSL, StopOffCost2 AS StopOffCost FROM #GetFileUploadDetails WITH (NOLOCK) WHERE ISNULL(StopOfflocation2,'')<> '') A

			SET		@i = 1
			SET		@n  = (SELECT COUNT(*) FROM #DATA)
			SET		@FileProcessKey = 0
			SET		@RecordSL = 0
		
			WHILE (@i <= @n)
				BEGIN
					SET @FileProcessKey = (SELECT FileProcessKey FROM #DATA WHERE SlNO = @i  )
					SET @RecordSL = (SELECT RecordSL FROM #DATA WHERE SlNO = @i  )
					SET	@PrepullCost = (SELECT PrepullCost FROM #DATA WHERE SlNO = @i  )
					-- SELECT @RecordSL
					INSERT INTO #SplitData_StopOff
					SELECT *
					FROm	(SELECT @FileProcessKey AS FileProcessKey, @RecordSL AS RecordSL, @PrepullCost AS PrepullCost ) A
					INNER JOIN (SELECT RTRIM(LTRIM(value) )StopOfflocation
					FROM STRING_SPLIT((SELECT TextValue FROM #DATA WHERE SlNO = @i  ), ',') )	
					B ON 1 = 1
					SET @i = @i + 1
				END
		
			---------------------------------------------------------------------------------------------------------------------------------------------------------------

			SELECT			*
			INTO			#TMPDATA
			FROM			(SELECT			Market,B.Terminal,City,State,ZipCode,Zone,C.StopOfflocation,  C.StopOffCost,  CAST(LEFT(EffectiveDate,10) AS DATETIME) EffectiveDate, EffectiveDateFrom 
							FROM			#GetFileUploadDetails A WITH (NOLOCK)
							INNER JOIN		#SplitData_Terminal B  ON A.FileProcessKey = B.FileProcessKey AND A.RecordSL = B.RecordSL  
							INNER JOIN		#SplitData_StopOff C ON B.FileProcessKey = C.FileProcessKey AND B.RecordSL = C.RecordSL  ) A 
			
			-- SELECT * FROM #TMPDATA 

			DELETE			CD
			FROM			#TMPDATA A
			INNER JOIN		COST_CostDataOutput_StopOff  CD WITH (NOLOCK) ON CD.Market = A.Market AND ISNULL(CD.Terminal,'') = ISNULL(A.Terminal, '') 
							AND CD.City = A.City AND CD.State = A.State AND ISNULL(CD.ZipCode,'') = ISNULL(A.ZipCode,'')
							AND CD.Zone = A.Zone 
							-- AND CD.EffectiveDate = A.EffectiveDate AND CD.EffectiveDateFrom = A.EffectiveDateFrom
							AND CD.StopOfflocation = A.StopOfflocation -- AND A.TruckTypeFROM = CD.YardPortType


			INSERT INTO		COST_CostDataOutput_StopOff
							(Market,Terminal,City,State,ZipCode,Zone,StopOfflocation,StopOffCost,EffectiveDate,EffectiveDateFrom)
			SELECT			A.Market,A.Terminal,A.City,A.State,A.ZipCode,A.Zone,A.StopOfflocation,A.StopOffCost,A.EffectiveDate,A.EffectiveDateFrom  --  , CD.Cost
			FROM			#TMPDATA A
			LEFT OUTER JOIN	COST_CostDataOutput_StopOff  CD WITH (NOLOCK) ON CD.Market = A.Market AND ISNULL(CD.Terminal,'') = ISNULL(A.Terminal, '') 
							AND CD.City = A.City AND CD.State = A.State AND ISNULL(CD.ZipCode,'') = ISNULL(A.ZipCode,'')
							AND CD.Zone = A.Zone AND CD.EffectiveDate = A.EffectiveDate AND CD.EffectiveDateFrom = A.EffectiveDateFrom
							AND A.StopOfflocation = CD.StopOfflocation
			WHERE			CD.StopOffCost IS NULL

	
			--UPDATE			CD
			--SET				StopOffCost = A.StopOffCost 
			--FROM			COST_CostDataOutput_StopOff CD WITH (NOLOCK)
			--INNER JOIN		#TMPDATA A  ON CD.Market = A.Market AND ISNULL(CD.Terminal,'') = ISNULL(A.Terminal, '') 
			--				AND CD.City = A.City AND CD.State = A.State AND ISNULL(CD.ZipCode,'') = ISNULL(A.ZipCode,'')
			--				AND CD.Zone = A.Zone AND CD.EffectiveDate = A.EffectiveDate AND CD.EffectiveDateFrom = A.EffectiveDateFrom
			--				AND A.StopOfflocation = CD.StopOfflocation
			--WHERE			CD.StopOffCost <> A.StopOffCost 

			
			-- CODE TO CREATE TERMINAL ELWOOD DATA FROM TERMINAL JOLIET AS JOLIET = ELWOOD
			insert into COST_CostDataOutput_StopOff (Market, Terminal, City, State, ZipCode, Zone, StopOfflocation, 
						StopOffCost, EffectiveDate, EffectiveDateFrom, FromCostOutputDataKey)
			select   A.Market, 'Elwood', A.City, A.State, A.ZipCode, A.Zone, A.StopOfflocation, A.StopOffCost, 
				A.EffectiveDate, A.EffectiveDateFrom, A.CostOutputDataKey
			from COST_CostDataOutput_StopOff A 
			LEft join COST_CostDataOutput_StopOff B on A.CostOutputDataKey = B.FromCostOutputDataKey
			where A.Terminal = 'Joliet' and B.CostOutputDataKey is null and A.FromCostOutputDataKey is null

END



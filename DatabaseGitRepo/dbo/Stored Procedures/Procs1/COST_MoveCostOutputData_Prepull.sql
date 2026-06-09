

CREATE PROCEDURE [dbo].[COST_MoveCostOutputData_Prepull]
(
	@FileProcessKey		INT
)
AS
BEGIN
	-- DROP TABLE #DATA

	-- SELECT * FROM COST_CostDataOutput_PrePull

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

	CREATE TABLE #SplitData_PrePull
	(
		FileProcessKey			INT,
		RecordSL				INT,
		PrePullCost				DECIMAL(18,2),
		Prepulllocation			VARCHAR(100)
	
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


			---------------------------------------------PrePull---------------------------------------------------------------------------------
			DECLARE @MAXCOUNT INT = 0

			TRUNCATE TABLE #DATA
			INSERT INTO		#DATA
			SELECT			ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,Prepulllocation , RecordSL, PrePullCost
			FROM			(SELECT DISTINCT FileProcesskey,Prepulllocation1 AS Prepulllocation, RecordSL, PrePullCost1 AS PrePullCost FROM #GetFileUploadDetails WITH (NOLOCK) WHERE ISNULL(Prepulllocation1,'')<> '') A
			--SELECT *  FROM #DATA ORDER BY SLNo
			SET @MAXCOUNT = (SELECT MAX(SLNo) FROM #DATA)

			--SELECT @MAXCOUNT

			INSERT INTO		#DATA
			SELECT			@MAXCOUNT + ROW_NUMBER() Over (Order By FileProcesskey)SlNO,FileProcesskey,Prepulllocation , RecordSL, PrePullCost
			FROM			(SELECT DISTINCT FileProcesskey,Prepulllocation2 AS Prepulllocation, RecordSL, PrePullCost2 AS PrePullCost FROM #GetFileUploadDetails WITH (NOLOCK) WHERE ISNULL(Prepulllocation2,'')<> '') A
			--SELECT COUNT(*) FROM #DATA
			--SET @MAXCOUNT = (SELECT MAX(RecordSL) FROM #DATA)

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
					INSERT INTO #SplitData_PrePull
					SELECT *
					FROm	(SELECT @FileProcessKey AS FileProcessKey, @RecordSL AS RecordSL, @PrepullCost AS PrepullCost ) A
					INNER JOIN (SELECT RTRIM(LTRIM(value) )Prepulllocation
					FROM STRING_SPLIT((SELECT TextValue FROM #DATA WHERE SlNO = @i  ), ',') )	
					B ON 1 = 1
					SET @i = @i + 1
				END
		
			---------------------------------------------------------------------------------------------------------------------------------------------------------------

			SELECT			*
			INTO			#TMPDATA
			FROM			(SELECT			Market,B.Terminal,City,State,ZipCode,Zone,C.Prepulllocation,  C.PrepullCost,  CAST(LEFT(EffectiveDate,10) AS DATETIME) EffectiveDate, EffectiveDateFrom 
							FROM			#GetFileUploadDetails A WITH (NOLOCK)
							INNER JOIN		#SplitData_Terminal B  ON A.FileProcessKey = B.FileProcessKey AND A.RecordSL = B.RecordSL  
							INNER JOIN		#SplitData_PrePull C ON B.FileProcessKey = C.FileProcessKey AND B.RecordSL = C.RecordSL  ) A 

			
			
			DELETE			CD
			FROM			#TMPDATA A
			INNER JOIN		COST_CostDataOutput_PrePull  CD WITH (NOLOCK) ON CD.Market = A.Market AND ISNULL(CD.Terminal,'') = ISNULL(A.Terminal, '') 
							AND CD.City = A.City AND CD.State = A.State AND ISNULL(CD.ZipCode,'') = ISNULL(A.ZipCode,'')
							AND CD.Zone = A.Zone 
							-- AND CD.EffectiveDate = A.EffectiveDate AND CD.EffectiveDateFrom = A.EffectiveDateFrom
							AND CD.Prepulllocation = A.Prepulllocation -- AND A.TruckTypeFROM = CD.YardPortType



			INSERT INTO		COST_CostDataOutput_PrePull
							(Market,Terminal,City,State,ZipCode,Zone,PrePulllocation,PrePullCost,EffectiveDate,EffectiveDateFrom)
			SELECT			A.Market,A.Terminal,A.City,A.State,A.ZipCode,A.Zone,A.PrePulllocation,A.PrePullCost,A.EffectiveDate,A.EffectiveDateFrom  --  , CD.Cost
			FROM			#TMPDATA A
			LEFT OUTER JOIN	COST_CostDataOutput_PrePull CD WITH (NOLOCK) ON CD.Market = A.Market AND ISNULL(CD.Terminal,'') = ISNULL(A.Terminal, '') 
							AND CD.City = A.City AND CD.State = A.State AND ISNULL(CD.ZipCode,'') = ISNULL(A.ZipCode,'')
							AND CD.Zone = A.Zone AND A.Prepulllocation =  CD.Prepulllocation
			WHERE			CD.PrePullCost IS NULL

	
			--UPDATE			CD
			--SET				PrePullCost = A.PrePullCost 
			--FROM			COST_CostDataOutput_PrePull CD WITH (NOLOCK)
			--INNER JOIN		#TMPDATA A  ON CD.Market = A.Market AND ISNULL(CD.Terminal,'') = ISNULL(A.Terminal, '') 
			--				AND CD.City = A.City AND CD.State = A.State AND ISNULL(CD.ZipCode,'') = ISNULL(A.ZipCode,'')
			--				AND CD.Zone = A.Zone AND CD.EffectiveDate = A.EffectiveDate AND CD.EffectiveDateFrom = A.EffectiveDateFrom
			--				AND A.Prepulllocation =  CD.Prepulllocation
			--WHERE			CD.PrePullCost <> A.PrePullCost 

			-- CODE TO CREATE TERMINAL ELWOOD DATA FROM TERMINAL JOLIET AS JOLIET = ELWOOD
			insert into COST_CostDataOutput_PrePull (Market, Terminal, City, State, ZipCode, Zone, Prepulllocation, 
						PrepullCost, EffectiveDate, EffectiveDateFrom, FromCostOutputDataKey)
			select   A.Market, 'Elwood', A.City, A.State, A.ZipCode, A.Zone, A.Prepulllocation, A.PrepullCost, 
				A.EffectiveDate, A.EffectiveDateFrom, A.CostOutputDataKey
			from COST_CostDataOutput_PrePull A 
			LEft join COST_CostDataOutput_PrePull B on A.CostOutputDataKey = B.FromCostOutputDataKey
			where A.Terminal = 'Joliet' and B.CostOutputDataKey is null and A.FromCostOutputDataKey is null


END



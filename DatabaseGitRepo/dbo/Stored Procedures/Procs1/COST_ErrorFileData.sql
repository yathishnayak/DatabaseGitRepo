/**
DECLARE @UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '{"FileProcessKey":183,"FileType":"LongBeach"}',
	@Status			BIT	= 0 ,
	@Reason			VARCHAR(1000) = '' ,
	@IsDebug		BIT = 1
	exec [COST_ErrorFileData] @UserKey,@JSONString,@Status output,@Reason output,@IsDebug 
	select @Status,@Reason
**/
CREATE PRoc [dbo].[COST_ErrorFileData]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
) 
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
	
		DECLARE 
			@FileProcessKey		INT,
			@FileType			VARCHAR(20)

		SELECT 
			@FileProcessKey	= FileProcessKey,
			@FileType		= FileType
		FROM OPENJSON(@JSONString)
		WITH
		(
			FileProcessKey		INT				'$.FileProcessKey',
			FileType			VARCHAR(20)		'$.FileType'
		)
		SET @Status = 0
		IF(@FileType='Chicago')
		BEGIN
			EXEC COST_UpdateFileDownloadStatus  @FileProcesskey,1
			SELECT					A.*, FileProcesskey
							,RecordStatus,RecordRemarks
							,Market,Terminal,City,[State]	,ZipCode,[Zone],Prepulllocation1,Prepullcost1,Prepulllocation2,Prepullcost2,Prepulllocation3,
							Prepullcost3,Prepulllocation4,Prepullcost4,Prepulllocation5
							,Prepullcost5,Stopofflocation1,Stopoffcost1,Stopofflocation2,Stopoffcost2,Stopofflocation3,Stopoffcost3,Stopofflocation4,
							Stopoffcost4,Stopofflocation5,Stopoffcost5,YardshuttledirectionTO1
							,YardshuttledirectionFROM1,Yardshuttlecost1,YardshuttledirectionTO2,YardshuttledirectionFROM2,Yardshuttlecost2
							,TruckTypeA,TruckTypeABaseCost1,TruckTypeAFSF1,TruckTypeAFROM1,TruckTypeABaseCost2,TruckTypeAFSF2,TruckTypeAFROM2
							,TruckTypeABaseCost3,TruckTypeAFSF3,TruckTypeAFROM3
							,TruckTypeB,TruckTypeBBaseCost1,TruckTypeBFSC1,TruckTypeBFROM1,TruckTypeBBaseCost2,TruckTypeBFSC2,TruckTypeBFROM2
							,TruckTypeBBaseCost3,TruckTypeBFSC3,TruckTypeBFROM3
							,TruckTypeC,TruckTypeCBaseCost1,TruckTypeCFSC1,TruckTypeCFROM1,TruckTypeCBaseCost2,TruckTypeCFSC2,TruckTypeCFROM2
							,TruckTypeCBaseCost3,TruckTypeCFSC3,TruckTypeCFROM3
							,TruckTypeD,TruckTypeDBaseCost1,TruckTypeDFSC1,TrucktypeDFROM1,TrucktypeDBaseCost2,TrucktypeDFSC2,TrucktypeDFROM2
							,TrucktypeDBaseCost3,TrucktypeDFSC3,TrucktypeDFROM3
							,TruckTypeE,TruckTypeEBaseCost1 TruckTypeEBaseCost1,TruckTypeEFSC1 TruckTypeEFSC1
							,EffectiveDate,EffectiveDateFrom
							-- ,RecordStatus,RecordRemarks
			FROM					(SELECT @Status AS Status, @Reason AS Reason ) A
			LEFT OUTER JOIN			(SELECT	 *
									FROM	COST_FileUploadData_Chicago WITH (NOLOCK)
									WHERE	FileProcesskey = @FileProcesskey							
									) B ON 1 = CASE WHEN @Status = 1 THEN 0 ELSE 1 END
			ORDER BY RecordSL
			FOR JSON PATH;
		END
		IF(@FileType='LongBeach')
		BEGIN
			EXEC COST_UpdateFileDownloadStatus  @FileProcesskey,1
			SELECT					A.*, FileProcesskey
									,RecordStatus,RecordRemarks
									,Market,Terminal,City,[State]	,ZipCode,[Zone],Prepulllocation1,Prepullcost1,Prepulllocation2,Prepullcost2,Prepulllocation3,
									Prepullcost3,Prepulllocation4,Prepullcost4,Prepulllocation5
									,Prepullcost5,Stopofflocation1,Stopoffcost1,Stopofflocation2,Stopoffcost2,Stopofflocation3,Stopoffcost3,Stopofflocation4,
									Stopoffcost4,Stopofflocation5,Stopoffcost5,YardshuttledirectionTO1
									,YardshuttledirectionFROM1,Yardshuttlecost1,YardshuttledirectionTO2,YardshuttledirectionFROM2,Yardshuttlecost2
									,TruckTypeA,TruckTypeABaseCost1,TruckTypeAFSF1,TruckTypeAFROM1,TruckTypeABaseCost2,TruckTypeAFSF2,TruckTypeAFROM2
									,TruckTypeABaseCost3,TruckTypeAFSF3,TruckTypeAFROM3
									,TruckTypeB,TruckTypeBBaseCost1,TruckTypeBFSC1,TruckTypeBFROM1,TruckTypeBBaseCost2,TruckTypeBFSC2,TruckTypeBFROM2
									,TruckTypeBBaseCost3,TruckTypeBFSC3,TruckTypeBFROM3
									,TruckTypeC,TruckTypeCBaseCost1,TruckTypeCFSC1,TruckTypeCFROM1,TruckTypeCBaseCost2,TruckTypeCFSC2,TruckTypeCFROM2
									,TruckTypeCBaseCost3,TruckTypeCFSC3,TruckTypeCFROM3
									,TruckTypeD,TruckTypeDBaseCost1,TruckTypeDFSC1,TrucktypeDFROM1,TrucktypeDBaseCost2,TrucktypeDFSC2,TrucktypeDFROM2
									,TrucktypeDBaseCost3,TrucktypeDFSC3,TrucktypeDFROM3
									,TruckTypeE,TruckTypeEBaseCost1 TruckTypeEBaseCost1,TruckTypeEFSC1 TruckTypeEFSC1
									,EffectiveDate,EffectiveDateFrom
									-- ,RecordStatus,RecordRemarks
			FROM					(SELECT @Status AS ISSuccess, @Reason AS Remarks ) A
			LEFT OUTER JOIN			(SELECT	 *
									FROM	COST_FileUploadData_LongBeach WITH (NOLOCK)
									WHERE	FileProcesskey = @FileProcesskey						
									) B ON 1 = CASE WHEN @Status = 1 THEN 0 ELSE 1 END
			ORDER BY RecordSL
			FOR JSON PATH;
		END
		IF(@FileType='Accessorial')
		BEGIN
			EXEC COSTACC_UpdateFileDownloadStatus  @FileProcesskey,1
			SELECT			 A.*, FileProcesskey
							,RecordStatus,RecordRemarks
							,RecordSL, LineItem, Market, Terminal, TruckType, YardPort, Zone [Group], FixVsNonFix, Per, UnitCost,EffectiveDate,EffectiveDateFrom, FreePer, SplitPercent
							-- ,RecordStatus,RecordRemarks
			FROM					(SELECT @Status AS ISSuccess, '' AS Remarks ) A
			LEFT OUTER JOIN			(SELECT	 *
									FROM	COSTACC_FileUploadData
									WHERE	FileProcesskey = @FileProcesskey							
									) B ON 1 = CASE WHEN @Status = 1 THEN 0 ELSE 1 END
			ORDER BY RecordSL
			FOR JSON PATH;
		END
		SET @STatus = 1;
		SET @Reason = 'Success'
END
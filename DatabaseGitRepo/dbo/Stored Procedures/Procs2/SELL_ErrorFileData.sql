/**
DECLARe @UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '{"FileProcessKey":1687,"FileType":"Draybase"}',
	@Status			BIT	= 0 ,
	@Reason			VARCHAR(1000) = '' ,
	@IsDebug		BIT = 0
	exec [dbo].[SELL_ErrorFileData] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
	select @Status as Status, @Reason as Reason
**/
CREATE PRoc [dbo].[SELL_ErrorFileData]
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

		IF(@FileType='Bobtail')
		BEGIN
			EXEC SELL_NAC_Bobtail_UpdateFileDownloadStatus @FileProcessKey,1
			select FileProcessKey, RecordSL, CustID, CustName, RateType, Segment, MarketLocation, Terminal, City, State, Zip, 
			LocationName, IsLocationExists, BobtailRate, BobtailFormat, EffectiveDate, EffectiveDateFrom, Remarks
			from SELL_NAC_BOBTAIL_FileUploadData A
			where FileProcessKey = @FileProcessKey
			ORDER BY RecordSL
			FOR JSON PATH;
		END
		IF(@FileType='Accessorial')
		BEGIN
			EXEC SELL_NACAccUpdateFileDownloadStatus @FileProcessKey,1
			select FileProcessKey, RecordSL, CustID, CustName, RateType, Segment, MarketLocation, Terminal, LineItem, City, State, Zip, 
			LocationName, IsLocationExists, Rate, BvsNB, FreeTime, MinCnt, MaxCnt, ContainerSize, EffectiveDate, EffectiveDateFrom, Remarks
			from SELL_NAC_Accessorial_FileUploadData A
			where FileProcessKey = @FileProcessKey
			ORDER BY RecordSL
			FOR JSON PATH;
		END
		IF(@FileType='Draybase')
		BEGIN
			EXEC SELL_NACDraybaseUpdateFileDownloadStatus @FileProcessKey,1
			select FileProcessKey, RecordSL, CustID, CustName, RateType, Segment, MarketLocation, Terminal, City, State, Zip, 
			LocationName, IsLocationExists, DraybaseCost, FSF, EffectiveDate, EffectiveDateFrom, Remarks
			from SELL_NAC_Draybase_FileUploadData A
			where FileProcessKey = @FileProcessKey
			ORDER BY RecordSL
			FOR JSON PATH;
		END
		SET @STatus = 1;
		SET @Reason = 'Success'
END
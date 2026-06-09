/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"FileName":"107 (1).xlsx","MarketLocation":"Chicago","MarketLocationKey":3,"SheetData":[{"Terminal":"LA/LB","City":"ADAMS","State":"CA","ZipCode":"","Zone":"B","Prepulllocation1":"Local","Prepullcost1":100,"Prepulllocation2":"IE","Prepullcost2":172.5,"Stopofflocation1":"Local","Stopoffcost1":95,"Stopofflocation2":"IE","YardshuttledirectionTO1":"IE","YardshuttledirectionFROM1":"Local","Yardshuttlecost1":160,"YardshuttledirectionTO2":"Local","YardshuttledirectionFROM2":"IE","Yardshuttlecost2":160,"TruckTypeA":"Company - Asset","TruckTypeABaseCost1":223,"TruckTypeAFSF1":"","TruckTypeAFROM1":"Local","TruckTypeABaseCost2":293,"TruckTypeAFSF2":"","TruckTypeAFROM2":"Port","TruckTypeB":"Broker Carrier","TruckTypeBBaseCost1":213,"TruckTypeBFSC1":"","TruckTypeBFROM1":"Local","TruckTypeBBaseCost2":283,"TruckTypeBFSC2":"","TruckTypeBFROM2":"Port","TruckTypeC":"Company  - Owner Operator","TruckTypeCBaseCost1":213,"TruckTypeCFSC1":"","TruckTypeCFROM1":"Local","TruckTypeCBaseCost2":283,"TruckTypeCFSC2":"","TruckTypeCFROM2":"Port","TruckTypeD":"","TruckTypeDBaseCost1":"Company - EV","TruckTypeDFSC1":"","TruckTypeE":"","TruckTypeEBaseCost1":"","TruckTypeEFSC1":"","EffectiveDate":"","EffectiveDateFrom":"Order Create"}]}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [COST_InsertFileProcessInfo_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[COST_InsertFileProcessInfo_V2] 
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)

AS
BEGIN

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
		@FileName			VARCHAR(100),
		@MarketLocation		VARCHAR(50),
		@MarketLocationKey	INT,
		@JSOnData			NVARCHAR(MAX)

	SELECT 
		@FileName			= FileName,		
		@MarketLocation		= MarketLocation,
		@MarketLocationKey	= MarketLocationKey,
		@JSOnData			= JSOnData
	FROM OPENJSON(@JSONString)
	WITH
	(
		FileName			VARCHAR(100)	'$.FileName',		
		MarketLocation		VARCHAR(50)		'$.MarketLocation',
		MarketLocationKey	INT				'$.MarketLocationKey',
		JSOnData			NVARCHAR(MAX)	'$.SheetData'  AS JSON
	)

	SET			@Status = 1
	SET @Reason = 'Record Saved Successfully'
	DECLARE @ErrorMessage VARCHAR(100) = 'Something went wrong, Contact System Administrator. Error Code : '
	DECLARE			@FileProcessKey INT = 0

	If(ISNULL(@FileName,'') = '')
		BEGIN
			SET @Status = 0
			SET @Reason = @ErrorMessage + '101'
		END
	ELSE IF (@MarketLocation = '')
		BEGIN
			SET @Status = 0
			SET @Reason = @ErrorMessage + '102'
		END
	ELSE IF (@UserKey = 0)
		BEGIN
			SET @Status = 0
			SET @Reason = @ErrorMessage + '103'
		END

	IF(@Status = 1)
		BEGIN
			INSERT INTO		COST_FileProcessInfo
							(FileName,DateUploaded,MarketLocation,FileUploadStatus,FileProcessStatus,IsEmailSent,UserKey)
			SELECT			@FileName,GETDATE(),@MarketLocation,0,0,0,@UserKey

			SET				@FileProcessKey = @@IDENTITY

	IF (@FileProcessKey > 0)
    BEGIN
        IF (@MarketLocationKey = 3)
        BEGIN
            EXEC COST_InsertFileProcessData_Chicago
                @FileProcessKey,
                @JSOnData, @Status OUTPUT
        END
        ELSE IF (@MarketLocationKey = 2)
        BEGIN
            EXEC COST_InsertFileProcessData_LongBeach
                @FileProcessKey,
                @JSOnData, @Status OUTPUT
        END
        ELSE
        BEGIN
            SET @Status = 0
            SET @Reason = 'Invalid MarketLocationKey'
        END
    END
END

	SELECT @Status AS Status, @Reason AS Reason, @FileProcessKey AS FileProcessKey FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END
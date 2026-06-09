/** 
DECLARE 
	@UserKey INT,
	@JSONString NVARCHAR(MAX)= '{"OrderDetailKey":47796, "OrderTypeKey" : 5, "OrderDetailStopKey":255074, "ShipFromKey":31766,"StopTypeCode":"RT","AddressType":"Port", "ContainerSizeKey" : 6, "BookingNo" : 1222}',
	@Status	BIT=0, 
	@Reason	VARCHAR(100)='', 
	@IsDebug bit = 0
	EXEC [Container_InsertUpdate_All] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Container_InsertUpdate_All]
(
    @UserKey INT = 1144,
    @JSONString NVARCHAR(MAX),
    @Status BIT OUTPUT,
    @Reason VARCHAR(1000) OUTPUT,
	@IsDebug		bit = 0
)
AS
BEGIN

SET NOCOUNT ON

	IF ISNULL(@JSONString, '') = ''
	BEGIN
		SET	@Status = 0
		SET	@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
	@OrderDetailKey INT,
	@ContainerNo NVARCHAR(20),
	@OrderTypeKey INT = 1,
	@OrderKey INT,
	@CsrKey INT,
	@RefNo NVARCHAR(100),
	@DropLive NVARCHAR(20),
	@Weight DECIMAL(18,2),
	@WeightUnitKey INT,
	@SealNo VARCHAR(50),
	@PriorityKey INT,
	@ShipFromKey INT,
	@OrderDetailStopKey INT,
	-- @ReturnToKey INT,
	@AddressType NVARCHAR(100) ,
	@StopTypeCode NVARCHAR(100) ,
	-- @ContainerTypeKey INT,
	@SizeKey	INT=0,
	-- @IsSelected BIT
	@BookingNo	NVARCHAR(100)=''

	SELECT
	@OrderDetailKey = OrderDetailKey,
	@ContainerNo = ContainerNo,
	@OrderTypeKey = OrderTypeKey,
	@OrderKey = OrderKey,
	@CsrKey = CsrKey,
	@RefNo = RefNo,
	@DropLive = DropLive,
	@Weight = Weight,
	@WeightUnitKey = WeightUnitKey,
	@SealNo = SealNo,
	@PriorityKey = PriorityKey,
	@ShipFromKey = ShipFromKey,
	@OrderDetailStopKey = OrderDetailStopKey,
	-- @ReturnToKey = ReturnToKey,
	@AddressType = AddressType,
	@StopTypeCode = StopTypeCode,
	-- @ContainerTypeKey = ContainerTypeKey,
	@SizeKey			= SizeKey,
	-- @IsSelected = IsSelected,
	@BookingNo		=		BookingNo
	FROM OPENJSON(@JSONString)
	WITH
	(
	OrderDetailKey			INT                    '$.OrderDetailKey'    ,
	ContainerNo				NVARCHAR(20)           '$.ContainerNo'       ,
	OrderTypeKey			INT					   '$.OrderTypeKey'      ,
	OrderKey				INT                    '$.OrderKey'          ,
	CsrKey					INT                    '$.CsrKey'            ,
	RefNo					NVARCHAR(100)          '$.RefNo'             ,
	DropLive				NVARCHAR(20)           '$.DropLive'          ,
	Weight					DECIMAL(18,2)          '$.Weight'            ,
	WeightUnitKey			INT                    '$.WeightUnitKey'     ,
	SealNo					VARCHAR(50)            '$.SealNo'            ,
	PriorityKey				INT                    '$.PriorityKey'       ,
	ShipFromKey				INT                    '$.ShipFromKey'       ,
	OrderDetailStopKey		INT				       '$.OrderDetailStopKey',
	-- ReturnToKey			   INT                    '$.ReturnToKey'       ,
	AddressType				NVARCHAR(100)          '$.AddressType'       ,
	StopTypeCode			NVARCHAR(100)          '$.StopTypeCode'      ,
	-- ContainerTypeKey		INT                    '$.ContainerTypeKey'  ,
	SizeKey					INT					   '$.ContainerSizeKey'  ,
	-- IsSelected			BIT                    '$.IsSelected'		 ,
	BookingNo				NVARCHAR(100)		   '$.BookingNo'
	)

	BEGIN TRY
	BEGIN TRANSACTION

	-----------------------------------
	-- Container
	-----------------------------------
	-- IF @ContainerNo IS NOT NULL
	IF EXISTS (SELECT 1 FROM OPENJSON(@JSONString) WHERE [key] = 'ContainerNo')
	EXEC Update_ContainerNo_V2 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT

	-----------------------------------
	-- OrderTypeKey
	-----------------------------------
	-- IF @OrderTypeKey IS NOT NULL
	IF EXISTS (SELECT 1 FROM OPENJSON(@JSONString) WHERE [key] = 'OrderTypeKey')
	EXEC Container_Update_OrderType @UserKey,@JSONString,NULL,@Status OUTPUT,@Reason OUTPUT


	-----------------------------------
	-- CSR
	-----------------------------------
	-- IF @CsrKey IS NOT NULL
	IF EXISTS (SELECT 1 FROM OPENJSON(@JSONString) WHERE [key] = 'CsrKey')
	EXEC Update_OrderDetailCSR_V2 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT

	-----------------------------------
	-- RefNo
	-----------------------------------
	-- IF @RefNo IS NOT NULL
	IF EXISTS (SELECT 1 FROM OPENJSON(@JSONString) WHERE [key] = 'RefNo')
	EXEC Container_Update_RefNo @UserKey,@JSONString,NULL,@Status OUTPUT,@Reason OUTPUT

	-----------------------------------
	-- Drop
	-----------------------------------
	-- IF @DropLive IS NOT NULL
	IF EXISTS (SELECT 1 FROM OPENJSON(@JSONString) WHERE [key] = 'DropLive')
	EXEC Container_Update_DropOrLive @UserKey,@JSONString,NULL,@Status OUTPUT,@Reason OUTPUT

	-----------------------------------
	-- Weight
	-----------------------------------
	-- IF @Weight IS NOT NULL
	IF EXISTS (SELECT 1 FROM OPENJSON(@JSONString) WHERE [key] = 'Weight')
	EXEC Container_Update_Weight @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT,0

	-----------------------------------
	-- Weight Unit
	-----------------------------------
	-- IF @WeightUnitKey IS NOT NULL
	IF EXISTS (SELECT 1 FROM OPENJSON(@JSONString) WHERE [key] = 'WeightUnitKey')
	EXEC Container_Update_WeightUnit @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT,0

	-----------------------------------
	-- Seal No
	-----------------------------------
	-- IF @SealNo IS NOT NULL
	IF EXISTS (SELECT 1 FROM OPENJSON(@JSONString) WHERE [key] = 'SealNo')
	EXEC Container_Update_SealNo @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT,0

	-----------------------------------
	-- Priority
	-----------------------------------
	-- IF @PriorityKey IS NOT NULL
	IF EXISTS (SELECT 1 FROM OPENJSON(@JSONString) WHERE [key] = 'PriorityKey')
	EXEC Container_Update_Priority @UserKey,@JSONString,NULL,@Status OUTPUT,@Reason OUTPUT

	-----------------------------------
	-- Ship From
	-----------------------------------
	-- IF @ShipFromKey IS NOT NULL
	IF EXISTS (SELECT 1 FROM OPENJSON(@JSONString) WHERE [key] = 'StopTypeCode')
	EXEC Container_InsertUpdate_ShipFrom_V2 @UserKey,@JSONString,NULL,@Status OUTPUT,@Reason OUTPUT

	-----------------------------------
	-- Properties
	-----------------------------------
	-- IF @ContainerTypeKey IS NOT NULL
	--IF EXISTS (SELECT 1 FROM OPENJSON(@JSONString) WHERE [key] = 'ContainerTypeKey')
	--EXEC InsertUpdate_ContainerTypeLink_V2 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT,0

	-----------------------------------
	-- Container Size
	-----------------------------------
	IF EXISTS (SELECT 1 FROM OPENJSON(@JSONString) WHERE [key] = 'ContainerSizeKey')
	EXEC Container_Update_ContainerSize_V2 @UserKey, @JSONString, NULL, @Status OUTPUT, @Reason OUTPUT


	-----------------------------------
	-- Booking Number
	-----------------------------------
	IF EXISTS (SELECT 1 FROM OPENJSON(@JSONString) WHERE [key] = 'BookingNo')
	EXEC Container_Update_BookingNo @UserKey, @JSONString, NULL, @Status OUTPUT, @Reason OUTPUT

	COMMIT

	SET @Status = 1
	SET @Reason = 'Success'

	END TRY
	BEGIN CATCH

	ROLLBACK

	SET @Status = 0
	SET @Reason = ERROR_MESSAGE()

	END CATCH

END
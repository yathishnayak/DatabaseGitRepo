/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"InvoiceKey":38513, "CustKey":0}'
	EXEC [SELL_GetCustomerRateType_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[SELL_GetCustomerRateType_V2] 
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	
	-- reference only. To verify Customer and their segments
	--SELECT Cs.CustomerSegment, RT.RateType, C.CustKey
	--		FROM CUSTOMER C
	--		LEft JOIN CustomerRateType RT ON C.RateTypeKey = RT.RateTypeKey
	--		Left join CustomerSegments CS on C.CustomerSegmentKey = CS.CustomerSegmentKey
	--order by Cs.CustomerSegment, RT.RateType, C.CustKey

	--Update CustomerSegments set CustomerSegment = 'ENT' where CustomerSegment = 'Enterprise'
	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE
	@InvoiceKey		int = 0,
	@CustKey		int = 0,
	@OutputType		varchar(5) = 'NAC' -- SMB /ENT / NAC / NA

	SELECT 
	@InvoiceKey		= InvoiceKey	,
	@CustKey		= CustKey	
	-- @OutputType		varchar(5) = 'NAC' output -- SMB /ENT / NAC / NA
	FROM OPENJSON(@JSONString)
	WITH
	(
	InvoiceKey	INT		'$.InvoiceKey',	
	CustKey		INT		'$.CustKey'	
	)

	IF(ISNULL(@InvoiceKey,0) <> 0)
	BEGIN
		SELECT @CustKey = CustKey
		FROM InvoiceHeader WITH (NOLOCK) 
		WHERE InvoiceKey = @InvoiceKey
	END
	--select @CustKey
	if(isnull(@CustKey,0) = 0)
	BEGIN
		SET @OutputType = 'NA'
		RETURN
	END

	IF(@CustKey > 0)
	BEGIN
		SELECT @OutputType = Case when isnull(c.RateTypeKey,0) = 0 then 'NAC'
			when C.RateTypeKey = 2 then 'NAC'
			when C.RateTypeKey = 1 then CS.CustomerSegment
			else 'NAC' end
		FROM CUSTOMER C WITH (NOLOCK)
		LEFT JOIN CustomerRateType RT WITH (NOLOCK) ON C.RateTypeKey = RT.RateTypeKey
		Left join CustomerSegments CS WITH (NOLOCK) on C.CustomerSegmentKey = CS.CustomerSegmentKey
		where C.CustKey = @CustKey
	END
	SELECT @OutputType AS OutputType FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

	SET @Status = 1
	SET @Reason = 'Success'
END
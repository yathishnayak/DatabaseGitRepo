-- 185623
/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"CustKey" : 3057, "OrderNo" : "UT230903"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [ValidateOrderNo_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[ValidateOrderNo_V3]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
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
		@CustKey	INT = 0,
		@OrderNo	varchar(50) = ''
		-- @IsValid	BIT = 0

	SELECT
		@CustKey		=		CustKey,
		@OrderNo		=		OrderNo
		-- @IsValid		=		IsValid
	FROM OPENJSON(@JSONString)
	WITH
	(
		CustKey		INT					'$.CustKey',
		OrderNo		VARCHAR(50)			'$.OrderNo'
		-- IsValid		BIT					'$.IsValid'
	)

	IF(ISNULL(@CustKey,0) = 0 OR ISNULL(@OrderNo,'') = '')
	BEGIN
		SET @Status = CONVERT(BIT, 0)
		SET @Reason	= 'Order Number and Customer Key is Mandatory'
		RETURN;
	END
	ELSE
	BEGIN
		DECLARE @cnt INT = 0
		SELECT @cnt = COUNT(1) FROM OrderHeader WITH (NOLOCK)
		WHERE CustKey = @CustKey AND OrderNo = @OrderNo

		IF(@cnt > 0)
		BEGIN
			SET @Status = CONVERT(BIT,1)
			SET @Reason = 'It is valid'
		END
		ELSE
		BEGIN
			SET @Status = CONVERT(BIT, 0)
			SET @Reason = 'It is not valid'
		END
		RETURN;
	END
END
/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"CustKey" : 1562, "OrderNo" : "FL230303"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_BrokerRefByOrderNo_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_BrokerRefByOrderNo_V3]		-- EXEC Get_BrokerRefByOrderNo 1562, 'FL230303' 
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

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
		@CustKey		INT,
		@OrderNo		VARCHAR(50)

	SELECT 
		@CustKey		=	CustKey,
		@OrderNo		=	OrderNo
	FROM OPENJSON(@JSONString)
	WITH
	(
		CustKey		INT				'$.CustKey',
		OrderNo		VARCHAR(50)		'$.OrderNo'
	)

	SELECT BrokerRefNo
	FROM OrderHeader OH WITH (NOLOCK)
	WHERE CustKey = @CustKey AND OrderNo = @OrderNo
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
END
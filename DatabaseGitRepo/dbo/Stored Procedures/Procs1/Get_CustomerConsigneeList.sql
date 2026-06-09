/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"CustKey":1671}',
	@Status BIT=0,@IsDebug		BIT = 0,
	@Reason VARCHAR(100)=''
EXec [Get_CustomerConsigneeList] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status AS Status, @Reason AS Reason
**/
CREATE PROC [dbo].[Get_CustomerConsigneeList]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN

	Declare
		@CustKey		INT = 0;

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END

	SELECT 
	@CustKey	=	CustKey
	FROM	OPENJSON(@JsonString, '$')
	WITH (CustKey	INT	'$.CustKey')

	SELECT  ConsigneeKey, ConsigneeId, ConsigneeName, CustKey 
	FROM Customer_Consignee WITH (NOLOCK)
	WHERE CustKey = @CustKey OR 0 = @CustKey 
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'

END
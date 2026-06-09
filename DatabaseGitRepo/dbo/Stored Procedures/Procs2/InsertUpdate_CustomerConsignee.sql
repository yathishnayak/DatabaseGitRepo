/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"CustKey":1671,"ConsigneeName":"test123"}',
	@Status BIT=0,@IsDebug		BIT = 0,
	@Reason VARCHAR(100)=''
EXEC [InsertUpdate_CustomerConsignee] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status AS Status, @Reason AS Reason
**/
CREATE PROC [dbo].[InsertUpdate_CustomerConsignee]
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
		@CustKey			INT = 0,
		@ConsigneeKey		INT = 0,
		@ConsigneeName		NVARCHAR(300) = ''

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END

	SELECT 
	@CustKey		=	CustKey,
	@ConsigneeName	=	ConsigneeName,
	@ConsigneeKey	=	ConsigneeKey
	FROM	OPENJSON(@JsonString, '$')
	WITH (
		CustKey			INT				'$.CustKey',
		ConsigneeKey	INT				'$.ConsigneeKey',
		ConsigneeName	NVARCHAR(300)	'$.ConsigneeName'
	)
	
	BEGIN TRY
		IF EXISTS (SELECT 1 FROM Customer_Consignee WITH(NOLOCK) WHERE ConsigneeKey = @ConsigneeKey AND @ConsigneeKey > 0)
		BEGIN
			-- Update existing
			UPDATE Customer_Consignee
			SET ConsigneeName = @ConsigneeName
			WHERE ConsigneeKey = @ConsigneeKey
		END
		ELSE
		BEGIN
			-- Insert new
			INSERT INTO Customer_Consignee (ConsigneeName, CustKey)
			VALUES (@ConsigneeName, @CustKey)

			-- Optionally, get the new inserted key if needed
			-- SET @ConsigneeKey = SCOPE_IDENTITY()
		END

		SET @Status = 1
		SET @Reason = ' Consignee Inserted Successfully'
	END TRY
	BEGIN CATCH
		SET @Status = -1
		SET @Reason = ERROR_MESSAGE()
	END CATCH


	SET @Status = 1
	SET @Reason = 'Success'

END
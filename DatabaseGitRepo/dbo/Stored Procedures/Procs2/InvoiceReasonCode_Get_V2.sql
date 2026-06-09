/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [InvoiceReasonCode_Get_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/

CREATE PROCEDURE [dbo].[InvoiceReasonCode_Get_V2]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
      SELECT ReasoncodeKey,ReasonCode,Status 
	  FROM InvoiceReasonCode WITH(NOLOCK)
	  WHERE Status = 1
	  FOR JSON PATH

	  SET @Status=1
	  SET @Reason = 'Success'
END

--SELECT * FROM InvoiceReasonCode
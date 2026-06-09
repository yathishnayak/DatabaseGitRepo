/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceNo" : "87"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [Get_InvoiceKeybyNo_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_InvoiceKeybyNo_V2]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS

BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON
	SET Concat_null_Yields_null ON

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
		@InvoiceNo	VARCHAR(100)=''

	SELECT 
		@InvoiceNo = InvoiceNo
	FROM OPENJSON(@JSONString)
	WITH
	(
		InvoiceNo		VARCHAR(100)		'$.InvoiceNo'
	)

	SELECT InvoiceKey, InvoiceNo, OrderKey From InvoiceHeader WITH (NOLOCK) WHERE InvoiceNo=@InvoiceNo
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

	SET @Status=1
	SET @Reason = 'Success'
END
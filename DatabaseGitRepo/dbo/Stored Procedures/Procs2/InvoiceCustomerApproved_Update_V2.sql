/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceKeyStr" : "83262:83182:"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [InvoiceCustomerApproved_Update_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/

CREATE PROCEDURE [dbo].[InvoiceCustomerApproved_Update_V2] --InvoiceCustomerApproved_Update @InvoiceKey = '83262:83182:'
(
	@UserKey		INT = 0,
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
	    @InvoiceKeyStr varchar(max) = ''

	SELECT
		@InvoiceKeyStr = InvoiceKeyStr
	FROM OPENJSON(@JSONString)
	WITH
	(
		InvoiceKeyStr		VARCHAR(MAX)		'$.InvoiceKeyStr'
	)

    select * into #InvoiceKeys from dbo.Fn_SplitParamCol(@InvoiceKeyStr)

      UPDATE  InvoiceHeader 
	  SET CustApproved = 1  --@CustApproved
	  WHERE InvoiceKey in (select value from #InvoiceKeys ) 

	  SET @Status=1
	  SET @Reason = 'Success'
END
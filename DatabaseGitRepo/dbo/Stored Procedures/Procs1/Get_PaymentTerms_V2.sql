/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = ''
	EXEC [Get_PaymentTerms_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
Select @Status Status, @Reason Reason
**/

CREATE PROCEDURE [dbo].[Get_PaymentTerms_V2]
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

	SELECT PaymentTermsKey,PaymentTermsID, [Days],[Description],CompanyKey,StatusKey  FROM dbo.PaymentTerms WITH (NOLOCK) order by [Days]
FOR JSON PATH;


	SET @Status = 1
	SET @Reason = 'Success'
END
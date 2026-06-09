/*
DECLARE 
	@UserKey INT = 953,
	@JSONString NVARCHAR(MAX)= '',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [BillingCompanyInfo_List_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason

*/

CREATE  procedure [dbo].[BillingCompanyInfo_List_V2]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT Companykey,CompanyName,CreateDate,CreateUser,UpdateDate,UpdateUser,IsActive
	FROM BillingCompanyInfo WITH(NOLOCK)
	FOR JSON PATH;


		SET @Status=1
		SET @Reason = 'Success'
END
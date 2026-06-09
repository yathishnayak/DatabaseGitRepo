/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = ''
	EXEC [Get_InvoicePaymentStatus] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
SELECT @Status AS Status, @Reason AS Reason 
**/
CREATE PROCEDURE [dbo].[Get_InvoicePaymentStatus]
(
	@UserKey      INT=488,
	@JSONString   NVARCHAR(MAX)='',
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	Select StatusKey,[Description], StatusType
	from InvoicePaymentStatus  WITH (NOLOCK)
	where isActive = 1 and IsDeleted = 0
	Order by OrderBy
	FOR JSON PATH

	SET @Status =1
	SET @Reason='Success'
END
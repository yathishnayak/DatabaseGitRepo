/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"MInvoiceKey" : 46}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [ManualInvoice_UpdateNotVoid_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[ManualInvoice_UpdateNotVoid_V3]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
as
begin
	set nocount on
	set fmtonly off

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
		@InvoiceKey INT = 0

	SELECT 
		@InvoiceKey	=	InvoiceKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		InvoiceKey			INT		'$.MInvoiceKey'
	)

	DECLARE @cnt int = 0, @PreVoidStatusKey int = 0
	SET @Status = 0
	SELECT @cnt = count(1)	from ManualInvoiceHeader WITH (NOLOCK) where MInvoiceKey = @InvoiceKey
	SELECT @PreVoidStatusKey = PreVoidStatusKey from ManualInvoiceHeader WITH (NOLOCK) where MInvoiceKey = @InvoiceKey

	DECLARE @UserName NVARCHAR(MAX)=''
	SELECT @UserName=ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey=@UserKey

	if(@cnt > 0)
	begin
		UPDATE ManualInvoiceHeader 
			SET VoidedDate = null,
			IsVoid = 0,
			VoidedUserKey = 0,
			StatusKey = @PreVoidStatusKey
		WHERE MInvoiceKey = @InvoiceKey

		INSERT INTO ManualInvoiceComments (MInvoiceKey, CommentDate, CreateUserKey, Comment)
		VALUES (@InvoiceKey, GETDATE(), @UserKey, 'Invoice marked as Open on ' + convert(varchar, getDate()))
		SET @Status = 1
		SET @Reason = 'Updated Successfully'

		INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Order',ISNULL(IH.OrderNo, ''),IH.OrderKey,null,'Text','Manual Invoice ' + IH.MInvoiceNo + ' marked as Not Void by ' +@UserName
		FROM ManualInvoiceHeader IH WHERE IH.MInvoiceKey = @InvoiceKey
	end
end
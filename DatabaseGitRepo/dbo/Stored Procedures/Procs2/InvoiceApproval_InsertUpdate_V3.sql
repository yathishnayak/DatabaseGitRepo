/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceType" : "Invoice", "InvoiceKey" : 185672, "IsApproved" : 1}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [InvoiceApproval_InsertUpdate_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/

CREATE PROCEDURE [dbo].[InvoiceApproval_InsertUpdate_V3]
(
	@UserKey		INT = 0,
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
		@InvoiceType	varchar(10),
		@InvoiceKey		int,
		@IsApproved		Bit = 0

	SELECT
		@InvoiceType		=		InvoiceType,
		@InvoiceKey			=		InvoiceKey	,
		@IsApproved			=		IsApproved	
	FROM OPENJSON(@JSONString)
	WITH
	(
		InvoiceType		VARCHAR(10)		'$.InvoiceType',
		InvoiceKey		INT				'$.InvoiceKey',	
		IsApproved		BIT				'$.IsApproved'
	)

	DECLARE @cnt int = 0
	select @cnt = COUNT(1)
	from vAllInvoiceStatement
	where InvoiceType = @InvoiceType and InvoiceKey = @InvoiceKey 
	if(ISNULL(@cnt,0) = 0)
	begin
		set @Status = 0
		set @Reason ='Invoice not exists'
	end
	select @cnt = COUNT(1)
	from vAllInvoiceStatement
	where InvoiceType = @InvoiceType and InvoiceKey = @InvoiceKey and Description = 'Approved'
	if(ISNULL(@cnt,0) = 0)
	begin
		set @Status = 0
		set @Reason ='Invoice not approved'
		return
	end
	set @cnt = 0
	select @cnt = COUNT(1) from invoiceApproval WITH(NOLOCK) where Invoicetype = @InvoiceType and InvoiceKey = @InvoiceKey
	if(isnull(@cnt,0) = 0)
	begin
		insert into InvoiceApproval (InvoiceType, InvoiceKey, IsApproved, ApprovedUserKey, ApprovedDate)
		select @InvoiceType, @InvoiceKey, @IsApproved, @UserKey, GETDATE()
		set @Status = 1
		set @Reason ='Invoice Approved'
	end
	else
	begin
		if(@IsApproved = 1)
		begin
			update InvoiceApproval set 
				IsApproved = @IsApproved,
				ApprovedUserKey = @UserKey,
				ApprovedDate = GETDATE()
			where InvoiceType = @InvoiceType and InvoiceKey = @InvoiceKey and @IsApproved = 1
			set @Status = 1
			set @Reason ='Invoice Approved'
		end
		else
		begin
			update InvoiceApproval set 
				IsApproved = @IsApproved,
				ApprovedUserKey = @UserKey,
				ApprovedDate = GETDATE()
			where InvoiceType = @InvoiceType and InvoiceKey = @InvoiceKey and @IsApproved = 0
			set @Status = 1
			set @Reason ='Invoice Approval reverted'
		end
	end
END
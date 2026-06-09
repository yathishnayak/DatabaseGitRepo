
/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"VoucherKey" : 353238, "PaidDate" : "2026-04-15T18:30:00.000Z"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [Update_VoucherPaidDate_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/

CREATE Proc [dbo].[Update_VoucherPaidDate_V3]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	
	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
		@VoucherKey  INT,
		@PaidDate	 DATETIME

	SELECT
		@VoucherKey		=    VoucherKey,
		@PaidDate		=	 PaidDate
	FROM OPENJSON(@JSONString)
	WITH
	(
		VoucherKey			INT				'$.VoucherKey',
		PaidDate			DATETIME		'$.PaidDate'
	)

	Declare @Comment varchar(500) = '',
			@CommentKey int,
			@PrevPaidDate datetime,
			@UserName varchar(100)

	select @PrevPaidDate = PaidDate from VoucherHeader where VoucherKey = @VoucherKey
	Select @UserName = UserName from [User] where UserKey = @UserKey
	
	set @Comment = 'Voucher Paid Date changed from : ' +  convert(varchar,@PrevPaidDate,101) 
		+ '  to ' +  convert(varchar,@PaidDate,101) + ' by ' + @UserName + '<br>'

	UPDATE dbo.VoucherHeader
	SET PaidDate = @PaidDate
	WHERE VoucherKey = @VoucherKey;

	
	update VoucherHeader set InternalNote = @Comment where VoucherKey = @VoucherKey

	SET @Status = 1;
	SET @Reason = 'Paid Date Updated'
END

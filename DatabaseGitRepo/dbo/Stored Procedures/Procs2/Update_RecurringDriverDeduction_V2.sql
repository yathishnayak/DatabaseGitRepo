/** 
Declare 
	@UserKey		INT = 1144,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"DriverVocherKey" : 70, "IsRecurring" : null}'
	EXEC [Update_RecurringDriverDeduction_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason 
**/

CREATE PROCEDURE [dbo].[Update_RecurringDriverDeduction_V2]
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

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE
		@DriverVocherKey	INT,
		@IsRecurring		BIT = 0

	SELECT 
		@DriverVocherKey	=	DriverVocherKey,
		@IsRecurring		=	IsRecurring	
	FROM OPENJSON(@JSONString)
	WITH
	(
		DriverVocherKey		INT		'$.DriverVocherKey',
		IsRecurring			BIT		'$.IsRecurring'
	)

	IF(@DriverVocherKey = 0 or @UserKey = 0)
	BEGIN
		SET @Status = 0;
		RETURN
	END

	UPDATE DriverVoucherDeduction 
	SET IsRecurring = @IsRecurring
	where DriverVoucherKey = @DriverVocherKey

	declare @comment1	varchar(1000) = '',
			@Comment2	varchar(1000) = '',
			@UserName	varchar(100) 

	Select @UserName = isnull(UserName,'') 
		From [User] WITH (NOLOCK) where UserKey = @UserKey

	Select  @Comment1 = 'Driver Deduction Voucher ' + isnull(DriverVoucherNumber,'NA') + 
		Case when isnull(@IsRecurring,0) = 1 then ' Marked Recurring on ' else ' UnMarked Recurring on ' END +
		convert(varchar, isnull(DriverVoucherdate,GetDate()), 101) + ' by user ' + isnull(@UserName, @UserKey)
	from DriverVoucherDeduction WITH (NOLOCK)
	where DriverVoucherKey = @DriverVocherKey

	insert into LogDeduction (DriverVoucherKey, Comment1, Comment2 )
	values ( @DriverVocherKey, @comment1, @Comment2 )

	Set @Status = 1
	SET @Reason = 'Success'
END
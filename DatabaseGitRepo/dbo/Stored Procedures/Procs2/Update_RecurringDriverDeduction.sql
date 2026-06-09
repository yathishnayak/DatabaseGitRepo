

CREATE Proc [dbo].[Update_RecurringDriverDeduction]
(
	@DriverVocherKey	INT,
	@UserKey			INT,
	@IsRecurring		BIT = 0,
	@Output				BIT = 0 OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF(@DriverVocherKey = 0 or @UserKey = 0)
	BEGIN
		SET @Output = 0;
		RETURN
	END

	UPDATE DriverVoucherDeduction 
	SET IsRecurring = @IsRecurring
	where DriverVoucherKey = @DriverVocherKey

	declare @comment1	varchar(1000) = '',
			@Comment2	varchar(1000) = '',
			@UserName	varchar(100) 

	Select @UserName = isnull(UserName,'') 
		From [User] where UserKey = @UserKey

	Select  @Comment1 = 'Driver Deduction Voucher ' + isnull(DriverVoucherNumber,'NA') + 
		Case when isnull(@IsRecurring,0) = 1 then ' Marked Recurring on ' else ' UnMarked Recurring on ' END +
		convert(varchar, isnull(DriverVoucherdate,GetDate()), 101) + ' by user ' + isnull(@UserName, @UserKey)
	from DriverVoucherDeduction
	where DriverVoucherKey = @DriverVocherKey

	insert into LogDeduction (DriverVoucherKey, Comment1, Comment2 )
	values ( @DriverVocherKey, @comment1, @Comment2 )

	Set @output = 1
END

CREATE Procedure [dbo].[InsertUpdate_DriverVoucherDeduction] -- execute InsertUpdate_DriverVoucherDeduction 0,'2022-04-12',121.10,5,'Harish'
(
	@DriverVoucherKey int Output,
	@DriverVoucherdate Datetime,
	@DriverVoucherAmount decimal(18,2),
	@DriverKey int,
	@CreateUser Varchar(50),
	@OutPut				BIT=0 OUTPUT  -- @Result 1 - sucess, 0 - failure
)
as 
Begin
	set nocount on;
	set fmtonly off;
	set @DriverVoucherdate = isnull(@DriverVoucherdate, getdate())

	if(@DriverKey = 0)
	BEGIN
		SET @output = 0
		RETURN;
	END;

		Declare @WeekNumber int
		set @WeekNumber = (select DATEPART(ISO_WEEK,isnull(@DriverVoucherdate,getdate())))

	IF @DriverVoucherKey = 0
	BEGIN
		Insert into DriverVoucherDeduction(DriverVoucherdate,DriverVoucherAmount,DriverKey,
					CreateUser,CreateDate)
		SELECT @DriverVoucherdate, @DriverVoucherAmount, @DriverKey, @CreateUser, Getdate()
		select @DriverVoucherKey = scope_identity()

		Declare	@DriverVoucherNumber Varchar(50)
		set @DriverVoucherNumber = 'D-000'+ convert(varchar(50),@DriverVoucherKey)

		update DriverVoucherDeduction
		set WeekNumber = @WeekNumber , DriverVoucherNumber = @DriverVoucherNumber
		where DriverVoucherKey = @DriverVoucherKey

		SET @OutPut=1
		return
	END
	ELSE
	BEGIN
		update DriverVoucherDeduction
		set DriverVoucherdate = @DriverVoucherdate,
			--DriverVoucherNumber = @DriverVoucherNumber,
			DriverVoucherAmount = @DriverVoucherAmount,
			DriverKey = @DriverKey,
			UpdateDate = Getdate(),
			UpdateUser = @CreateUser,
			WeekNumber = @WeekNumber
		where DriverVoucherKey = @DriverVoucherKey
		SET @OutPut=1
		return
	End
	
End

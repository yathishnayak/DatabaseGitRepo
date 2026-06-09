
/*
declare @result Bit = 0
declare @Count int = 0
exec Auto_CreateRecurringDriverDeductions 29, @result output, @Count output
select @result, @Count
select * from DriverVoucherDeduction
*/

CREATE proc [dbo].[Auto_CreateRecurringDriverDeductions]
(
	@UserKey		int,
	@Result			Bit = 0 OUTPUT,
	@Count			Int	= 0 OUTPUT
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	Declare @WeekNumber			int,
			@DriverVoucherdate	DateTime,
			@DriverVoucherKey	int,
			@DriverKey			int,
			@NewDriverVoucherKey int,
			@CntVoucher			int = 0
			
	Set @Count = 0
	set @WeekNumber = (select DATEPART(ISO_WEEK,getdate()))
	set @DriverVoucherdate = isnull(@DriverVoucherdate, getdate())

	print @Weeknumber 
	
	select *
	into #Header
	from DriverVoucherDeduction WITH (NOLOCK)
	where IsRecurring  = 1 and isnull(WeekNumber,0) <> @WeekNumber

	select DD.* 
	into #Detail
	from DriverVoucherDeductionDetail DD WITH (NOLOCK)
	inner join #Header H on H.DriverVoucherKey = Dd.DriverVoucherKey
	
	update #Header 
	set DriverVoucherdate = @DriverVoucherdate,
		IsRecurring = 0,
		WeekNumber = @WeekNumber,
		CreateUser = @UserKey,
		CreateDate = GETDATE(),
		UpdateDate = null,
		UpdateUser = null

	update #Detail
	set		CreateDate = GETDATE(),
			CreateUser = @UserKey,
			UpdateDate = null,
			UpdateUser = null

	declare _Cursor CURSOR FOR 
		select DriverVoucherKey, DriverKey from #Header

	BEGIN TRANSACTION DDTran
	BEGIN TRY
		Open _Cursor
		Fetch Next from _Cursor into @DriverVoucherKey, @DriverKey
	
		while @@FETCH_STATUS = 0
		BEGIN
			print 'Start ----------------------'
			print @DriverVoucherKey
			print @DriverKey

			set @NewDriverVoucherKey = null
			set @CntVoucher = 0

			select @CntVoucher = count(1) 
			from DriverVoucherDeduction WITH (NOLOCK)
			where WeekNumber = @WeekNumber and RecurrSourceVoucherKey = @DriverVoucherKey

			if(isnull(@CntVoucher,0) = 0)
			BEGIN
				insert into DriverVoucherDeduction (DriverVoucherdate, DriverVoucherNumber, DriverVoucherAmount,
					DriverKey, PaymentApprover, CreateUser, CreateDate, UpdateDate, UpdateUser, WeekNumber, IsRecurring, 
					RecurrSourceVoucherKey)
				select DriverVoucherdate, DriverVoucherNumber, DriverVoucherAmount,
					DriverKey, PaymentApprover, CreateUser, CreateDate, UpdateDate, UpdateUser, WeekNumber, IsRecurring,
					@DriverVoucherKey
				from #Header 
				Where DriverVoucherKey = @DriverVoucherKey and DriverKey = @DriverKey

				select @NewDriverVoucherKey = scope_identity()
				print @NewDriverVoucherKey
		
				insert into DriverVoucherDeductionDetail (DriverVoucherKey, ItemKey, Description, UnitCost, Qty, ExtCost, 
						Remarks,CreateUser, CreateDate, UpdateDate, UpdateUser)
				select @NewDriverVoucherKey, ItemKey, Description, UnitCost, Qty, ExtCost, 
						Remarks,CreateUser, CreateDate, UpdateDate, UpdateUser
				from #Detail
				where DriverVoucherKey = @DriverVoucherKey

				set @Count = @Count + 1
			END
			print 'End ----------------------'
			Fetch Next from _Cursor into @DriverVoucherKey, @DriverKey
		END

		COMMIT TRANSACTION DDTran
		set @Result = 1
		print 'Success'
		Close _Cursor
		deallocate _Cursor
	END TRY
	BEGIN CATCH
		SEt @Result  = 0
		SEt @Count = 0
		ROLLBACK TRANSACTION DDTran
		print 'Fail'
	END CATCH
END

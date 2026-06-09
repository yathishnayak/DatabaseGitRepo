
/*
	declare @DriverVoucherKeys varchar(50) = '40:41:', @DeleteUserKey int = 29, @OUTPUT bit = 0
	Exec [Delete_DriverDeductionVoucherBulk] @DriverVoucherKeys, @DeleteUserKey, @OUTPUT output
	select @OUTPUT
*/
create PROC [dbo].[Delete_DriverDeductionVoucherBulk]
(
	@DriverVoucherKeys		varchar(max)='', -- seperated by ':'
	@DeleteUserKey			INT,
	@OUTPUT					BIT = 0 OUTPUT
)
As
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	DECLARE @TRAN VARCHAR(50) = 'DRIVERVOUCHER_TRAN'
	Declare @DriverVoucherKey	int = 0

	create table #VoucherKeysRecd
	(
		DriverVoucherKey	int
	)

	insert into #VoucherKeysRecd (DriverVoucherKey)
	select Value from dbo.Fn_SplitParamCol(@DriverVoucherKeys)
	SET @OUTPUT = 0
	--select * from #VoucherKeysRecd
	
	
	select  A.DriverVoucherKey into #VoucherKeys 
	from #VoucherKeysRecd A
	inner join DriverVoucherDeduction B on A.DriverVoucherKey = B.DriverVoucherKey
	where isnull(B.IsRecurring,0) = 0

	declare @pendCnt int = 0
	select  @pendCnt = count(1) from #VoucherKeys

	if(@pendCnt > 0)
	Begin
		BEGIN TRANSACTION @TRAN;
		BEGIN TRY 
			DECLARE @CNT INT = 0

			while (@pendCnt > 0)
			Begin
				Select top 1 @DriverVoucherKey = DriverVoucherKey from #VoucherKeys

				SELECT @CNT = COUNT(1) FROM DriverVoucherDeduction WHERE DriverVoucherKey = @DriverVoucherKey and isnull(IsRecurring,0) = 0
				print '---------------- Start'
				print  @DriverVoucherKey
				IF(@CNT > 0)
				BEGIN
					INSERT INTO DriverVoucherDeduction_Deleted (DriverVoucherKey, DriverVoucherdate, DriverVoucherNumber, DriverVoucherAmount, 
						DriverKey, PaymentApprover, CreateUser, CreateDate, UpdateDate, UpdateUser, WeekNumber, IsRecurring, 
						RecurrSourceVoucherKey,	DeleteUserKey, DeletedDate)
					select DriverVoucherKey, DriverVoucherdate, DriverVoucherNumber, DriverVoucherAmount, 
						DriverKey, PaymentApprover, CreateUser, CreateDate, UpdateDate, UpdateUser, WeekNumber, IsRecurring, 
						RecurrSourceVoucherKey, @DeleteUserKey, GETDATE()
					from DriverVoucherDeduction
					where DriverVoucherKey = @DriverVoucherKey

					INSERT INTO DriverVoucherDeductionDetail_Deleted (DriverVoucherLineKey, DriverVoucherKey, ItemKey, Description, UnitCost, 
						Qty, ExtCost,Remarks, CreateUser, CreateDate, UpdateDate, UpdateUser, DeleteUserKey, DeletedDate)
					SELECT DriverVoucherLineKey, DriverVoucherKey, ItemKey, Description, UnitCost, 
						Qty, ExtCost,Remarks, CreateUser, CreateDate, UpdateDate, UpdateUser, @DeleteUserKey, GETDATE()
					FROM DriverVoucherDeductionDetail 
					WHERE DriverVoucherKey = @DriverVoucherKey

					DELETE FROM DriverVoucherDeduction WHERE DriverVoucherKey = @DriverVoucherKey
					DELETE FROM DriverVoucherDeductionDetail WHERE DriverVoucherKey = @DriverVoucherKey

					delete from #VoucherKeys where DriverVoucherKey = @DriverVoucherKey
					select @pendCnt = count(1) from #VoucherKeys
				
				END
				
				print '---------------- End'
			End
			SET @OUTPUT = 1
			COMMIT TRANSACTION @TRAN;
			RETURN
		 END TRY
		 BEGIN CATCH
			set @OUTPUT = 0
			ROLLBACK TRANSACTION @TRAN
		 END CATCH
	End
	
END

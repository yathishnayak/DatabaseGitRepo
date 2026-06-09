

CREATE PROC [dbo].[Delete_DriverDeductionVoucherFull]
(
	@DriverVoucherKey		INT,
	@DeleteUserKey			INT,
	@OUTPUT					BIT = 0 OUTPUT
)
As
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	DECLARE @TRAN VARCHAR(50) = 'DRIVERVOUCHER_TRAN'
	BEGIN TRANSACTION @TRAN;
	BEGIN TRY 
		DECLARE @CNT INT = 0

		SET @OUTPUT = 0
		SELECT * FROM InvoiceStatus
		SELECT @CNT = COUNT(1) FROM DriverVoucherDeduction WHERE DriverVoucherKey = @DriverVoucherKey and isnull(IsRecurring,0) = 0

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

			SET @OUTPUT = 1
			COMMIT TRANSACTION @TRAN;
		END
		RETURN
	 END TRY
	 BEGIN CATCH
		ROLLBACK TRANSACTION @TRAN
	 END CATCH
END

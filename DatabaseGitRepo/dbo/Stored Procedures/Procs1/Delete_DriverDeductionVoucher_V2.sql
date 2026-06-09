/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"DriverVoucherKeys" : "455:452"}'
	EXEC [Delete_DriverDeductionVoucher_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/ 
CREATE PROC [dbo].[Delete_DriverDeductionVoucher_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
As
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
	@DriverVoucherKeys		varchar(max) = ''
	-- @UserKey			INT

	SELECT 
	@DriverVoucherKeys		=		DriverVoucherKeys
	-- @UserKey			=		DeleteUserKey	
	FROM OPENJSON(@JSONString)
	WITH
	(
	DriverVoucherKeys		varchar(max)		'$.DriverVoucherKeys'
	-- DeleteUserKey			INT		'$.DeleteUserKey'		
	)

	DECLARE @TRAN VARCHAR(50) = 'DRIVERVOUCHER_TRAN'
	Declare @DriverVoucherKey	int = 0

	create table #VoucherKeysRecd
	(
		DriverVoucherKey	int
	)

	insert into #VoucherKeysRecd (DriverVoucherKey)
	select Value from dbo.Fn_SplitParamCol(@DriverVoucherKeys)
	SET @Status = 0
	--select * from #VoucherKeysRecd
	
	
	select  A.DriverVoucherKey into #VoucherKeys 
	from #VoucherKeysRecd A
	inner join DriverVoucherDeduction B WITH (NOLOCK) on A.DriverVoucherKey = B.DriverVoucherKey
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

				SELECT @CNT = COUNT(1) FROM DriverVoucherDeduction WITH (NOLOCK) WHERE DriverVoucherKey = @DriverVoucherKey and isnull(IsRecurring,0) = 0
				print '---------------- Start'
				print  @DriverVoucherKey
				IF(@CNT > 0)
				BEGIN
					INSERT INTO DriverVoucherDeduction_Deleted (DriverVoucherKey, DriverVoucherdate, DriverVoucherNumber, DriverVoucherAmount, 
						DriverKey, PaymentApprover, CreateUser, CreateDate, UpdateDate, UpdateUser, WeekNumber, IsRecurring, 
						RecurrSourceVoucherKey,	DeleteUserKey, DeletedDate)
					select DriverVoucherKey, DriverVoucherdate, DriverVoucherNumber, DriverVoucherAmount, 
						DriverKey, PaymentApprover, CreateUser, CreateDate, UpdateDate, UpdateUser, WeekNumber, IsRecurring, 
						RecurrSourceVoucherKey, @UserKey, GETDATE()
					from DriverVoucherDeduction WITH (NOLOCK)
					where DriverVoucherKey = @DriverVoucherKey

					INSERT INTO DriverVoucherDeductionDetail_Deleted (DriverVoucherLineKey, DriverVoucherKey, ItemKey, Description, UnitCost, 
						Qty, ExtCost,Remarks, CreateUser, CreateDate, UpdateDate, UpdateUser, DeleteUserKey, DeletedDate)
					SELECT DriverVoucherLineKey, DriverVoucherKey, ItemKey, Description, UnitCost, 
						Qty, ExtCost,Remarks, CreateUser, CreateDate, UpdateDate, UpdateUser, @UserKey, GETDATE()
					FROM DriverVoucherDeductionDetail  WITH (NOLOCK)
					WHERE DriverVoucherKey = @DriverVoucherKey

					DELETE FROM DriverVoucherDeduction WHERE DriverVoucherKey = @DriverVoucherKey
					DELETE FROM DriverVoucherDeductionDetail WHERE DriverVoucherKey = @DriverVoucherKey

					delete from #VoucherKeys where DriverVoucherKey = @DriverVoucherKey
					select @pendCnt = count(1) from #VoucherKeys
				
				END
				
				print '---------------- End'
			End
			SET @Status = 1
			SET @Reason = 'Success'
			COMMIT TRANSACTION @TRAN;
			RETURN
		 END TRY
		 BEGIN CATCH
			set @Status = 0
			ROLLBACK TRANSACTION @TRAN
		 END CATCH
	End
	
END
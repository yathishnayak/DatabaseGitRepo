
CREATE Procedure [dbo].[InsertUpdate_DriverVoucherDeductionDetail] -- [InsertUpdate_DriverVoucherDeductionDetail] 3,2,5,15.00,2.00,'test1','harish'
(
@DriverVoucherKey int,
@DriverVoucherLineKey int,
@ItemKey int,
@UnitCost Decimal(18,5),
@Qty Decimal(18,2),
@Remarks Varchar(200),
@CreateUser Varchar(50),
@OutPut		BIT=0 OUTPUT  -- @Result 1 - sucess, 0 - failure
)
as
BEGIN
  SET NOCOUNT ON;
  SET FMTONLY OFF;
  set @DriverVoucherLineKey  = isnull(@DriverVoucherLineKey,0)

  	IF(@DriverVoucherKey = 0)
	BEGIN
		SET @output = 0
		RETURN;
	END;

		Declare @ExtCost decimal(18,2)
		declare @total decimal(18,2)

	IF @DriverVoucherLineKey =0
	BEGIN
		Insert Into DriverVoucherDeductionDetail ( DriverVoucherKey,ItemKey, UnitCost, Qty, Remarks,CreateUser, CreateDate)
		Select @DriverVoucherKey,@ItemKey,@UnitCost, @Qty, @Remarks, @CreateUser, getdate()
		select @DriverVoucherLineKey = scope_identity()

		set @ExtCost = (select (UnitCost*Qty) as ExtCost from DriverVoucherDeductionDetail where  DriverVoucherLineKey=@DriverVoucherLineKey)

		update DriverVoucherDeductionDetail
		set ExtCost = @ExtCost
		where  DriverVoucherLineKey=@DriverVoucherLineKey

		set @total = (select sum(ExtCost)from DriverVoucherDeductionDetail where  DriverVoucherKey=@DriverVoucherKey)

		Update DriverVoucherDeduction
		set DriverVoucherAmount= @total
		where DriverVoucherKey = @DriverVoucherKey

		SET @OutPut=1
		return
	End
	Else
	Begin
		Update DriverVoucherDeductionDetail
		set ItemKey = @ItemKey,
			UnitCost = @UnitCost,
			Qty = @Qty,
			--ExtCost = @ExtCost,
			Remarks = @Remarks,
			UpdateDate = getdate(),
			UpdateUser = @CreateUser
		where DriverVoucherKey = @DriverVoucherKey
		and DriverVoucherLineKey = @DriverVoucherLineKey

		set @ExtCost = (select (UnitCost*Qty) as ExtCost from DriverVoucherDeductionDetail where  DriverVoucherLineKey=@DriverVoucherLineKey)

		update DriverVoucherDeductionDetail
		set ExtCost = @ExtCost
		where  DriverVoucherLineKey=@DriverVoucherLineKey

		set @total = (select sum(ExtCost)from DriverVoucherDeductionDetail where  DriverVoucherKey=@DriverVoucherKey)

		Update DriverVoucherDeduction
		set DriverVoucherAmount= @total
		where DriverVoucherKey = @DriverVoucherKey

		SET @OutPut=1
		return
	END
End

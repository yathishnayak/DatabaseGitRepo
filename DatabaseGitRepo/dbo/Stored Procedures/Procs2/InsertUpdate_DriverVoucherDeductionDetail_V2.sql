/** 
Declare 
	@UserKey		INT = 1144,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"DriverVoucherKey" : 3, "DriverVoucherLineKey" : 0, "ItemKey" : 10, "UnitCost" : 5.00, "Qty" : 10, "Remarks" : "123"}'
	EXEC [InsertUpdate_DriverVoucherDeductionDetail_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
SELECT @Status AS Status, @Reason AS Reason 
**/
CREATE PROCEDURE [dbo].[InsertUpdate_DriverVoucherDeductionDetail_V2] -- [InsertUpdate_DriverVoucherDeductionDetail] 3,2,5,15.00,2.00,'test1','harish'
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,  -- @Result 1 - sucess, 0 - failure,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
as
BEGIN
  SET NOCOUNT ON;
  SET FMTONLY OFF;

  	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

  DECLARE
	@DriverVoucherKey				int,
	@DriverVoucherLineKey			int,
	@ItemKey						int,
	@UnitCost						Decimal(18,5),
	@Qty							Decimal(18,2),
	@Remarks						Varchar(200)

   SELECT 
	   @DriverVoucherKey		= DriverVoucherKey		,
	   @DriverVoucherLineKey	= DriverVoucherLineKey	,
	   @ItemKey					= ItemKey				,
	   @UnitCost				= UnitCost				,
	   @Qty						= Qty					,
	   @Remarks					= Remarks			
	 FROM OPENJSON(@JSONString)
	 WITH
	 (
		 DriverVoucherKey		   INT					'$.DriverVoucherKey'		,
		 DriverVoucherLineKey	   INT					'$.DriverVoucherLineKey'	,
		 ItemKey				   INT					'$.ItemKey'				,
		 UnitCost				   DECIMAL(18,5)		'$.UnitCost'				,
		 Qty					   Decimal(18,2)		'$.Qty'					,
		 Remarks				   VARCHAR(200)			'$.Remarks'
	 )

  set @DriverVoucherLineKey  = isnull(@DriverVoucherLineKey,0)

  	IF(@DriverVoucherKey = 0)
	BEGIN
		SET @Status = 0
		RETURN;
	END;

		Declare @ExtCost decimal(18,2)
		declare @total decimal(18,2)

	IF @DriverVoucherLineKey =0
	BEGIN
		Insert Into DriverVoucherDeductionDetail ( DriverVoucherKey,ItemKey, UnitCost, Qty, Remarks,CreateUser, CreateDate)
		Select @DriverVoucherKey,@ItemKey,@UnitCost, @Qty, @Remarks, @UserKey, getdate()
		select @DriverVoucherLineKey = scope_identity()

		set @ExtCost = (select (UnitCost*Qty) as ExtCost from DriverVoucherDeductionDetail where  DriverVoucherLineKey=@DriverVoucherLineKey)

		update DriverVoucherDeductionDetail
		set ExtCost = @ExtCost
		where  DriverVoucherLineKey=@DriverVoucherLineKey

		set @total = (select sum(ExtCost)from DriverVoucherDeductionDetail where  DriverVoucherKey=@DriverVoucherKey)

		Update DriverVoucherDeduction
		set DriverVoucherAmount= @total
		where DriverVoucherKey = @DriverVoucherKey

		SET @Status=1
		SET @Reason = 'Success'
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
			UpdateUser = @UserKey
		where DriverVoucherKey = @DriverVoucherKey
		and DriverVoucherLineKey = @DriverVoucherLineKey

		set @ExtCost = (select (UnitCost*Qty) as ExtCost from DriverVoucherDeductionDetail WITH (NOLOCK) where  DriverVoucherLineKey=@DriverVoucherLineKey)

		update DriverVoucherDeductionDetail
		set ExtCost = @ExtCost
		where  DriverVoucherLineKey=@DriverVoucherLineKey

		set @total = (select sum(ExtCost)from DriverVoucherDeductionDetail WITH (NOLOCK) where  DriverVoucherKey=@DriverVoucherKey)

		Update DriverVoucherDeduction
		set DriverVoucherAmount= @total
		where DriverVoucherKey = @DriverVoucherKey

		SET @Status=1
		SET @Reason = 'Success'
		return
	END
End

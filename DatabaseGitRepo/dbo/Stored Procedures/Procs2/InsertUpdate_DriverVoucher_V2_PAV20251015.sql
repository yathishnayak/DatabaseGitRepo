/*
DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)='{"DriverVoucherKey": 0,"DriverVoucherdate": "2025-08-10","DriverVoucherAmount": 200,"DriverKey": 661,
								"ContainerNo": "MSKU9996003","CreateUser": "",
								"DeductionDetails":{"DriverVoucherLineKey": 0, "ItemKey": 6, "UnitCost":20.00, "Qty":5.00, "Remarks": "Test3"}}',
	@Status BIT=0,
	@Reason VARCHAR(100)='',
	@isDebug BIT=1
EXEC [InsertUpdate_DriverVoucher_V2_PAV20251015] @UserKey,@JSONString,'',@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason

*/

Create PROCEDURE [dbo].[InsertUpdate_DriverVoucher_V2_PAV20251015]
(
	@UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT,
	@isDebug       BIT = 0
)
AS
SET NOCOUNT ON
SET FMTONLY OFF
SET ARITHABORT ON;
BEGIN
	IF(@JSONString='' OR @JSONString IS NULL)
	BEGIN
		SET @Reason='Parameter not Present';
		SET @Status=0
		RETURN;
	END
	SET @Status=0;
	SET @Reason='Failure';

	DECLARE @DriverVoucherKey	INT=0, @DriverVoucherdate DateTime, @DriverVoucherAmount Decimal(18,2), @DriverKey INT, @ContainerNo NVARCHAR(50), 
			@CreateUser NVARCHAR(50), @DeductionDetails  NVARCHAR(MAX)

	SELECT  @DriverVoucherKey = ISNULL(DriverVoucherKey,0), 
			@DriverVoucherdate=DriverVoucherdate, 
			@DriverVoucherAmount = DriverVoucherAmount, 
			@DriverKey = DriverKey, 
			@ContainerNo = ContainerNo, @CreateUser=CreateUser,
			@DeductionDetails = DeductionDetails
	FROM OPENJSON(@JSONString,'$')
    WITH (
			DriverVoucherKey		INT				'$.DriverVoucherKey',			
			DriverVoucherdate		DATETIME		'$.DriverVoucherdate',
			DriverVoucherAmount		DECIMAL(18,2)	'$.DriverVoucherAmount',
			DriverKey				INT				'$.DriverKey',
			ContainerNo				NVARCHAR(50)	'$.ContainerNo',
			CreateUser				NVARCHAR(50)	'$.CreateUser',
			DeductionDetails		NVARCHAR(MAX)	'$.DeductionDetails' AS JSON
		)

	DECLARE @DriverVoucherLineKey INT, @ItemKey INT, @UnitCost DECIMAL(18,5),
			@Qty DECIMAL(18,2), @Remarks NVARCHAR(200), @CreateDate DATETIME

	Select @DeductionDetails

	CREATE TABLE #tempDeduction (
		DriverVoucherKey		INT,
		DriverVoucherLineKey	INT,
		ItemKey					INT,
		UnitCost				DECIMAL(18,2),
		Qty						DECIMAL(18,2),
		Remarks					NVARCHAR(200),
		CreateUser				INT,
		CreateDate				DATETIME
	);

	INSERT INTO #tempDeduction
	(DriverVoucherLineKey, ItemKey, UnitCost, Qty, Remarks)
	SELECT * FROM OPENJSON(@DeductionDetails,'$')
    WITH (
			DriverVoucherLineKey	INT				'$.DriverVoucherLineKey',			
			ItemKey					INT				'$.ItemKey',
			UnitCost				DECIMAL(18,2)	'$.UnitCost',
			Qty						DECIMAL(18,2)	'$.Qty',
			Remarks					NVARCHAR(200)	'$.Remarks'
		)	

	IF(@DriverKey = 0)
	BEGIN
		SET @Status=0;
		SET @Reason='Driver is Required';
	END

	--SELECT @CreateUser = ISNULL(UserName,'') FROM [User] WHERE UserKey = @UserKey
	SELECT @CreateUser = @UserKey

	DECLARE @WeekNumber INT
		SET @WeekNumber = (SELECT DATEPART(ISO_WEEK, ISNULL(@DriverVoucherdate,GETDATE())))

	DECLARE @ExtCost DECIMAL(18,2)
	DECLARE @total DECIMAL(18,2)

	BEGIN TRY
		BEGIN TRANSACTION
			IF @DriverVoucherKey = 0
			BEGIN
				INSERT INTO DriverVoucher(DriverVoucherdate,DriverVoucherAmount,DriverKey,
					CreateUser,CreateDate, ContainerNo)
				SELECT @DriverVoucherdate, @DriverVoucherAmount, @DriverKey, @CreateUser, GETDATE(),@ContainerNo
				SELECT @DriverVoucherKey = scope_identity()

				DECLARE	@DriverVoucherNumber VARCHAR(50)
				SET @DriverVoucherNumber = 'M-000'+ CONVERT(VARCHAR(50),@DriverVoucherKey)

				UPDATE DriverVoucher
				SET WeekNumber = @WeekNumber , DriverVoucherNumber = @DriverVoucherNumber
				WHERE DriverVoucherKey = @DriverVoucherKey

			END
			ELSE
			BEGIN
				UPDATE DriverVoucher
				SET DriverVoucherdate	=	@DriverVoucherdate,
					ContainerNo			=	@ContainerNo,
					DriverVoucherAmount =	@DriverVoucherAmount,
					DriverKey			=	@DriverKey,
					UpdateDate			=	GETDATE(),
					UpdateUser			=	@CreateUser,
					WeekNumber			=	@WeekNumber
				WHERE DriverVoucherKey	=	@DriverVoucherKey
			END

			print @DriverVoucherKey

			IF @isDebug = 1
			BEGIN
				SELECT '@DriverVoucherKey', @DriverVoucherKey
			END
			--********************** Driver Voucher Dedection **********************
			IF (@DriverVoucherKey > 0)
			BEGIN
			print '@DriverVoucherKey'
			SELECT * FROM #tempDeduction

			UPDATE #tempDeduction SET
				DriverVoucherKey = @DriverVoucherKey,
				CreateUser = @UserKey
				--********************** CURSOR **********************
				IF @isDebug = 1
				BEGIN
					SELECT * FROM #tempDeduction
				END

				DECLARE curDeducation CURSOR FOR 
				SELECT DriverVoucherKey, DriverVoucherLineKey, ItemKey, UnitCost, Qty, Remarks, CreateUser, CreateDate
				FROM #tempDeduction

				OPEN curDeducation
				FETCH NEXT FROM curDeducation
					INTO @DriverVoucherKey, @DriverVoucherLineKey, @ItemKey, @UnitCost, @Qty, @Remarks, @UserKey, @CreateDate
				WHILE @@FETCH_STATUS = 0
				BEGIN
					IF @DriverVoucherLineKey = 0
					BEGIN
						--INSERT INTO DriverVoucherDetail (DriverVoucherKey,ItemKey, UnitCost, Qty, Remarks, CreateUser, CreateDate)
						--SELECT @DriverVoucherKey, @ItemKey, @UnitCost, @Qty, @Remarks, @UserKey, GetDate()

						--SELECT @DriverVoucherLineKey = scope_identity()

						--SET @ExtCost = (SELECT (UnitCost*Qty) AS ExtCost FROM DriverVoucherDetail WHERE DriverVoucherLineKey=@DriverVoucherLineKey)

						--UPDATE DriverVoucherDetail
						--SET ExtCost = @ExtCost
						--WHERE  DriverVoucherLineKey=@DriverVoucherLineKey

						--SET @total = (SELECT SUM(ExtCost)FROM DriverVoucherDetail WHERE DriverVoucherKey=@DriverVoucherKey)

						--UPDATE DriverVoucher
						--SET DriverVoucherAmount= @total
						--WHERE DriverVoucherKey = @DriverVoucherKey

						-- Replace entire cursor block with set-based operations
						INSERT INTO DriverVoucherDetail (DriverVoucherKey, ItemKey, UnitCost, Qty, Remarks, CreateUser, CreateDate)
						SELECT @DriverVoucherKey, ItemKey, UnitCost, Qty, Remarks, @UserKey, GETDATE()
						FROM #tempDeduction 
						WHERE DriverVoucherLineKey = 0

						-- Single update for all ExtCost calculations
						UPDATE dvd
						SET ExtCost = UnitCost * Qty
						FROM DriverVoucherDetail dvd
						INNER JOIN #tempDeduction tmp ON dvd.DriverVoucherLineKey = tmp.DriverVoucherLineKey

						-- Single update for total amount
						UPDATE dv
						SET DriverVoucherAmount = (SELECT SUM(ExtCost) FROM DriverVoucherDetail WHERE DriverVoucherKey = @DriverVoucherKey)
						FROM DriverVoucher dv
						WHERE DriverVoucherKey = @DriverVoucherKey
					END
					ELSE
					BEGIN
						UPDATE DriverVoucherDetail
						SET ItemKey = @ItemKey,
							UnitCost = @UnitCost,
							Qty = @Qty,
							--ExtCost = @ExtCost,
							Remarks = @Remarks,
							UpdateDate = GETDATE(),
							UpdateUser = @CreateUser
						WHERE DriverVoucherKey = @DriverVoucherKey
						AND DriverVoucherLineKey = @DriverVoucherLineKey

						SET @ExtCost = (SELECT (UnitCost*Qty) AS ExtCost FROM DriverVoucherDetail WHERE DriverVoucherLineKey=@DriverVoucherLineKey)

						UPDATE DriverVoucherDetail
						SET ExtCost = @ExtCost
						WHERE  DriverVoucherLineKey=@DriverVoucherLineKey

						SET @total = (SELECT SUM(ExtCost)FROM DriverVoucherDetail WHERE DriverVoucherKey=@DriverVoucherKey)

						UPDATE DriverVoucher
						SET DriverVoucherAmount= @total
						WHERE DriverVoucherKey = @DriverVoucherKey
					END
				END
				CLOSE curDeducation  
				DEALLOCATE curDeducation
			END

		SET @Status=1;
		SET @Reason='Success';
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		SET @Status = 0;
		SET @Reason = 'Error: ' + ERROR_MESSAGE();

		SELECT @Status AS Status, @Reason AS Reason FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
	END CATCH

	DROP Table #tempDeduction
END

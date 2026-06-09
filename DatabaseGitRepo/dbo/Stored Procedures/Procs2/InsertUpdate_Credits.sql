
/*
Select * from invoicecredits

DECLARE @UserKey INT = 951, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString = '{"CreditKey":0,"CreditAmount":1990.89,"CreditDate":"2025-07-26","IsCreditApplied":1,"CreditStatus":1,
"InvoiceKeys":"38397:38398::38399", "MInvoiceKey":10}'

EXEC [InsertUpdate_Credits] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason

*/
CREATE PROCEDURE [dbo].[InsertUpdate_Credits]
(
	@UserKey	INT,
	@JSONString	NVARCHAR(MAX) = '',
	@Status		BIT OUTPUT,
	@Reason		NVARCHAR(MAX) OUTPUT,
	@IsDebug	BIT = 0 
)
AS
BEGIN
	SET NOCOUNT ON;

	-- Initialize default output values
	SET @Reason  = 'Something went wrong, Contact system administrator';
	SET @Status = 0;
	DECLARE
		@CreditKey			INT,
		@CreditTypeKey      INT,
		@CreditNo			NVARCHAR(50),
		@CreditAmount		DECIMAL(18,2),
		@CreditDate			DATE,
		@IsCreditApplied	BIT,
		@CreditAppliedDate	DATETIME,
		@CreditAppliedBy	INT,
		@CreditStatus		INT,
		@CreatedDate		DATETIME,
		@CreatedUserKey		INT,
		@UpdatedDate		DATETIME,
		@UpdatedUserKey		INT,
		@InvoiceKeys		VARCHAR(MAX),
		@MInvoiceKey		INT
	BEGIN TRY

		/*==================================================================
			1. Validate input JSON
		==================================================================*/

		IF (ISNULL(@JSONString, '') = '')
		BEGIN
			SET @Reason = 'JSON string cannot be blank';
			RETURN;
		END

		/*==================================================================
			2. Parse the JSON input into variables
		==================================================================*/

		SELECT 
				@CreditKey			= CreditKey,
				@CreditTypeKey      = CreditTypeKey,
				@CreditNo			= CreditNo,
				@CreditAmount		= CreditAmount,
				@CreditDate			= CreditDate,
				@IsCreditApplied	= IsCreditApplied,
				@CreditAppliedDate	= CreditAppliedDate,
				@CreditAppliedBy	= CreditAppliedBy,
				@CreditStatus		= CreditStatus,	
				@CreatedDate		= CreatedDate,
				@CreatedUserKey		= CreatedUserKey,	
				@UpdatedDate		= UpdatedDate,
				@UpdatedUserKey		= UpdatedUserKey,
				@InvoiceKeys		= InvoiceKeys,
				@MInvoiceKey		= MInvoiceKey
		FROM	OPENJSON(@JSONString, '$')
				WITH (
				CreditKey			INT				'$.CreditKey',
				CreditTypeKey       INT             '$.CreditTypeKey',
				CreditNo			NVARCHAR(50)	'$.CreditNo',
				CreditAmount		DECIMAL(18,2)	'$.CreditAmount',
				CreditDate			DATE			'$.CreditDate',
				IsCreditApplied		BIT				'$.IsCreditApplied',
				CreditAppliedDate	DATETIME		'$.CreditAppliedDate',
				CreditAppliedBy		INT				'$.CreditAppliedBy',
				CreditStatus		INT				'$.CreditStatus',	
				CreatedDate			DATETIME		'$.CreatedDate',
				CreatedUserKey		INT				'$.CreatedUserKey',	
				UpdatedDate			DATETIME		'$.UpdatedDate',
				UpdatedUserKey		INT				'$.UpdatedUserKey',
				InvoiceKeys			VARCHAR(MAX)	'$.InvoiceKeys',
				MInvoiceKey			INT				'$.MInvoiceKey'
				);

		/*==================================================================
			3. Validate required fields
		==================================================================*/


		/*==================================================================
			4. Begin transaction after validations
		==================================================================*/

		BEGIN TRANSACTION;

		-- ================================
		-- Main Business Logic goes here
		-- ================================
		-- Example: INSERT/UPDATE/DELETE
		/*==================================================================
			5. Insert Update Tickets Records
		==================================================================*/

		DECLARE @NewInvoiceKeys TABLE (InvoiceKey INT);
		INSERT INTO @NewInvoiceKeys (InvoiceKey)
		SELECT CAST(Value AS INT)
		FROM dbo.Fn_SplitParamCol(@InvoiceKeys);

		IF(@IsDebug = 1)
		BEGIN
			SELECT * FROM @NewInvoiceKeys
		END

		IF (ISNULL(@CreatedUserKey, 0) = 0)
		Begin
			Set @CreatedUserKey = @UserKey
		End

		IF (ISNULL(@CreditKey,0) = 0)
		BEGIN
			DECLARE @NewCreditNo VARCHAR(50)

			SELECT @NewCreditNo = CAST(ISNULL(MAX(CAST(CreditNo AS INT)), 0) + 1 AS VARCHAR)
			FROM InvoiceCredits
			WHERE ISNUMERIC(CreditNo) = 1

			INSERT INTO InvoiceCredits (CreditNo,CreditTypeKey, CreditAmount, CreditDate, IsCreditApplied, 
								CreditAppliedDate, CreditAppliedBy, CreditStatus,
								CreatedDate, CreatedUserKey, UpdatedDate, UpdatedUserKey)
			Values (@NewCreditNo,@CreditTypeKey, @CreditAmount, ISNULL(@CreditDate, GETDATE()), @IsCreditApplied, 
					ISNULL(@CreditAppliedDate, GETDATE()), ISNULL(@CreditAppliedBy, @Userkey), @CreditStatus,
					ISNULL(@CreatedDate, GETDATE()), @CreatedUserKey, ISNULL(@CreatedDate, GETDATE()), @CreatedUserKey)

			SET @CreditKey = SCOPE_IDENTITY();

			DECLARE @cnt INT  = (SELECT COUNT(1) FROM @NewInvoiceKeys)

			IF(@cnt <> 0)
			BEGIN
			INSERT INTO InvoiceCreditLink (CreditKey, InvoiceKey, MInvoiceKey)
			SELECT 
				@CreditKey,R.InvoiceKey,@MInvoiceKey
			FROM @NewInvoiceKeys R
			END
			ELSE
			BEGIN
				INSERT INTO InvoiceCreditLink (CreditKey, MInvoiceKey)
				VALUES (@CreditKey,@MInvoiceKey)
			END
		END
		ELSE
		BEGIN

			UPDATE InvoiceCredits
			SET CreditAmount = @CreditAmount, CreditDate = @CreditDate, IsCreditApplied = @IsCreditApplied,
				CreditAppliedDate = @CreditAppliedDate, CreditAppliedBy = @CreditAppliedBy, CreditStatus = @CreditStatus, 
				UpdatedDate=ISNULL(@UpdatedDate, GETDATE()), UpdatedUserKey=@UserKey
			WHERE CreditKey = @CreditKey;

			--UPDATE InvoiceCreditLink
			--SET InvoiceKey = @InvoiceKeys, MInvoiceKey = @MInvoiceKey
			--WHERE CreditKey = @CreditKey;

		END

		/*==================================================================
			6. Debug
		==================================================================*/

		If (@IsDebug = 1)
		Begin
			SELECT * FROM InvoiceCredits WHERE CreditKey = @CreditKey;
			SELECT * FROM InvoiceCreditLink WHERE CreditKey = @CreditKey;
		End

		/*==================================================================
			7. Set success response
		==================================================================*/

		SELECT 'CreditKey' = @CreditKey
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

		SET @Status = 1;
		SET @Reason = 'Success';
		SET @Reason = @Reason;

		/*==================================================================
			8. Commit transaction
		==================================================================*/

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		-- Roll back the transaction if it was started------------------------------------------------------------
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		-- Set error output ---------------------------------------------------------------------------------------
		SET @Status = 0;
		SET @Reason = ERROR_MESSAGE();
	END CATCH
END


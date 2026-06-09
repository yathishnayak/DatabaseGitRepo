/*

Select * from InvoiceCredits

DECLARE @UserKey INT = 951, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString = '{"CreditKey":6}'

EXEC [Get_InvoiceCredits] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason
*/
CREATE PROCEDURE [dbo].[Get_InvoiceCredits]
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

	DECLARE @CreditKey INT;

	BEGIN TRY

		/*==================================================================
			Parse the JSON input into variables
		==================================================================*/

		SET @CreditKey = JSON_VALUE(@JSONString, '$.CreditKey')

		/*==================================================================
			Validate required fields
		==================================================================*/

		-- Necessary Validations

		/*==================================================================
			Begin transaction after validations
		==================================================================*/

		BEGIN TRANSACTION;

		/*================================
			Main Business Logic goes here
		-- ================================*/
		
		Declare @JSONResult NVARCHAR(MAX) = ''

		SET @JSONResult = (
			SELECT	
					IC.CreditKey,IC.CreditTypeKey,IC.CreditNo,IC.CreditAmount,IC.CreditDate,IC.CreditAppliedBy,IC.CreditAppliedDate,
					U.UserName as 'User',IC.CreditStatus,IC.CreatedUserKey,IC.CreatedDate,
					STRING_AGG(CAST(ISNULL(IH.CustKey, MIH.CustomerKey) AS VARCHAR(20)), ',') AS CustKeys,
					STRING_AGG(ISNULL(C1.CustName, C2.CustName), ',') AS CustomerNames,
					STRING_AGG(CAST(ISNULL(ICL.InvoiceKey,ICL.MInvoiceKey) AS VARCHAR(20)), ',') AS Invoicekeys,
					STRING_AGG(ISNULL(IH.InvoiceNo, MIH.MInvoiceNo), ',') WITHIN GROUP(ORDER BY ISNULL(IH.InvoiceNo, MIH.MInvoiceNo)) AS InvoiceNumbers
			FROM InvoiceCredits IC
				INNER JOIN InvoiceCreditLink ICL ON IC.CreditKey = ICL.CreditKey
				LEFT JOIN InvoiceHeader IH ON ICL.InvoiceKey = IH.InvoiceKey
				LEFT JOIN ManualInvoiceHeader MIH ON ICL.MInvoiceKey = MIH.MInvoiceKey
				LEFT JOIN Customer C1 ON IH.CustKey = C1.CustKey
				LEFT JOIN Customer C2 ON MIH.CustomerKey = C2.CustKey
				INNER JOIN [User] U ON IC.CreditAppliedBy = U.UserKey
				INNER JOIN [User] CU ON IC.CreatedUserKey = CU.UserKey
				INNER JOIN [User] UU ON IC.UpdatedUserKey = UU.UserKey
			WHERE CASE WHEN ISNULL(@CreditKey, 0) = 0 THEN 0 ELSE IC.CreditKey END = ISNULL(@CreditKey, 0)
				AND IC.CreditStatus <> 3
			GROUP BY IC.CreditKey,IC.CreditTypeKey,IC.CreditNo,IC.CreditAmount,IC.CreditDate,IC.CreditAppliedBy,
					U.UserName,IC.CreditAppliedDate,IC.CreditStatus,IC.CreatedUserKey,IC.CreatedDate
			ORDER BY IC.CreditKey DESC
			FOR JSON PATH
		);

		/*==================================================================
			5. Set success response
		==================================================================*/

		SELECT @JSONResult as JSONResult

		SET @Status = 1;
		SET @Reason = 'Success';

		/*==================================================================
			6. Commit transaction
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

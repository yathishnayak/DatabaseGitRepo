/*
DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)='{"SalesPersonKey":16}',
	@Status BIT=0,
	@Reason VARCHAR(100)=''
EXec [Delete_SalesPerson_V2] @UserKey,@JSONString,'',@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Delete_SalesPerson_V2]
(
	@UserKey		INT = 488,
	@JSONString		NVARCHAR(MAX) = '',
	@JSONOutput		NVARCHAR(MAX) = '' OUTPUT,
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN	
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	-- Validate input
	IF (@JSONString = '' OR @JSONString IS NULL)
	BEGIN
		SET @Status = 0;
		SET @Reason = 'Parameter not Present';
		RETURN;
	END

	DECLARE @SalesPersonKey INT;

	SELECT @SalesPersonKey = SalesPersonKey
	FROM OPENJSON(@JSONString)
	WITH (
		SalesPersonKey INT '$.SalesPersonKey'
	)

	-- Validate SalesPerson exists
	IF NOT EXISTS (SELECT 1 FROM dbo.SalesPerson WITH (NOLOCK) WHERE SalesPersonKey = @SalesPersonKey)
	BEGIN
		SET @Status = 0;
		SET @Reason = 'No Salesperson found matching this';
		RETURN;
	END

	-- Check Customer links
	IF EXISTS (SELECT 1 FROM dbo.Customer WITH (NOLOCK) WHERE SalesPersonKey = @SalesPersonKey)
	BEGIN
		SET @Status = 0;
		SET @Reason = 'Salesperson linked to Customer. Cannot be deleted';
		RETURN;
	END

	-- Check OrderHeader links
	IF EXISTS (SELECT 1 FROM dbo.OrderHeader WITH (NOLOCK) WHERE SalesPersonKey = @SalesPersonKey)
	BEGIN
		SET @Status = 0;
		SET @Reason = 'Salesperson linked to Order. Cannot be deleted';
		RETURN;
	END

	-- Perform delete with error handling
	BEGIN TRY
		BEGIN TRAN;

		DELETE FROM dbo.SalesPerson 
		WHERE SalesPersonKey = @SalesPersonKey;

		COMMIT;
		SET @Status = 1;
		SET @Reason = 'Salesperson Deleted';

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		SET @Status = 0;
		SET @Reason = ERROR_MESSAGE();
	END CATCH
END
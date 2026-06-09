

CREATE PROCEDURE [dbo].[Update_InvoicePrinted]
@InvoiceKeySTR varchar(2000),
@UserKey	INT,
@Output		BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @STATUSKEY INT = 0

	SET @Output=0;

	select * into #InvoiceKeys from dbo.Fn_SplitParamCol(@InvoiceKeySTR)

	UPDATE dbo.InvoiceHeader
	SET IsPrinted = 1, PrintedDate = GETDATE(), PrintedUserKey = @UserKey
	WHERE StatusKey = 2 and InvoiceKey in (select Value from #InvoiceKeys);
	
	SET @Output=1;
END

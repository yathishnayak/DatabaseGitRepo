/**

DECLARE 
	@UserKey	INT				= 512,
	@JSONString NVARCHAR(MAX)	= '',
	@Status		BIT				= 0,
	@Reason		VARCHAR(100)	= ''
EXEC [GET_ExpenseItemList_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
Select @Status Status, @Reason Reason

**/
CREATE PROCEDURE [dbo].[GET_ExpenseItemList_V2]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT I.ItemKey,IT.ItemTypeKey,I.[Description] AS ItemDescription,I.ItemID,I.UnitCost, I.PriceBasisKey,  I.InvoiceItemDesc, P.PriceBasisID
	FROM dbo.Item I WITH (NOLOCK)
		INNER JOIN dbo.ItemType IT WITH (NOLOCK) ON IT.ItemTypeKey=I.ItemTypeKey
		INNER JOIN [Status]  S WITH (NOLOCK) ON S.StatusKey=I.StatusKey
		INNER JOIN ItemPriceBasis P WITH (NOLOCK) ON I.PriceBasisKey = P.PriceBasisKey
	WHERE S.StatusName='Active' AND IT.ItemType in ( 'Expense', 'Expense + Service')
	ORDER BY I.DESCRIPTION
	FOR JSON PATH;

	IF(@@ROWCOUNT=0)
	BEGIN
		SET @Status=0;
		SET @Reason='No records found';
		RETURN;
	END

	SET @Status=1;
	SET @Reason='Success'

END
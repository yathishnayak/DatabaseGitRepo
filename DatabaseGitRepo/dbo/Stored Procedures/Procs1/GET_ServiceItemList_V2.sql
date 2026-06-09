/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [GET_ServiceItemList_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[GET_ServiceItemList_V2]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '{}',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	
	SET NOCOUNT ON;
	SET FMTONLY OFF
    
	SELECT I.ItemKey,IT.ItemTypeKey,I.[Description] AS ItemDescription,I.ItemID,I.UnitCost, 
	I.PriceBasisKey, I.InvoiceItemDesc, P.PriceBasisID,IC.Name As CategoryName,
	M.Description as MDescription, IT.ItemType
	FROM dbo.Item I WITH (NOLOCK)
		INNER JOIN dbo.ItemType IT WITH (NOLOCK) ON IT.ItemTypeKey=I.ItemTypeKey
		INNER JOIN [Status]  S WITH (NOLOCK) ON S.StatusKey=I.StatusKey
		INNER JOIN ItemPriceBasis P WITH (NOLOCK) ON I.PriceBasisKey = P.PriceBasisKey
		INNER JOIN Item M WITH (NOLOCK) ON M.ItemKey=I.MasterItemKey
		INNER JOIN ItemCateGory IC WITH (NOLOCK) ON IC.CategoryKey=I.CategoryKey
	WHERE S.StatusName='Active' AND IT.ItemType in ('Service','Expense + Service')
	--GROUP BY I.ItemKey,IT.ItemTypeKey,I.[Description],I.ItemID,I.UnitCost, I.PriceBasisKey, I.InvoiceItemDesc,  P.PriceBasisID
	ORDER BY I.[Description]
	FOR JSON PATH;

	SET @Status=1;
	SET @Reason='Success'

END
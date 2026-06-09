

Create PROCEDURE [dbo].[Get_CustomerForDrowdown] 
(
	@MarketLocationKey		int = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	Select
	c.CustKey, CustID, CustName, C.StatusKey, S.StatusName
	FROM dbo.Customer C  with ( NOLOCK) 
		LEFT JOIN [Status] S  with ( NOLOCK) ON S.Statuskey=C.StatusKey
		LEFT join MarketLocation ML WITH (NOLOCK) ON C.MarketLocationKey = ML.MarketLocationKey
	WHERE ISNULL(C.IsActive,0)=1 AND ISNULL(C.IsDelete,0)=0 and
		(isnull(@MarketLocationKey,0) = 0 OR C.MarketLocationKey = @MarketLocationKey)
	ORDER BY CustName
END

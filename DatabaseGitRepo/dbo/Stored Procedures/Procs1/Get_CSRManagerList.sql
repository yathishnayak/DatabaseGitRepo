CREATE PROCEDURE [dbo].[Get_CSRManagerList]
	@MarketLocationKey	INT=0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT C.CsrKey, C.CsrName, C.FirstName, C.LastName
	FROM dbo.CSR C WITH (NOLOCK)
	INNER JOIN [Status] S WITH (NOLOCK) ON S.Statuskey= C.StatusKey 
	WHERE  S.StatusName='Active' and isnull(C.IsManager,0) = 1
	AND (ISNULL(@MarketLocationKey,0)=0 OR C.TerminalLocationKey=@MarketLocationKey)
	ORDER BY CsrName;
END

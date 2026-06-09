CREATE PROCEDURE [dbo].[GET_RouteDocumentCount]
@RouteKey INT= 00
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT DT.DocumentTypeKey, DT.[Description] AS DocType, DT.Shortcode, isnull(DocCount,0) as DocCount
	FROM DocumenType DT
	LEFT JOIN 
		(
		SELECT A.RouteKey, S.DocumentTypeKey,S.[Description] AS DocType, S.Shortcode,COUNT(D.DocumentKey) AS DocCount
		FROM ContainerLegDocuments A 
			INNER JOIN Document D		ON D.DocumentKey=A.DocumentKey
			INNER JOIN DocumenType S	ON S.DocumentTypeKey=D.DocumentType
		WHERE  A.RouteKey= @RouteKey AND D.IsDeleted=0 and s.LinkTo = 'Order'
		GROUP BY A.RouteKey,S.[Description],  S.DocumentTypeKey,  S.Shortcode
		) A on DT.DocumentTypeKey = A.DocumentTypeKey
	where Dt.LinkTo = 'Order'
END
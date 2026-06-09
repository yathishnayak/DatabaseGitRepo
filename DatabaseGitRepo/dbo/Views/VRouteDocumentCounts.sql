


CREATE View [dbo].[VRouteDocumentCounts]
as
SELECT A.routeKey, DT.DocumentTypeKey, DT.[Description] AS DocType, DT.Shortcode, isnull(DocCount,0) as DocCount
	FROM DocumenType DT  WITH (NOLOCK) 
	LEFT JOIN 
		(
		SELECT A.RouteKey, S.DocumentTypeKey,S.[Description] AS DocType, 
				S.Shortcode,COUNT(D.DocumentKey) AS DocCount
		FROM ContainerLegDocuments A  WITH (NOLOCK) 
			INNER JOIN Document D	 WITH (NOLOCK) 	ON D.DocumentKey=A.DocumentKey
			INNER JOIN DocumenType S WITH (NOLOCK) 	ON S.DocumentTypeKey=D.DocumentType
		WHERE  D.IsDeleted=0 and s.LinkTo = 'Order'
		GROUP BY A.RouteKey,S.[Description],  S.DocumentTypeKey,  S.Shortcode
		) A on   DT.DocumentTypeKey = A.DocumentTypeKey
	where Dt.LinkTo = 'Order' and A.RouteKey is not null

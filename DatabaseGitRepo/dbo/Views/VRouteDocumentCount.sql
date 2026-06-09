


CREATE VIEW [dbo].[VRouteDocumentCount]
AS
SELECT DISTINCT A.RouteKey,
	STUFF(( 
			SELECT COALESCE(Shortcode + '(' + CONVERT(VARCHAR,DocCount) + ')' + '; ' ,'') 
			FROM dbo.VRouteDocumentCounts  WITH (NOLOCK) 
			WHERE RouteKey=A.RouteKey
		FOR XML PATH('')), 1, 0, '') AS DocCount
FROM dbo.ContainerLegDocuments  A  WITH (NOLOCK) 

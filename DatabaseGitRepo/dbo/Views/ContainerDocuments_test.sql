CREATE view [dbo].[ContainerDocuments_test]
as
	with    
	ddata as (
		SELECT  OD.OrderDetailKey 
			FROM dbo.Document D 
				INNER JOIN dbo.OrderDetailDocuments ODD ON D.DocumentKey =ODD.DocumentKey 
				inner join dbo.OrderDetail OD on ODD.OrderDetailKey = OD.OrderDetailKey
				inner join dbo.OrderHeader OH on OD.OrderKey = OH.OrderKey
				INNER JOIN dbo.DocumenType DT ON DT.DocumentTypeKey=D.DocumentType
			WHERE D.IsDeleted=0
		UNION ALL
		SELECT r.OrderDetailKey
		FROM dbo.Document D 
				INNER JOIN dbo.ContainerLegDocuments CLD ON D.DocumentKey =CLD.DocumentKey 
				INNER JOIN dbo.DocumenType DT ON DT.DocumentTypeKey=D.DocumentType
				INNER JOIN DBO.Routes R ON CLD.RouteKey = R.RouteKey
				inner join dbo.OrderDetail OD on R.OrderDetailKey = OD.OrderDetailKey
				inner join dbo.OrderHeader OH on OD.OrderKey = OH.OrderKey
				INNER JOIN DBO.Leg L ON R.LegKey = L.LegKey
				INNER JOIN DBO.LegType LT ON L.LegTypeKey = LT.LegtypeKey
			WHERE D.IsDeleted=0
		union all 
		SELECT OD.OrderDetailKey
			FROM dbo.Document D 
				INNER JOIN dbo.OrderheaderDocuments OHD ON D.DocumentKey =OHD.DocumentKey 
				inner join dbo.OrderHeader OH on OHD.OrderKey = OH.OrderKey
				inner join dbo.OrderDetail OD on OH.OrderKey = OD.OrderKey
				INNER JOIN dbo.DocumenType DT ON DT.DocumentTypeKey=D.DocumentType
			WHERE  D.IsDeleted=0
	) 
	select OrderDetailKey , count(1) as DocumentCount 
	from  ddata group by OrderDetailKey
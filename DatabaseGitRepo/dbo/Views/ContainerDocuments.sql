


--select * from containerdocuments
CREATE view [dbo].[ContainerDocuments]
as
	with  FileUploadPath as
	(select 'app_data\Files\' as fpath), 
	ddata as (
		SELECT D.DocumentKey,OriginalFileName, OriginalFileType ,FileSizeinMB,
			DT.[Description] AS DocType,DT.DocumentTypeKey, OD.OrderDetailKey, 'Container' as Levl,
			CONVERT(VARCHAR(50),'')  AS LegID, CONVERT(VARCHAR(50),'') AS  LegTypeID,0 AS LegNo,
			D.CreateDate, DT.LinkTo, DT.StoragePath, OH.OrderNo,
			0 AS ROUTEKEY, OD.OrderKey, D.CreateUserKey as DocumentUserKey,
			convert(varchar,OD.OrderDetailKey) + '_' + OD.ContainerNo + '\' + D.OriginalFileName as DocumentWithPath
			FROM dbo.Document D   WITH (NOLOCK) 
				INNER JOIN dbo.OrderDetailDocuments ODD WITH (NOLOCK)  ON D.DocumentKey =ODD.DocumentKey 
				inner join dbo.OrderDetail OD  WITH (NOLOCK) on ODD.OrderDetailKey = OD.OrderDetailKey
				inner join dbo.OrderHeader OH  WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
				INNER JOIN dbo.DocumenType DT  WITH (NOLOCK) ON DT.DocumentTypeKey=D.DocumentType
			WHERE D.IsDeleted=0
		UNION ALL
		SELECT D.DocumentKey,OriginalFileName, OriginalFileType ,FileSizeinMB,
			DT.[Description] AS DocType,DT.DocumentTypeKey, r.OrderDetailKey, 'Leg' as Levl,
			L.LegID, LT.LegTypeID, R.LegNo,
			D.CreateDate, DT.LinkTo, DT.StoragePath,  OH.OrderNo,
			R.RouteKey, OD.OrderKey, D.CreateUserKey as DocumentUserKey,
			 + convert(varchar,OD.OrderDetailKey) + '_' + OD.ContainerNo + '\Leg\' + D.OriginalFileName as DocumentWithPath
			FROM dbo.Document D  WITH (NOLOCK) 
				INNER JOIN dbo.ContainerLegDocuments CLD  WITH (NOLOCK) ON D.DocumentKey =CLD.DocumentKey 
				INNER JOIN dbo.DocumenType DT  WITH (NOLOCK) ON DT.DocumentTypeKey=D.DocumentType
				INNER JOIN DBO.Routes R  WITH (NOLOCK) ON CLD.RouteKey = R.RouteKey
				inner join dbo.OrderDetail OD  WITH (NOLOCK) on R.OrderDetailKey = OD.OrderDetailKey
				inner join dbo.OrderHeader OH  WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
				INNER JOIN DBO.Leg L  WITH (NOLOCK) ON R.LegKey = L.LegKey
				INNER JOIN DBO.LegType LT  WITH (NOLOCK) ON L.LegTypeKey = LT.LegtypeKey
			WHERE D.IsDeleted=0
		union all 
		SELECT D.DocumentKey,OriginalFileName, OriginalFileType ,FileSizeinMB,
			DT.[Description] AS DocType,DT.DocumentTypeKey,OD.OrderDetailKey, 'Order' as Levl,
			CONVERT(VARCHAR(50),'')  AS LegID, CONVERT(VARCHAR(50),'') AS  LegTypeID,0 AS LegNo,
			D.CreateDate, DT.LinkTo, DT.StoragePath,  OH.OrderNo,
			0 AS ROUTEKEY, OH.OrderKey, D.CreateUserKey as DocumentUserKey,
			 convert(varchar,OH.OrderNo) + '\' + D.OriginalFileName as DocumentWithPath
			FROM dbo.Document D  WITH (NOLOCK) 
				INNER JOIN dbo.OrderheaderDocuments OHD  WITH (NOLOCK) ON D.DocumentKey =OHD.DocumentKey 
				inner join dbo.OrderHeader OH  WITH (NOLOCK) on OHD.OrderKey = OH.OrderKey
				inner join dbo.OrderDetail OD  WITH (NOLOCK) on OH.OrderKey = OD.OrderKey
				INNER JOIN dbo.DocumenType DT  WITH (NOLOCK) ON DT.DocumentTypeKey=D.DocumentType
			WHERE  D.IsDeleted=0
	) 
	select DocumentKey,OriginalFileName, OriginalFileType ,FileSizeinMB,
			DocType, DocumentTypeKey, OrderDetailKey, Levl,
			LegID, LegTypeID, LegNo,
			CreateDate, LinkTo, StoragePath, OrderNo,
			ROUTEKEY, OrderKey, DocumentUserKey,
			FileUploadPath.fpath + DocumentWithPath as DocumentWithPath
	from FileUploadPath, ddata 
	




CREATE view [dbo].[AllDocuments]
as
SELECT distinct D.DocumentKey,d.OriginalFileName, D.CreateDate,
	D.OriginalFileType ,D.FileSizeinMB, DT.LinkTo, Dt.StoragePath,
	DT.[Description] AS DocType,DT.DocumentTypeKey, 
	isnull(isnull(OD.OrderDetailKey,R.OrderDetailKey),0) as OrderDetailKey,
	isnull(OH.OrderNo, '') as OrderNo, isnull(OH.OrderKey,0) as OrderKey,
	isnull(OD.ContainerNo, '' ) as ContainerNo, isnull(R.RouteKey,0) as RouteKey,
	isnull(L.Description,'') as LegID, isnull(L.LegNo,0) as LegNo, isnull(L.LegKey,0) as LegKey,
	ISNULL(DR.DriverID,'') as DriverID, isnull(DR.driverkey,0) as DriverKey
	FROM dbo.Document D  WITH (NOLOCK)
	INNER JOIN dbo.DocumenType DT WITH (NOLOCK) ON DT.DocumentTypeKey=D.DocumentType
		left JOIN dbo.DriverDocuments DD WITH (NOLOCK) ON D.DocumentKey =DD.DocumentKey 
		left join dbo.ContainerDocuments CD WITH (NOLOCK) on D.DocumentKey = Cd.DocumentKey
		left join dbo.OrderheaderDocuments OHD WITH (NOLOCK) on D.DocumentKey = OHD.DocumentKey
		left join dbo.OrderDetailDocuments ODL WITH (NOLOCK) on d.DocumentKey = ODL.DocumentKey
		left join dbo.CommentDocuments Md WITH (NOLOCK) on D.DocumentKey = MD.DocumentKey
		left join dbo.ContainerLegDocuments  CLD WITH (NOLOCK) on D.DocumentKey = CLD.DocumentKey
		left join dbo.SchedulerDocument SD WITH (NOLOCK) on D.DocumentKey = SD.DocumentKey

	LEFT join dbo.Routes R WITH (NOLOCK) on isnull(isnull(CD.ROUTEKEY, CLD.RouteKey), SD.RouteKey) = R.RouteKey
	LEFT join dbo.OrderDetail OD WITH (NOLOCK) on isnull(ODL.OrderDetailKey, R.OrderDetailKey) = OD.OrderDetailKey
	LEFT join dbo.OrderHeader OH WITH (NOLOCK) on isnull(OHD.OrderKey, R.OrderKey) = OH.OrderKey
	LEFT JOIN dbo.Driver DR WITH (NOLOCK) on isnull(DD.DriverKey, R.DriverKey) = DR.DriverKey 
	LEFT join dbo.Leg L WITH (NOLOCK) on R.LegKey = L.LegKey
		
	

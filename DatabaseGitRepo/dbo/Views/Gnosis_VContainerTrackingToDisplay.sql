

CREATE VIEW [dbo].[Gnosis_VContainerTrackingToDisplay] -- SELECT * FROM Gnosis_VContainerTrackingToDisplay
WITH SCHEMABINDING
AS
SELECT			OrderNo, C.CustName, MBL,RR.ContainerNo,RR.OrderDetailKey, TrackingStatus, CreatedDate ,
					CASE WHEN TrackingStatus = 'Pending' then 'Pending from Gnosis'
						 WHEN LEN(LTRIM(RTRIM(RR.ContainerNo))) < 11 then  'Invalid Container No'
						 WHEN		MBL like '%[-]%' OR MBL like '%[)]%' OR MBL like '%[(]%' OR MBL like '%[_]%'
								 OR MBL like '%[&]%' OR MBL like '%[$]%' OR MBL like '%[*]%' OR MBL like '%[%]%'
								 OR MBL like '%[#]%' OR MBL like '%[@]%' OR MBL like '%[!]%' OR MBL like '%[~]%'
								 OR MBL like '%[`]%' OR MBL like '%[:]%' OR MBL like '%[;]%' OR MBL like '%["]%' 
								 OR MBL like '%[,]%' OR MBL like '%[.]%' OR MBL like '%[<]%' OR MBL like '%[?]%'
								 OR MBL like '%[{]%' OR MBL like '%[}]%' OR MBL like '%[[]%' OR MBL like '%[]]%'
								 OR MBL like '%[|]%' OR MBL like '%[\]%' OR MBL like '%[/]%' OR MBL like '%[?]%'
								THEN 'Invalid MBL no'
						 WHEN	MBL = 'JCT' THEN 'MBL Update Pending'
						 ELSE  'Rejected by Gnosis'
						 END as Remarks
	FROM			(SELECT			SL, MBL,ContainerNo, TrackingStatus, OrderDetailKey,CreatedDate 
					FROM			(SELECT			ROW_NUMBER() OVER (PARTITION BY MBL,ContainerNo ORDER BY CreatedDate DESC )SL, MBL,ContainerNo, TrackingStatus, OrderDetailKey,CreatedDate
									FROM			DBO.Gnosis_TrackingContainerRequestResponseDetail WITH (NOLOCK)) A
					WHERE			Sl  = 1
					UNION ALL
					SELECT			SL, MBL,ContainerNo, TrackingStatus, OrderDetailKey,CreatedDate 
					FROm			(SELECT			ROW_NUMBER() OVER (PARTITION BY MBL,ContainerNo ORDER BY CreatedDate DESC )SL, MBL,ContainerNo, 'Not Processed' TrackingStatus, OrderDetailKey,CreatedDate
					FROM			DBO.Gnosis_MBLContainer_NotProcessed WITH (NOLOCK)) A
					WHERE			Sl  = 1
					UNION ALL
					SELECT			0 SL, BillOfLading MBL,ContainerNo, '' TrackingStatus, OrderDetailKey,OD.CreateDate
					FROm			DBO.OrderDetail  OD WITH (NOLOCK)
					INNER JOIN		DBO.OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
					WHERE			BillOfLading = 'JCT' ) RR
	INNER JOIN		DBO.OrderDetail  OD WITH (NOLOCK) ON RR.OrderDetailKey = OD.OrderDetailKey
	INNER JOIN		DBO.OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
	INNER JOIN		DBO.Customer C WITH (NOLOCK) ON OH.CustKey = C.CustKey
	WHERE			TrackingStatus IN ('Failed','Pending','Not Processed')

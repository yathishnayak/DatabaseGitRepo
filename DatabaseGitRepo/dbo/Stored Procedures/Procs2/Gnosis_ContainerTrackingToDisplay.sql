-- DROP PROCEDURE Gnosis_ContainerTracking
/*
DECLARE @Userkey INT, @JsonString NVARCHAR(MAX), @Status BIT , @Reason VARCHAR(1000)
EXEC Gnosis_ContainerTrackingToDisplay @Userkey =  714, @JsonString =  ''  
SELECT @Status, @Reason
*/

CREATE PROCEDURE [dbo].[Gnosis_ContainerTrackingToDisplay]
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT
AS

BEGIN

-- 4658
	SET @Status=1
	SET @Reason='Success'
	/*
	SELECt			*
	INTO			#ContainerData
	FROm			(SELECT			ROW_NUMBER() OVER (PARTITION BY MBL,ContainerNo ORDER BY CreatedDate DESC )SL, MBL,ContainerNo, TrackingStatus, OrderDetailKey,CreatedDate
					FROM			Gnosis_TrackingContainerRequestResponseDetail WITH (NOLOCK)) A
	WHERE			Sl  = 1

	--SELECT * FROM #ContainerData WHERE			TrackingStatus IN ('Failed','Pending')

	SELECt			*
	INTO			#ContainerDataNotProcessed
	FROm			(SELECT			ROW_NUMBER() OVER (PARTITION BY MBL,ContainerNo ORDER BY CreatedDate DESC )SL, MBL,ContainerNo, 'Not Processed' TrackingStatus, OrderDetailKey,CreatedDate
					FROM			Gnosis_MBLContainer_NotProcessed WITH (NOLOCK)) A
	WHERE			Sl  = 1

	-- SELECT * FROM #ContainerDataNotProcessed

	SELECT			OrderNo, C.CustName, MBL,RR.ContainerNo,RR.OrderDetailKey, TrackingStatus, CreatedDate ,
					CASE WHEN TrackingStatus = 'Pending' then 'Pending from Gnosis'
						 WHEN len(ltrim(rtrim(RR.ContainerNo))) < 11 then  'Invalid Container No'
						 WHEN		MBL like '%[-]%' OR MBL like '%[)]%' OR MBL like '%[(]%' OR MBL like '%[_]%'
								 OR MBL like '%[&]%' OR MBL like '%[$]%' OR MBL like '%[*]%' OR MBL like '%[%]%'
								 OR MBL like '%[#]%' OR MBL like '%[@]%' OR MBL like '%[!]%' OR MBL like '%[~]%'
								 OR MBL like '%[`]%' OR MBL like '%[:]%' OR MBL like '%[;]%' OR MBL like '%["]%' 
								 OR MBL like '%[,]%' OR MBL like '%[.]%' OR MBL like '%[<]%' OR MBL like '%[?]%'
								 OR MBL like '%[{]%' OR MBL like '%[}]%' OR MBL like '%[[]%' OR MBL like '%[]]%'
								 OR MBL like '%[|]%' OR MBL like '%[\]%' OR MBL like '%[/]%' OR MBL like '%[?]%'
								THEN 'Invalid MBL no'
						 ELSE  'Rejected by Gnosis'
						 END as Remarks
	FROM			(SELECT SL, MBL,ContainerNo, TrackingStatus, OrderDetailKey,CreatedDate FROM #ContainerData
					UNION ALL
					SELECT SL, MBL,ContainerNo, TrackingStatus, OrderDetailKey,CreatedDate FROM #ContainerDataNotProcessed) RR
	INNER JOIN		OrderDetail  OD WITH (NOLOCK) ON RR.OrderDetailKey = OD.OrderDetailKey
	INNER JOIN		OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
	INNER JOIN		Customer C WITH (NOLOCK) ON OH.CustKey = C.CustKey
	WHERE			TrackingStatus IN ('Failed','Pending','Not Processed')
	FOR JSON PATH
	*/

	SELECT * FROM Gnosis_VContainerTrackingToDisplay FOR JSON PATH
END
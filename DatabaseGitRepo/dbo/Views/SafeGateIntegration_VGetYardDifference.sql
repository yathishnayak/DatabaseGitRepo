







CREATE VIEW [dbo].[SafeGateIntegration_VGetYardDifference] -- SELECT * FROM SafeGateIntegration_VGetYardDifference

AS

WITH FilterOrderDetail AS (	
	SELECT		OD.*
	FROM		OrderDetail OD
	INNER JOIN	(SELECT  ContainerNo, COUNT(*) CNT FROM OrderDetail
				GROUP BY ContainerNo
				HAVING COUNT(*) = 1) OD1 ON OD.ContainerNo = OD1.ContainerNo )

SELECT		Sl, ActivityId,YardName,ContainerNo,ContainerDesc,Effect,CreatedDate,TMSYardName,Remarks,PickupDateFrom,PickupDateTo,DeliveryDateFrom,DeliveryDateTo
			,ScheduledArrival,ScheduledDeparture,ActualArrival,ActualDeparture,RouteKey,SGSourceAddrKey, TMSSourceAddrKey,SGDestinationAddrKey,TMSDestinationAddrKey,LegID
			,OrderDetailKey,PrevLegRouteKey,TMSPrevDestinationAddrKey,TMSPrevLegID,TMSPrevYardName,NextLegRouteKey,TMSNextSourceAddrKey,TMSNextLegID,TMSNextYardName
			,CASE WHEN  TMSPrevDestinationAddrKey IS NOT NULL AND TMSPrevDestinationAddrKey <> SGSourceAddrKey THEN 1 ELSE 0 END AS UpdatePrevLegRoute
			,CASE WHEN  TMSNextSourceAddrKey IS NOT NULL AND TMSNextSourceAddrKey <> SGDestinationAddrKey THEN 1 ELSE 0 END AS UpdateNextLegRoute
FROM		(SELECT			ROW_NUMBER() OVER (PARTITION BY CD.ContainerNo ORDER BY CD.ContainerNo, CD.createdDate DESC ) SL, CD.ActivityID,CD.YardName,CD.ContainerNo
							,CD.ContainerDesc,CD.Effect,CD.CreatedDate
							,CASE WHEN Effect = 1 THEN YD.ShortName ELSE YS.ShortName  END AS TMSYardName, '' AS Remarks
							,PickupDateFrom, PickupDateTo, DeliveryDateFrom, DeliveryDateTo 
							,ScheduledArrival, ScheduledDeparture,ActualArrival, ActualDeparture, RT.RouteKey
							, CASE WHEN Effect = -1 THEN  YSC.AddrKey ELSE '' END AS SGSourceAddrKey
							, CASE WHEN Effect = -1 THEN  RT.SourceAddrKey ELSE '' END AS TMSSourceAddrKey
							, CASE WHEN Effect = 1 THEN  YDC.AddrKey ELSE '' END AS SGDestinationAddrKey
							, CASE WHEN Effect = 1 THEN  RT.DestinationAddrKey ELSE '' END AS TMSDestinationAddrKey, L.LegID 	, OD.OrderDetailKey				
							, CASE WHEN Effect = 1 THEN NULL ELSE RL1.RouteKey END PrevLegRouteKey
							, CASE WHEN Effect = 1 THEN NULL ELSE TMSPrevDestinationAddrKey END TMSPrevDestinationAddrKey,TMSPrevLegID, PYSA.ShortName AS TMSPrevYardName
							, CASE WHEN Effect = -1 THEN NULL ELSE RL.RouteKey END NextLegRouteKey
							, CASE WHEN Effect = -1 THEN NULL ELSE TMSNextSourceAddrKey END TMSNextSourceAddrKey,TMSNextLegID, NYSA.ShortName AS TMSNextYardName
			FROm			(SELECT * FROM SafeGateIntegration_ContainerDetails ) CD
			INNER JOIN		SafegateIntegration_SafegateTMSYardNameMapping YM ON CD.YardName = YM.SafeGateYardName
			INNER JOIN		FilterOrderDetail OD ON CD.ContainerNo = OD.ContainerNo
			INNER JOIN		Routes RT ON OD.OrderDetailKey = RT.OrderDetailKey
			INNER JOIN		Leg L On RT.LegKey = L.LegKey 
			LEFT JOIN		Yard YD ON RT.DestinationAddrKey = YD.AddrKey  AND Effect = 1  AND YM.TMSYardID <> YD.YardID  
			LEFT JOIN		Yard YS ON RT.SourceAddrKey = YS.AddrKey   AND Effect = -1   AND YM.TMSYardID <> YS.YardID 
			LEFT JOIN		YARD YDC ON YM.TMSYardID = YDC.YardID   AND Effect = 1  
			LEFT JOIN		Yard YSC ON YM.TMSYardID = YSC.YardID    AND Effect = -1 
			LEFT JOIN		(SELECT		RouteKey, L.LegID, RT.LegNo,OrderDetailKey,SourceAddrKey TMSNextSourceAddrKey, L.LegID AS TMSNextLegID 
							FROm Routes RT
							INNER JOIN	Leg L On RT.LegKey = L.LegKey
							WHERE		L.FromLocation = 'Yard' AND L.ToLocation <> 'Yard') RL ON OD.OrderDetailKey = RL.OrderDetailKey AND RT.LegNo+1 = RL.LegNo
			LEFT JOIN		(SELECT		RouteKey, L.LegID, RT.LegNo,OrderDetailKey, DestinationAddrKey TMSPrevDestinationAddrKey, L.LegID AS TMSPrevLegID  
							FROm Routes RT
							INNER JOIN	Leg L On RT.LegKey = L.LegKey
							WHERE		L.ToLocation = 'Yard' AND L.FromLocation <> 'Yard') RL1 ON OD.OrderDetailKey = RL1.OrderDetailKey AND RT.LegNo = RL1.LegNo+1
			LEFT JOIN		YARD NYSA ON RL.TMSNextSourceAddrKey = NYSA.AddrKey   AND Effect = 1  
			LEFT JOIN		YARD PYSA ON RL1.TMSPrevDestinationAddrKey = PYSA.AddrKey   AND Effect = -1  
			WHERE			1 = 1  --  AND RT.RouteKey = 502813   AND ActivityId = 985643 --AND TMSYardName IS NOT NULL --  AND OD.ContainerNo = 'GCXU2115927'  
							AND  ((1 = CASE WHEN EFFECT = 1 AND L.ToLocation = 'YARD' AND (CD.CreatedDate BETWEEN Dateadd(hour,-1,DeliveryDateFrom) AND Dateadd(hour,2,DeliveryDateTo))  THEN 1 ELSE 0 END)				
							OR (1 = CASE WHEN EFFECT = -1 AND L.FromLocation = 'YARD' AND (CD.CreatedDate BETWEEN Dateadd(hour,-1,PickupDateFrom) AND Dateadd(hour,2,PickupDateTo))  THEN 1 ELSE 0 END))
							AND ISNULL(CASE WHEN Effect = 1 THEN YD.ShortName ELSE YS.ShortName  END,'') <> '' AND CD.CreatedDate > GETDATE()-100 
							) A
-- WHERE		RouteKey NOT IN (SELECT DISTINCT RouteKey FROM Routes WHERE SFGYardDiffLogKey IS NOT NULL )  --  AND OrderDetailKey = 149376
			--ORDER By		RT.RouteKey  DESC

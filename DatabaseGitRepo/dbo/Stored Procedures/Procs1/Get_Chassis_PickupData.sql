


CREATE PROC [dbo].[Get_Chassis_PickupData]
(
    @ChassisNo VARCHAR(50) = 'JCTD100091' ,
    @RangeType VARCHAR(50)  = 'All'   -- e.g. 'Today', 'ThisWeek', 'Last2Weeks', 'Last30Days', 'LastMonth', 'ThisMonth', 'Last60Days', 'ThisYear', 'Last6Months'
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT		DISTINCT OD.OrderDetailKey,OD.ContainerNo,OH.OrderKey,OH.OrderNo,R.ChassisNo,
				OS.[Description] AS ContainerStatus,
				C.CustName,
				ODS.ActualPickupDate
    FROM		Routes R WITH (NOLOCK)
    INNER JOIN	OrderDetail OD WITH (NOLOCK) ON OD.OrderDetailKey = R.OrderDetailKey
    INNER JOIN	OrderHeader OH WITH (NOLOCK) ON OH.OrderKey = OD.OrderKey
    LEFT JOIN	OrderDetailStatus OS WITH (NOLOCK) ON OS.Status = OD.Status
    LEFT JOIN	OrderDetailStops ODS WITH (NOLOCK) ON ODS.OrderDetailKey = OD.OrderDetailKey
    LEFT JOIN	Customer C WITH (NOLOCK) ON C.CustKey = OH.CustKey
    WHERE		R.ChassisNo = @ChassisNo
				AND ODS.ActualPickupDate IS NOT NULL
				AND ( @RangeType = 'All'    
				 OR	(@RangeType = 'Today'         AND CONVERT(DATE, ODS.ActualPickupDate) = CONVERT(DATE, GETDATE()))
				 OR (@RangeType = 'ThisWeek'      AND DATEPART(WEEK, ODS.ActualPickupDate) = DATEPART(WEEK, GETDATE()) 
												  AND YEAR(ODS.ActualPickupDate) = YEAR(GETDATE()))
				 OR (@RangeType = 'Last2Weeks'    AND ODS.ActualPickupDate >= DATEADD(DAY, -14, GETDATE()))
				 OR (@RangeType = 'Last30Days'    AND ODS.ActualPickupDate >= DATEADD(DAY, -30, GETDATE()))
				 OR (@RangeType = 'LastMonth'     AND MONTH(ODS.ActualPickupDate) = MONTH(DATEADD(MONTH, -1, GETDATE())) 
												  AND YEAR(ODS.ActualPickupDate) = YEAR(DATEADD(MONTH, -1, GETDATE())))
				 OR (@RangeType = 'ThisMonth'     AND MONTH(ODS.ActualPickupDate) = MONTH(GETDATE()) 
												  AND YEAR(ODS.ActualPickupDate) = YEAR(GETDATE()))
				 OR (@RangeType = 'Last60Days'    AND ODS.ActualPickupDate >= DATEADD(DAY, -60, GETDATE()))
				 OR (@RangeType = 'ThisYear'      AND YEAR(ODS.ActualPickupDate) = YEAR(GETDATE()))
				 OR (@RangeType = 'LastYear'      AND YEAR(ODS.ActualPickupDate) = YEAR(GETDATE())-1)
				 OR (@RangeType = 'Last6Months'   AND ODS.ActualPickupDate >= DATEADD(MONTH, -6, GETDATE()))
				)
    ORDER BY	ODS.ActualPickupDate DESC;
END;

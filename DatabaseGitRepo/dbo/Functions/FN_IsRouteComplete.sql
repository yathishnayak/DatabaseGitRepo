CREATE FUNCTION [dbo].[FN_IsRouteComplete]
(
    @RouteKey INT
)
RETURNS BIT
AS
BEGIN
	DECLARE @IsRouteComplete BIT = 0
    SELECT @IsRouteComplete = CASE WHEN ISNULL(RT.driverKey ,0) > 0 
	-- CHASSIS IS NOT COMPULSORY AS PER TICKET TRACKER ID 79
	--AND ISNULL(RT.ChassisNo,'') <> '' 
	--AND ISNULL(RT.chassistype,'') <> '' 
		AND		ISNULL(RT.ActualDeparture,'1970-01-01 00:00:00.000') <>  '1970-01-01 00:00:00.000' AND
				ISNULL(RT.ActualArrival,'1970-01-01 00:00:00.000') <> '1970-01-01 00:00:00.000'
			THEN 1 ELSE 0 END 
    FROM dbo.Routes RT
    WHERE RT.RouteKey = @RouteKey and ISNULL(RT.Status,1) <> 5
	/*
	if(@IsRouteComplete = 1)
	begin
		declare @cnt int = 0
		SELECT @cnt = count(1)
		FROM Routes R
		LEFT JOIN Leg L ON R.LegKey = L.LegKey
		where L.ToLocation = 'PORT'and  orderdetailkey in 
		(
			select distinct OrderDetailKey 
			from Routes
			where routekey = @RouteKey
		)and R.LegNo = 
		(
			select max(LegNo)
			from routes T
			where OrderDetailKey = R.OrderDetailKey
		)
		if(@cnt = 0)
		begin
			set @IsRouteComplete = 0
		end
		ELSE
		begin
			set @IsRouteComplete = 1
		end
	end
   */
    -- Return the result of the function
    RETURN @IsRouteComplete;
END
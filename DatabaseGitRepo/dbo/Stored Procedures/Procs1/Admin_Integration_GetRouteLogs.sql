/*
DECLARE @UserKey INT = 714, @JSONString NVARCHAR(MAX) = '', @Status BIT, @ExtMessage VARCHAR(1000)
SET @JSONString = '{"RouteKey":766940}'
EXEC Admin_Integration_GetRouteLogs @UserKey = @UserKey, @JSONString = @JSONString, @Status = @Status OUTPUT, @ExtMessage = @ExtMessage OUTPUT
*/
CREATE PROC [dbo].[Admin_Integration_GetRouteLogs]
(
    @UserKey INT,
    @JSONString NVARCHAR(MAX),
    @Status BIT OUTPUT,
    @ExtMessage VARCHAR(1000) OUTPUT,
	@IntMessage VARCHAR = '',
	@Result1 VARCHAR = '',
	@Result2 VARCHAR = '',
	@Result3 VARCHAR = '',
	@IsDebug BIT = 0
) AS 
BEGIN
    SET @Status = 1
	SET @ExtMessage = ''

    DECLARE 
        @RouteKey INT = 0,
        @JsonResult NVARCHAR(MAX)

    SET @RouteKey = JSON_VALUE(@JSONString, '$.RouteKey')

    IF(ISNULL(@RouteKey, 0) = 0)
    BEGIN
        SET @Status = 0
        SET @ExtMessage = 'Route Key is NULL or 0'
        SET @JsonResult = ''
        RETURN
    END

    SELECT *
    INTO #RouteEventChanges
    FROM vw_RouteEventChanges
    WHERE RouteKey = @RouteKey 
	OPTION (RECOMPILE);


    SET @JsonResult = (
        SELECT 
            'ActualArrival' = (
                SELECT 
                    EventDate,LastUpdateDate 
                FROM 
                    #RouteEventChanges ECa
                WHERE 
                    EventType = 'Actual Arrival' AND ECa.RouteKey = @RouteKey
                FOR JSON PATH, INCLUDE_NULL_VALUES
            ),
            'ActualDeparture' = (
                SELECT 
                    EventDate,LastUpdateDate 
                FROM 
                    #RouteEventChanges ECd
                WHERE 
                    EventType = 'Actual Departure' AND ECd.RouteKey = @RouteKey
                FOR JSON PATH, INCLUDE_NULL_VALUES
            )
        FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
    )
    
    SELECT @JsonResult AS JsonResult

    --SELECT '{"ActualArrival":[{"EventDate":"2025-05-23T08:20:00","LastUpdateDate":"2025-06-03T08:20:17.850"},{"EventDate":"2025-05-27T08:20:00","LastUpdateDate":"2025-06-03T08:24:05.367"}],"ActualDeparture":[{"EventDate":"2025-05-23T08:20:00","LastUpdateDate":"2025-06-03T08:20:17.850"}]}]' AS JsonResult

    DROP TABLE IF EXISTS #RouteEventChanges

END
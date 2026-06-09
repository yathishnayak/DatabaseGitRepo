/*
DECLARE @UserKey INT = 714 ,@JSONString NVARCHAR(MAX),@Status BIT,@Reason VARCHAR(10)
SET @JSONString = '{"RouteKey":"729782"}'
EXEC Integration_GetRouteLogs @UserKey,@JSONString,@Status OUTPUT, @Reason OUTPUT
SELECT @Status, @Reason
*/
CREATE PROC [dbo].[Integration_GetRouteLogs]
(
    @UserKey INT,
    @JSONString NVARCHAR(MAX),
    @Status BIT OUTPUT,
    @Reason VARCHAR(10) OUTPUT
) AS 
BEGIN
    SET @Status = 1
	SET @Reason = ''

    DECLARE 
        @RouteKey INT,
        @JsonResult NVARCHAR(MAX)

    SET @RouteKey = JSON_VALUE(@JSONString, '$.RouteKey')

    IF(ISNULL(@RouteKey, 0) = 0)
    BEGIN
        SET @Status = 0
        SET @Reason = 'Route Key is NULL or 0'
        SET @JsonResult = ''
        RETURN
    END

    SELECT *
    INTO #RouteEventChanges
    FROM JCBDB_Live.dbo.vw_RouteEventChanges
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

    DROP TABLE IF EXISTS #RouteEventChanges

END

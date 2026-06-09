CREATE FUNCTION [dbo].[fn_getIsoWeekStartEndDates]
(
    @dt DATETIME
)
RETURNS @rtnTable TABLE
(
    Week_Start_Date DATETIME NOT NULL,
    Week_End_Date   DATETIME NOT NULL
)
AS
BEGIN
    IF (@dt IS NULL)
        RETURN;

    DECLARE @weekStart DATE;
    DECLARE @weekEnd   DATETIME;

    /*
        1900-01-01 = Monday
        ISO week starts on Monday
    */
    SET @weekStart =
        DATEADD(
            DAY,
            - (DATEDIFF(DAY, '19000101', CAST(@dt AS DATE)) % 7),
            CAST(@dt AS DATE)
        );

    -- Convert to DATETIME before using seconds
    SET @weekEnd =
        DATEADD(
            SECOND, -1,
            DATEADD(DAY, 7, CAST(@weekStart AS DATETIME))
        );

    INSERT INTO @rtnTable (Week_Start_Date, Week_End_Date)
    VALUES (CAST(@weekStart AS DATETIME), @weekEnd);

    RETURN;
END

CREATE FUNCTION [dbo].[GetDateRange] (@FilterDate NVARCHAR(50))
RETURNS @DateRange TABLE (
    FromDate DATETIME,
    ToDate DATETIME
)
AS
BEGIN
    DECLARE @FromDate DATETIME;
    DECLARE @ToDate DATETIME;

    -- Determine the date range based on the DispatchDate value
    IF (@FilterDate = 'Today')
    BEGIN
        SET @FromDate = CAST(GETDATE() AS DATE); -- Start of today
        SET @ToDate = DATEADD(DAY, 1, CAST(GETDATE() AS DATE)); -- Start of tomorrow
    END
    ELSE IF (@FilterDate = 'Tomorrow')
    BEGIN
        SET @FromDate = DATEADD(DAY, 1, CAST(GETDATE() AS DATE)); -- Start of tomorrow
        SET @ToDate = DATEADD(DAY, 2, CAST(GETDATE() AS DATE)); -- Start of the day after tomorrow
    END
    ELSE IF (@FilterDate = 'This week')
    BEGIN
        SET @FromDate = DATEADD(DAY, -DATEPART(ISO_WEEK, GETDATE()), CAST(GETDATE() AS DATE)); -- Start of this week
        SET @ToDate = DATEADD(DAY, 7 - DATEPART(ISO_WEEK, GETDATE()), CAST(GETDATE() AS DATE)); -- Start of next week
    END
    ELSE IF (@FilterDate = 'Next week')
    BEGIN
        SET @FromDate = DATEADD(DAY, 7 - DATEPART(ISO_WEEK, GETDATE()), CAST(GETDATE() AS DATE)); -- Start of next week
        SET @ToDate = DATEADD(DAY, 14 - DATEPART(ISO_WEEK, GETDATE()), CAST(GETDATE() AS DATE)); -- Start of the week after next
    END
    ELSE IF (@FilterDate = 'This month')
    BEGIN
        SET @FromDate = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1); -- Start of this month
        SET @ToDate = DATEADD(MONTH, 1, @FromDate); -- Start of next month
    END
    ELSE IF (@FilterDate = 'Next month')
    BEGIN
        SET @FromDate = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()) + 1, 1); -- Start of next month
        SET @ToDate = DATEADD(MONTH, 1, @FromDate); -- Start of the month after next
    END

    -- Insert the result into the table
    INSERT INTO @DateRange (FromDate, ToDate)
    VALUES (@FromDate, @ToDate);

    RETURN;
END;

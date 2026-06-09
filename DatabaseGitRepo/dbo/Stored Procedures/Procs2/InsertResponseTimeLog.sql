
/*
EXEC dbo.InsertResponseTimeLog
    @Method = 'POST',
    @Path = '/Scheduler/GetSchedulerList',
    @StatusCode = 200,
    @ResponseTime = 350;
*/
CREATE PROCEDURE [dbo].[InsertResponseTimeLog]
    @Method NVARCHAR(10),
    @Path NVARCHAR(2000),
    @StatusCode INT,
    @ResponseTime DECIMAL(10,3)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.ResponseTimeLogs
    (
        Method,
        Path,
        StatusCode,
        ResponseTime,
        LoggedAt
    )
    VALUES
    (
        @Method,
        @Path,
        @StatusCode,
        @ResponseTime,
        SYSUTCDATETIME()
    );
END

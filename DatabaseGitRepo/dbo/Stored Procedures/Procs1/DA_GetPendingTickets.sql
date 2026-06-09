CREATE PROC [dbo].[DA_GetPendingTickets]  -- EXEC [DA_GetPendingTickets]
AS BEGIN
	SET FMTONLY OFF
	SET NOCOUNT ON

	SELECT 
		TicketKey,IncidentId,TicketStatus
	FROM DA_DriverTicket
	WHERE ISNULL(IsResolved,0) = 0 AND IncidentId IS NOT NULL
	FOR JSON PATH
END

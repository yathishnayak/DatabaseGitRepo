CREATE PROC [dbo].[DA_GetTickets_IncidentNULL]	-- EXEC [DA_GetTickets_IncidentNULL]
AS BEGIN

	SELECT
		TicketKey,TicketTitle
	FROM 
		DA_DriverTicket
	WHERE
			IncidentId IS NULL 
		OR
			IncidentNo IS NULL
	FOR JSON PATH
END

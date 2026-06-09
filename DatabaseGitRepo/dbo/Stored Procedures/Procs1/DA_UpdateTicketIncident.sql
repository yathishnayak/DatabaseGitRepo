/*

select * from DriverTicket

*/
CREATE PROC [dbo].[DA_UpdateTicketIncident](
	@TicketKey INT,
	@IncidentNo INT,
	@IncidentId INT
) AS BEGIN
	SET FMTONLY OFF
	SET NOCOUNT ON

	DECLARE @Status BIT = 0

	BEGIN TRY
		BEGIN TRANSACTION
			UPDATE DA_DriverTicket
			SET 
				IncidentNo = @IncidentNo,
				IncidentId = @IncidentId
			WHERE TicketKey = @TicketKey 
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH

END

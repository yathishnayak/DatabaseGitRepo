/*
--UPDATE DA_DriverTicket
--SET TicketStatus = 'OPEN',IsResolved = 0
--

SELECT * FROM DA_DriverTicket

DECLARE @JsonStr NVARCHAR(MAX) = '[{"TicketKey":36,"IncidentId":155287470,"TicketStatus":"Resolved"},{"TicketKey":37,"IncidentId":155287610,"TicketStatus":"Resolved"},{"TicketKey":42,"IncidentId":155289348,"TicketStatus":"Resolved"},{"TicketKey":43,"IncidentId":155289365,"TicketStatus":"Resolved"},{"TicketKey":44,"IncidentId":155289826,"TicketStatus":"Resolved"},{"TicketKey":45,"IncidentId":155289827,"TicketStatus":"Resolved"},{"TicketKey":46,"IncidentId":155289982,"TicketStatus":"Resolved"},{"TicketKey":47,"IncidentId":155290020,"TicketStatus":"New"},{"TicketKey":48,"IncidentId":155543137,"TicketStatus":"New"}]'
EXEC [DA_UpdateTicketStatus] @JsonStr

SELECT * FROM DA_DriverTicket
WHERE IsResolved = 1

SELECT * FROM DA_DriverTicket
*/
CREATE PROC [dbo].[DA_UpdateTicketStatus](
	@JSONString NVARCHAR(MAX)
) AS 
BEGIN
	SET FMTONLY OFF
	SET NOCOUNT ON
	
	CREATE TABLE #temp(
		TicketKey INT,
		IncidentId INT,
		TicketStatus VARCHAR(20)
	)

	BEGIN TRY
		BEGIN TRANSACTION

			INSERT INTO #temp(TicketKey,IncidentId,TicketStatus)
			SELECT 
				TicketKey,
				IncidentId,
				CASE TicketStatus 
					WHEN 'resolved' then 'Resolved' 
					WHEN 'new' THEN 'Open' 
					ELSE 'In Progress'
				END
			FROM OPENJSON(@JSONString,'$')
			WITH (
				TicketKey INT '$.TicketKey',
				IncidentId INT '$.IncidentId',
				TicketStatus VARCHAR(20) '$.TicketStatus'
			)



			UPDATE DT
			SET DT.TicketStatus = T.TicketStatus,
				DT.TicketStatusUpdatedDate = GETDATE()
			FROM
				DA_DriverTicket DT INNER JOIN #temp T
					ON DT.TicketKey = T.TicketKey
			WHERE 
				DT.TicketStatus <> T.TicketStatus

			select * from #temp


			UPDATE DA_DriverTicket
			SET IsResolved = 1
			WHERE TicketStatus = 'Resolved'

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT ERROR_MESSAGE()

	END CATCH

	DROP TABLE IF EXISTS #temp
END

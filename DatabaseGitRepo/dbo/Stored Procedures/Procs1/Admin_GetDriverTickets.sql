/*
	SELECT GETDATE()

	DECLARE 
		@UserKey INT  = 954,
		@JSONString NVARCHAR(MAX) = '{"DriverKey":0,"FromDate":"2025-04-25 03:57:41.230","ToDate":"2025-04-29 03:57:41.230"}',
		@Status BIT = 0,
		@IntError VARCHAR(1000) = '',
		@Reason VARCHAR(1000) = '',
		@IsDebug BIT = 0,
		@FirebaseID	VARCHAR(500) = '',
		@IsLogout BIT = 0

	EXEC Admin_GetDriverTickets @UserKey,@JSONString,@Status OUTPUT,@IntError OUTPUT,@Reason OUTPUT,@IsDebug,@FirebaseID,@IsLogout OUTPUT

	SELECT @IntError,@Reason,@Status,@IsLogout

	SELECT * FROM DA_DriverTicket WHERE DriverKey = 1234

*/
CREATE PROC [dbo].[Admin_GetDriverTickets](
	@UserKey INT,
	@JSONString NVARCHAR(MAX),
	@Status BIT = 0 OUTPUT,
	@IntError VARCHAR(1000) = '' OUTPUT,
	@Reason VARCHAR(1000) = '' OUTPUT,
	@IsDebug BIT = 0,
	@FirebaseID		VARCHAR(500) = '',
	@IsLogout		BIT = 0 OUTPUT
) AS BEGIN
	
	SET FMTONLY OFF
	SET NOCOUNT ON

	DECLARE 
		@DriverKey INT,
		@FromDate DATETIME,
		@ToDate DATETIME,
		@ImagePath VARCHAR(100)


	BEGIN TRY
		--BEGIN TRANSACTION
			

			SELECT @ImagePath = ConfigValue1 FROM DA_ConfigValues WHERE ConfigKey = 4  -- image path 

			SELECT 
				@DriverKey = j_DriverKey
			FROM OPENJSON(@JSONString)
			WITH(
				j_DriverKey INT '$.DriverKey'
			)

			SELECT 
				@DriverKey = j_DriverKey,
				@FromDate = j_From,
				@ToDate = j_To
			FROM OPENJSON(@JSONString)
			WITH(
				j_DriverKey INT '$.DriverKey',
				j_From DATETIME '$.FromDate',
				j_To DATETIME '$.ToDate'
			)

			SET @DriverKey = ISNULL(@DriverKey,0)

			
			SELECT		DT.TicketKey,
						DT.TicketTitle,
						DT.TicketDescription,
						DT.IncidentNo,
						DT.CreatedDate,
						D.DriverID,
						D.FirstName + ' ' + ISNULL(D.LastName,'') AS DriverName,
						@ImagePath + 'Ticket_' + CAST(DT.TicketKey AS VARCHAR) + '.pdf' AS ImagePath,
						DT.TicketStatus AS TicketStatus,
						D.DriverKey,
						DT.TicketStatusUpdatedDate AS UpdatedDate
			INTO		#DriverData
			FROM		DA_DriverTicket DT
			INNER JOIN	Driver D ON DT.DriverKey = D.DriverKey
			WHERE		(DT.DriverKey = @DriverKey OR @DriverKey = 0 ) AND (DT.CreatedDate >= @FromDate AND DT.CreatedDate < DATEADD(DAY,1,@ToDate))
						 
			
			DECLARE @JSON NVARCHAR(MAX)	
			SET @JSON = (SELECT		
								DriverTickets = (SELECT * FROM #DriverData FOR JSON PATH),
								DriverDetails = (SELECT  DISTINCT DriverKey, DriverID + ' - ' + DriverName AS DriverName FROM #DriverData FOR JSON PATH)
								FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
							) 

			SELECT @JSON AS JsonResult

			SET @Status = 1
			SET @IntError = ''
			SET @Reason = ''

		--COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		
		--ROLLBACK TRANSACTION

		SET @Status = 0
		SET @IntError = ERROR_MESSAGE()
		SET @Reason = 'DB Error'

		SELECT ''

	END CATCH

END

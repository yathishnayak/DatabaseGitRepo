/** 
Declare 
	@UserKey		INT = 1144,
	@JSONSTRING		NVARCHAR(Max) = '{"DriverKey" : 1681}',
	@Status			BIT	= 0,
	@IntError		VARCHAR(1000) = '',
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@FirebaseID		VARCHAR(500) = '',
	@IsLogout		BIT = 0
	EXEC [DA_GetDriverTickets] @Userkey, @JSONSTRING, @Status OUTPUT, @IntError OUTPUT, @Reason Output, @IsDebug, @FirebaseID, @IsLogout OUTPUT
	SELECT @Status, @IntError, @Reason
**/
CREATE PROC [dbo].[DA_GetDriverTickets](
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

			SET @DriverKey = ISNULL(@DriverKey,0)
			
			SELECT 
				DT.TicketKey,
				DT.TicketTitle,
				DT.TicketDescription,
				DT.IncidentNo,
				DT.CreatedDate,
				D.DriverID,
				D.FirstName + ' ' + ISNULL(D.LastName,'') AS DriverName,
				@ImagePath + 'Ticket_' + CAST(DT.TicketKey AS VARCHAR) + '.pdf' AS ImagePath,
				TicketStatus
			FROM DA_DriverTicket DT
				INNER JOIN Driver D ON DT.DriverKey = D.DriverKey
			WHERE DT.DriverKey = @DriverKey
			ORDER BY CAST(IncidentNo AS INT) DESC
			FOR JSON PATH

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

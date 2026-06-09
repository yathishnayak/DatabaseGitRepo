
/*



DECLARE @status bit = 0,@interr varchar(1000) = '',@reason varchar(1000) = ''

exec DA_CreateTickets 954,'{"DriverKey":1234,"TicketTitle":"Test title 2","TicketDescription":"test description...."}',@status OUTPUT,@interr OUTPUT,@reason OUTPUT

select 'status'=@status,'interr'=@interr,'reason'=@reason
--truncate table DriverTicket
select * from DA_DriverTicket

*/
CREATE PROC [dbo].[DA_CreateTickets](
	@UserKey INT,
	@JSONString NVARCHAR(MAX),
	@Status BIT = 0 OUTPUT,
	@IntError VARCHAR(1000) = '' OUTPUT,
	@Reason VARCHAR(1000) = '' OUTPUT,
	@IsDebug BIT = 0,
	@FirebaseID		VARCHAR(500) = '',
	@IsLogout		BIT = 0 OUTPUT
) AS
BEGIN
	
	SET FMTONLY OFF
	SET NOCOUNT ON

	DECLARE 
		@TicketTitle VARCHAR(500),
		@TicketDescription VARCHAR(MAX),
		@TicketKey INT = 0,
		@DriverKey INT = 0,
		@XmlPayload NVARCHAR(MAX)

	BEGIN TRY
		BEGIN TRANSACTION

			SELECT 
				@DriverKey = t_DriverKey,
				@TicketTitle = t_Title,
				@TicketDescription = t_Description
			FROM OPENJSON(@JSONString,'$')
				WITH(
					t_DriverKey		INT			 '$.DriverKey',
					t_Title			VARCHAR(500) '$.TicketTitle',
					t_Description	VARCHAR(MAX) '$.TicketDescription'
				)

			INSERT INTO DA_DriverTicket(DriverKey,TicketTitle,TicketDescription,CreatedDate,TicketStatus)
			VALUES (@DriverKey,@TicketTitle,@TicketDescription,GETDATE(),'Open')

			SET @TicketKey = SCOPE_IDENTITY()

			UPDATE DA_DriverTicket
			SET TicketTitle = ISNULL(TicketTitle,'') + '_[' + CAST(@TicketKey AS VARCHAR) + ']'
			WHERE TicketKey = @TicketKey

			SET @TicketTitle = ISNULL(@TicketTitle,'') + '_[' + CAST(@TicketKey AS VARCHAR) + ']'

			SET @XmlPayload = '<incident>
				  <name>'+@TicketTitle+'</name>
				  <description>'+@TicketDescription+'</description>
				  <description_no_html>Test Request description HTML</description_no_html>
				  <state>New</state>
				  <priority>Medium</priority>
				  <assignee>
					<email>KathrynH@junctionintegratedlogistics.com</email>
				  </assignee>
				  <requester>
					<email>driverapp@jctransports.com</email>
				  </requester>
				  <category>
					<id>2382448</id>
					<name>JCB</name>
					<default_tags></default_tags>
					<parent_id nil="true"/>
					<deleted>false</deleted>
					<default_assignee_id>10744973</default_assignee_id>
				  </category>
				  <subcategory>
					<id>2382452</id>
					<name>Break-Fix</name>
					<default_tags></default_tags>
					<parent_id>2382448</parent_id>
					<deleted>false</deleted>
					<default_assignee_id>10744973</default_assignee_id>
				  </subcategory>
				  <site>
					<id>184113</id>
					<name>JCT Main</name>
					<location>100 W Victoria St Long Beach CA 90805</location>
					<description>JCT Head Office</description>
					<time_zone>Pacific Time (US &amp; Canada)</time_zone>
					<language>-1</language>
					<business_record nil="true"/>
				  </site>
				</incident>'

			SET @Status = 1
			SET @IntError = ''
			SET @Reason = ''

			SELECT 
				@TicketKey AS TicketKey,
				@XmlPayload AS XmlPayload
			FOR JSON PATH,WITHOUT_ARRAY_WRAPPER

		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

			--SET @Status = 0
			SET @IntError = ERROR_MESSAGE()
			SET @Reason = 'DB Insert Error'

			SELECT 
				0 AS TicketKey,
				'' AS XmlPayload
			FOR JSON PATH,WITHOUT_ARRAY_WRAPPER

	END CATCH

END

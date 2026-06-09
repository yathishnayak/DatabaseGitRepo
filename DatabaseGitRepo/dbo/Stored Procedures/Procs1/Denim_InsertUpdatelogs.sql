CREATE PROCEDURE [dbo].[Denim_InsertUpdatelogs]
(
    @UserKey		INT,
	@JSONString		NVARCHAR(MAX),
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT	
)
AS
BEGIN

	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @Denimlogkey INT, 
	        @Request VARCHAR(500), 
			@Response VARCHAR(500)

			SELECT @Denimlogkey = Denimlogkey, @Request = Request,
			 @Response = Response 
	        FROM OPENJSON		(@JSONString, '$')
						WITH (  
								Denimlogkey						INT		            '$.Denimlogkey',				                                  
								Request						    VARCHAR(20)			'$.Request',	
								Response 				        VARCHAR(20)			'$.Response '							
	)

	IF(ISNULL(@Denimlogkey, 0) = 0)							
		BEGIN		

			INSERT INTO JCB_Logs.DBO.DenimIntegration_log (Request,SentTime)
			SELECT @Request, getdate()
		END
	ELSE
		BEGIN
			UPDATE JCB_Logs.DBO.DenimIntegration_log
			SET Response= @Response,
			ReceivedTime=GETDATE()
			WHERE Denimlogkey = @Denimlogkey

			SELECT @Denimlogkey AS logkey FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		END
END

/*
DECLARE @UserKey INT = 1144,
		@JSONString NVARCHAR(MAX) = '{"DriverKey" : 0, "DriverID" : "19-RS", "OrgName" : " Reyes Green Trucking, LLC aa"}',
		@Status BIT,
		@Reason VARCHAR(50)
EXEC Carrier_ValidateIdName_V2 @UserKey,  @JSONString, @Status OUTPUT, @Reason OUTPUT
select @Status, @Reason
*/


CREATE PROCEDURE [dbo].[Carrier_ValidateIdName_V2]
(
	@UserKey		INT,
	@JSONString		NVARCHAR(MAX),
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT
	            
)
AS
BEGIN
 SET NOCOUNT ON
 SET FMTONLY OFF

 DECLARE    @DriverKey                         INT = 0,
            @DriverID                          VARCHAR(100),
            @CNTId                             INT = 0,
            @CNTName                           INT = 0,
			@OrgName                           VARCHAR(100)

			 SELECT  
            @DriverKey = DriverKey,
            @DriverID  = DriverID,
            @OrgName   = OrgName

            FROM OPENJSON(@JSONString , '$')
	        WITH (                           
								DriverKey 					 INT		                '$.DriverKey ',				                                  
								DriverID 			         VARCHAR(100) 		        '$.DriverID',
								OrgName                      VARCHAR(100)               '$.OrgName'
								)



	SELECT @CNTId = COUNT(1) FROM Driver D WHERE D.DriverKey <> @DriverKey AND D.DriverID = @DriverID
	SELECT @CNTName = COUNT(1) FROM Driver D WHERE D.DriverKey <> @DriverKey AND D.OrgName = @OrgName
	
						
	IF ISNULL(@CNTId,0) = 0 AND ISNULL(@CNTName,0) = 0
		BEGIN
			SET @Status = 1
			SET @Reason = 'Success'
		END
	ELSE
		BEGIN
			IF ISNULL(@CNTId,0) > 0
				BEGIN
					SET @Status = 0
					SET @Reason = 'Carrier Id Already Exist'
				END
			IF ISNULL(@CNTName,0) > 0
				BEGIN
					SET @Status = 0
					SET @Reason = ISNULL(@Reason,'') + ' Carrier Name Already Exist'

				END
		END

		set @Status = 1
	    set @Reason = 'SUCCESS'
		
END





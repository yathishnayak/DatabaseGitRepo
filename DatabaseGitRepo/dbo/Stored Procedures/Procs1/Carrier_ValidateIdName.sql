

/*
declare @DriverKey	INT = 0,
	@DriverID		VARCHAR(100) = '19-RS',
	@OrgName	VARCHAR(100) = ' Reyes Green Trucking, LLC aa',
	@OutPut     BIT = 0  ,
	@Reason     VARCHAR(50) 
exec	Carrier_ValidateIdName @DriverKey,  @DriverID ,@OrgName ,@OutPut output ,@Reason output
select @OutPut,@Reason

*/


CREATE PROCEDURE [dbo].[Carrier_ValidateIdName]  
(
	@DriverKey		INT=0,
	@DriverID      VARCHAR(100) = '',
	@OrgName	   VARCHAR(100) = '',
	@OutPut			BIT=0		 OUTPUT,
	@Reason			VARCHAR(100) OUTPUT
)
AS
BEGIN
 SET NOCOUNT ON
 SET FMTONLY OFF

 DECLARE @CNTId INT = 0,
         @CNTName INT = 0;

	SELECT @CNTId = COUNT(1) FROM Driver D WHERE D.DriverKey <> @DriverKey AND D.DriverID = @DriverID
	SELECT @CNTName = COUNT(1) FROM Driver D WHERE D.DriverKey <> @DriverKey AND D.OrgName = @OrgName

	IF ISNULL(@CNTId,0) = 0 AND ISNULL(@CNTName,0) = 0
		BEGIN
			SET @OutPut = 1
			SET @Reason = 'Success'
		END
	ELSE
		BEGIN
			IF ISNULL(@CNTId,0) > 0
				BEGIN
					SET @OutPut = 0
					SET @Reason = 'Carrier Id Already Exist'
				END
			IF ISNULL(@CNTName,0) > 0
				BEGIN
					SET @OutPut = 0
					SET @Reason = ISNULL(@Reason,'') + ' Carrier Name Already Exist'

				END
		END
END

--SELECT * from driver

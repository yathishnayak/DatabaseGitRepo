
CREATE PROCEDURE [dbo].[Insert_Carrier]
/*
Order Entry Screen
*/
@CarrierID			VARCHAR(20),
@CarrierName		VARCHAR(100),
@IssteamLine		BIT,
@Addrkey			INT,
@Scaccode			VARCHAR(4)=NULL,
@LicensePlate		VARCHAR(255)=NULL ,
@LicensePlateExpiryDate		DATE=NULL ,
@StatusDate				DATE ,
@CarrierKey				INT		OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @CarrierKey=0;

	INSERT INTO dbo.Carrier( CarrierID, CarrierName, IssteamLine, AddrKey, ScacCode, LicensePlate, LicensePlateExpiryDate, CreateDate,StatusKey,StatusDate)
	VALUES (@CarrierID, @CarrierName, @IssteamLine, @Addrkey, @Scaccode, @LicensePlate, @LicensePlateExpiryDate, GETDATE(),1,GETDATE());

	
	SET @CarrierKey = ( SELECT SCOPE_IDENTITY());		
END

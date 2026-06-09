/*
DECLARE 
    @UserKey        INT = 953,
    @Status         BIT = 0,
    @Reason         VARCHAR(1000) = '',
    @IsDebug        BIT = 0,
    @JSONString     NVARCHAR(MAX) = '{}'

EXEC [dbo].[GetRejectReasons]   @UserKey,@JSONString, @Status OUTPUT,  @Reason OUTPUT,@IsDebug
SELECT @Status AS Status, @Reason AS Reason;

*/
CREATE PROCEDURE [dbo].[GetRejectReasons]
(    
    @UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(500) = '' output,
	@IsDebug		bit = 0
)  
AS
BEGIN
	
	SET NOCOUNT ON;
	SET FMTONLY OFF;  
	SET ARITHABORT ON;  

	SELECT RejectReasonKey,RejectReasonDescr,AllowEntry,ReasonType from RejectReasons 
	WHERE ReasonType='Reject' 
	FOR JSON PATH;

	Set @Status=1;
	SET @Reason='Success'
	
END
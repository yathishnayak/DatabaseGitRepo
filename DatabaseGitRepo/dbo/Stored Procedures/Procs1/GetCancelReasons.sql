CREATE PROCEDURE [dbo].[GetCancelReasons]
(    
    @UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output,
	@IsDebug		bit = 0
)  
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;  
	SET ARITHABORT ON;  

	SELECT RejectReasonKey,RejectReasonDescr,AllowEntry,ReasonType from RejectReasons WITH (NOLOCK)
	WHERE ReasonType='Cancel' 
	FOR JSON PATH;

	Set @Status=1;
	SET @Reason='Success'
	
END

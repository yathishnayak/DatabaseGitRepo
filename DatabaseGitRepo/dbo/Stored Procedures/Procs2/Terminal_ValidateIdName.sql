
/*
declare @TerminalKey	INT = 3,
	@TerminaID		VARCHAR(100) = 'Measrk Terminal1',
	@OutPut     BIT = 0  ,
	@Reason     VARCHAR(50) 
exec	Terminal_ValidateIdName @TerminalKey,  @TerminaID  ,@OutPut output ,@Reason output
select @OutPut,@Reason

*/

CREATE PROCEDURE [dbo].[Terminal_ValidateIdName]
(
	@TerminalKey INT = 0,
	@TerminaID	 VARCHAR(100) = '',
	@OutPut      BIT = 0 OUTPUT,
	@Reason		 VARCHAR(100) = '' OUTPUT
)
AS
BEGIN
 SET NOCOUNT ON
 SET FMTONLY OFF

 DECLARE @CNTId INT = 0

 SELECT @CNTId = COUNT(1) FROM ShippingPortTerminals T WHERE T.TerminalKey <> @TerminalKey AND T.TerminaID = @TerminaID

 IF ISNULL(@CNTId,0) = 0
	BEGIN
		SET @OutPut = 1
		SET @Reason = 'Success'
	END
 ELSE
	BEGIN
		IF ISNULL(@CNTId,0) > 0
			BEGIN
				SET @OutPut = 0
				SET @Reason = 'Terminal Id Already Exist'
			END
	END
END


--SELECT * FROM ShippingPortTerminals

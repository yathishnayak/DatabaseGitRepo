
/*
declare @ShippingPortKey	INT = 3,
	@ShippingPortID		VARCHAR(100) = 'Charleston P1',
	@OutPut     BIT = 0  ,
	@Reason     VARCHAR(50) 
exec	Port_ValidateIdName @ShippingPortKey, @ShippingPortID , @OutPut output ,@Reason output
select @OutPut,@Reason

*/

CREATE PROCEDURE [dbo].[Port_ValidateIdName]
(
	@ShippingPortKey  INT = 0,
	@ShippingPortID	  VARCHAR(100) = '',
	@OutPut           BIT = 0     OUTPUT,
	@Reason           VARCHAR(100) OUTPUT
)
AS

 BEGIN
   SET NOCOUNT ON
   SET FMTONLY OFF

	DECLARE @CNTId INT = 0;

	SELECT @CNTId = COUNT(1) FROM ShippingPort S WHERE S.ShippingPortKey <> @ShippingPortKey AND S.ShippingPortID = @ShippingPortID
	PRINT @CNTId
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
					SET @Reason = 'Port Id Already Exist'
				END
		END
 END

-- SELECT * FROM ShippingPort

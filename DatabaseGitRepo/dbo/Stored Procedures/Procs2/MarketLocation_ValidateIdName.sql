
/*
declare @MarketLocationKey	INT = 3,
	@MarketLocation		VARCHAR(100) = 'Measrk Terminal1',
	@OutPut     BIT = 0  ,
	@Reason     VARCHAR(50) 
exec	MarketLocation_ValidateIdName @MarketLocationKey,  @MarketLocation  ,@OutPut output ,@Reason output
select @OutPut,@Reason

*/

CREATE PROCEDURE [dbo].[MarketLocation_ValidateIdName]
(
	@MarketLocationKey  INT = 0,
	@MarketLocation		VARCHAR(100) = '',
	@OutPut				BIT = 0 OUTPUT,
	@Reason             VARCHAR(100) = '' OUTPUT
)
AS 
 BEGIN
  SET NOCOUNT ON
  SET FMTONLY OFF

  DECLARE @CNTId  INT = 0

  SELECT @CNTId = COUNT(1) FROM MarketLocation M WHERE M.MarketLocationKey <> @MarketLocationKey AND M.MarketLocation = @MarketLocation

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
				SET @Reason = 'Market Location Already Exist'
			END
	END
 END

 --SELECT *FROM MarketLocation

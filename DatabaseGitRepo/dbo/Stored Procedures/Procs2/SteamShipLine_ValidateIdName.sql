
/*
declare @LineKey	INT = 1,
	@LineName		VARCHAR(100) = 'Savannah',
	@OutPut     BIT = 0  ,
	@Reason     VARCHAR(50) 
exec	SteamShipLine_ValidateIdName @LineKey,  @LineName  ,@OutPut output ,@Reason output
select @OutPut,@Reason

*/

CREATE PROCEDURE [dbo].[SteamShipLine_ValidateIdName]
(
	@LineKey      INT = 0,
	@LineName	  VARCHAR(100) = '',
	@OutPut		  BIT = 0 OUTPUT,
	@Reason       VARCHAR(100) = '' OUTPUT
)
AS 
 BEGIN
  SET NOCOUNT ON
  SET FMTONLY OFF

  DECLARE @CNTId  INT = 0

  SELECT @CNTId = COUNT(1) FROM SteamShipLine S WHERE S.LineKey <> @LineKey AND S.LineName = @LineName

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
				SET @Reason = 'Steam Ship Line Already Exist'
			END
	END
 END

 --SELECT *FROM SteamShipLine

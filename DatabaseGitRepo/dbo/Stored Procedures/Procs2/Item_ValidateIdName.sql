
/*
declare @ItemKey	INT = 0,
	@ItemID		VARCHAR(100) = 'WAIT TIME-PORT',
	@Description	 VARCHAR(100) = 'WAIT TIME- PORT AFTER 2 HOURS  ',
	@OutPut     BIT = 0  ,
	@Reason     VARCHAR(50) 
exec	Item_ValidateIdName @ItemKey, @ItemID , @Description ,@OutPut output ,@Reason output
select @OutPut,@Reason
SELECT * FROM Item I WHERE itemkey=5 and  I.Description like '%WAIT TIME- PORT AFTER 2 HOURS%'

*/

CREATE PROCEDURE [dbo].[Item_ValidateIdName]
(
	@ItemKey	 INT  = 0,
	@ItemID		 VARCHAR(100) = '',
	@Description VARCHAR(100) = '',
	@OutPut      BIT = 0  OUTPUT,
	@Reason		 VARCHAR(100) OUTPUT
)
AS
 BEGIN
  SET NOCOUNT ON
  SET FMTONLY OFF

  DECLARE @CNTId  INT = 0,
		  @CNTName INT = 0;	 

  SELECT @CNTId = COUNT(1) FROM Item I WHERE I.ItemKey <> @ItemKey AND I.ItemID = @ItemID
  SELECT @CNTName = COUNT(1) FROM Item I WHERE I.ItemKey <> @ItemKey AND I.Description Like '%'+ TRIM(@Description)+'%'


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
				SET @Reason = 'Item Id Already Exist'
			END
		IF ISNULL(@CNTName,0) > 0
			BEGIN
				SET @OutPut = 0
				SET @Reason = ISNULL(@Reason,'') + ' Item Description Already Exist'
			END
	END 
 END

 --SELECT * FROM Item

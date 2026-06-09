
/*
DECLARE 
	@UserKey INT=953,
	@JSONString		NVARCHAR(MAX) = '[{"ItemKey":100, "ItemId": "CTF", "Description":"Clean Truck Fees" }]',
	@Status BIT=0,
	@Reason VARCHAR(100)='',
	@IsDebug BIT=0
EXec Item_ValidateIdName_V2 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
*/

CREATE PROCEDURE [dbo].[Item_ValidateIdName_V2]
(
	@UserKey		INT = 953,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT ,
	@IsDebug		BIT = 0

)

AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE
	@ItemKey			INT,
	@ItemID				VARCHAR(100),
	@Description		VARCHAR(100),
	@CNTId  INT = 0,
	@CNTName INT = 0;	 

 

	

	SELECT @ItemKey = ItemKey, @ItemID = ItemID, @Description = Description
	from OPENJSON(@JSONString, '$')
	with (
			ItemKey		    INT							'$.ItemKey',
			ItemID			VARCHAR(100)				'$.ItemId',
			Description		VARCHAR(100)				'$.Description'
		 )

		 SELECT @CNTId = COUNT(1) FROM Item I WHERE I.ItemKey <> @ItemKey AND I.ItemID = @ItemID
		 SELECT @CNTName = COUNT(1) FROM Item I WHERE I.ItemKey <> @ItemKey AND I.Description Like '%'+ TRIM(@Description)+'%'

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
				SET @Reason = 'Item Id Already Exist'
			END
		IF ISNULL(@CNTName,0) > 0
			BEGIN
				SET @Status = 0
				SET @Reason = ISNULL(@Reason,'') + ' Item Description Already Exist'
			END
	END 
 END

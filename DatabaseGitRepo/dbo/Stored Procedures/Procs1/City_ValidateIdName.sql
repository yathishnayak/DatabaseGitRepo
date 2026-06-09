



/*
declare @CityKey	INT = 1,
	@ZipCode	VARCHAR(100) = '5858455',
	@OutPut     BIT = 0  ,
	@Reason     VARCHAR(50) 
exec	City_ValidateIdName @CityKey,  @ZipCode ,@OutPut output ,@Reason output
select @OutPut,@Reason

*/

CREATE PROCEDURE [dbo].[City_ValidateIdName] 
(
	@CityKey	INT = 0,
	@ZipCode	VARCHAR(100) ='',
	@OutPut     BIT = 0  OUTPUT,
	@Reason     VARCHAR(100) OUTPUT
)
AS
BEGIN
 SET NOCOUNT ON
 SET FMTONLY OFF

    DECLARE @CNTId  INT = 0
			
   SELECT @CNTId = COUNT(1) FROM LocationData C WHERE C.CityKey <> @CityKey AND C.ZipCode = @ZipCode 

   IF ISNULL(@CNTId,0)=0 
	   BEGIN
		   SET @OutPut = 1
		   sET @Reason='Success'
	   END
   ELSE
	   BEGIN
		   IF ISNULL(@CNTId,0) > 0

			   BEGIN
					SET @OutPut = 0
					SET @Reason = 'Zipcode Already Exist'
		
			   END			
		  END	           
END

--SELECT * FROM LocationData

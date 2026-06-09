
/*
declare @YardId	INT = 1,
	@ShortName	VARCHAR(100) = 'JCT-Via Plata',
	@Name	 VARCHAR(100) = 'JCT Main Yard 1483 W Via Plata',
	@OutPut     BIT = 0  ,
	@Reason     VARCHAR(50) 
exec	Yard_ValidateIdName @YardId, @ShortName , @Name , @OutPut output ,@Reason output
select @OutPut,@Reason

*/

CREATE PROCEDURE [dbo].[Yard_ValidateIdName]
(
	@YardId		INT = 0,
	@ShortName  VARCHAR(100) = '',
	@Name       VARCHAR(100) = '',
	@OutPut     BIT = 0  OUTPUT,
	@Reason     VARCHAR(100) OUTPUT
)
AS
 BEGIN
  SET NOCOUNT ON
  SET FMTONLY OFF

  DECLARE @CNTId INT = 0,
          @CNTName INT = 0

 SELECT  @CNTId = COUNT(1) FROM Yard Y WHERE Y.YardId <> @YardId AND Y.ShortName = @ShortName
 SELECT  @CNTName = COUNT(1) FROM Yard Y WHERE Y.YardId <> @YardId AND Y.Name = @Name

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
				SET @Reason = 'Yard Name Already Exist'
			END
		IF ISNULL(@CNTName,0) > 0
			BEGIN
				SET @OutPut=0
				SET @Reason = ISNULL(@Reason,'') +' Yard Description Already Exist'
			END
	END
 END

--select *from Yard


/*
declare @chassisKey	INT = 603,
	@chassisNo		VARCHAR(100) = '46y46ytr',	
	@OutPut     BIT = 0  ,
	@Reason     VARCHAR(50) 
exec	Chassis_ValidateIdName @chassisKey,  @chassisNo ,@OutPut output ,@Reason output
select @OutPut,@Reason

*/
CREATE PROCEDURE [dbo].[Chassis_ValidateIdName]
(
	@chassisKey  INT = 0,
	@chassisNo	 VARCHAR(100) = '',	
	@OutPut      BIT = 0 OUTPUT,
	@Reason      VARCHAR(100) OUTPUT
)
AS
BEGIN
 SET NOCOUNT ON
 SET FMTONLY OFF
  
  DECLARE @CNTId   INT = 0
         
 SELECT @CNTId = COUNT(1) FROM Chassis C WHERE C.chassisKey <> @chassisKey AND C.chassisNo = @chassisNo
 

 IF ISNULL(@CNTId,0) = 0 
	BEGIN
		SET @OutPut = 1
		SET @Reason = 'Success'
	END
 ELSE
	BEGIN
		IF ISNULL(@CNTId,0) > 0
			BEGIN
				SET @OutPut =0
				SET @Reason = 'Chasis Id Already Exist'
			END        
	END

END

--SELECT * FROM Chassis

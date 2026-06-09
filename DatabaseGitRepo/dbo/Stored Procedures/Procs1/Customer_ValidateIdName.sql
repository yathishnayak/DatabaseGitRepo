/*
declare @CustKey	INT = 4,
	@CustID		VARCHAR(100) = 'LGT01',
	@CustName	VARCHAR(100) = 'Landstar Global- Tr',
	@OutPut     BIT = 0  ,
	@Reason     VARCHAR(50) 
exec	Customer_ValidateIdName @CustKey,  @CustID ,@CustName  ,@OutPut output ,@Reason output
select @OutPut,@Reason

*/

CREATE PROCEDURE [dbo].[Customer_ValidateIdName]  
(
	@CustKey	INT = 0,
	@CustID		VARCHAR(100) ='',
	@CustName	VARCHAR(100) = '',
	@OutPut     BIT = 0  OUTPUT,
	@Reason     VARCHAR(100) OUTPUT
)
AS
BEGIN
 SET NOCOUNT ON
 SET FMTONLY OFF

    DECLARE @CNTId  INT = 0,
			@CNTName  INT = 0;

   SELECT @CNTId = COUNT(1) FROM Customer C WHERE C.CustKey <> @CustKey AND C.CustID = @CustID
   SELECT @CNTName = COUNT(1) FROM Customer C WHERE C.CustKey <> @CustKey AND C.CustName = @CustName

   IF ISNULL(@CNTId,0)=0 AND ISNULL(@CNTName,0)=0
	   BEGIN
		   SET @OutPut = 1
		   sET @Reason='Success'
	   END
   ELSE
	   BEGIN
		   IF ISNULL(@CNTId,0) > 0

			   BEGIN
					SET @OutPut = 0
					SET @Reason = 'Customer Id Already Exist'
		
			   END
 
			IF ISNULL(@CNTName,0) >0
			   BEGIN
					SET @OutPut = 0
					SET @Reason = ISNULL(@Reason,'') + ' Customer Name Already Exist'
			   END
		  END	           
END

--SELECT *FROM Customer


/*
declare @SalesPersonKey	INT = 12,
	@SalesPersonID	VARCHAR(100) = '1012',
	@SalesPersonName	VARCHAR(100) = 'reethika  Test',
	@OutPut     BIT = 0  ,
	@Reason     VARCHAR(50) 
exec	SalePerson_ValidateIdName @SalesPersonKey	,  @SalesPersonID ,@SalesPersonName  ,@OutPut output ,@Reason output
select @OutPut,@Reason

*/
CREATE PROCEDURE [dbo].[SalePerson_ValidateIdName]
(
	@SalesPersonKey		INT = 0,
	@SalesPersonID		VARCHAR(100) = '',
	@SalesPersonName	VARCHAR(100) = '',
	@OutPut				BIT = 0  OUTPUT,
	@Reason             VARCHAR(100) OUTPUT 
)
AS
 BEGIN
  SET NOCOUNT ON
  SET FMTONLY OFF

  DECLARE @CNTId INT = 0,
		  @CNTName INT = 0;

 SELECT @CNTId = COUNT(1) FROM SalesPerson S WHERE S.SalesPersonKey <> @SalesPersonKey AND S.SalesPersonID = @SalesPersonID
 SELECT @CNTName = COUNT(1) FROM SalesPerson S WHERE S.SalesPersonKey <> @SalesPersonKey AND S.SalesPersonName = @SalesPersonName

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
				SET @Reason = 'Sale Person Id Already Exist'
			END
        IF ISNULL(@CNTName,0) > 0
			BEGIN
				SET @OutPut = 0
				SET @Reason =ISNULL(@Reason,'')  +' Sale Person Name Already Exist'
			END
	END
  END 

  --SELECT * FROM SalesPerson

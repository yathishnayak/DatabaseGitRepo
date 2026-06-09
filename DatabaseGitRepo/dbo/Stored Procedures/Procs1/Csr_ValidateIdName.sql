
/*
declare @CsrKey	INT = 3,
	@CsrName	VARCHAR(100) = 'Jocob',
	@OutPut     BIT = 0  ,
	@Reason     VARCHAR(50) 
exec	Csr_ValidateIdName @CsrKey,  @CsrName  ,@OutPut output ,@Reason output
select @OutPut,@Reason

*/

CREATE PROCEDURE [dbo].[Csr_ValidateIdName]
(
	@CsrKey   INT = 0,
	@CsrName  VARCHAR(100) = '',
	@OutPut   BIT = 0 OUTPUT,
	@Reason   VARCHAR(100) = '' OUTPUT
)
AS
 BEGIN
  SET NOCOUNT ON
  SET FMTONLY OFF

  DECLARE @CNTName INT = 0

  SELECT @CNTName = COUNT(1) FROM CSR C WHERE C.CsrKey <> @CsrKey AND C.CsrName = @CsrName

  IF ISNULL(@CNTName,0) = 0
	BEGIN
		SET @OutPut = 1
		SET @Reason = 'Success'
	END
  ELSE
	BEGIN
		IF ISNULL(@CNTName,0) > 0
			BEGIN
				SET @OutPut = 0
				SET @Reason = 'CSR Name Already Exist'
			END
	END


 END

 --SELECT *FROM CSR

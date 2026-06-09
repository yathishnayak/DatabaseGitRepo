
CREATE PROCEDURE [dbo].[Update_OrderCSR]
@OrderKey	INT,
@CSRKey		SMALLINT=null,
@OutPut		BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SET @OutPut=0

	UPDATE OrderHeader
	SET CsrKey=@CSRKey
	WHERE OrderKey=@OrderKey

	SET @OutPut=1
END

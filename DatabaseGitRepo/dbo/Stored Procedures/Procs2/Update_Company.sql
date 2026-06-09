CREATE PROCEDURE [dbo].[Update_Company]
/*
dbo.fn_update_company
*/
@Compkey	INT,
@CompID		VARCHAR (20),
@CompName	VARCHAR(255),
@OutPut		BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	UPDATE dbo.Company 
    SET CompanyID =@CompID ,
		CompanyName =@CompName         
	WHERE CompanyKey = @Compkey;

	SET @OutPut=1
END

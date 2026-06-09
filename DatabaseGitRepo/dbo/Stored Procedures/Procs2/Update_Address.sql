CREATE PROCEDURE [dbo].[Update_Address]
/*
dbo.fn_update_address
*/
@AddrKey	INT,
@AddrName	varchar(255),
@Address1	VARCHAR(255),
@Address2	VARCHAR(255),
@City		VARCHAR(255),
@State		VARCHAR(255),
@ZipCode	VARCHAR(50),
@Country	CHAR(3),
@WebSite	VARCHAR(255),
@Phone		VARCHAR(255),
@Email		VARCHAR(255),
@Fax		VARCHAR(20),
@Phone2		VARCHAR(20),
@Email2		VARCHAR(255),
@OutPut		BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	UPDATE dbo.[Address]
	SET 
		AddrName = @AddrName ,
		Address1 =@Address1 ,
		Address2 =@Address2 ,
		City =@City ,State =@State,ZipCode=@ZipCode,Country=@Country,
		Website=@Website,Phone=@Phone,Email=@Email,Phone2=@Phone2,Email2=@Email2,Fax= @Fax
	WHERE AddrKey =@AddrKey;
	
	SET @OutPut=1
END

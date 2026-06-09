CREATE PROCEDURE [dbo].[Create_Address]
@Addrname	VARCHAR(255),
@Address1	VARCHAR(255),
@Address2	VARCHAR(255),
@City		VARCHAR(50),
@State		VARCHAR(50),
@Zipcode	VARCHAR(50),
@Country	CHAR(3),
@Website	VARCHAR(100),
@Phone		VARCHAR(20),
@Email		VARCHAR(50),
@Fax		VARCHAR(20),
@Phone2		VARCHAR(20),
@Email2		VARCHAR(255),
@AddrKey		INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF


	SET @AddrKey=0	

	INSERT INTO dbo.[Address](AddrName,Address1, Address2, City,[State],ZipCode,Country,Website,Phone,Email,Fax,Phone2,Email2)
		VALUES (@Addrname,@Address1, @Address2, @City,@State,@Zipcode,@Country,@Website,@Phone,@Email,@Fax,@Phone2,@Email2) ;

		SET @AddrKey = ( SELECT SCOPE_IDENTITY());
END

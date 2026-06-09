/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"address1":"1234 Elm St  ","address2":" Apt 56B  ","city":" Chicago","state":" IL","zipCode":"60601 ","country":"USA"}',
	@Status BIT=0,@IsDebug		BIT = 0,
	@Reason VARCHAR(100)=''
EXec [Address_Validate_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/
CREATE proc [dbo].[Address_Validate_V2]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON
	SET Concat_null_Yields_null ON

	Declare @ValidAddrKey	int = 0

	SELECT *
	into #Temp
	FROM	OPENJSON(@JsonString, '$')
	WITH (
		address1			varchar(100)			'$.Address1',
		address2			varchar(100)			'$.Address2',
		city				varchar(50)				'$.City',
		state				varchar(50)				'$.State',
		zipCode				varchar(20)				'$.Zip',
		country				varchar(5)				'$.Country'
	)


	if(isnull((Select count(1) from #Temp),0) > 0)
	Begin
		select @ValidAddrKey = VAL.ValidAddressKey
		from ValidAddress VAL WITH (NOLOCK)
		inner join #Temp T on ltrim(rtrim(VAL.Address1)) = ltrim(rtrim( T.address1))
			and ltrim(rtrim(VAL.address2)) = ltrim(rtrim( T.address2))
			and ltrim(rtrim(VAL.city)) = ltrim(rtrim( T.city))
			and ltrim(rtrim(VAL.state)) = ltrim(rtrim( T.state))
			and ltrim(rtrim(VAL.country)) = ltrim(rtrim( T.country))
		
		if(isnull(@ValidAddrKey,0) = 0)
		Begin 
			insert into ValidAddress (Address1, Address2, City, State, ZipCode, Country )
			select Address1, Address2, City, State, ZipCode, Country from #Temp
			set @ValidAddrKey = SCOPE_IDENTITY()
		end
		
		select @ValidAddrKey as ValidAddrKey FOR JSON PATH, WITHOUT_Array_Wrapper
		set @Status = 1
		set @Reason = 'SUCCESS'
	End
	else 
	BEGIN
		select 0 as ValidAddrKey FOR JSON PATH, WITHOUT_Array_Wrapper
		SET @Status = 0
		SET @Reason = 'NO ADDRESS RECEIVED'
	END
END

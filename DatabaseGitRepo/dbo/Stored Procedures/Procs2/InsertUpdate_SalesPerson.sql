/**
declare @Output varchar(100)=''
DECLARE @SalesPersonKey int=15
exec InsertUpdate_SalesPerson @SalesPersonKey output, 'PraveenT','Praveen',3721,606,1,512,@Output output
select @Output
**/
CREATE proc [dbo].[InsertUpdate_SalesPerson] -- 
(
	@SalesPersonKey		int Output,
	@SalesPersonID		varchar(10),
	@SalesPersonName	varchar(100),
	@addrKey			int,
	@LinkedUserKey		int,
	@IsActive			Bit,
	@UserKey			int,
	@Output				Bit = 0 OUTPUT
)
as
Begin
	set nocount on
	set fmtonly off
	set @Output = CONVERT(Bit, 0)

	if( isnull(@SalesPersonID,'') = '' OR ISNULL(@SalesPersonName,'') = '' OR isnull(@addrKey,0) = 0)
	begin
		set @Output = CONVERT(Bit, 0)
		return;
	end
	ELSE
	Begin
		If(isnull(@SalesPersonKey,0) = 0)
		Begin
			insert into SalesPerson( SalesPersonID, SalesPersonName, FirstName, AddrKey, IsActive, CreateUser, CreateDate, LinkedUserKey )
			Select  @SalesPersonID, @SalesPersonName,@SalesPersonName, @addrKey, @IsActive, @UserKey, GETDATE(), @LinkedUserKey
			Set @SalesPersonKey = SCOPE_IDENTITY();
			Set @output = convert(bit,1)
		End
		ELSE
		BEGIN
			Update SalesPerson
			SET
				SalesPersonID = @SalesPersonID,
				SalesPersonName = @SalesPersonName,
				FirstName = @SalesPersonName,
				AddrKey = @addrKey,
				IsActive = @IsActive,
				UpdateUser = @UserKey,
				UpdateDate = GETDATE(),
				LinkedUserKey = @LinkedUserKey
			Where SalesPersonKey = @SalesPersonKey
			Set @output = convert(bit,1)
		END
	END
	return @output
End

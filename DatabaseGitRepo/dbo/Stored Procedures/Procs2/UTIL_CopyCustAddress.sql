CREATE  Procedure [dbo].[UTIL_CopyCustAddress]
(
	@FromAddrKey as int,
	@FromCustKey int,
	@ToCustKey int,
	@NewAddrKey int output
)
as
Begin	
	set @NewAddrKey =0 
	set @NewAddrKey=0
	declare @AddrType varchar(50) 
  
	select A.*, B.CustKey as CustKey, B.AddrType into #tmp1 from [Address] A
	inner join CustomerAddress B on (A.AddrKey = B.AddrKey)
	where   B.AddrKey = @FromAddrKey and B.CustKey= @FromCustKey
       
    if not exists (select * from #tmp1) return

	select @AddrType=AddrType  from  CustomerAddress where CustKey=@FromCustKey and AddrKey = @FromAddrKey
	 
	select  @NewAddrKey = isnull(A.AddrKey,0)   from [Address] A
	inner join CustomerAddress B on (A.AddrKey = B.AddrKey)
	inner join  #tmp1 as C on (A.Address1 = C.Address1 and A.AddrName = C.AddrName and A.City= C.City and A.State = C.State )
	where B.CustKey=@ToCustKey 
	 
	if @NewAddrKey =0
	Begin	
	    insert into Address (AddrName,Address1,Address2,City,State,ZipCode,Country,Website,Phone,Email,Fax,Phone2,Email2,CityKey)
		select AddrName,Address1,Address2,City,State,ZipCode,Country,Website,Phone,Email,Fax,Phone2,Email2,CityKey from  #tmp1
		set  @NewAddrKey = @@IDENTITY

		if (@AddrType is not null) 
		Begin
			Insert into CustomerAddress(CustKey,AddrKey,AddrType)
			select @ToCustKey,  @NewAddrKey,@AddrType
		End
	End

End

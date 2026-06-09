/*
	Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
	set @JsonString = '{"WarehouseItemKey":9002}'
	exec Charge_DeleteWarehouseItemDetails @UserKey, @JSONString, @Status output, @Reason output
	select @Status, @Reason
*/

CREATE  PROCEDURE [dbo].[Charge_DeleteWarehouseItemDetails] 
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	Declare 
		@Count						int

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	Create Table #Items
	(
		WarehouseItemKey	int
	)

	insert into #Items(WarehouseItemKey)
	Select  WarehouseItemKey
	from OpenJSON(@JsonString, '$')
	WITH (
		WarehouseItemKey		int				'$.WarehouseItemKey'
	)

	--select * from #Temp
	
	if((Select count(1) from #Items) = 0)
	Begin
		set @Status = 0
		set @Reason = 'No Record to Delete'
	End

	Begin Try
		delete from Warehouse_Charges Where WarehouseItemKey in (select WarehouseItemKey from #Items)

		set @Status = 1
		set @Reason = 'SUCCESS'
	end try
	begin catch
		set @Status = 0
		set @Reason = 'ERROR IN PROC: ' + convert(varchar, ERROR_LINE()) + ' : ' + ERROR_MESSAGE()
	end catch
END

/*
Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
set @JsonString = ''
exec Gnosis_GetCSMList @UserKey, @JSONString, @Status output, @Reason output
select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Gnosis_GetCSMList]   
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
	
	select distinct CM.CsrName as CSMName
	from GNosis_Integration_ContainerCustomer CC  WITH (NOLOCK)
	Left join CSR CM  WITH (NOLOCK) on ltrim(rtrim(CC.Field_value)) = ltrim(rtrim(CM.CsrName))
	where Field_name = 'Order CSR' and CM.IsManager = 1
	Order by CM.CsrName 
	FOR JSON PATH
	SEt @Status = 1
	SEt @Reason = 'SUCCESS'
END

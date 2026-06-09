
/*
Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
set @JsonString = ''
exec Gnosis_GetCSRList @UserKey, @JSONString, @Status output, @Reason output
select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Gnosis_GetCSRList]   
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
	
	select distinct CC.Field_Value as CSRName
	from GNosis_Integration_ContainerCustomer CC  WITH (NOLOCK)
	where Field_name = 'Order CSR'
	Order by CC.Field_Value
	FOR JSON PATH
	SEt @Status = 1
	SEt @Reason = 'SUCCESS'
END

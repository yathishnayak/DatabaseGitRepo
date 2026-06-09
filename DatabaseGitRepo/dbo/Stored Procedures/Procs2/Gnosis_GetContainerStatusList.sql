
/*
Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
set @JsonString = ''
exec Gnosis_GetContainerStatusList @UserKey, @JSONString, @Status output, @Reason output
select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Gnosis_GetContainerStatusList]   
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
	
	--Select 'All' as StatusName
	--union all 
	select StatusName
	from Gnosis_Container_Status  WITH (NOLOCK)
	Order by StatusName
	FOR JSON PATH
	SEt @Status = 1
	SEt @Reason = 'SUCCESS'
END

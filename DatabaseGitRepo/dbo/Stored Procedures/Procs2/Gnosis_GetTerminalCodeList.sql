
/*
Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
set @JsonString = ''
exec Gnosis_GetTerminalCodeList @UserKey, @JSONString, @Status output, @Reason output
select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Gnosis_GetTerminalCodeList]   
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
	
	--Select ' All' as Pod_terminal_firms_code
	--union all 
	select distinct  A.Pod_terminal_firms_code
	from Gnosis_Integration_Container A  WITH (NOLOCK)
	where Pod_terminal_firms_code is not null
	order by Pod_terminal_firms_code
	FOR JSON PATH
	SEt @Status = 1
	SEt @Reason = 'SUCCESS'
END

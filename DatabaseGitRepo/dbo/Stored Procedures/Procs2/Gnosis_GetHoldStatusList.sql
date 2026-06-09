/*
Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
set @JsonString = ''
exec Gnosis_GetHoldStatusList @UserKey, @JSONString, @Status output, @Reason output
select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Gnosis_GetHoldStatusList]   
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
	select 1 As StatusKey,'CTF' as StatusName
	union all 
	select 2,'CUSTOMS'
	union all 
	select 3,'LINE'
	union all 
	select 4,'OTHERS'
	union all 
	select 5,'TMF'
	FOR JSON PATH
	SEt @Status = 1
	SEt @Reason = 'SUCCESS'
END
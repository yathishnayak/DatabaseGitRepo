
/*
Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
set @JsonString = ''
exec Gnosis_GetVesselImoList @UserKey, @JSONString, @Status output, @Reason output
select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Gnosis_GetVesselImoList]   
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
	
	--Select ' All' as Current_vessel_imo
	--union all 
	select distinct  A.Current_vessel_imo
	from Gnosis_Integration_Container A  WITH (NOLOCK)
	where Current_vessel_imo is not null
	order by Current_vessel_imo
	FOR JSON PATH
	SEt @Status = 1
	SEt @Reason = 'SUCCESS'
END

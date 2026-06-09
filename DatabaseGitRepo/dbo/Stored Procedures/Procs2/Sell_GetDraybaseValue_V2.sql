/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"MarketLocationKey" : 3, "ZoneKey": 11, "TerminalKey" : 4, "HighestOff" : "ALL"}'
	EXEC [Sell_GetDraybaseValue_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Sell_GetDraybaseValue_V2] -- Sell_GetDraybaseValue 3, 11, 5, 'Company - Asset'
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)

as
Begin
	Set nocount on
	set fmtonly off

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE 
		@MarketKey		int,
		@ZoneKey		int,
		@TerminalKey	int,
		@HighestOff		varchar(20) -- All, Local, Port, IE


	SELECT 
	@MarketKey		= 	MarketKey	,
	@ZoneKey		= 	ZoneKey	,
	@TerminalKey	= 	TerminalKey,
	@HighestOff		= 	HighestOff	
	FROM OPENJSON(@JSONSTRING)
	WITH
	(
	MarketKey			INT					'$.MarketLocationKey',	
	ZoneKey				INT					'$.ZoneKey',	
	TerminalKey			INT					'$.TerminalKey',
	HighestOff			VARCHAR(20)			'$.HighestOff'
	)

	select isnull(Sc.SellConfigKey,0) as SellConfigKey,  
		max(isnull(isnull(SC.DrayBaseValue, PP.DrayBase),0)) as DrayBaseCost
	from MarketLocation ML WITH(NOLOCK) 
	LEft join PriceGrouping T WITH(NOLOCK) on ML.MarketLocationKey = T.MarketLocationKey
	LEft Join COST_CostDataOutput PP WITH(NOLOCK) on ml.MarketLocation = PP.Market and PP.Terminal = T.PriceGrouping
	LEft join cost_Zones Z WITH(NOLOCK) on PP.Zone = Z.ZoneName and ML.MarketLocationKey = Z.MarketKey
	Left join Sell_Config SC WITH(NOLOCK) on ML.MarketLocationKey = SC.MarketKey and T.PriceGroupingKey = SC.TerminalKey and Z.ZoneKey = SC.ZoneKey
	where ML.MarketLocationKey = @MarketKey and T.PriceGroupingKey = @TerminalKey and Z.ZoneKey = @ZoneKey and
		--PP.YardPortType = case when isnull(@HighestOff,'ALL') = 'ALL' then PP.YardPortType else  @HighestOff end
		PP.DriverType = case when isnull(@HighestOff,'ALL') = 'ALL' then PP.DriverType else  @HighestOff end
	group by Sc.SellConfigKey
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
End
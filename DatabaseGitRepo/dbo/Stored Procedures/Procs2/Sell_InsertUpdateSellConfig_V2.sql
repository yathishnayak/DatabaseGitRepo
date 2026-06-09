/** 
Declare 
	@UserKey		INT = 951,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{
					"MarketLocationKey": 3,
					"TerminalKey": 4,
					"ZoneKey": 11,
					"HighestOff": "Company - Asset",
					"YardType": "Local",
					"IsPrePull": true,
					"PrePullValue": 81.44,
					"IsStopOff": true,
					"StopOffValue": 81.44,
					"DrayBaseValue": 138,
					"SellConfigKey": 0,
					"EffectiveFromKey": 2,
					"EffectiveDateFrom": "2026-03-09T18:30:00"
				}'
	EXEC [Sell_InsertUpdateSellConfig_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/

CREATE PROCEDURE [dbo].[Sell_InsertUpdateSellConfig_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
As
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

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
		@IsPrePull		Bit = 0,
		@PrePullCost	numeric(18,2),
		@IsStopOff		Bit = 0,
		@StopOffCost	numeric(18,2),
		@HighestOff		varchar(20) , --> All, Local, Port, IE
		@YardType		varchar(20) , --> All, Local, Port, IE
		@DrayBaseValue	numeric(18,2),
		@EffectiveDate	dateTime,
		@EffectiveFromKey	int,
		@SellConfigKey	int = 0

	SELECT 
		@MarketKey				=   MarketKey		,
		@ZoneKey				=   ZoneKey			,
		@TerminalKey			=   TerminalKey		,
		@IsPrePull				=   IsPrePull		,
		@PrePullCost			=   PrePullCost		,
		@IsStopOff				=   IsStopOff		,
		@StopOffCost			=   StopOffCost		,
		@HighestOff				=   HighestOff		,
		@YardType				=   YardType		,
		@DrayBaseValue			=   DrayBaseValue	,
		@EffectiveDate			=   EffectiveDate	,
		@EffectiveFromKey		=   EffectiveFromKey,
		@SellConfigKey			=   SellConfigKey	
	FROM OPENJSON(@JSONString)
	WITH
	(
		MarketKey				INT					'$.MarketLocationKey',			
		ZoneKey					INT					'$.ZoneKey',		
		TerminalKey				INT					'$.TerminalKey',		
		IsPrePull				BIT					'$.IsPrePull',			
		PrePullCost				NUMERIC(18,2)		'$.PrePullValue',		
		IsStopOff				BIT					'$.IsStopOff',			
		StopOffCost				NUMERIC(18,2)		'$.StopOffValue',		
		HighestOff				VARCHAR(20)			'$.HighestOff',			
		YardType				VARCHAR(20)			'$.YardType',			
		DrayBaseValue			NUMERIC(18,2)		'$.DrayBaseValue',		
		EffectiveDate			DATETIME			'$.EffectiveDateFrom',		
		EffectiveFromKey		INT					'$.EffectiveFromKey',	
		SellConfigKey			INT					'$.SellConfigKey'
	)


	if(isnull(@MarketKey,0) = 0 OR 
		isnull(@ZoneKey,0) = 0 OR
		isnull(@TerminalKey,0) = 0)
	Begin
		set @Status = 0
		Set @Reason = 'Market / Terminal / Zone data missing'
		return
	End

	if(isnull(@IsPrePull,0) = 1 and isnull(@PrePullCost,0) = 0)
	Begin
		set @Status = 0
		Set @Reason = 'PrePull Cost is missing'
		return
	End

	if(isnull(@IsStopOff,0) = 1 and isnull(@StopOffCost,0) = 0)
	Begin
		set @Status = 0
		Set @Reason = 'StopOff Cost is missing'
		return
	End

	if(isnull(@HighestOff,'') = '')
	Begin
		set @Status = 0
		Set @Reason = 'Highest Off is missing'
		return

	End
	if(isnull(@YardType,'') = '')
	Begin
		set @Status = 0
		Set @Reason = 'Yard Type is missing'
		return

	End

	if(isnull(@DrayBaseValue,0) = 0)
	Begin
		set @Status = 0
		Set @Reason = 'DrayBase Cost is missing'
		return
	End
	if(isnull(@EffectiveDate,'') = '')
	Begin
		set @Status = 0
		Set @Reason = 'Effective Date is missing'
		return

	End
	if(isnull(@EffectiveFromKey,0) = 0)
	Begin
		set @Status = 0
		Set @Reason = 'Effective From Key is missing'
		return

	End
	if(isnull(@UserKey,0) = 0)
	Begin
		set @Status = 0
		Set @Reason = 'User Key is missing'
		return

	End
	if(isnull(@SellConfigKey ,0) = 0)
	Begin
		insert into Sell_Config (MarketKey, ZoneKey, TerminalKey, IsPrePull, PrePullValue, IsStopOff, StopOffValue, 
				HighestOff, DrayBaseValue, Effective_date, EffectiveFromKey, YardType, CreateDate, CreateUser)
		select @MarketKey, @ZoneKey, @TerminalKey, @IsPrePull, @PrePullCost, @IsStopOff, @StopOffCost,
				@HighestOff, @DrayBaseValue,@EffectiveDate, @EffectiveFromKey, @YardType , GETDATE(),  @UserKey
		set @SellConfigKey = SCOPE_IDENTITY()
		set @Status = 1
	Set @Reason = 'Record inserted successfully'
	End
	else
	Begin
		insert into Sell_Config_History (SellConfigKey, MarketKey, ZoneKey, TerminalKey, IsPrePull, PrePullValue, IsStopOff, 
				StopOffValue, HighestOff, DrayBaseValue, Effective_date, EffectiveFromKey, YardType, CreateDate, CreateUser, UpdateDate, UpdateUser)
		Select SellConfigKey, MarketKey, ZoneKey, TerminalKey, IsPrePull, PrePullValue, IsStopOff, 
				StopOffValue, HighestOff, DrayBaseValue, Effective_date, EffectiveFromKey, @YardType, CreateDate, CreateUser, UpdateDate, UpdateUser
		from Sell_Config WITH(NOLOCK)
		where SellConfigKey = @SellConfigKey

		update Sell_Config set
			IsPrePull = @IsPrePull,
			PrePullValue = @PrePullCost,
			IsStopOff = @IsStopOff,
			StopOffValue = @StopOffCost,
			HighestOff = @HighestOff,
			DrayBaseValue = @DrayBaseValue,
			Effective_date = @EffectiveDate,
			EffectiveFromKey = @EffectiveFromKey,
			YardType = @YardType,
			UpdateDate = GetDate(),
			UpdateUser = @UserKey
		where SellConfigKey = @SellConfigKey
	set @Status = 1
	Set @Reason = 'Record updated successfully'
	End	
END
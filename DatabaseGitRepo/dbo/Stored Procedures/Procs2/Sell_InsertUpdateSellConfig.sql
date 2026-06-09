

CREATE proc [dbo].[Sell_InsertUpdateSellConfig]
(
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
	@UserKey		int,
	@SellConfigKey	int = 0 output,
	@Status			Bit = 0 output,
	@Reason			varchar(200) = '' output 
)
As
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

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
		from Sell_Config
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

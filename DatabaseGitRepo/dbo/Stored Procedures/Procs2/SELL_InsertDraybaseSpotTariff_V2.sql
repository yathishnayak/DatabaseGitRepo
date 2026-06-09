/** 
Declare 
	@UserKey		INT = 1144,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING NVARCHAR(MAX) = '[{"Market":"Chicago","Terminal":"Joliet","Zone":"1","City":"Channahon","State":"IL","Zipcode":"60410","DrayBase_Cost":174,"FSF":0,"FSFCost":0,"YardPortType":"Port","RecordRank":1,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":260.11,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":312.13,"SMB_Margin":0.2,"SMB_FSFPercent":0.35,"ENT_DrayBaseRate":299.13,"ENT_Margin":0.15,"ENT_FSFPercent":0.35,"NAC_DrayBaseRate":260.11,"NAC_Margin":0,"NAC_FSFPercent":0.35,"SMB_FSFValue":109.25,"SMB_Total":421.38,"SMB_NetRevenue":161.27,"ENT_FSFValue":104.7,"ENT_Total":403.83,"ENT_NetRevenue":143.72},{"Market":"Chicago","Terminal":"Joliet","Zone":"1","city":"Channahon","state":"IL","Zipcode":"60410","DrayBase_Cost":174,"FSF":0,"FSFCost":0,"YardPortType":"Local","RecordRank":2,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":260.11,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":312.13,"SMB_Margin":0.2,"SMB_FSFPercent":0.35,"ENT_DrayBaseRate":299.13,"ENT_Margin":0.15,"ENT_FSFPercent":0.35,"NAC_DrayBaseRate":260.11,"NAC_Margin":0,"NAC_FSFPercent":0.35,"SMB_FSFValue":109.25,"SMB_Total":421.38,"SMB_NetRevenue":161.27,"ENT_FSFValue":104.7,"ENT_Total":403.83,"ENT_NetRevenue":143.72},{"Market":"Chicago","Terminal":"Joliet","Zone":"1","city":"Channahon","state":"IL","Zipcode":"60410","DrayBase_Cost":120,"FSF":0.42,"FSFCost":0.35,"YardPortType":"Local","RecordRank":3,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":206.46,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":247.75,"SMB_Margin":0.2,"SMB_FSFPercent":0,"ENT_DrayBaseRate":237.43,"ENT_Margin":0.15,"ENT_FSFPercent":0,"NAC_DrayBaseRate":206.46,"NAC_Margin":0,"NAC_FSFPercent":0,"SMB_FSFValue":0,"SMB_Total":247.75,"SMB_NetRevenue":41.29,"ENT_FSFValue":0,"ENT_Total":237.43,"ENT_NetRevenue":30.97},{"Market":"Chicago","Terminal":"Joliet","Zone":"1","city":"Channahon","state":"IL","Zipcode":"60410","DrayBase_Cost":120,"FSF":0.42,"FSFCost":0.35,"YardPortType":"Port","RecordRank":4,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":206.46,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":247.75,"SMB_Margin":0.2,"SMB_FSFPercent":0,"ENT_DrayBaseRate":237.43,"ENT_Margin":0.15,"ENT_FSFPercent":0,"NAC_DrayBaseRate":206.46,"NAC_Margin":0,"NAC_FSFPercent":0,"SMB_FSFValue":0,"SMB_Total":247.75,"SMB_NetRevenue":41.29,"ENT_FSFValue":0,"ENT_Total":237.43,"ENT_NetRevenue":30.97},{"Market":"Chicago","Terminal":"Joliet","Zone":"1","city":"CRESTHILL","state":"IL","Zipcode":"60403","DrayBase_Cost":174,"FSF":0,"FSFCost":0,"YardPortType":"Port","RecordRank":1,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":260.11,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":312.13,"SMB_Margin":0.2,"SMB_FSFPercent":0.35,"ENT_DrayBaseRate":299.13,"ENT_Margin":0.15,"ENT_FSFPercent":0.35,"NAC_DrayBaseRate":260.11,"NAC_Margin":0,"NAC_FSFPercent":0.35,"SMB_FSFValue":109.25,"SMB_Total":421.38,"SMB_NetRevenue":161.27,"ENT_FSFValue":104.7,"ENT_Total":403.83,"ENT_NetRevenue":143.72},{"Market":"Chicago","Terminal":"Joliet","Zone":"1","city":"CRESTHILL","state":"IL","Zipcode":"60403","DrayBase_Cost":174,"FSF":0,"FSFCost":0,"YardPortType":"Local","RecordRank":2,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":260.11,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":312.13,"SMB_Margin":0.2,"SMB_FSFPercent":0.35,"ENT_DrayBaseRate":299.13,"ENT_Margin":0.15,"ENT_FSFPercent":0.35,"NAC_DrayBaseRate":260.11,"NAC_Margin":0,"NAC_FSFPercent":0.35,"SMB_FSFValue":109.25,"SMB_Total":421.38,"SMB_NetRevenue":161.27,"ENT_FSFValue":104.7,"ENT_Total":403.83,"ENT_NetRevenue":143.72},{"Market":"Chicago","Terminal":"Joliet","Zone":"1","city":"CRESTHILL","state":"IL","Zipcode":"60403","DrayBase_Cost":162,"FSF":0.567,"FSFCost":0.35,"YardPortType":"Local","RecordRank":3,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":248.46,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":298.15,"SMB_Margin":0.2,"SMB_FSFPercent":0.01,"ENT_DrayBaseRate":285.73,"ENT_Margin":0.15,"ENT_FSFPercent":0.01,"NAC_DrayBaseRate":248.46,"NAC_Margin":0,"NAC_FSFPercent":0.01,"SMB_FSFValue":2.98,"SMB_Total":301.13,"SMB_NetRevenue":52.67,"ENT_FSFValue":2.86,"ENT_Total":288.59,"ENT_NetRevenue":40.13},{"Market":"Chicago","Terminal":"Joliet","Zone":"1","city":"CRESTHILL","state":"IL","Zipcode":"60403","DrayBase_Cost":162,"FSF":0.567,"FSFCost":0.35,"YardPortType":"Port","RecordRank":4,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":248.46,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":298.15,"SMB_Margin":0.2,"SMB_FSFPercent":0.01,"ENT_DrayBaseRate":285.73,"ENT_Margin":0.15,"ENT_FSFPercent":0.01,"NAC_DrayBaseRate":248.46,"NAC_Margin":0,"NAC_FSFPercent":0.01,"SMB_FSFValue":2.98,"SMB_Total":301.13,"SMB_NetRevenue":52.67,"ENT_FSFValue":2.86,"ENT_Total":288.59,"ENT_NetRevenue":40.13},{"Market":"Chicago","Terminal":"Joliet","Zone":"1","city":"Elwood","state":"IL","Zipcode":"60421","DrayBase_Cost":174,"FSF":0,"FSFCost":0,"YardPortType":"Port","RecordRank":1,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":260.11,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":312.13,"SMB_Margin":0.2,"SMB_FSFPercent":0.35,"ENT_DrayBaseRate":299.13,"ENT_Margin":0.15,"ENT_FSFPercent":0.35,"NAC_DrayBaseRate":260.11,"NAC_Margin":0,"NAC_FSFPercent":0.35,"SMB_FSFValue":109.25,"SMB_Total":421.38,"SMB_NetRevenue":161.27,"ENT_FSFValue":104.7,"ENT_Total":403.83,"ENT_NetRevenue":143.72},{"Market":"Chicago","Terminal":"Joliet","Zone":"1","city":"Elwood","state":"IL","Zipcode":"60421","DrayBase_Cost":174,"FSF":0,"FSFCost":0,"YardPortType":"Local","RecordRank":2,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":260.11,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":312.13,"SMB_Margin":0.2,"SMB_FSFPercent":0.35,"ENT_DrayBaseRate":299.13,"ENT_Margin":0.15,"ENT_FSFPercent":0.35,"NAC_DrayBaseRate":260.11,"NAC_Margin":0,"NAC_FSFPercent":0.35,"SMB_FSFValue":109.25,"SMB_Total":421.38,"SMB_NetRevenue":161.27,"ENT_FSFValue":104.7,"ENT_Total":403.83,"ENT_NetRevenue":143.72},{"Market":"Chicago","Terminal":"Joliet","Zone":"1","city":"Elwood","state":"IL","Zipcode":"60421","DrayBase_Cost":162,"FSF":0.567,"FSFCost":0.35,"YardPortType":"Local","RecordRank":3,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":248.46,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":298.15,"SMB_Margin":0.2,"SMB_FSFPercent":0.01,"ENT_DrayBaseRate":285.73,"ENT_Margin":0.15,"ENT_FSFPercent":0.01,"NAC_DrayBaseRate":248.46,"NAC_Margin":0,"NAC_FSFPercent":0.01,"SMB_FSFValue":2.98,"SMB_Total":301.13,"SMB_NetRevenue":52.67,"ENT_FSFValue":2.86,"ENT_Total":288.59,"ENT_NetRevenue":40.13},{"Market":"Chicago","Terminal":"Joliet","Zone":"1","city":"Elwood","state":"IL","Zipcode":"60421","DrayBase_Cost":162,"FSF":0.567,"FSFCost":0.35,"YardPortType":"Port","RecordRank":4,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":248.46,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":298.15,"SMB_Margin":0.2,"SMB_FSFPercent":0.01,"ENT_DrayBaseRate":285.73,"ENT_Margin":0.15,"ENT_FSFPercent":0.01,"NAC_DrayBaseRate":248.46,"NAC_Margin":0,"NAC_FSFPercent":0.01,"SMB_FSFValue":2.98,"SMB_Total":301.13,"SMB_NetRevenue":52.67,"ENT_FSFValue":2.86,"ENT_Total":288.59,"ENT_NetRevenue":40.13},{"Market":"Chicago","Terminal":"Joliet","Zone":"1","city":"JOLIET","state":"IL","Zipcode":null,"DrayBase_Cost":174,"FSF":0,"FSFCost":0,"YardPortType":"Port","RecordRank":1,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":260.11,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":312.13,"SMB_Margin":0.2,"SMB_FSFPercent":0.35,"ENT_DrayBaseRate":299.13,"ENT_Margin":0.15,"ENT_FSFPercent":0.35,"NAC_DrayBaseRate":260.11,"NAC_Margin":0,"NAC_FSFPercent":0.35,"SMB_FSFValue":109.25,"SMB_Total":421.38,"SMB_NetRevenue":161.27,"ENT_FSFValue":104.7,"ENT_Total":403.83,"ENT_NetRevenue":143.72},{"Market":"Chicago","Terminal":"Joliet","Zone":"1","city":"JOLIET","state":"IL","Zipcode":null,"DrayBase_Cost":174,"FSF":0,"FSFCost":0,"YardPortType":"Local","RecordRank":2,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":260.11,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":312.13,"SMB_Margin":0.2,"SMB_FSFPercent":0.35,"ENT_DrayBaseRate":299.13,"ENT_Margin":0.15,"ENT_FSFPercent":0.35,"NAC_DrayBaseRate":260.11,"NAC_Margin":0,"NAC_FSFPercent":0.35,"SMB_FSFValue":109.25,"SMB_Total":421.38,"SMB_NetRevenue":161.27,"ENT_FSFValue":104.7,"ENT_Total":403.83,"ENT_NetRevenue":143.72},{"Market":"Chicago","Terminal":"Joliet","Zone":"1","city":"JOLIET","state":"IL","Zipcode":null,"DrayBase_Cost":162,"FSF":0.567,"FSFCost":0.35,"YardPortType":"Local","RecordRank":3,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":248.46,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":298.15,"SMB_Margin":0.2,"SMB_FSFPercent":0.01,"ENT_DrayBaseRate":285.73,"ENT_Margin":0.15,"ENT_FSFPercent":0.01,"NAC_DrayBaseRate":248.46,"NAC_Margin":0,"NAC_FSFPercent":0.01,"SMB_FSFValue":2.98,"SMB_Total":301.13,"SMB_NetRevenue":52.67,"ENT_FSFValue":2.86,"ENT_Total":288.59,"ENT_NetRevenue":40.13},{"Market":"Chicago","Terminal":"Joliet","Zone":"1","city":"JOLIET","state":"IL","Zipcode":null,"DrayBase_Cost":162,"FSF":0.567,"FSFCost":0.35,"YardPortType":"Port","RecordRank":4,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":248.46,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":298.15,"SMB_Margin":0.2,"SMB_FSFPercent":0.01,"ENT_DrayBaseRate":285.73,"ENT_Margin":0.15,"ENT_FSFPercent":0.01,"NAC_DrayBaseRate":248.46,"NAC_Margin":0,"NAC_FSFPercent":0.01,"SMB_FSFValue":2.98,"SMB_Total":301.13,"SMB_NetRevenue":52.67,"ENT_FSFValue":2.86,"ENT_Total":288.59,"ENT_NetRevenue":40.13},{"Market":"Chicago","Terminal":"Joliet","Zone":"1","city":"LOCKPORT","state":"IL","Zipcode":"60441","DrayBase_Cost":174,"FSF":0,"FSFCost":0,"YardPortType":"Port","RecordRank":1,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":260.11,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":312.13,"SMB_Margin":0.2,"SMB_FSFPercent":0.35,"ENT_DrayBaseRate":299.13,"ENT_Margin":0.15,"ENT_FSFPercent":0.35,"NAC_DrayBaseRate":260.11,"NAC_Margin":0,"NAC_FSFPercent":0.35,"SMB_FSFValue":109.25,"SMB_Total":421.38,"SMB_NetRevenue":161.27,"ENT_FSFValue":104.7,"ENT_Total":403.83,"ENT_NetRevenue":143.72},{"Market":"Chicago","Terminal":"Joliet","Zone":"1","city":"LOCKPORT","state":"IL","Zipcode":"60441","DrayBase_Cost":174,"FSF":0,"FSFCost":0,"YardPortType":"Local","RecordRank":2,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":260.11,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":312.13,"SMB_Margin":0.2,"SMB_FSFPercent":0.35,"ENT_DrayBaseRate":299.13,"ENT_Margin":0.15,"ENT_FSFPercent":0.35,"NAC_DrayBaseRate":260.11,"NAC_Margin":0,"NAC_FSFPercent":0.35,"SMB_FSFValue":109.25,"SMB_Total":421.38,"SMB_NetRevenue":161.27,"ENT_FSFValue":104.7,"ENT_Total":403.83,"ENT_NetRevenue":143.72},{"Market":"Chicago","Terminal":"Joliet","Zone":"1","city":"LOCKPORT","state":"IL","Zipcode":"60441","DrayBase_Cost":162,"FSF":0.567,"FSFCost":0.35,"YardPortType":"Local","RecordRank":3,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":248.46,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":298.15,"SMB_Margin":0.2,"SMB_FSFPercent":0.01,"ENT_DrayBaseRate":285.73,"ENT_Margin":0.15,"ENT_FSFPercent":0.01,"NAC_DrayBaseRate":248.46,"NAC_Margin":0,"NAC_FSFPercent":0.01,"SMB_FSFValue":2.98,"SMB_Total":301.13,"SMB_NetRevenue":52.67,"ENT_FSFValue":2.86,"ENT_Total":288.59,"ENT_NetRevenue":40.13},{"Market":"Chicago","Terminal":"Joliet","Zone":"1","city":"LOCKPORT","state":"IL","Zipcode":"60441","DrayBase_Cost":162,"FSF":0.567,"FSFCost":0.35,"YardPortType":"Port","RecordRank":4,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":248.46,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":298.15,"SMB_Margin":0.2,"SMB_FSFPercent":0.01,"ENT_DrayBaseRate":285.73,"ENT_Margin":0.15,"ENT_FSFPercent":0.01,"NAC_DrayBaseRate":248.46,"NAC_Margin":0,"NAC_FSFPercent":0.01,"SMB_FSFValue":2.98,"SMB_Total":301.13,"SMB_NetRevenue":52.67,"ENT_FSFValue":2.86,"ENT_Total":288.59,"ENT_NetRevenue":40.13},{"Market":"Chicago","Terminal":"Joliet","Zone":"1","city":"Minooka","state":"IL","Zipcode":"60447","DrayBase_Cost":174,"FSF":0,"FSFCost":0,"YardPortType":"Port","RecordRank":1,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":260.11,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":312.13,"SMB_Margin":0.2,"SMB_FSFPercent":0.35,"ENT_DrayBaseRate":299.13,"ENT_Margin":0.15,"ENT_FSFPercent":0.35,"NAC_DrayBaseRate":260.11,"NAC_Margin":0,"NAC_FSFPercent":0.35,"SMB_FSFValue":109.25,"SMB_Total":421.38,"SMB_NetRevenue":161.27,"ENT_FSFValue":104.7,"ENT_Total":403.83,"ENT_NetRevenue":143.72},{"Market":"Chicago","Terminal":"Joliet","Zone":"1","city":"Minooka","state":"IL","Zipcode":"60447","DrayBase_Cost":174,"FSF":0,"FSFCost":0,"YardPortType":"Local","RecordRank":2,"PrepullCost":86.11,"Prepulllocation":"Local","StopOffCost":86.11,"StopOfflocation":"Local","TotalCost":260.11,"IsPrePull":false,"PrePullValue":0,"IsStopOff":true,"StopOffValue":86.11,"HighestOff":"All","DrayBaseValue":218.7,"SMB_DrayBaseRate":312.13,"SMB_Margin":0.2,"SMB_FSFPercent":0.35,"ENT_DrayBaseRate":299.13,"ENT_Margin":0.15,"ENT_FSFPercent":0.35,"NAC_DrayBaseRate":260.11,"NAC_Margin":0,"NAC_FSFPercent":0.35,"SMB_FSFValue":109.25,"SMB_Total":421.38,"SMB_NetRevenue":161.27,"ENT_FSFValue":104.7,"ENT_Total":403.83,"ENT_NetRevenue":143.72}]'
	EXEC [SELL_InsertDraybaseSpotTariff_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[SELL_InsertDraybaseSpotTariff_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF(ISNULL(@UserKey,0) = 0)
	begin
		set @Status = 0
		Set @Reason = 'UserKey required'
		return
	end

	if(isnull(@JSONString,'') = '')
	Begin
		set @Status = 0
		Set @Reason = 'Sell Draybase Data required'
		return
	end

	select * into #TempData from Sell_DrayBaseSpotTariff where 1=0

	insert into #TempData ( MarketKey, TerminalKey, City, State, ZipCode, ZoneKey, 
		DrayBaseValue, 
		SMB_Margin, SMB_MarginValue, SMB_DrayBaseRate, SMB_FSF, SMB_FSFValue, SMB_DraybaseTotal, SMB_NetRevenue, 
		ENT_Margin, ENT_MarginValue, ENT_DrayBaseRate, ENT_FSF, ENT_FSFValue, ENT_DraybaseTotal, ENT_NetRevenue, 
		DateCreated, UserCreated, TruckType)
	select MarketKey, TerminalKey, City, State, ZipCode, ZoneKey, 
		DrayBaseValue, 
		SMB_Margin, SMB_MarginValue, SMB_DrayBaseRate, SMB_FSF, SMB_FSFValue, SMB_DraybaseTotal, SMB_NetRevenue, 
		ENT_Margin, ENT_MarginValue, ENT_DrayBaseRate, ENT_FSF, ENT_FSFValue, ENT_DraybaseTotal, ENT_NetRevenue, 
		GetDate(), @UserKey, TruckType
	from OpenJSON(@JSONString, '$')
	WITH (
		MarketKey				int				'$.MarketLocationKey',
		TerminalKey				int				'$.TerminalKey',
		City					varchar(50)		'$.City',
		State					varchar(20)		'$.State',
		ZipCode					varchar(10)		'$.ZipCode',
		ZoneKey					int				'$.ZoneKey',
		DrayBaseValue			decimal(18,2)	'$.DrayBase_Cost',
		SMB_Margin				decimal(18,2)	'$.SMB_Margin',
		SMB_MarginValue			decimal(18,2)	'$.SMB_MarginValue',
		SMB_DrayBaseRate		decimal(18,2)	'$.SMB_DrayBaseRate',
		SMB_FSF					decimal(18,2)	'$.SMB_FSFPercent',
		SMB_FSFValue			decimal(18,2)	'$.SMB_FSFValue',
		SMB_DraybaseTotal		decimal(18,2)	'$.SMB_Total',
		SMB_NetRevenue			decimal(18,2)	'$.SMB_NetRevenue',
		ENT_Margin				decimal(18,2)	'$.ENT_Margin',
		ENT_MarginValue			decimal(18,2)	'$.ENT_MarginValue',
		ENT_DrayBaseRate		decimal(18,2)	'$.ENT_DrayBaseRate',
		ENT_FSF					decimal(18,2)	'$.ENT_FSFPercent',
		ENT_FSFValue			decimal(18,2)	'$.ENT_FSFValue',
		ENT_DraybaseTotal		decimal(18,2)	'$.ENT_Total',
		ENT_NetRevenue			decimal(18,2)	'$.ENT_NetRevenue',
		TruckType				varchar(50)		'$.HighestOff'
	)

	if((select count(1) from #TempData )>0)
	Begin
		Begin Try
			Begin Transaction Tran1
			insert into Sell_DrayBaseSpotTariff_History(MarketKey, TerminalKey, City, State, ZipCode, ZoneKey, 
				DrayBaseValue, SMB_Margin, SMB_MarginValue, SMB_DrayBaseRate, SMB_FSF, SMB_FSFValue, SMB_DraybaseTotal, SMB_NetRevenue, 
				ENT_Margin, ENT_MarginValue, ENT_DrayBaseRate, ENT_FSF, ENT_FSFValue, ENT_DraybaseTotal, ENT_NetRevenue, 
				DateCreated, UserCreated, TruckType )
			select MarketKey, TerminalKey, City, State, ZipCode, ZoneKey, 
				DrayBaseValue, SMB_Margin, SMB_MarginValue, SMB_DrayBaseRate, SMB_FSF, SMB_FSFValue, SMB_DraybaseTotal, SMB_NetRevenue, 
				ENT_Margin, ENT_MarginValue, ENT_DrayBaseRate, ENT_FSF, ENT_FSFValue, ENT_DraybaseTotal, ENT_NetRevenue, 
				DateCreated, UserCreated, TruckType
			from Sell_DrayBaseSpotTariff WITH(NOLOCK)
			

			Delete from Sell_DrayBaseSpotTariff
			

			insert into Sell_DrayBaseSpotTariff (MarketKey, TerminalKey, City, State, ZipCode, ZoneKey, 
				DrayBaseValue, SMB_Margin, SMB_MarginValue, SMB_DrayBaseRate, SMB_FSF, SMB_FSFValue, SMB_DraybaseTotal, SMB_NetRevenue, 
				ENT_Margin, ENT_MarginValue, ENT_DrayBaseRate, ENT_FSF, ENT_FSFValue, ENT_DraybaseTotal, ENT_NetRevenue, 
				DateCreated, UserCreated, TruckType)
			select MarketKey, TerminalKey, City, State, ZipCode, ZoneKey, 
				DrayBaseValue, SMB_Margin, SMB_MarginValue, SMB_DrayBaseRate, SMB_FSF, SMB_FSFValue, SMB_DraybaseTotal, SMB_NetRevenue, 
				ENT_Margin, ENT_MarginValue, ENT_DrayBaseRate, ENT_FSF, ENT_FSFValue, ENT_DraybaseTotal, ENT_NetRevenue, 
				Getdate(), UserCreated, TruckType
			from #TempData T
			
			
			commit transaction Tran1
			set @Status = 1
			Set @Reason = 'Saved Successfully'
		return
		end try
		begin catch
			set @Status = 0
			Set @Reason = 'ERROR: ' + ERROR_MESSAGE()
			rollback transaction tran1
		end catch
	End
	ELSE
	Begin
		set @Status = 0
		Set @Reason = 'No proper records found to Save'
		return
	End
END
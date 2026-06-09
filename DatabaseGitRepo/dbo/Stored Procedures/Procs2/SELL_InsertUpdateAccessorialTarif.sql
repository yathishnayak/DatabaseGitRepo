/*
DECLARE @UserKey int =29, @JSONString	nvarchar(max) = '', @Status	bit = 0 , @Reason	varchar(200) = '' 
SET @JSONString = '[{"MarketLocationKey":2,"Market":"Long Beach","LineItem":"20% FUEL CHARGE","YardPort":"","ZoneKey":0,"Zone":"","Group":"DRAYAGE","UnitCost":"0.00","Per":"Occurence","SellAccRateKey":0,"SMB_Margin":20,"SMB_Rate":"25.00","SMB_BvsNB":"B","SMB_FreeTime":"2","SMB_Min":"1","SMB_Max":"5","SMB_NetRevenue":"5.00","SMB_Date":"1900-01-01T00:00:00","SMB_UserKey":0,"SMB_UserName":"","ENT_Margin":0,"ENT_Rate":0,"ENT_BvsNB":"","ENT_FreeTime":0,"ENT_Min":0,"ENT_Max":0,"ENT_NetRevenue":0,"ENT_Date":"1900-01-01T00:00:00","ENT_UserKey":0,"ENT_UserName":"","NAC_Margin":0,"NAC_Rate":0,"NAC_BvsNB":"","NAC_FreeTime":0,"NAC_Min":0,"NAC_Max":0,"NAC_NetRevenue":0,"NAC_Date":"1900-01-01T00:00:00","NAC_UserKey":0,"NAC_UserName":""},{"MarketLocationKey":2,"Market":"Long Beach","LineItem":"25% FUEL CHARGE","YardPort":"","ZoneKey":0,"Zone":"","Group":"DRAYAGE","UnitCost":"0.00","Per":"Occurence","SellAccRateKey":0,"SMB_Margin":15,"SMB_Rate":"40","SMB_BvsNB":"NB","SMB_FreeTime":"3","SMB_Min":"2","SMB_Max":"6","SMB_NetRevenue":"25","SMB_Date":"1900-01-01T00:00:00","SMB_UserKey":0,"SMB_UserName":"","ENT_Margin":0,"ENT_Rate":0,"ENT_BvsNB":"","ENT_FreeTime":0,"ENT_Min":0,"ENT_Max":0,"ENT_NetRevenue":0,"ENT_Date":"1900-01-01T00:00:00","ENT_UserKey":0,"ENT_UserName":"","NAC_Margin":0,"NAC_Rate":0,"NAC_BvsNB":"","NAC_FreeTime":0,"NAC_Min":0,"NAC_Max":0,"NAC_NetRevenue":0,"NAC_Date":"1900-01-01T00:00:00","NAC_UserKey":0,"NAC_UserName":""},{"MarketLocationKey":2,"Market":"Long Beach","LineItem":"30% FUEL CHARGE","YardPort":"","ZoneKey":0,"Zone":"","Group":"DRAYAGE","UnitCost":"0.00","Per":"Occurence","SellAccRateKey":0,"SMB_Margin":8,"SMB_Rate":"10.00","SMB_BvsNB":"B","SMB_FreeTime":"4","SMB_Min":"3","SMB_Max":"7","SMB_NetRevenue":"2","SMB_Date":"1900-01-01T00:00:00","SMB_UserKey":0,"SMB_UserName":"","ENT_Margin":0,"ENT_Rate":0,"ENT_BvsNB":"","ENT_FreeTime":0,"ENT_Min":0,"ENT_Max":0,"ENT_NetRevenue":0,"ENT_Date":"1900-01-01T00:00:00","ENT_UserKey":0,"ENT_UserName":"","NAC_Margin":0,"NAC_Rate":0,"NAC_BvsNB":"","NAC_FreeTime":0,"NAC_Min":0,"NAC_Max":0,"NAC_NetRevenue":0,"NAC_Date":"1900-01-01T00:00:00","NAC_UserKey":0,"NAC_UserName":""},{"MarketLocationKey":2,"Market":"Long Beach","LineItem":"35% FULE CHARGE","YardPort":"","ZoneKey":0,"Zone":"","Group":"DRAYAGE","UnitCost":"0.00","Per":"Occurence","SellAccRateKey":0,"SMB_Margin":0,"SMB_Rate":0,"SMB_BvsNB":"","SMB_FreeTime":0,"SMB_Min":0,"SMB_Max":0,"SMB_NetRevenue":0,"SMB_Date":"1900-01-01T00:00:00","SMB_UserKey":0,"SMB_UserName":"","ENT_Margin":0,"ENT_Rate":0,"ENT_BvsNB":"","ENT_FreeTime":0,"ENT_Min":0,"ENT_Max":0,"ENT_NetRevenue":0,"ENT_Date":"1900-01-01T00:00:00","ENT_UserKey":0,"ENT_UserName":"","NAC_Margin":0,"NAC_Rate":0,"NAC_BvsNB":"","NAC_FreeTime":0,"NAC_Min":0,"NAC_Max":0,"NAC_NetRevenue":0,"NAC_Date":"1900-01-01T00:00:00","NAC_UserKey":0,"NAC_UserName":""},{"MarketLocationKey":2,"Market":"Long Beach","LineItem":"ADJUSTMENTS","YardPort":"","ZoneKey":0,"Zone":"","Group":"DRAYAGE","UnitCost":"0.00","Per":"Occurence","SellAccRateKey":0,"SMB_Margin":0,"SMB_Rate":0,"SMB_BvsNB":"","SMB_FreeTime":0,"SMB_Min":0,"SMB_Max":0,"SMB_NetRevenue":0,"SMB_Date":"1900-01-01T00:00:00","SMB_UserKey":0,"SMB_UserName":"","ENT_Margin":0,"ENT_Rate":0,"ENT_BvsNB":"","ENT_FreeTime":0,"ENT_Min":0,"ENT_Max":0,"ENT_NetRevenue":0,"ENT_Date":"1900-01-01T00:00:00","ENT_UserKey":0,"ENT_UserName":"","NAC_Margin":0,"NAC_Rate":0,"NAC_BvsNB":"","NAC_FreeTime":0,"NAC_Min":0,"NAC_Max":0,"NAC_NetRevenue":0,"NAC_Date":"1900-01-01T00:00:00","NAC_UserKey":0,"NAC_UserName":""},{"MarketLocationKey":2,"Market":"Long Beach","LineItem":"Administrative Fee","YardPort":"","ZoneKey":0,"Zone":"","Group":"DRAYAGE","UnitCost":"0.00","Per":"Occurence","SellAccRateKey":0,"SMB_Margin":0,"SMB_Rate":0,"SMB_BvsNB":"","SMB_FreeTime":0,"SMB_Min":0,"SMB_Max":0,"SMB_NetRevenue":0,"SMB_Date":"1900-01-01T00:00:00","SMB_UserKey":0,"SMB_UserName":"","ENT_Margin":0,"ENT_Rate":0,"ENT_BvsNB":"","ENT_FreeTime":0,"ENT_Min":0,"ENT_Max":0,"ENT_NetRevenue":0,"ENT_Date":"1900-01-01T00:00:00","ENT_UserKey":0,"ENT_UserName":"","NAC_Margin":0,"NAC_Rate":0,"NAC_BvsNB":"","NAC_FreeTime":0,"NAC_Min":0,"NAC_Max":0,"NAC_NetRevenue":0,"NAC_Date":"1900-01-01T00:00:00","NAC_UserKey":0,"NAC_UserName":""},{"MarketLocationKey":2,"Market":"Long Beach","LineItem":"Administrative Fee","YardPort":"","ZoneKey":0,"Zone":"","Group":"Warehouse","UnitCost":"25.00","Per":"Occurence","SellAccRateKey":0,"SMB_Margin":0,"SMB_Rate":0,"SMB_BvsNB":"","SMB_FreeTime":0,"SMB_Min":0,"SMB_Max":0,"SMB_NetRevenue":0,"SMB_Date":"1900-01-01T00:00:00","SMB_UserKey":0,"SMB_UserName":"","ENT_Margin":0,"ENT_Rate":0,"ENT_BvsNB":"","ENT_FreeTime":0,"ENT_Min":0,"ENT_Max":0,"ENT_NetRevenue":0,"ENT_Date":"1900-01-01T00:00:00","ENT_UserKey":0,"ENT_UserName":"","NAC_Margin":0,"NAC_Rate":0,"NAC_BvsNB":"","NAC_FreeTime":0,"NAC_Min":0,"NAC_Max":0,"NAC_NetRevenue":0,"NAC_Date":"1900-01-01T00:00:00","NAC_UserKey":0,"NAC_UserName":""},{"MarketLocationKey":2,"Market":"Long Beach","LineItem":"AFTER HOURS P/U","YardPort":"","ZoneKey":0,"Zone":"","Group":"DRAYAGE","UnitCost":"0.00","Per":"Occurence","SellAccRateKey":0,"SMB_Margin":0,"SMB_Rate":0,"SMB_BvsNB":"","SMB_FreeTime":0,"SMB_Min":0,"SMB_Max":0,"SMB_NetRevenue":0,"SMB_Date":"1900-01-01T00:00:00","SMB_UserKey":0,"SMB_UserName":"","ENT_Margin":0,"ENT_Rate":0,"ENT_BvsNB":"","ENT_FreeTime":0,"ENT_Min":0,"ENT_Max":0,"ENT_NetRevenue":0,"ENT_Date":"1900-01-01T00:00:00","ENT_UserKey":0,"ENT_UserName":"","NAC_Margin":0,"NAC_Rate":0,"NAC_BvsNB":"","NAC_FreeTime":0,"NAC_Min":0,"NAC_Max":0,"NAC_NetRevenue":0,"NAC_Date":"1900-01-01T00:00:00","NAC_UserKey":0,"NAC_UserName":""},{"MarketLocationKey":2,"Market":"Long Beach","LineItem":"AFTER HOURS P/U","YardPort":"","ZoneKey":0,"Zone":"","Group":"Drayage","UnitCost":"50.00","Per":"Occurence","SellAccRateKey":0,"SMB_Margin":0,"SMB_Rate":0,"SMB_BvsNB":"","SMB_FreeTime":0,"SMB_Min":0,"SMB_Max":0,"SMB_NetRevenue":0,"SMB_Date":"1900-01-01T00:00:00","SMB_UserKey":0,"SMB_UserName":"","ENT_Margin":0,"ENT_Rate":0,"ENT_BvsNB":"","ENT_FreeTime":0,"ENT_Min":0,"ENT_Max":0,"ENT_NetRevenue":0,"ENT_Date":"1900-01-01T00:00:00","ENT_UserKey":0,"ENT_UserName":"","NAC_Margin":0,"NAC_Rate":0,"NAC_BvsNB":"","NAC_FreeTime":0,"NAC_Min":0,"NAC_Max":0,"NAC_NetRevenue":0,"NAC_Date":"1900-01-01T00:00:00","NAC_UserKey":0,"NAC_UserName":""},{"MarketLocationKey":2,"Market":"Long Beach","LineItem":"Airbags","YardPort":"","ZoneKey":0,"Zone":"","Group":"Drayage","UnitCost":"5.00","Per":"Occurence","SellAccRateKey":0,"SMB_Margin":0,"SMB_Rate":0,"SMB_BvsNB":"","SMB_FreeTime":0,"SMB_Min":0,"SMB_Max":0,"SMB_NetRevenue":0,"SMB_Date":"1900-01-01T00:00:00","SMB_UserKey":0,"SMB_UserName":"","ENT_Margin":0,"ENT_Rate":0,"ENT_BvsNB":"","ENT_FreeTime":0,"ENT_Min":0,"ENT_Max":0,"ENT_NetRevenue":0,"ENT_Date":"1900-01-01T00:00:00","ENT_UserKey":0,"ENT_UserName":"","NAC_Margin":0,"NAC_Rate":0,"NAC_BvsNB":"","NAC_FreeTime":0,"NAC_Min":0,"NAC_Max":0,"NAC_NetRevenue":0,"NAC_Date":"1900-01-01T00:00:00","NAC_UserKey":0,"NAC_UserName":""}]'
EXEC SELL_InsertUpdateAccessorialTarif @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT
SELECT @Status, @Reason
*/

CREATE PROC [dbo].[SELL_InsertUpdateAccessorialTarif]
(
	@UserKey			int =0,
	@JSONString			nvarchar(max) = '',
	@Status				bit = 0 OUTPUT,
	@Reason				varchar(200) = '' OUTPUT
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF(ISNULL(@UserKey,0) = 0)
	BEGIN
		SET @Status = 0
		SET @Reason = 'User information missing'
		return;
	END
	IF(ISNULL(@JSONString,'') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'Data missing'
		return;
	END

	select * into #ACC_DATA from Sell_AccessorialRates WITH(NOLOCK) where 1 = 0
	set IDENTITY_INSERT #ACC_DATA ON 
	--Sell_AccessorialRates
	insert into #ACC_DATA (SellAccRateKey, MarketKey, ZoneKey, YardPort, LineItem, Cost, 
		SMB_Margin, SMB_Rate, SMB_BvsNB, SMB_FreeTime, SMB_Min, SMB_Max, SMB_NetRevenue, 
		ENT_Margin, ENT_Rate, ENT_BvsNB, ENT_FreeTime, ENT_Min, ENT_Max, ENT_NetRevenue, 
		NAC_Margin, NAC_Rate, NAC_BvsNB, NAC_FreeTime, NAC_Min, NAC_Max, NAC_NetRevenue)
	select SellAccRateKey, MarketKey, ZoneKey, YardPort, LineItem, Cost, 
		SMB_Margin, SMB_Rate, SMB_BvsNB, SMB_FreeTime, SMB_Min, SMB_Max, SMB_NetRevenue, 
		ENT_Margin, ENT_Rate, ENT_BvsNB, ENT_FreeTime, ENT_Min, ENT_Max, ENT_NetRevenue, 
		NAC_Margin, NAC_Rate, NAC_BvsNB, NAC_FreeTime, NAC_Min, NAC_Max, NAC_NetRevenue
	from OpenJSON(@JSONString,'$')
	with (
		SellAccRateKey		int				'$.SellAccRateKey',
		MarketKey			int				'$.MarketLocationKey',
		ZoneKey				int				'$.ZoneKey',
		YardPort			varchar(20)		'$.YardPort',
		LineItem			varchar(200)	'$.LineItem',
		Cost				numeric(18,2)	'$.UnitCost',
		SMB_Margin			numeric(18,2)	'$.SMB_Margin',
		SMB_Rate			numeric(18,2)	'$.SMB_Rate',
		SMB_BvsNB			varchar(5)		'$.SMB_BvsNB',
		SMB_FreeTime		int				'$.SMB_FreeTime',
		SMB_Min				int				'$.SMB_Min',
		SMB_Max				int				'$.SMB_Max',
		SMB_NetRevenue		numeric(18,2)	'$.SMB_NetRevenue',
		ENT_Margin			numeric(18,2)	'$.ENT_Margin',
		ENT_Rate			numeric(18,2)	'$.ENT_Rate',
		ENT_BvsNB			varchar(5)		'$.ENT_BvsNB',
		ENT_FreeTime		int				'$.ENT_FreeTime',
		ENT_Min				int				'$.ENT_Min',
		ENT_Max				int				'$.ENT_Max',
		ENT_NetRevenue		numeric(18,2)	'$.ENT_NetRevenue',
		NAC_Margin			numeric(18,2)	'$.NAC_Margin',
		NAC_Rate			numeric(18,2)	'$.NAC_Rate',
		NAC_BvsNB			varchar(5)		'$.NAC_BvsNB',
		NAC_FreeTime		int				'$.NAC_FreeTime',
		NAC_Min				int				'$.NAC_Min',
		NAC_Max				int				'$.NAC_Max',
		NAC_NetRevenue		numeric(18,2)	'$.NAC_NetRevenue'
	)

	set IDENTITY_INSERT #ACC_DATA off

	-- *** THIS IS REQUIRED AS MARGIN IS NOT ENTERED IN SCREEN
	update #ACC_DATA set SMB_Margin = isnull(SMB_Margin, (SMB_Rate - SMB_NetRevenue))
	where isnull(SMB_Rate,0) <> 0 and isnull(SMB_NetRevenue,0) <> 0 

	update #ACC_DATA set ENT_Margin = isnull(ENT_Margin, (ENT_Rate - ENT_NetRevenue))
	where isnull(ENT_Rate,0) <> 0 and isnull(ENT_NetRevenue,0) <> 0

	update #ACC_DATA set NAC_Margin = isnull(NAC_Margin, (NAC_Rate - NAC_NetRevenue))
	where isnull(NAC_Rate,0) <> 0 and isnull(NAC_NetRevenue,0) <> 0

	--SELECT * FROM #ACC_DATA

	IF((SELECT COUNT(1) FROM #ACC_DATA) > 0)
	BEGIN
		INSERT INTO Sell_AccessorialRates ( MarketKey, ZoneKey, YardPort, LineItem, Cost, 
			SMB_Margin, SMB_Rate, SMB_BvsNB, SMB_FreeTime, SMB_Min, SMB_Max, SMB_NetRevenue,SMB_Date, SMB_UserKey,
			ENT_Margin, ENT_Rate, ENT_BvsNB, ENT_FreeTime, ENT_Min, ENT_Max, ENT_NetRevenue, ENT_Date, ENT_UserKey,
			NAC_Margin, NAC_Rate, NAC_BvsNB, NAC_FreeTime, NAC_Min, NAC_Max, NAC_NetRevenue, NAC_Date, NAC_UserKey)
		SELECT A.MarketKey, A.ZoneKey, A.YardPort, A.LineItem, A.Cost, 
			A.SMB_Margin, 
			A.SMB_Rate, 
			A.SMB_BvsNB, A.SMB_FreeTime, A.SMB_Min, A.SMB_Max,
			A.SMB_Rate - A.SMB_Margin as SMB_NEtRevenue,
			CASE WHEN ISNULL(A.SMB_Rate,0) > 0 THEN GETDATE() ELSE NULL END , 
			CASE WHEN ISNULL(A.SMB_Rate,0) > 0 THEN @UserKey ELSE NULL END , 

			A.ENT_Margin, 
			A.ENT_Rate, 
			A.ENT_BvsNB, A.ENT_FreeTime, A.ENT_Min, A.ENT_Max,
			A.ENT_Rate - A.ENT_Margin as ENT_NEtRevenue,
			CASE WHEN ISNULL(A.ENT_Rate,0) > 0 THEN GETDATE() ELSE NULL END, 
			CASE WHEN ISNULL(A.ENT_Rate,0) > 0 THEN @UserKey ELSE NULL END, 

			A.NAC_Margin, 
			A.NAC_Rate, 
			A.NAC_BvsNB, A.NAC_FreeTime, A.NAC_Min, A.NAC_Max, 
			A.NAC_Margin - A.NAC_Rate as NAC_NetRevenue,
			CASE WHEN ISNULL(A.NAC_Rate,0) > 0 THEN GETDATE() ELSE NULL END,
			CASE WHEN ISNULL(A.NAC_Rate,0) > 0 THEN @UserKey ELSE NULL END
		FROM #ACC_DATA A
		LEFT JOIN Sell_AccessorialRates AR WITH(NOLOCK) ON A.MarketKey = AR.MarketKey AND A.ZoneKey = AR.ZoneKey 
				AND A.YardPort = AR.YardPort AND A.LineItem = AR.LineItem
		WHERE ISNULL(A.SellAccRateKey,0) = 0 AND (A.SMB_Rate > 0 OR A.ENT_Rate > 0 OR A.NAC_Rate > 0)

		UPDATE AR SET SMB_Rate = A.SMB_RATE, SMB_MARGIN = A.SMB_MARGIN, 
			SMB_BvsNB = A.SMB_BvsNB, 
			SMB_FreeTime = A.SMB_FreeTime, 
			SMB_Min = A.SMB_Min, 
			SMB_Max = A.SMB_Max, 
			SMB_NetRevenue = A.SMB_Rate - A.SMB_Margin,
			SMB_Date = GETDATE(),
			SMB_UserKey = @UserKey
		FROM #ACC_DATA A
		LEFT JOIN Sell_AccessorialRates AR ON A.MarketKey = AR.MarketKey AND A.ZoneKey = AR.ZoneKey 
				AND A.YardPort = AR.YardPort AND A.LineItem = AR.LineItem
		WHERE ISNULL(A.SellAccRateKey,0) > 0 AND (
				(ISNULL(A.SMB_Rate,0) <> ISNULL(AR.SMB_Rate,0)) OR
				(ISNULL(A.SMB_Margin,0) <> ISNULL(AR.SMB_Margin,0)) OR
				(ISNULL(A.SMB_NetRevenue,0) <> ISNULL(AR.SMB_NetRevenue,0)) OR
				(ISNULL(A.SMB_BvsNB,'') <> ISNULL(AR.SMB_BvsNB,'')) OR
				(ISNULL(A.SMB_FreeTime,0) <> ISNULL(AR.SMB_FreeTime,0)) OR
				(ISNULL(A.SMB_Min,0) <> ISNULL(AR.SMB_Min,0)) OR
				(ISNULL(A.SMB_Max,0) <> ISNULL(AR.SMB_Max,0)) 
			)

		UPDATE AR SET ENT_Rate = A.ENT_RATE, ENT_MARGIN = A.ENT_MARGIN, 
			ENT_BvsNB = A.ENT_BvsNB, 
			ENT_FreeTime = A.ENT_FreeTime, 
			ENT_Min = A.ENT_Min, 
			ENT_Max = A.ENT_Max, 
			ENT_NetRevenue = A.ENT_Rate - A.ENT_Margin,
			ENT_Date = GETDATE(),
			ENT_UserKey = @UserKey
		FROM #ACC_DATA A
		LEFT JOIN Sell_AccessorialRates AR ON A.MarketKey = AR.MarketKey AND A.ZoneKey = AR.ZoneKey 
				AND A.YardPort = AR.YardPort AND A.LineItem = AR.LineItem
		WHERE ISNULL(A.SellAccRateKey,0) > 0 AND (
				(ISNULL(A.ENT_Rate,0) <> ISNULL(AR.ENT_Rate,0)) OR
				(ISNULL(A.ENT_Margin,0) <> ISNULL(AR.ENT_Margin,0)) OR
				(ISNULL(A.ENT_NetRevenue,0) <> ISNULL(AR.ENT_NetRevenue,0)) OR
				(ISNULL(A.ENT_BvsNB,'') <> ISNULL(AR.ENT_BvsNB,'')) OR
				(ISNULL(A.ENT_FreeTime,0) <> ISNULL(AR.ENT_FreeTime,0)) OR
				(ISNULL(A.ENT_Min,0) <> ISNULL(AR.ENT_Min,0)) OR
				(ISNULL(A.ENT_Max,0) <> ISNULL(AR.ENT_Max,0)) 
			)

		UPDATE AR SET NAC_Rate = A.NAC_RATE, NAC_MARGIN = A.NAC_MARGIN, 
			NAC_BvsNB = A.NAC_BvsNB, 
			NAC_FreeTime = A.NAC_FreeTime, 
			NAC_Min = A.NAC_Min, 
			NAC_Max = A.NAC_Max, 
			NAC_NetRevenue = A.NAC_Rate - A.NAC_Margin,
			NAC_Date = GETDATE(),
			NAC_UserKey = @UserKey
		FROM #ACC_DATA A
		LEFT JOIN Sell_AccessorialRates AR ON A.MarketKey = AR.MarketKey AND A.ZoneKey = AR.ZoneKey 
				AND A.YardPort = AR.YardPort AND A.LineItem = AR.LineItem
		WHERE ISNULL(A.SellAccRateKey,0) > 0 AND (
				(ISNULL(A.NAC_Rate,0) <> ISNULL(AR.NAC_Rate,0)) OR
				(ISNULL(A.NAC_Margin,0) <> ISNULL(AR.NAC_Margin,0)) OR
				(ISNULL(A.NAC_NetRevenue,0) <> ISNULL(AR.NAC_NetRevenue,0)) OR
				(ISNULL(A.NAC_BvsNB,'') <> ISNULL(AR.NAC_BvsNB,'')) OR
				(ISNULL(A.NAC_FreeTime,0) <> ISNULL(AR.NAC_FreeTime,0)) OR
				(ISNULL(A.NAC_Min,0) <> ISNULL(AR.NAC_Min,0)) OR
				(ISNULL(A.NAC_Max,0) <> ISNULL(AR.NAC_Max,0)) 
			)

		SET @Reason='Success'
		SET @Status=1
	END
END
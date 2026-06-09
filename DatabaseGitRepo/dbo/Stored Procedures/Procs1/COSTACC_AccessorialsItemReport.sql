

CREATE PROCEDURE [dbo].[COSTACC_AccessorialsItemReport]
(
	@MarketKey			INT = 0,
	@GroupKey			INT = 0,
	@Zone				VARCHAR(100)='',
	@YardPort			VARCHAR(100)='',
	@SearchText			VARCHAR(200) = ''

)
AS

BEGIN

	DECLARE @Market VARCHAR(100), @Group VARCHAR(100)

	SET		@Market = (SELECT MarketLocation FROm MarketLocation WHERE MarketLocationKey = @MarketKey )		
	SET		@Group = ''


	SELECT				DISTINCT Market,  Description LineItem, [Group] AS ACCGroup,   FixVsNonFix AS FixedVNonFixed, Per, UnitCost AS Cost,  
						EffectiveDate, EffectiveDateFrom, Terminal, TruckType,YardPort,[Zone], FreePer,SplitPercent
	FROM				(SELECT DISTINCT Description FROM Item ) A
	LEFT OUTER JOIN		COSTACC_FinalDataOutput B ON A.Description = B.LineItem
	WHERE				(ISNULL(Market,'') = @Market OR '' = ISNULL(@Market,'') )

END 

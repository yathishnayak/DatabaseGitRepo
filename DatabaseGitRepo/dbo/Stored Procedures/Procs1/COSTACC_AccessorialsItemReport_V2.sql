/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING NVARCHAR(MAX) = '{"MarketKey" : 0}'
	EXEC [COSTACC_AccessorialsItemReport_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/

CREATE PROCEDURE [dbo].[COSTACC_AccessorialsItemReport_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS

BEGIN

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE 
		@MarketKey			INT = 0,
		@GroupKey			INT = 0,
		@Zone				VARCHAR(100)='',
		@YardPort			VARCHAR(100)=''
		--@SearchText			VARCHAR(200) = ''

	SELECT 
		@MarketKey = MarketKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		MarketKey			INT			'$.MarketKey'
	)

	DECLARE @Market VARCHAR(100), @Group VARCHAR(100)

	SET		@Market = (SELECT MarketLocation FROm MarketLocation WITH (NOLOCK) WHERE MarketLocationKey = @MarketKey )		
	SET		@Group = ''


	SELECT				DISTINCT Market,  Description LineItem, [Group] AS ACCGroup,   FixVsNonFix AS FixedVNonFixed, Per, UnitCost AS Cost,  
						EffectiveDate, EffectiveDateFrom, Terminal, TruckType,YardPort,[Zone], FreePer,SplitPercent
	FROM				(SELECT DISTINCT Description FROM Item WITH (NOLOCK) ) A
	LEFT OUTER JOIN		COSTACC_FinalDataOutput B WITH (NOLOCK) ON A.Description = B.LineItem
	WHERE				(ISNULL(@Market,'')='' OR ISNULL(Market,'') = @Market  )
	FOR JSON PATH, INCLUDE_NULL_VALUES;

	SET @Status = 1
	SET @Reason = 'Success'
END 
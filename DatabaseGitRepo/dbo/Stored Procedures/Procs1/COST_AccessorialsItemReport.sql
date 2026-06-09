
CREATE PROCEDURE [dbo].[COST_AccessorialsItemReport]
(
	@MarketKey			INT = 0,
	@GroupKey			INT = 0,
	@SearchText			VARCHAR(200) = ''

)
AS

BEGIN
	SELECT				Market, '' LineItem, '' AS ACCGroup,   '' AS FixedVNonFixed, 0.00 AS Per, 0.00 AS Cost,  EffectiveDate, EffectiveDateFrom
	FROM				COST_FileUploadData_Chicago
END

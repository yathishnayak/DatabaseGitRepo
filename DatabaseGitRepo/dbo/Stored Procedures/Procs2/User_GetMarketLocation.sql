CREATE PROCEDURE [dbo].[User_GetMarketLocation]
(
	@UserKey			INT
)
AS

BEGIN
	SELECT UserKey, ISNULL(MarketLocationKey,0) MarketLocationKey FROM [User] WHERE UserKey=@UserKey
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END

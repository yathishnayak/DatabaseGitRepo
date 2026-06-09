CREATE PROCEDURE [dbo].[Update_BulkRouteDriver]
/*Dispatch Screen Bulk driver Update*/
@RouteKey	VARCHAR(500), -- Colon Separated RouteKey
@DriverKey	INT,
@UserKey	INT,
@OutPut		BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	CREATE Table #RouteKey
	(
		RouteKey INT,		
	);

	INSERT INTO #RouteKey (RouteKey)
	SELECT [Value] FROM Fn_SplitParamCol (@RouteKey);

	UPDATE A 
	SET A.DriverKey=@DriverKey,UpdateUserKey=@UserKey
	FROM dbo.Routes A 
		INNER JOIN #RouteKey D ON D.RouteKey=A.RouteKey;

	IF @@ROWCOUNT>0
	BEGIN
		SET @OutPut=1;
	END;
END

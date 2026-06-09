CREATE PROCEDURE [dbo].[Update_YardLocation]
@RouteKey		INT,
@LocationKey	INT,
@OutPut			BIT OUTPUT
AS
BEGIN
	SET @OutPut=0

	UPDATE dbo.[Routes]
	SET LocationKey= @LocationKey
	WHERE RouteKey=@RouteKey

	IF @@ROWCOUNT>0
	BEGIN
		SET @OutPut=1
	END
END

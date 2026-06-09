CREATE PROCEDURE [dbo].[DeleteCity]
(
@CityKey INT,
@OutPut bit=0 OUTPUT,
@reason varchar(100) = '' OUTPUT
)
AS
BEGIN
	DECLARE @CNT INT=0
	SET @CNT = (SELECT count(City) FROM locationdata WHERE CityKey = @CityKey)
	IF(@CNT = 0)
	BEGIN
		SET @reason = 'No record found for the given City data'
		SET @output = 0;
		RETURN
	END
ELSE
	BEGIN
		UPDATE locationdata
		SET IsActive = 0, IsDelete = 1
		WHERE CityKey = @CityKey
		SET @reason ='City Deleted Successfully'
		SET @output = 1;
		RETURN
	END
END

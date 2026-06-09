
CREATE proc [dbo].[Insert_GeoTracker]  -- Insert_GeoTracker 29, 1, 47.65100, -45.34900
(
	@UserKey int,
	@EventKey smallint,
	@Latitude decimal(18,5),
	@Longitude decimal(18,5)
)
as
BEGIN
	DECLARE @CNT INT =0
	SELECT @CNT = COUNT(1) FROM GeoEvents where EventKey = @EventKey
	if(@CNT > 0)
	BEGIN
		declare @point varchar(100) 
		set @point = 'POINT('+ convert(varchar,@Latitude) + ' ' + convert(Varchar, @Longitude) + ')'
		insert into GeoEventTracking (UserKey, EventKey, GeoCordinates, CaptureDateTime)
		values (@userKey, @eventKey,  geography::STPointFromText(@point, 4326), getdate())
	END
END

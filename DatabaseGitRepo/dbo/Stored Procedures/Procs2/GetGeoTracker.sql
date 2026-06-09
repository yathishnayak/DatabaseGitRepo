
CREATE proc [dbo].[GetGeoTracker] -- GetGeoTracker
(
	@UserKey int,
	@ForTheDate date
)
as
BEGIN
	
	select  RecordKey, 
			UserKey, 
			EventKey, 
			GeoCordinates, 
			CaptureDateTime,  
			convert(varchar(max),GeoCordinates) as Coordinates ,
			GeoCordinates.Lat as Latitude,
			GeoCordinates.Long as Longitude
	from GeoEventTracking
	where UserKey = @userkey and convert(varchar,CaptureDateTime,101) = convert(varchar,@ForTheDate,101)
	order by recordkey
END

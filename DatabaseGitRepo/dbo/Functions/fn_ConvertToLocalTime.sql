Create FUNCTION fn_ConvertToLocalTime
(	
	@utcTime as datetime 
)
RETURNS  datetime	
AS
BEGIN
	if @utcTime is null return null
	return  CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,  @utcTime),  DATENAME(TzOffset, SYSDATETIMEOFFSET()))) 
END

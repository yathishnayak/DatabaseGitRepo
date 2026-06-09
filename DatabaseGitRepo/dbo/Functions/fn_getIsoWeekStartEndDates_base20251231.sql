
--select * from [fn_getIsoWeekStartEndDates](Getdate())
CREATE function [dbo].[fn_getIsoWeekStartEndDates_base20251231](
	@dt datetime
)
returns @rtnTable Table
(
	Week_Start_Date DateTime Not null,
	Week_End_Date dateTime not null
)
as
Begin
	if(@dt is null)
	Return;
	else
	Begin
		--insert into @rtnTable (Week_Start_Date, Week_End_Date)
		--SELECT DATEADD(DAY, 2 - DATEPART(WEEKDAY, @dt), CAST(@dt AS DATE)) [Week_Start_Date],
		--DATEADD(DAY, 8 - DATEPART(WEEKDAY, @dt), CAST(@dt AS DATE)) [Week_End_Date]
		--RETURN;

		
		DECLARE @iso_week INT = DatePart(ISO_WEEK,@dt);
		DECLARE @iso_year INT = YEAR(GETDATE()); -- Or any year you need

		-- Calculate the start date of the ISO week
		DECLARE @start_date DATETIME;
		SET @start_date = DATEADD(wk, @iso_week - 1, DATEADD(yy, @iso_year - 1900, 0));
		SET @start_date = DATEADD(wk, DATEDIFF(wk, 7, @start_date) , 7); --adjust for iso week
		SET @start_date = DATEADD(day, -(DATEPART(dw, @start_date) + @@DATEFIRST + 5) % 7, @start_date);


		-- Calculate the end date of the ISO week
		DECLARE @end_date DATETIME;
		SET @end_date = DATEADD(d, 6, @start_date);
		set @end_date = @end_date +  CAST('23:59' AS datetime)

		insert into @rtnTable (Week_Start_Date, Week_End_Date)
		SELECT @start_date AS StartOfWeek, @end_date AS EndOfWeek;
	End
	RETURN;
End

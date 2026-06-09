
CREATE PROC [dbo].[Get_DriverView] -- Get_DriverView '2020-12-24 00:00:00','2020-12-26 00:00:00'
(
	@FromDate	date = '2020-10-15 00:00:00',
	@ToDate		date = '2020-10-25 00:00:00',
	@StatusKey	smallint=0,
	@Type		varchar(500)=''
)
as
BEGIN
	SET FMTONLY OFF
	SET NOCOUNT ON
	SET @ToDate = DATEADD(Day, 0, DATEDIFF(Day, 0, dateadd(D,1,@ToDate)))
	SEt @FromDate = DATEADD(Day, 0, DATEDIFF(Day, 0, @FromDate))
	print @FromDate
	Print @Todate

	select distinct D.DriverKey, D.DriverID, D.DrivingLicenseNo, D.DrivingLicenseExpiryDate, D.FirstName, d.LastName, 
	D.Plate, d.RFID, D.HireDate, D.VINId, D.YearMake, S.StatusName, '' as Drivertype
	INTO #DRIVERS
	from  Driver D 
	left join Routes R on R.DriverKey = D.DriverKey
	left join Status S on D.StatusKey = S.StatusKey
	where R.DriverKey is not null

	ALTER TABLE #DRIVERS ADD SCHEDULE VARCHAR(MAX)
	--SELECT * FROM #DRIVERS

	select driverkey, PickupDateFrom, DeliveryDateFrom
	INTO #RECS
	from Routes R
	where DriverKey is not null and
	--(PickupDateFrom >= convert(date,@FromDate) OR DeliveryDatefrom >= convert(date,@FromDate)) AND
	((PickupDateFrom between @FromDate and @ToDate) OR (isnull(DeliveryDateTo, DeliveryDateFrom) between @FromDate and @ToDate) OR 
	 (@FromDate between PickupDateFrom and isnull(DeliveryDateTo,DeliveryDateFrom)) OR 
	 (@ToDate between PickupDateFrom and isnull(DeliveryDateTo, DeliveryDateFrom)))
	order by driverkey 
 
	DECLARE --@FromDate datetime = '2020-10-15 00:00:00',
			--@ToDate   datetime = '2020-10-25 00:00:00',
			@TDate		datetime,
			@FromTime smallint = 0,
			@ToTime smallint = 24,
			@CURRENT_DRIVERKEY INT = 0,
			@PickupDateFrom datetime,
			@DeliveryDateFrom datetime,
			@Count SMALLINT = 0,
			@CountSub SMALLINT = 0,
			@IsExists BIT = 0,
			@Mins smallint = 0,
			@RemMins smallint = 0

	create table #temp
	(
		DRIVERKEY INT ,
		TDate date ,
		THour smallint ,
		BusyMins smallint,
		FreeMins smallint,
		FreeMinsLocation char(1),
		BusyMinsLocation char(1)
	)

	DECLARE DB_CURSOR CURSOR FOR 
		SELECT DISTINCT D.DriverKey FROM #DRIVERS D left join #RECS R on D.DriverKey = R.DriverKey

	OPEN DB_CURSOR
	FETCH NEXT FROM DB_CURSOR INTO @CURRENT_DRIVERKEY

	Set @TDate = @FromDate

	WHILE @@FETCH_STATUS = 0
	BEGIN
		WHILE (@TDate < @ToDate)
		BEGIN
			print '----------------------------------------------------'
			PRINT @TDATE
			SELECT @Count = COUNT(1) FROM #RECS WHERE DriverKey = @CURRENT_DRIVERKEY AND  PickupDateFrom <= dateadd(hour,1,@TDate) AND DeliveryDateFrom >= @TDATE 
			print @count
			IF(@Count > 0)
			BEGIN
				SELECT top 1 @PickupDateFrom = PickupDateFrom, @DeliveryDateFrom = DeliveryDateFrom  
				FROM #RECS
				WHERE DriverKey = @CURRENT_DRIVERKEY AND  PickupDateFrom <= dateadd(hour,1,@TDate) AND DeliveryDateFrom >= @TDATE 

				PRINT convert(date,@PickupDateFrom)
				PRINT CONVERT(date, @DeliveryDateFrom)
				PRINT datepart(hour, @PickupDateFrom) 
				PRINT DATEPART(hour,@DeliveryDateFrom) 
				PRINT convert(date, @PickupDateFrom)
				PRINT convert(Date,@Tdate) 
				PRINT datepart(hour,@PickupDateFrom) 
				PRINT DATEPART(hour,@Tdate) 
				if(isnull(@PickupDateFrom,'2020-01-01') != '2020-01-01')
				begin
					if(convert(date,@PickupDateFrom) = CONVERT(date, @DeliveryDateFrom) and datepart(hour, @PickupDateFrom) = DATEPART(hour,@DeliveryDateFrom) 
						and convert(date, @PickupDateFrom) = convert(Date,@Tdate) and datepart(hour,@PickupDateFrom) = DATEPART(hour,@Tdate) )
					begin
						PRINT '-----1'
						INSERT INTO #temp VALUES (@CURRENT_DRIVERKEY, CONVERT(DATE, @TDate), DATEPART(HOUR, @TDate), 60,0,'S','E')
					end
					else if(convert(date, @PickupDateFrom) = convert(Date,@Tdate) and datepart(hour,@PickupDateFrom) = DATEPART(hour,@Tdate))
					Begin
						PRINT '-----2'
						set @Mins = 0
						set @RemMins = 0
						set @Mins = DATEPART(minute,@PickupDateFrom)
						set @RemMins = 60 - @Mins
						INSERT INTO #temp VALUES (@CURRENT_DRIVERKEY, CONVERT(DATE, @TDate), DATEPART(HOUR, @TDate), @RemMins,@Mins, 'S','E')
					end
					else if(convert(date, @DeliveryDateFrom) = convert(Date,@Tdate) and datepart(hour,@DeliveryDateFrom) = DATEPART(hour,@Tdate))
					Begin
						PRINT '-----3'
						set @Mins = 0
						set @RemMins = 0
						set @Mins = DATEPART(minute,@DeliveryDateFrom)
						set @RemMins = 60 - @Mins
						INSERT INTO #temp VALUES (@CURRENT_DRIVERKEY, CONVERT(DATE, @TDate), DATEPART(HOUR, @TDate), @Mins, @RemMins,'E','S')
					end
					else
					begin
						PRINT '-----4'
						INSERT INTO #temp VALUES (@CURRENT_DRIVERKEY, CONVERT(DATE, @TDate), DATEPART(HOUR, @TDate), 60,0,'S','E')
					end
					--WHERE DriverKey = @CURRENT_DRIVERKEY AND ( (convert(date,PickupDateFrom) = convert(date, @TDate) and datepart(hour,PickupDateFrom) = datepart(hour, @TDate) )
					--OR (convert(date,DeliveryDateFrom) = convert(date, @TDate) and datepart(hour,DeliveryDateFrom) = datepart(hour, @TDate) ) )
				END
			END
			ELSE
			BEGIN
				PRINT '-----5'
				INSERT INTO #temp VALUES (@CURRENT_DRIVERKEY, CONVERT(DATE, @TDate), DATEPART(HOUR, @TDate), 0,60,'S','E')
			END
			SET @TDate = DATEADD(HOUR,1,@TDATE)
			print '----------------------------------------------------'
		END
		Set @TDate = @FromDate
		FETCH NEXT FROM DB_CURSOR INTO @CURRENT_DRIVERKEY
	END
	CLOSE DB_CURSOR
	DEALLOCATE DB_CURSOR

	--SELECT * FROM #TEMP 

	DECLARE CURSOR1 CURSOR FOR 
		SELECT * FROM #TEMP

	DECLARE @THOUR SMALLINT,
			@BUSYMINS SMALLINT,
			@FREEMINS SMALLINT,
			@FREEMINSLOCATION CHAR(1),
			@BUSYMINSLOCATION CHAR(1),
			@RESULT VARCHAR(5000),
			@PREVDRIVERKEY INT
	OPEN CURSOR1
	FETCH NEXT FROM CURSOR1 INTO @CURRENT_DRIVERKEY, @TDATE, @THOUR, @BUSYMINS, @FREEMINS, @FREEMINSLOCATION, @BUSYMINSLOCATION

	SET @PREVDRIVERKEY = 0
	set @RESULT = ''
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @PREVDRIVERKEY = @CURRENT_DRIVERKEY
		SET @RESULT = @RESULT +       convert(varchar,DATEDIFF(D,@FromDate, convert(date,@Tdate))+1) + ';'
									+ CONVERT(VARCHAR,@THOUR)  + ';'
									+ CONVERT(VARCHAR,@BUSYMINS) + ';'
									+ CONVERT(VARCHAR,@FREEMINS) + ';'
									+ @FREEMINSLOCATION + ';'
									+ @BUSYMINSLOCATION + '}'
		FETCH NEXT FROM CURSOR1 INTO @CURRENT_DRIVERKEY, @TDATE, @THOUR, @BUSYMINS, @FREEMINS, @FREEMINSLOCATION, @BUSYMINSLOCATION
		IF(@PREVDRIVERKEY != @CURRENT_DRIVERKEY)
		BEGIN
			
			UPDATE #DRIVERS SET SCHEDULE = @RESULT WHERE DriverKey = @PREVDRIVERKEY
			set @RESULT = ''
		END
	END
	--SET @RESULT = @RESULT + ']'
	UPDATE #DRIVERS SET SCHEDULE = @RESULT WHERE DriverKey = @PREVDRIVERKEY
	CLOSE CURSOR1
	DEALLOCATE CURSOR1

	declare @Schedule varchar(max)
	-- include drivers who are not included in previous steps
	select top 1 @Schedule = SCHEDULE
		from #DRIVERS d
		left join #RECS r on d.DriverKey = r.DriverKey
	where r.DriverKey is null

	insert into #DRIVERS
	select distinct D.DriverKey, D.DriverID, D.DrivingLicenseNo, D.DrivingLicenseExpiryDate, D.FirstName, d.LastName, 
	D.Plate, d.RFID, D.HireDate, D.VINId, D.YearMake, S.StatusName, '' as Drivertype, @Schedule
	from  Driver D 
	left join Status S on D.StatusKey = S.StatusKey
	left join #DRIVERS R on d.DriverKey = r.DriverKey
	where r.DriverKey is null

	SELECT D.*, L.DisplayName as DriverLicenses 
	FROM #DRIVERS D
	inner join DriverLicences L on D.DriverKey = L.driverKey
	order by DriverID
	 DROP TABLE #temp
	 DROP TABLE #DRIVERS
	 DROP TABLE #RECS
END

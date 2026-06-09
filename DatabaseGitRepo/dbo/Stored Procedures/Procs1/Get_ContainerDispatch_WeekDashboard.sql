CREATE PROCEDURE [dbo].[Get_ContainerDispatch_WeekDashboard] 
@Weekday		CHAR(3)='',
@Customer		VARCHAR(50)='',
@OrderNo		VARCHAR(20)='',
@ContainerNo	VARCHAR(20)='',
@LegType		VARCHAR(200)='',
@Status			VARCHAR(100)='',
@ContainerType	VARCHAR(100)='',
@PickUpDateFrom	DATE='01/01/2020',
@PickUpDateTo	DATE='12/31/2099',
@PickupTypeKey  SMALLINT=0
AS
BEGIN	
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @StartDate		DATETIME
	DECLARE @EndDate		DATETIME
	SET @StartDate=CAST(GETDATE() AS DATE)
	SET @EndDate=DATEADD(SECOND,59,DATEADD(MINUTE,59,DATEADD(hh,23,DATEADD(DD,6,@StartDate))))
	
	create table #week
	(
		Weeknum smallint,
		WeekDay varchar(50)
	)
	insert into #week values (-9, 'Pas')
	insert into #week values (1, 'Mon')
	insert into #week values (2, 'Tue')
	insert into #week values (3, 'Wed')
	insert into #week values (4, 'Thu')
	insert into #week values (5, 'Fri')
	insert into #week values (6, 'Sat')
	insert into #week values (7, 'Sun')
	insert into #week values (8, 'Fut');
	
	WITH FinalData  (OrderDetailKey, CurrentRouteKey, WeekDay) AS ( 
		select OrderDetailKey, CurrentRouteKey,UPPER(LEFT([WeekDay],3)) AS [WeekDay] from (
			SELECT OD.OrderDetailKey, OD.CurrentRouteKey, 
			CASE WHEN RT.PickupDateFrom BETWEEN @StartDate AND @EndDate THEN  DATENAME(DW,RT.PickupDateFrom ) 
			WHEN RT.PickupDateFrom<@StartDate THEN 'Past'ELSE 'Future' END AS [WeekDay]
			FROM OrderDetail OD
				INNER JOIN dbo.Routes RT		ON RT.OrderDetailKey=OD.OrderDetailKey
				INNER JOIN dbo.RouteStatus RTS	ON RTS.[Status]=RT.[Status]
			WHERE RTS.[Description]<>'Leg Completed' and OD.CurrentRouteKey = RT.RouteKey
		) A
	)
	select A.*, isnull(B.RecCount ,0) as RecCount
	from #Week A 
	Left join (
	select  WeekDay, count(1) as RecCount 
	from FinalData 
	group by  WeekDay
	) B on a.WeekDay = b.WeekDay
	order by a.weeknum,  a.WeekDay;

	Drop table #week
END

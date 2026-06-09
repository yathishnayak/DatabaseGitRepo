/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_ContainerDispatch_WeekDashboard_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_ContainerDispatch_WeekDashboard_V3] 
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN	
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	--IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	--BEGIN
	--	SET		@Status = 0
	--	SET		@Reason = 'Parameters not found'
	--	RETURN
	--END	

	--DECLARE
	--	@Weekday		CHAR(3)='',
	--	@Customer		VARCHAR(50)='',
	--	@OrderNo		VARCHAR(20)='',
	--	@ContainerNo	VARCHAR(20)='',
	--	@LegType		VARCHAR(200)='',
	--	@StatusKey		VARCHAR(100)='',
	--	@PickUpDateFrom	DATE='01/01/2020',
	--	@PickUpDateTo	DATE='12/31/2099',
	--	@PickupTypeKey  SMALLINT=0

	--SELECT
	--	@Weekday				=	Weekday			,
	--	@Customer			    =	Customer		,
	--	@OrderNo				=	OrderNo			,
	--	@ContainerNo			=	ContainerNo		,
	--	@LegType				=	LegType			,
	--	@StatusKey				=	StatusKey		,
	--	@PickUpDateFrom			=	PickUpDateFrom	,
	--	@PickUpDateTo			=	PickUpDateTo	,
	--	@PickupTypeKey			=	PickupTypeKey 
	--FROM OPENJSON(@JSONString)
	--WITH
	--(
	--	Weekday				CHAR(3)				'$.Weekday',		
	--	Customer			VARCHAR(50)			'$.Customer',	
	--	OrderNo				VARCHAR(20)			'$.OrderNo',		
	--	ContainerNo			VARCHAR(20)			'$.ContainerNo',	
	--	LegType				VARCHAR(200)		'$.LegType',		
	--	StatusKey			VARCHAR(100)		'$.StatusKey',		
	--	PickUpDateFrom		DATE				'$.PickUpDateFrom',	
	--	PickUpDateTo		DATE				'$.PickUpDateTo',	
	--	PickupTypeKey		SMALLINT			'$.PickupTypeKey'
	--)

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
			FROM OrderDetail OD with(nolock)
				INNER JOIN dbo.Routes RT with(nolock) ON RT.OrderDetailKey=OD.OrderDetailKey
				INNER JOIN dbo.RouteStatus RTS with(nolock)	ON RTS.[Status]=RT.[Status]
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
	order by a.weeknum,  a.WeekDay
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'

	Drop table #week
END

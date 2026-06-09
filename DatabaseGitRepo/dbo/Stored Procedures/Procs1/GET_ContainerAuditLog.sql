







--select * from OrderDetail where ContainerNo = 'TCLU9605449'
CREATE PROCEDURE [dbo].[GET_ContainerAuditLog] -- [GET_ContainerAuditLog] 43
@OrderDetailKey INT=112
AS
BEGIN

	SET NOCOUNT ON
	SET FMTONLY OFF

	--SELECT OH.OrderNo,OH.CreateDate AS OrderCreateDate,OD.ContainerNo,ODS.[Description] AS ContainerStatus,L.LegID,RT.CreateDate AS LegCreateDate,
	--		ISNULL(DR.DriverID,'') + ': ' + ISNULL(DR.FirstName,'')+' '+ISNULL(DR.LastName,'') AS DriverName,
	--		RTS.[Description] AS LegStatus,RT.ActualDeparture,RT.ActualArrival,
	--		INC.InvoiceNo,INC.InvoiceDate,INC.InvoiceAmount,
	--		OD.OrderDetailKey

	--FROM OrderHeader OH 
	--	INNER JOIN dbo.OrderDetail OD			ON OD.OrderKey=OH.OrderKey
	--	INNER JOIN dbo.OrderDetailStatus ODS	ON ODS.[Status]=OD.[Status]
	--	LEFT JOIN  dbo.Routes RT				ON RT.OrderDetailKey=OD.OrderDetailKey
	--	LEFT JOIN  dbo.RouteStatus RTS			ON RTS.[Status]=RT.[Status]
	--	LEFT JOIN dbo.Leg L						ON L.LegKey=RT.LegKey
	--	LEFT JOIN dbo.LegType LT				ON L.LegTypeKey=LT.LegtypeKey
	--	LEFT JOIN dbo.Driver DR					ON DR.DriverKey=RT.DriverKey
	--	LEFT JOIN 
	--			(	
	--				SELECT ID.OrderDetailKey,SUM(ExtAmt) AS InvoiceAmount ,IH.CreateDate AS InvoiceDate,
	--						IH.InvoiceNo
	--				FROM Invoicedetail ID INNER JOIN dbo.InvoiceHeader IH ON IH.InvoiceKey=ID.InvoiceKey
	--				GROUP BY ID.OrderDetailKey,IH.CreateDate ,IH.InvoiceNo
	--			) INC ON INC.OrderDetailKey=OD.OrderDetailKey
	--WHERE OD.OrderDetailKey= @OrderDetailKey
	--ORDER BY OD.OrderDetailKey,RT.RouteKey

	--SELECT 'ASHK2222222' AS ContainerNo,Getdate() As CreateDate,1 as UserKey,'Admin' AS UserName,'Test' AS Activity
	--union all
	--SELECT 'ASHK2222222' AS ContainerNo,Getdate() As CreateDate,1 as UserKey,'CSR1' AS UserName,'Test 2' AS Activity
	--	union all
	--SELECT 'ASHK2222222' AS ContainerNo,Getdate() As CreateDate,1 as UserKey,'CSR2' AS UserName,'Test 3' AS Activity

	create table #temp
	(
		ContainerNo varchar(20),
		CreateDate datetime,
		UserKey int,
		UserName varchar(50),
		Activity varchar(8000),
		LegID varchar(50),
		ActionType varchar(20),
		RouteKey int,
		OrderdetailKey int,
		ActionDate datetime
	)

	DECLARE @CREATEDATE DATETIME, 
			@CNT INT,
			@CONTAINERNO VARCHAR(50),
			@ACTIVITY VARCHAR(2000) 


	SELECT @CONTAINERNO = OD.ContainerNo
	FROM OrderDetail OD
	WHERE OrderDetailKey = @OrderDetailKey

	--PRINT @cONTAINERNO

	DECLARE DB_CURSOR CURSOR  FOR
	select distinct  LastUpdateDate, count(1) as cnt
	from OrderDetail_Log
	where OrderDetailKey = @OrderDetailKey
	group by OrderDetailKey, LastUpdateDate

	OPEN DB_CURSOR
	FETCH NEXT FROM DB_CURSOR INTO @CREATEDATE, @CNT

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--PRINT @CNT
		SET @ACTIVITY = ''
		IF(@CNT = 1)
		BEGIN
			SET @ACTIVITY = 'New Container '+  @CONTAINERNO + ' created on ' + convert(varchar, @CREATEDATE,101)
			insert into #temp 
			select @CONTAINERNO, @CREATEDATE, CreateUserKey,  U.UserName, @ACTIVITY, '', 'Container',0,@OrderDetailKey, L.CreateDate
			from OrderDetail_Log L
			Left join [User] U on L.CreateUserKey = U.UserKey
			where CreateDate = @CREATEDATE and OrderDetailKey = @OrderDetailKey and ActionType = 'Insert'

			SET @ACTIVITY = 'Container '+  @CONTAINERNO + ' deleted on ' + convert(varchar, @CREATEDATE,101)
			insert into #temp 
			select @CONTAINERNO, @CREATEDATE, CreateUserKey,  U.UserName, @ACTIVITY, '', 'Container', 0,@OrderDetailKey, L.LastUpdateDate
			from OrderDetail_Log L
			Left join [User] U on L.CreateUserKey = U.UserKey
			where CreateDate = @CREATEDATE and OrderDetailKey = @OrderDetailKey and ActionType = 'Delete'
		END

		IF(@CNT >= 2)
		BEGIN
			SET @ACTIVITY = 'Container '+  @CONTAINERNO + ' updated on ' + convert(varchar, @CREATEDATE,101)

			select @ACTIVITY = @activity + ' with ' +
				case when LD.ConfirmationNo <> LI.ConfirmationNo  then 'Confirmation No  :  ' + LI.ConfirmationNo + CHAR(13)+CHAR(10)  ELSE '' end
				+
				case when LD.SealNo <> LI.SealNo then 'Seal No   :  ' + LI.SealNo + CHAR(13)+CHAR(10)  ELSE '' end
				+
				case when LD.Weight <> LI.Weight then 'Weight   :  '+ CONVERT(VARCHAR, LI.Weight) + CHAR(13)+CHAR(10)  ELSE '' end
				+
				case when LD.status <> LI.Status then 'Status   :  '+ 
					(select Description from OrderDetailStatus where Status = LI.Status) 
					+ ' on '+ convert(varchar, LI.statusDate,101) + CHAR(13)+CHAR(10)  ELSE '' end
				+
				case when LD.ContainerID <> LI.ContainerID then 'Container No changed to '+ LI.ContainerNo  + CHAR(13)+CHAR(10)  ELSE '' end
				+
				case when LD.IsHazardus <> LI.IsHazardus then 'Hazmat changed to ' + case when LI.IsHazardus = 0 then 'true' else 'false'end 
					+ CHAR(13)+CHAR(10)  ELSE '' end

				from
				(select top 1 * from OrderDetail_Log LD 
					where CreateDate = @CREATEDATE and OrderDetailKey = @OrderDetailKey and ActionType = 'Delete') LD 
				inner join 
				(select top 1 * from OrderDetail_Log LI 
					where CreateDate = @CREATEDATE and OrderDetailKey = @OrderDetailKey and ActionType = 'Insert') LI
						on LD.CreateDate = LI.CreateDate and LD.OrderDetailKey = LI.OrderDetailKey
				Left join [User] U on LD.CreateUserKey = U.UserKey
			where LD.CreateDate = @CREATEDATE and LD.OrderDetailKey = @OrderDetailKey 


			insert into #temp 
			select DISTINCT @CONTAINERNO, @CREATEDATE, CreateUserKey,  U.UserName, @ACTIVITY,'', 'Container',
			0,@OrderDetailKey, L.CreateDate
			from OrderDetail_Log L
			Left join [User] U on L.CreateUserKey = U.UserKey
			where CreateDate = @CREATEDATE and OrderDetailKey = @OrderDetailKey
		END
		FETCH NEXT FROM DB_CURSOR INTO @CREATEDATE, @CNT
	END
	CLOSE DB_CURSOR
	DEALLOCATE DB_CURSOR


	-- ROUTE LOG
	DECLARE @ROUTEKEY INT

	DECLARE DB_CURSOR CURSOR  FOR
	select distinct ROUTEKEY, ActionDate, count(1) as cnt
	from Routes_Log
	where OrderDetailKey = @OrderDetailKey
	group by RouteKey, ActionDate

	OPEN DB_CURSOR
	FETCH NEXT FROM DB_CURSOR INTO @ROUTEKEY, @CREATEDATE, @CNT

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--PRINT @ROUTEKEY
		--PRINT @CNT
		SET @ACTIVITY = ''
		IF(@CNT = 1)
		BEGIN
			insert into #temp 
			select @CONTAINERNO, @CREATEDATE, L.CreateUserKey,  U.UserName, 
			'New Leg ['+ CONVERT(VARCHAR,g.LegNo) + '] '+ G.LegID +  ' created on ' + convert(varchar, @CREATEDATE,101) as ACTIVITY,
			G.LegID, 'Leg', @ROUTEKEY ,@OrderDetailKey, L.ActionDate
			from Routes_Log L
			Left join [User] U on L.CreateUserKey = U.UserKey
			Left join Leg G on L.LegKey = G.LegKey
			where L.ActionDate = @CREATEDATE and OrderDetailKey = @OrderDetailKey and ActionType = 'Insert'

			insert into #temp 
			select @CONTAINERNO, @CREATEDATE, L.CreateUserKey,  U.UserName, 
			'Leg ['+ CONVERT(VARCHAR,g.LegNo) + '] '+ ' deleted on ' + convert(varchar, @CREATEDATE,101),
			G.LegID, 'Leg', @ROUTEKEY ,@OrderDetailKey, L.ActionDate
			from Routes_Log L
			Left join [User] U on L.CreateUserKey = U.UserKey
			Left join Leg G on L.LegKey = G.LegKey
			where L.ActionDate = @CREATEDATE and OrderDetailKey = @OrderDetailKey and ActionType = 'Delete'
		END

		IF(@CNT >= 2)
		BEGIN
			select @ACTIVITY = 'Leg ['+ CONVERT(VARCHAR,LI.LegNo) + '] '+  LD.legID +  ' updated on  - ' +
				case when LD.ActualArrival <> LI.ActualArrival  then 'Actual Arrival :  ' + convert(varchar,LI.ActualArrival,101) + CHAR(13)+CHAR(10)  ELSE '' end
				+
				case when LD.ActualDeparture <> LI.ActualDeparture  then 'Actual Delivery  :  ' + convert(varchar,LI.ActualDeparture,101) + CHAR(13)+CHAR(10)  ELSE '' end
				+
				case when LD.DriverKey <> LI.DriverKey  then 'Driver   :  ' + LI.DriverID + CHAR(13)+CHAR(10)  ELSE '' end
				+
				case when LD.ChassisKey <> LI.ChassisKey  then 'Chassis   :  ' + LI.ChassisNo + '(' + LI.ChassisType + ')' + CHAR(13)+CHAR(10)  ELSE '' end
				+
				case when LD.ScheduledDeparture <> LI.ScheduledDeparture  then 'Scheduled Pickup  :  ' + convert(varchar,LI.ScheduledDeparture,101) + CHAR(13)+CHAR(10)  ELSE '' end
				+
				case when LD.ScheduledArrival <> LI.ScheduledArrival  then 'Scheduled Delivery  :  ' + convert(varchar,LI.ScheduledArrival,101) + CHAR(13)+CHAR(10)  ELSE '' end
				+
				case when LD.FromLocation <> LI.FromLocation  then 'From Location   :  ' + LI.FromLocation + CHAR(13)+CHAR(10)  ELSE '' end
				+
				case when LD.ToLocation <> LI.ToLocation  then 'To Location   :  ' + LI.ToLocation + CHAR(13)+CHAR(10)  ELSE '' end
				+
				case when LD.LegID <> LI.LegID  then 'Leg changed  :  ' + LI.LegID + CHAR(13)+CHAR(10)  ELSE '' end
				--+
				--case when LD.Status <> LI.Status  then 'Driver changed  :  ' + LI.Description + CHAR(13)+CHAR(10)  ELSE '' end
				from
				(select top 1 LD.*, U.UserName, G.LegID, D.DriverID, RS.Description from Routes_Log LD 
					Left join [User] U on LD.CreateUserKey = U.UserKey
					Left join Leg G on LD.LegKey = G.LegKey
					left join driver D on LD.DriverKey = D.DriverKey
					left join RouteStatus RS on LD.Status = RS.Status
					where LD.ActionDate = @CREATEDATE and RouteKey = @ROUTEKEY and ActionType = 'Delete') LD 
				inner join 
				(select top 1 LI.*, U.UserName, G.LegID, D.DriverID, RS.Description from Routes_Log LI 
				Left join [User] U on LI.CreateUserKey = U.UserKey
					Left join Leg G on LI.LegKey = G.LegKey
					left join driver D on LI.DriverKey = D.DriverKey
					left join RouteStatus RS on LI.Status = RS.Status
					where LI.ActionDate = @CREATEDATE and RouteKey = @ROUTEKEY and ActionType = 'Insert') LI
						on LD.ActionDate = LI.ActionDate and LD.RouteKey = LI.RouteKey
				Left join [User] U on LD.CreateUserKey = U.UserKey
			where LD.ActionDate = @CREATEDATE and LD.RouteKey = @ROUTEKEY 


			insert into #temp 
			select DISTINCT @CONTAINERNO, @CREATEDATE, L.CreateUserKey,  U.UserName, @ACTIVITY, 
			G.LegID,  'Leg', @ROUTEKEY ,@OrderDetailKey, L.ActionDate
			from Routes_Log L
			Left join [User] U on L.CreateUserKey = U.UserKey
			left join Leg G on G.LegKey = L.LegKey
			where L.ActionDate = @CREATEDATE and RouteKey = @ROUTEKEY
		END
		FETCH NEXT FROM DB_CURSOR INTO @ROUTEKEY, @CREATEDATE, @CNT
	END
	CLOSE DB_CURSOR
	DEALLOCATE DB_CURSOR


	select * from #temp t where t.UserKey is not null  and t.UserName is not null
	order by t.ActionDate desc
	--SELECT * FROM OrderDetail WHERE OrderDetailKey = 99
	--select * from OrderDetail_Log
	--select * from Routes_Log where RouteKey = 134

	--select * from AuditLog where routekey = 134
END

/** 
Declare 
	@UserKey		INT,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0
	EXEC [Get_EmptyCOntainerAgingData_V2] @UserKey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/

CREATE PROCEDURE [dbo].[Get_EmptyCOntainerAgingData_V2]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
		
	DECLARE @OrderDetailKey INT
	  
	CREATE TABLE #OPenContainers
	(
		OrderDetailKey INT
	)

	CREATE TABLE #ClosedContainers
	(
		OrderDetailKey INT
	)

	CREATE Table #ContainerStatus
	(
		StatusName VARCHAR(50),
		RouteKey INT,
		OrderDetailKey INT
	)

	SELECT EmptySetRouteKey AS RouteKey,A.OrderDetailKey,EmptySetDate,EmptyRemoveDate INTO #Emptyleg
	FROM EmptyLegData A  WITH (NOLOCK) 
	inner join OrderDetail OD WITH (NOLOCK) on A.OrderDetailKey = OD.OrderDetailKey
	inner join OrderDetailStatus ODS WITH (NOLOCK)  on OD.Status = ODS.Status
	WHERE ODS.Status not in (  6, 10,12,13) and  EmptyRemoveDate IS NULL 
	--*********************All With Current Empty******************	
	SELECT A.OrderDetailKey,RTS.[Description] AS StatusName,LegNo,RT.RouteKey,DriverKey,AD.City,RT.IsEmpty INTO #OrderStautsbyLeg 
	FROM #Emptyleg A 
		INNER JOIN dbo.routes RT WITH (NOLOCK) 		ON RT.OrderDetailKey=A.OrderDetailKey
		INNER JOIN dbo.[Address] AD WITH (NOLOCK) 		ON AD.AddrKey=RT.DestinationAddrKey
		INNER JOIN  dbo.RouteStatus RTS WITH (NOLOCK)  ON RTS.[Status]=RT.[Status]


	SELECT A.OrderDetailKey,A.OrderKey INTO #EmptyCont
	FROM OrderDetail A 	
	WHERE A.IsEmpty=1
	--*******************Current Location**************************
	/*
	SELECT DISTINCT OrderDetailKey INTO #OrdeDtlKey FROM #Emptyleg		
	CREATE INDEX idx_OrderDetailKey  ON #OrdeDtlKey (OrderDetailKey);

		WHILE ( SELECT COUNT(1) FROM #OrdeDtlKey )>0
		BEGIN
				SET @OrderDetailKey=0
				SET @OrderDetailKey= ( SELECT TOP 1 OrderDetailKey FROM #OrdeDtlKey ORDER BY OrderDetailKey )				
				
				IF (	SELECT COUNT(1) 
						FROM
						(
							SELECT COUNT(1) AS Cnt FROM #OrderStautsbyLeg 
							WHERE OrderDetailKey=@OrderDetailKey 
							GROUP BY StatusName
						)R
				 )=1
				BEGIN	
					IF ( SELECT COUNT(1) FROM #OrderStautsbyLeg WHERE OrderDetailKey=@OrderDetailKey AND StatusName='Completed' )>0
					BEGIN					
						INSERT INTO #ContainerStatus (StatusName,RouteKey,OrderDetailKey)
						SELECT StatusName,MAX(RouteKey) AS RouteKey ,@OrderDetailKey
						FROM #OrderStautsbyLeg 
						WHERE OrderDetailKey=@OrderDetailKey
						GROUP BY StatusName
					END
					ELSE
					BEGIN					
						INSERT INTO #ContainerStatus (StatusName,RouteKey,OrderDetailKey)
						SELECT StatusName,MIN(RouteKey) AS RouteKey ,@OrderDetailKey
						FROM #OrderStautsbyLeg 
						WHERE OrderDetailKey=@OrderDetailKey
						GROUP BY StatusName
					END
				END
				ELSE				
				BEGIN					
					INSERT INTO #ContainerStatus (StatusName,RouteKey,OrderDetailKey)
					SELECT NULL,MIN(RouteKey) AS RouteKey,@OrderDetailKey 
					FROM #OrderStautsbyLeg 
					WHERE StatusName<>'Leg Completed' AND OrderDetailKey=@OrderDetailKey		
				END			
			DELETE FROM #OrdeDtlKey WHERE OrderDetailKey=@OrderDetailKey
		END		
		*/

		SELECT DISTINCT OrderDetailKey INTO #OrdeDtlKey FROM #Emptyleg		

		SELECT A.OrderDetailKey,COUNT(DISTINCT RT.RouteKey) AS LegCount INTO #LegCount
		FROM #OrdeDtlKey A 
			LEFT JOIN dbo.Routes RT WITH (NOLOCK)  ON RT.OrderDetailKey=A.OrderDetailKey
		GROUP BY A.OrderDetailKey

		--select * from #OrderDetl where OrderDetailKey=17

		SELECT A.OrderDetailKey,ISNULL(MAX(RT.RouteKey),0) AS CompletedRoutekey INTO #CompletedLeg
		FROM #OrdeDtlKey A 
			INNER JOIN dbo.Routes RT WITH (NOLOCK) 		ON RT.OrderDetailKey=A.OrderDetailKey
			INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) 	ON RTS.[Status]=RT.[Status]
		WHERE RTS.[Description]='Leg Completed'
		GROUP BY A.OrderDetailKey

		SELECT A.OrderDetailKey,ISNULL(MIN(RT.RouteKey),0) AS CurrOPenRoutekey INTO #CurrLeg
		FROM #OrdeDtlKey A 
			INNER JOIN dbo.Routes RT WITH (NOLOCK) 		ON RT.OrderDetailKey=A.OrderDetailKey
			INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) 	ON RTS.[Status]=RT.[Status]
		WHERE RTS.[Description] <> 'Leg Completed'
		GROUP BY A.OrderDetailKey

		UPDATE A
		SET A.StatusName= F.StatusName		
		FROM #ContainerStatus A 
		INNER JOIN #OrderStautsbyLeg F ON F.RouteKey=A.RouteKey	

		SELECT A.OrderDetailKey,A.RouteKey,A.StatusName,K.City  INTO #LegLocationStatus
		FROM #ContainerStatus A 
			LEFT JOIN #OrderStautsbyLeg K ON K.RouteKey=A.RouteKey		

			SELECT A.OrderDetailKey,L.City INTO #ContainerCity
			FROM dbo.OrderDetail A  WITH (NOLOCK) 
			INNER JOIN dbo.[Address] D WITH (NOLOCK)  ON D.AddrKey=A.SourceAddrKey 
			INNER JOIN dbo.LocationData L WITH (NOLOCK)  ON L.CityKey=D.CityKey
			WHERE OrderDetailKey IN ( SELECT OrderDetailKey FROM #LegLocationStatus WHERE RouteKey IS NULL )

			--UPDATE A
			--SET A.City=C.City
			--FROM  #LegLocationStatus A 
			--INNER JOIN #ContainerCity C ON C.OrderDetailKey=A.OrderDetailKey
			--WHERE A.RouteKey IS NULL
		--************************************************************************************		
		SELECT distinct F.OrderDetailKey,F.OrderKey,C.CustName, D.ContainerNo,isnull( CL.AddrNAme,'') AS CurrentLocation,
			isnull(DATEDIFF(DD,CN.EmptySetDate,GETDATE()),0) AS AgeDays,EmptySetDate AS EmptyMarkedDate,NULL AS EmptyRemovedDate
			, OH.OrderNo, R.CsrName, OH.BillOfLading, CS.Description as ContainerSize, D.Status as OrderStatus,
			ODS.Description as StatusText
		FROM 
			#EmptyCont F 
			LEFT JOIN 	#Emptyleg CN ON CN.OrderDetailKey=F.OrderDetailKey			
		LEFT JOIN dbo.OrderDetail D WITH (NOLOCK)  ON D.OrderDetailKey=F.OrderDetailKey
		LEFT JOIN dbo.OrderHeader OH WITH (NOLOCK)   ON OH.OrderKey=F.OrderKey
		LEFT JOIN dbo.Customer C WITH (NOLOCK)  ON C.CustKey=OH.CustKey
		LEFT JOIN #LegLocationStatus LS  ON LS.OrderDetailKey=F.OrderDetailKey		
		LEft join dbo.CSR R WITH (NOLOCK)  on OH.CsrKey = R.CsrKey
		left join ContainerSize CS WITH (NOLOCK)  on CS.ContainerSizeKey = D.ContainerSizeKey
		left join OrderDetailStatus ODS WITH (NOLOCK)  on ODS.Status = D.Status
		left join vContainerLocation CL WITH (NOLOCK)  on CL.OrderDetailkey = F.OrderDetailKey
		where
		D.Status not in (  6,10,12,13) and isnull(D.isStreetTurn,0) = 0
		FOR JSON PATH;

		SET @Status = 1
		SET @Reason = 'Success'
END


CREATE PROCEDURE [dbo].[SafeGateIntegration_InsertContainerDetails] -- SafeGateIntegration_InsertContainerDetails 
(
	@JSONTEXT NVARCHAR(MAX) = ''
)

AS

BEGIN

	Create table #Container
	(
		ActivityId		INT,
		YardName		VARCHAR(100),
		ContainerNo		VARCHAR(50),
		ContainerDesc	VARCHAR(20),
		Effect			SMALLINT,
		CreatedDate		DATETIME,
		ChassisKey		INT	,		
		ChassisNo		VARCHAR(50),
		ChassisType		VARCHAR(50),
		DriverKey		INT	,		
		DriverId		VARCHAR(20),
		FirstName		VARCHAR(50),
		LastName		VARCHAR(50),
		CDLNo			VARCHAR(50),
		DriverTag		VARCHAR(50),
		ContainerType	VARCHAR(20)
	)

	INSERT INTO #Container(ActivityId,YardName,ContainerNo,ContainerDesc,Effect,CreatedDate,ChassisKey,ChassisNo,ChassisType, DriverKey,DriverId,FirstName,LastName,CDLNo,DriverTag,ContainerType)
	SELECT ActivityId,YardName,ContainerNo,ContainerDesc,Effect,CreatedDate,ChassisKey,ChassisNo,ChassisType, DriverKey,DriverId,FirstName,LastName,CDLNo,DriverTag,ContainerType
	FROM OPENJSON(@jsonText,'$')
	WITH
	(
		ActivityId		INT					'$.ActivityId',
		YardName		VARCHAR(100)		'$.YardName',
		ContainerNo		VARCHAR(50)			'$.ContainerNo',
		ContainerDesc	VARCHAR(20)			'$.Description',
		Effect			SMALLINT			'$.Effect',
		CreatedDate		DATETIME			'$.CreateDate',
		ChassisKey		INT					'$.ChassisKey',
		ChassisNo		VARCHAR(50)			'$.ChassisNo',
		ChassisType		VARCHAR(50)			'$.ChassisType',
		DriverKey		INT					'$.DriverKey',
		DriverId		VARCHAR(20)			'$.DriverId',
		FirstName		VARCHAR(50)			'$.FirstName',
		LastName		VARCHAR(50)			'$.LastName',
		CDLNo			VARCHAR(50)			'$.CDLNo',
		DriverTag		VARCHAR(50)			'$.DriverTag',
		ContainerType	VARCHAR(20)			'$.ContainerType'
	)


	TRUNCATE TABLE SafeGateIntegration_ContainerDetails_WRK

	INSERT INTO SafeGateIntegration_ContainerDetails_WRK (ActivityId,YardName,ContainerNo,ContainerDesc,Effect,CreatedDate,ChassisKey,ChassisNo,ChassisType, DriverKey,DriverId,FirstName,LastName,CDLNo,DriverTag,ContainerType)
	SELECT ActivityId,YardName,ContainerNo,ContainerDesc,Effect,CreatedDate,ChassisKey,ChassisNo,ChassisType, DriverKey,DriverId,FirstName,LastName,CDLNo,DriverTag,ContainerType FROM #Container


	INSERT INTO SafeGateIntegration_ContainerDetails
				(ActivityId,YardName,ContainerNo,ContainerDesc,Effect,CreatedDate,IsProcessed,ChassisKey,ChassisNo,ChassisType, DriverKey
				,DriverId,FirstName,LastName,CDLNo,DriverTag, DataPulledDate, ContainerType)
	SELECT		A.ActivityId,A.YardName,A.ContainerNo,A.ContainerDesc,A.Effect,A.CreatedDate,0,A.ChassisKey,A.ChassisNo,A.ChassisType, A.DriverKey
				,A.DriverId,A.FirstName,A.LastName,A.CDLNo,A.DriverTag, GETDATE(),A.ContainerType
	FROM		SafeGateIntegration_ContainerDetails_WRK A
	LEFT JOIN	SafeGateIntegration_ContainerDetails B ON A.ActivityID = B.ActivityID
	WHERE		B.ActivityID IS NULL	

END




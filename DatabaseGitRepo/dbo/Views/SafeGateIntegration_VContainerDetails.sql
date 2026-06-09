
CREATE VIEW SafeGateIntegration_VContainerDetails -- SELECT * FROM SafeGateIntegration_VContainerDetails

AS

SELECT		* 
FROM		(SELECT ROW_NUMBER() OVER (PARTITION BY ContainerNo  ORDER BY ContainerNo, CreatedDate DESC ) SL,* 
			FROM SafeGateIntegration_ContainerDetails) A
WHERE		SL = 1

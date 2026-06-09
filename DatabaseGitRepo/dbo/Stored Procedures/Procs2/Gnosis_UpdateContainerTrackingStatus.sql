
CREATE PROCEDURE Gnosis_UpdateContainerTrackingStatus
-- Gnosis_UpdateContainerTrackingStatus '{"uuid":"a378844f-b126-460a-b8a2-b505a6a8d527","container_number":"TCNU8939794","submitted_mbl":"MEDUEX271335","tracking_request":{"uuid":"0f0222d0-0a8e-4e01-98ad-d28fd95003b5","mbl_number":"MEDUEX271335","tracking":true,"tracking_status":"Successful","created_dt":"2024-07-01T07:10:08"}}'

(
	@JsonText	NVARCHAR(MAX)
)

AS

BEGIN
	
		SELECT			*
		INTO			#TMP
		FROM OPENJSON	(@JsonText,'$')
						WITH (
							ContainerNo			VARCHAR(50)	'$.container_number' ,
							Istracking			BIT			'$.tracking_request.tracking' ,
							trackingstatus		VARCHAR(50)	'$.tracking_request.tracking_status',
							uuid				VARCHAR(50) '$.uuid'
						)


		UPDATE			A
		SET				IsTrackingEnabled = B.Istracking, TrackingStatus = B.TrackingStatus, TrackingStatusUpdateDate = GETDATE()
		FROM			Gnosis_TrackingContainerRequestResponseDetail A
		INNER JOIN		#TMP B ON A.ContainerNo = B.ContainerNo AND A.ContainerTrackingReqUUID = B.uuid

END

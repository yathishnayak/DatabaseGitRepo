
CREATE PROCEDURE [dbo].[Gnosis_PendingContainerTrackingStatus_Delete]
-- Gnosis_UpdateContainerTrackingStatus '{"uuid":"a378844f-b126-460a-b8a2-b505a6a8d527","container_number":"TCNU8939794","submitted_mbl":"MEDUEX271335","tracking_request":{"uuid":"0f0222d0-0a8e-4e01-98ad-d28fd95003b5","mbl_number":"MEDUEX271335","tracking":true,"tracking_status":"Successful","created_dt":"2024-07-01T07:10:08"}}'

AS

BEGIN	
		SELECT			DISTINCT ContainerNo, IsTrackingEnabled, TrackingStatus
		FROM			Gnosis_TrackingContainerRequestResponseDetail WITH (NOLOCK)
		WHERE			IsTrackingEnabled IS NULL OR TrackingStatus = 'Pending'
		ORDER BY		IsTrackingEnabled	
		-- FOR JSON PATH
END


CREATE PROCEDURE	[dbo].[Admin_GetTransLockDetails]
AS
SELECT		O.name AS LockedObjectName,
			L.resource_type,
			L.request_mode,
			L.request_status,
			L.request_session_id AS BlockedSessionID,
			S.login_name,
			S.host_name + ' (' + C.client_net_address + ')' AS HostWithIP,
			-- S.program_name,
			R.command,
			R.blocking_session_id AS BlockingSessionID,
			R.wait_type,
			R.wait_time,
			R.status AS RequestStatus,
			ST.text AS BlockedSQL    
FROM		sys.dm_tran_locks L  
INNER JOIN	sys.objects O  ON L.resource_associated_entity_id = O.object_id  
			AND O.is_ms_shipped = 0
LEFT JOIN	sys.dm_exec_sessions S ON L.request_session_id = S.session_id  
LEFT JOIN	sys.dm_exec_connections C ON S.session_id = C.session_id  
LEFT JOIN	sys.dm_exec_requests R ON L.request_session_id = R.session_id  
OUTER APPLY sys.dm_exec_sql_text(R.sql_handle) ST  
WHERE		L.resource_database_id = DB_ID() and R.wait_time > 0
FOR JSON PATH


CREATE PROCEDURE [dbo].[Azure_Replication_Tablecount_Mismatch_Alert]--- [Replication_Tablecount_Mismatch_Alert] 'yogish@trikaiser.com'
@Recepients varchar(100)
AS
BEGIN
	DECLARE @tableHTML VARCHAR(MAX),
			@tablecount INT,				
			@Subject VARCHAR(200),
			@AlertProfile VARCHAR(10)			

   
	SET @AlertProfile ='Alert'				 
	
	SET @Subject	='JCBDB_Live_Azure_Replication_RowCount_Mismatch'
	SET NOCOUNT ON	
		
		select REP.Name AS TableName,REP.rowcnt AS RepRowCount,live.rowcnt AS ActualRowCOunt,(live.rowcnt-REP.rowcnt) AS Varience  into #TableData
		FROM
			(				
				SELECT o.NAME,
				  (i.rowcnt )
				FROM AzureSQL_JCBDB_Repl.JCBDB_Repl.dbo.sysindexes AS i
				  INNER JOIN AzureSQL_JCBDB_Repl.JCBDB_Repl.dbo.sysobjects AS o ON i.id = o.id 
				WHERE i.indid < 2  AND (OBJECTPROPERTY(o.id, 'IsMSShipped') = 0 OR OBJECTPROPERTY(o.id, 'IsMSShipped') IS NULL)
				--ORDER BY o.NAME  4762259
			) REP
			left join
			(
				 SELECT o.NAME,
				  (i.rowcnt )
				FROM JCBDB_Live.dbo.sysindexes AS i
				  INNER JOIN JCBDB_Live.dbo.sysobjects AS o ON i.id = o.id 
				WHERE i.indid < 2  --AND OBJECTPROPERTY(o.id, 'IsMSShipped') = 0
			)Live ON REP.name=Live.name
		WHERE rep.rowcnt<>live.rowcnt
		ORDER BY REp.name		
		
		SET @tablecount=(SELECT COUNT(1)FROM  #TableData )		 			        
		IF @tablecount>0			        
	    BEGIN 			        
			       SET @tableHTML=
			                       N'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
					<html xmlns="http://www.w3.org/1999/xhtml" >
					<header>
					<title>untittled page></title>
					<body> <br>'+
				    N'Hello,<br><br>'+
				    N'<br><br><br>'+
                    N'<table border="1">'+
                    N'<tr>
                    <th align="center" width="150">Table Name</th>
                    <th align="center" width="150">Replication DB Row count</th>
					<th align="center" width="150">Actual Row Count</th>	                           
					<th align="center" width="150">Varience</th>	 
                   
                  </tr>'+
                    cast ((SELECT "td/@align"='LEFT', td=''+TableName,'' ,
								  "td/@align"='CENTER', td=''+RepRowCount,'',
								  "td/@align"='CENTER', td=''+ActualRowCOunt,'',
								  "td/@align"='CENTER', td=''+Varience,'' 
							FROM 	 #TableData ORDER BY TableName
							FOR XML PATh ('tr'),type) AS NVARCHAR(MAX)) +
                       
                         N'</table><br><br><br><br>' +
                         N'Thank You!<br>'  
		END
		ELSE
		BEGIN
			 SET @tableHTML='JCBDB_LIVE DB Replication is Intact'
		END
                     EXEC msdb.dbo.sp_send_dbmail 
					@profile_name= @AlertProfile,
					@recipients=@Recepients,
					--@copy_recipients = '',					
					@subject = @Subject,			   
					@body= @tableHTML ,  
					@body_format = 'HTML'
				SET NOCOUNT OFF		 
END



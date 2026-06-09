


CREATE PROCEDURE [dbo].[Gnosis_Export_Insert_BookingDetails_Containers_MovetoFinal]

AS

BEGIN
	

	INSERT INTO Gnosis_Export_BookingDetails_Containers_Final
				(uuid,container_number,empty_out_dt,in_gate_dt,container_type,Conweight,Conlength,provided_by_ssl,provided_by_supplier
				,booking_uuid,customer_tags,seal_no,custom_columns,drayage, CreatedDate)
	SELECT		A.uuid,A.container_number,A.empty_out_dt,A.in_gate_dt,A.container_type,A.Conweight,A.Conlength,A.provided_by_ssl,A.provided_by_supplier
				,A.booking_uuid,A.customer_tags,A.seal_no,A.custom_columns,A.drayage,GETDATE() 
	FROM		Gnosis_Export_BookingDetails_Containers A  WITH (NOLOCK)
	LEFT JOIN	Gnosis_Export_BookingDetails_Containers_Final B  WITH (NOLOCK) On A.uuid = B.uuid
	WHERE		B.uuid IS NULL

END

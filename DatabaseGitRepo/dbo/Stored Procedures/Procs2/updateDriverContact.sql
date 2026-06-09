
CREATE proc [dbo].[updateDriverContact]
(
	@DriverKey	int,
	@DriverContact varchar(20)
)
as
Begin
	update A set Phone = @DriverContact
	--select *
	from Driver D 
	inner join Address A on D.AddrKey = A.AddrKey
	where D.DriverKey = @DriverKey
End
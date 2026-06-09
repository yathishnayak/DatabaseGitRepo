
CREATE function [dbo].[getReqPath]
(
	@input varchar(500),
	@Position smallint
)
returns varchar(500) 
as
Begin

Declare @len int, 
		@reqPosition smallint,
		@reqStr varchar(50)

declare @T table 
(
	num smallint identity(1,1),
	strval varchar(50)
)
		
select @len = len(@input) - len(replace(@input,'\', ''))

insert into @t
select  value from string_split(@input,'\')

if(@len >= @position)
begin
	select @reqStr = strval from @t where num = @position
end
else 
Begin
	select @reqStr = strval from @t where num = @len
end
	
select @reqPosition = charindex(@reqStr,@input )
select @reqStr = SUBSTRING(@input , 0, @reqPosition)
return @reqstr
End

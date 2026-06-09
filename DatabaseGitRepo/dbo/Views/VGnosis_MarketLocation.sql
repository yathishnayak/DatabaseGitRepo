

CREATE view [dbo].[VGnosis_MarketLocation]
With SCHEMABINDING
as
	Select Final_dest_city , 
		MarketLocation = case when Final_dest_city in ('Chicago, US','Harvey, US','Joliet, US','Elwood, US')
		Then 'Chicago' 
		when isnull(Final_dest_city,'') = '' then 'NA' 
		else 'Long Beach' end
	from dbo.Gnosis_Integration_Container_FINAL WITH (NOLOCK)
	group by Final_dest_city

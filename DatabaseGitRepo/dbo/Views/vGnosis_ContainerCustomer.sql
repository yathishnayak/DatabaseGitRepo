create view vGnosis_ContainerCustomer
WITH SCHEMABinding
as
SELECT UUID ,  
	  [Delivery Location City] as DelLocCity, 
		[Order CSR] as OrderCSR, [Delivery Location State] as DelLocState, 
		[Broker Ref No] as BrokerRefNo, [Customer],[Delivery Location Name] as DelLocName
	FROM  
	(
	  SELECT A.UUID, Field_name, Field_value
	  FROM dbo.Gnosis_Integration_ContainerCustomer_Final A WITH (NOLOCK)
	) AS SourceTable  
	PIVOT  
	(  
	  max(Field_Value)
	  FOR Field_name IN ([Delivery Location City], 
		[Order CSR], [Delivery Location State], [Broker Ref No], [Customer],[Delivery Location Name])  
	) AS PivotTable;
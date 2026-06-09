

CREATE view [dbo].[vGnosis_ContainerCustomers]
as 
	Select A.DataKey, Field_value as CustName 
	from Gnosis_Integration_ContainerCustomer A  WITH (NOLOCK)
	inner join Gnosis_Integration_VGetContainerDetails B  WITH (NOLOCK) on A.DataKey = b.DataKey
	where Field_name = 'Customer'

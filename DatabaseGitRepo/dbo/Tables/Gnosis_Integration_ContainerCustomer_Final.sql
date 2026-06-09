CREATE TABLE [dbo].[Gnosis_Integration_ContainerCustomer_Final] (
    [UUID]            VARCHAR (50) NOT NULL,
    [Field_name]      VARCHAR (50) NOT NULL,
    [Field_value]     VARCHAR (50) NULL,
    [Field_value_str] VARCHAR (50) NULL,
    CONSTRAINT [PK_Gnosis_Integration_ContainerCustomer_Final_1] PRIMARY KEY CLUSTERED ([UUID] ASC, [Field_name] ASC)
);


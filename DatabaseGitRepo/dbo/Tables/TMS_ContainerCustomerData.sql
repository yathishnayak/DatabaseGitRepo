CREATE TABLE [dbo].[TMS_ContainerCustomerData] (
    [OrderDetailKey] INT           NOT NULL,
    [ContainerNo]    VARCHAR (20)  NOT NULL,
    [CustID]         VARCHAR (100) NOT NULL,
    [CustName]       VARCHAR (100) NOT NULL,
    [CustKey]        INT           NOT NULL,
    [IsFactored]     BIT           NOT NULL,
    [AddrName]       VARCHAR (255) NOT NULL,
    [Address1]       VARCHAR (255) NOT NULL,
    [Address2]       VARCHAR (255) NULL,
    [City]           VARCHAR (255) NULL,
    [State]          VARCHAR (255) NULL,
    [ZipCode]        VARCHAR (50)  NULL,
    [Country]        CHAR (3)      NULL,
    [Phone]          VARCHAR (20)  NULL,
    [Phone2]         VARCHAR (20)  NULL,
    [Email]          VARCHAR (255) NULL,
    [Email2]         VARCHAR (50)  NULL,
    [Website]        VARCHAR (255) NULL
);


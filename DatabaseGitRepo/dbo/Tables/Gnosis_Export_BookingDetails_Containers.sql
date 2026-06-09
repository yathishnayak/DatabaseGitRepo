CREATE TABLE [dbo].[Gnosis_Export_BookingDetails_Containers] (
    [uuid]                 VARCHAR (50)   NULL,
    [container_number]     VARCHAR (20)   NULL,
    [empty_out_dt]         VARCHAR (20)   NULL,
    [in_gate_dt]           VARCHAR (20)   NULL,
    [container_type]       VARCHAR (20)   NULL,
    [Conweight]            VARCHAR (20)   NULL,
    [Conlength]            VARCHAR (20)   NULL,
    [provided_by_ssl]      VARCHAR (100)  NULL,
    [provided_by_supplier] VARCHAR (100)  NULL,
    [booking_uuid]         VARCHAR (100)  NULL,
    [customer_tags]        NVARCHAR (MAX) NULL,
    [seal_no]              VARCHAR (100)  NULL,
    [custom_columns]       NVARCHAR (MAX) NULL,
    [drayage]              NVARCHAR (MAX) NULL,
    [CreatedDate]          DATETIME       NULL
);


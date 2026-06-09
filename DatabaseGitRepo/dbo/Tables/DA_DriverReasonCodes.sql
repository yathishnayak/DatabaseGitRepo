CREATE TABLE [dbo].[DA_DriverReasonCodes] (
    [ReasonCodeKey] INT          NOT NULL,
    [ReasonCode]    VARCHAR (50) NULL,
    CONSTRAINT [PK_DA_DriverReasonCodes] PRIMARY KEY CLUSTERED ([ReasonCodeKey] ASC)
);


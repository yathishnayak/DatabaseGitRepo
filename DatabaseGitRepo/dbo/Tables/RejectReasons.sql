CREATE TABLE [dbo].[RejectReasons] (
    [RejectReasonKey]   SMALLINT     IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [RejectReasonDescr] VARCHAR (50) NULL,
    [AllowEntry]        BIT          NULL,
    [ReasonType]        VARCHAR (20) NULL,
    [IsActive]          BIT          NULL,
    [OrderBy]           INT          NULL,
    PRIMARY KEY CLUSTERED ([RejectReasonKey] ASC)
);


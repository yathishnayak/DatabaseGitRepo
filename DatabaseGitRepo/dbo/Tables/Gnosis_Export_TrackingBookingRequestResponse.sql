CREATE TABLE [dbo].[Gnosis_Export_TrackingBookingRequestResponse] (
    [TrackingBookingKey] INT            IDENTITY (1, 1) NOT NULL,
    [RequestSent]        NVARCHAR (MAX) NULL,
    [ResponseRcvd]       NVARCHAR (MAX) NULL,
    [CreatedDate]        DATETIME       NULL
);


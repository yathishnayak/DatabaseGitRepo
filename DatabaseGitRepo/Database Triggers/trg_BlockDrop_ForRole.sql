



CREATE TRIGGER [trg_BlockDrop_ForRole]
ON DATABASE
FOR DROP_TABLE, DROP_VIEW, DROP_PROCEDURE, DROP_FUNCTION, DROP_TYPE, DROP_SCHEMA, DROP_SYNONYM
AS
BEGIN
    IF IS_ROLEMEMBER('db_CreateAlter') = 1 AND IS_ROLEMEMBER('db_DropDBObjects') = 0
    BEGIN
        ROLLBACK;
        THROW 51000, 'Dropping objects is not allowed for this user. Contact DB Admin.', 1;
    END
END


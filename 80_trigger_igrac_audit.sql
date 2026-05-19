/* ==========================================================
   AUDIT TRIGGER: dbo.Igrac_TR_LogChanges
   
   log_Action vrijednosti:
     'I'  = INSERT (novi red)
     'D'  = DELETE (obrisani red)
     'UD' = UPDATE - staro stanje (iz DELETED)
     'UI' = UPDATE - novo stanje  (iz INSERTED)

   Proslijediti ID odgovornog korisnika prije DELETE naredbe:
     SELECT [log_IdResponsible] = @KorisnikId INTO #Igrac_TR_LogChanges
   ========================================================== */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* ====================================================
   Provjera preduvjeta
==================================================== */
IF OBJECT_ID(N'dbo.Igrac', N'U') IS NULL
BEGIN
    RAISERROR(N'Tablica dbo.Igrac ne postoji. Pokreni FAZU 1 (10_schema_cleanup.sql).', 16, 1);
    SET NOEXEC ON;
END;
GO

IF OBJECT_ID(N'dbo.log_Igrac', N'U') IS NULL
BEGIN
    RAISERROR(N'Tablica dbo.log_Igrac ne postoji. Pokreni FAZU 1B (11_audit_log_tables.sql).', 16, 1);
    SET NOEXEC ON;
END;
GO

PRINT N'Kreiranje triggera: dbo.Igrac_TR_LogChanges';
GO

/* ====================================================
   dbo.Igrac_TR_LogChanges
==================================================== */
CREATE OR ALTER TRIGGER dbo.Igrac_TR_LogChanges
ON dbo.Igrac
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @CONFIG_LOG_INSERTS BIT = 1
    DECLARE @debug BIT = 0
    IF @debug = 0 SET NOCOUNT ON

    DECLARE @TriggerEvent INT
    SET @TriggerEvent = ISNULL((SELECT TOP 1 1 FROM INSERTED), 0)
                      + ISNULL((SELECT TOP 1 2 FROM DELETED),  0)
    IF (@TriggerEvent = 0 OR (@TriggerEvent = 1 AND @CONFIG_LOG_INSERTS = 0)) RETURN

    DECLARE @Now DATETIME2(0) = SYSUTCDATETIME()
    DECLARE @ResponsiblePersonId INT

    -- Za DELETE: dohvati iz temp tablice (aplikacija mora kreirati prije DELETE)
    -- Za INSERT/UPDATE: dohvati iz INSERTED.ResponsibleId
    IF @TriggerEvent = 2 -- DELETE
    BEGIN
        IF OBJECT_ID('tempdb..#Igrac_TR_LogChanges') IS NOT NULL
            SELECT @ResponsiblePersonId = t.log_IdResponsible FROM #Igrac_TR_LogChanges t
        IF @ResponsiblePersonId IS NULL
            SELECT @ResponsiblePersonId = MAX([ResponsibleId]) FROM DELETED
    END
    ELSE -- INSERT ili UPDATE
    BEGIN
        SELECT @ResponsiblePersonId = MAX([ResponsibleId]) FROM INSERTED
    END

    IF @debug = 1 SELECT [@ResponsiblePersonId] = @ResponsiblePersonId

    -- Pronadi promijenjene kolone za UPDATE
    CREATE TABLE #igrac_changed (admlog_row_number INT PRIMARY KEY, changed_columns VARCHAR(1500))
    IF @TriggerEvent = 3
    BEGIN
        INSERT INTO #igrac_changed (admlog_row_number, changed_columns)
        SELECT
            i.admlog_row_number,
            changed_columns = SUBSTRING(''
                + CASE WHEN i.[Ime]           = d.[Ime]           OR ISNULL(i.[Ime],           d.[Ime])           IS NULL THEN '' ELSE ',Ime'           END
                + CASE WHEN i.[Prezime]       = d.[Prezime]       OR ISNULL(i.[Prezime],       d.[Prezime])       IS NULL THEN '' ELSE ',Prezime'       END
                + CASE WHEN i.[Pozicija]      = d.[Pozicija]      OR ISNULL(i.[Pozicija],      d.[Pozicija])      IS NULL THEN '' ELSE ',Pozicija'      END
                + CASE WHEN i.[TimId]         = d.[TimId]         OR ISNULL(i.[TimId],         d.[TimId])         IS NULL THEN '' ELSE ',TimId'         END
                + CASE WHEN i.[ResponsibleId] = d.[ResponsibleId] OR ISNULL(i.[ResponsibleId], d.[ResponsibleId]) IS NULL THEN '' ELSE ',ResponsibleId' END
                + CASE WHEN i.[IsDeleted]     = d.[IsDeleted]     OR ISNULL(i.[IsDeleted],     d.[IsDeleted])     IS NULL THEN '' ELSE ',IsDeleted'     END
                + CASE WHEN i.[DeletedAt]     = d.[DeletedAt]     OR ISNULL(i.[DeletedAt],     d.[DeletedAt])     IS NULL THEN '' ELSE ',DeletedAt'     END
                , 2, 1500)
        FROM (SELECT admlog_row_number = ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), * FROM inserted) i
        JOIN  (SELECT admlog_row_number = ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), * FROM deleted)  d
               ON i.admlog_row_number = d.admlog_row_number
    END
    IF @debug = 1 SELECT [#igrac_changed] = 'DEBUG', * FROM #igrac_changed
    IF @TriggerEvent = 3 AND NOT EXISTS (SELECT 1 FROM #igrac_changed WHERE changed_columns <> '') RETURN

    -- DELETE i staro stanje UPDATE-a
    IF @TriggerEvent IN (2, 3)
    BEGIN
        INSERT INTO dbo.log_Igrac
            (IgracId, Ime, Prezime, Pozicija, TimId, ResponsibleId, IsDeleted, DeletedAt,
             log_DateTS, log_IdResponsible, log_Action, log_ColumnsUpdated)
        SELECT
            d.[IgracId], d.[Ime], d.[Prezime], d.[Pozicija], d.[TimId], d.[ResponsibleId], d.[IsDeleted], d.[DeletedAt],
            @Now, @ResponsiblePersonId,
            CASE @TriggerEvent WHEN 2 THEN 'D' WHEN 3 THEN 'UD' END,
            ch.changed_columns
        FROM (SELECT admlog_row_number = ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), * FROM deleted) d
        LEFT JOIN #igrac_changed ch ON ch.admlog_row_number = d.admlog_row_number
    END

    -- INSERT i novo stanje UPDATE-a
    IF @TriggerEvent IN (1, 3) AND @CONFIG_LOG_INSERTS = 1
    BEGIN
        INSERT INTO dbo.log_Igrac
            (IgracId, Ime, Prezime, Pozicija, TimId, ResponsibleId, IsDeleted, DeletedAt,
             log_DateTS, log_IdResponsible, log_Action, log_ColumnsUpdated)
        SELECT
            i.[IgracId], i.[Ime], i.[Prezime], i.[Pozicija], i.[TimId], i.[ResponsibleId], i.[IsDeleted], i.[DeletedAt],
            @Now, @ResponsiblePersonId,
            CASE @TriggerEvent WHEN 1 THEN 'I' WHEN 3 THEN 'UI' END,
            ch.changed_columns
        FROM (SELECT admlog_row_number = ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), * FROM inserted) i
        LEFT JOIN #igrac_changed ch ON ch.admlog_row_number = i.admlog_row_number
    END
END
GO

EXEC sp_settriggerorder @triggername = N'dbo.Igrac_TR_LogChanges', @order = N'Last', @stmttype = N'DELETE';
EXEC sp_settriggerorder @triggername = N'dbo.Igrac_TR_LogChanges', @order = N'Last', @stmttype = N'INSERT';
EXEC sp_settriggerorder @triggername = N'dbo.Igrac_TR_LogChanges', @order = N'Last', @stmttype = N'UPDATE';

PRINT N'Trigger dbo.Igrac_TR_LogChanges kreiran.';
GO

SET NOEXEC OFF;
GO

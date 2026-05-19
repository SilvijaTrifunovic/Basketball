/* ==========================================================
   CONSTRAINT TRIGGER: dbo.KorisnikTim (SOFT DELETE ONLY)
   
   Fizički DELETE nije dozvoljen - koristi soft delete:
     UPDATE SET IsDeleted = 1, DeletedAt = SYSUTCDATETIME()
   ========================================================== */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* ====================================================
   Provjera preduvjeta
==================================================== */
IF OBJECT_ID(N'dbo.KorisnikTim', N'U') IS NULL
BEGIN
    RAISERROR(N'Tablica dbo.KorisnikTim ne postoji. Pokreni FAZU 1 (10_schema_cleanup.sql).', 16, 1);
    SET NOEXEC ON;
END;
GO

PRINT N'Kreiranje constraint triggera za tablicu: dbo.KorisnikTim';
GO

/* ====================================================
   KorisnikTim_TR_PreventHardDelete - Zabranjuje fizički DELETE
==================================================== */
CREATE OR ALTER TRIGGER dbo.KorisnikTim_TR_PreventHardDelete
ON dbo.KorisnikTim
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    RAISERROR(N'Fizički DELETE nije dozvoljen na tablici KorisnikTim. Koristi soft delete: UPDATE SET IsDeleted=1, DeletedAt=SYSUTCDATETIME().', 16, 1);
END
GO

/* ====================================================
   KorisnikTim_TR_AllowOnlySoftDeleteUpdate - Dozvoljava UPDATE samo za soft delete
==================================================== */
CREATE OR ALTER TRIGGER dbo.KorisnikTim_TR_AllowOnlySoftDeleteUpdate
ON dbo.KorisnikTim
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Provjeri jesu li promijenjene samo dozvoljene kolone (IsDeleted, DeletedAt)
    -- Ako je promijenjena bilo koja druga kolona, baci error
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d ON i.KorisnikId = d.KorisnikId AND i.TimId = d.TimId
        WHERE i.CreatedAt <> d.CreatedAt  -- CreatedAt se ne smije mijenjati
    )
    BEGIN
        RAISERROR(N'UPDATE nije dozvoljen na tablici KorisnikTim osim za soft delete (IsDeleted, DeletedAt).', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

PRINT N'Constraint triggeri za dbo.KorisnikTim kreirani (soft-delete-only).';
GO

/*
-- Primjer koristenja:
-- Dodavanje pracenja:
INSERT INTO dbo.KorisnikTim (KorisnikId, TimId) VALUES (1, 5);  -- OK

-- Prestanak pracenja (soft delete):
UPDATE dbo.KorisnikTim 
SET IsDeleted = 1, DeletedAt = SYSUTCDATETIME() 
WHERE KorisnikId = 1 AND TimId = 5;  -- OK

-- Fizicki delete:
DELETE FROM dbo.KorisnikTim WHERE KorisnikId = 1 AND TimId = 5;  -- ERROR

-- Query aktivnih relacija:
SELECT * FROM dbo.KorisnikTim WHERE IsDeleted = 0;
*/
GO

SET NOEXEC OFF;
GO

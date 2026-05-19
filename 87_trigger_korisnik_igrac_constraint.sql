/* ==========================================================
   CONSTRAINT TRIGGER: dbo.KorisnikIgrac (SOFT DELETE ONLY)
   
   Fizički DELETE nije dozvoljen - koristi soft delete:
     UPDATE SET IsDeleted = 1, DeletedAt = SYSUTCDATETIME()
   ========================================================== */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* ====================================================
   Provjera preduvjeta
==================================================== */
IF OBJECT_ID(N'dbo.KorisnikIgrac', N'U') IS NULL
BEGIN
    RAISERROR(N'Tablica dbo.KorisnikIgrac ne postoji. Pokreni FAZU 1 (10_schema_cleanup.sql).', 16, 1);
    SET NOEXEC ON;
END;
GO

PRINT N'Kreiranje constraint triggera za tablicu: dbo.KorisnikIgrac';
GO

/* ====================================================
   KorisnikIgrac_TR_PreventHardDelete - Zabranjuje fizički DELETE
==================================================== */
CREATE OR ALTER TRIGGER dbo.KorisnikIgrac_TR_PreventHardDelete
ON dbo.KorisnikIgrac
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    RAISERROR(N'Fizički DELETE nije dozvoljen na tablici KorisnikIgrac. Koristi soft delete: UPDATE SET IsDeleted=1, DeletedAt=SYSUTCDATETIME().', 16, 1);
END
GO

/* ====================================================
   KorisnikIgrac_TR_AllowOnlySoftDeleteUpdate - Dozvoljava UPDATE samo za soft delete
==================================================== */
CREATE OR ALTER TRIGGER dbo.KorisnikIgrac_TR_AllowOnlySoftDeleteUpdate
ON dbo.KorisnikIgrac
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Provjeri jesu li promijenjene samo dozvoljene kolone (IsDeleted, DeletedAt)
    -- Ako je promijenjena bilo koja druga kolona, baci error
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d ON i.KorisnikId = d.KorisnikId AND i.IgracId = d.IgracId
        WHERE i.CreatedAt <> d.CreatedAt  -- CreatedAt se ne smije mijenjati
    )
    BEGIN
        RAISERROR(N'UPDATE nije dozvoljen na tablici KorisnikIgrac osim za soft delete (IsDeleted, DeletedAt).', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

PRINT N'Constraint triggeri za dbo.KorisnikIgrac kreirani (soft-delete-only).';
GO

/*
-- Primjer koristenja:
-- Dodavanje pracenja:
INSERT INTO dbo.KorisnikIgrac (KorisnikId, IgracId) VALUES (1, 10);  -- OK

-- Prestanak pracenja (soft delete):
UPDATE dbo.KorisnikIgrac 
SET IsDeleted = 1, DeletedAt = SYSUTCDATETIME() 
WHERE KorisnikId = 1 AND IgracId = 10;  -- OK

-- Fizicki delete:
DELETE FROM dbo.KorisnikIgrac WHERE KorisnikId = 1 AND IgracId = 10;  -- ERROR

-- Query aktivnih relacija:
SELECT * FROM dbo.KorisnikIgrac WHERE IsDeleted = 0;
*/
GO

SET NOEXEC OFF;
GO

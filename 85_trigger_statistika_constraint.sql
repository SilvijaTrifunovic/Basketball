/* ==========================================================
   CONSTRAINT TRIGGER: dbo.Statistika (INSERT ONLY / immutable)
   
   Statistika je nepromjenjiva - jednom upisani podaci se
   ne mogu mijenjati niti brisati.
   ========================================================== */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* ====================================================
   Provjera preduvjeta
==================================================== */
IF OBJECT_ID(N'dbo.Statistika', N'U') IS NULL
BEGIN
    RAISERROR(N'Tablica dbo.Statistika ne postoji. Pokreni FAZU 1 (10_schema_cleanup.sql).', 16, 1);
    SET NOEXEC ON;
END;
GO

PRINT N'Kreiranje constraint triggera za tablicu: dbo.Statistika';
GO

/* ====================================================
   Statistika_TR_PreventUpdate - Zabranjuje UPDATE
==================================================== */
CREATE OR ALTER TRIGGER dbo.Statistika_TR_PreventUpdate
ON dbo.Statistika
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    RAISERROR(N'UPDATE nije dozvoljen na tablici Statistika. Statistika je immutable (insert-only).', 16, 1);
END
GO

/* ====================================================
   Statistika_TR_PreventDelete - Zabranjuje DELETE
==================================================== */
CREATE OR ALTER TRIGGER dbo.Statistika_TR_PreventDelete
ON dbo.Statistika
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    RAISERROR(N'DELETE nije dozvoljen na tablici Statistika. Statistika je immutable (insert-only).', 16, 1);
END
GO

PRINT N'Constraint triggeri za dbo.Statistika kreirani (INSERT-only).';
GO

SET NOEXEC OFF;
GO

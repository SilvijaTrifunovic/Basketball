/* ==========================================================
   FAZA 2: STATICKI PODACI
   ========================================================== */

DECLARE @e_message NVARCHAR(4000);

SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

        PRINT N'FAZA 2 Start: staticki podaci (Tim, Dvorana).';

        /* Provjera: tablice moraju postojati */
        IF OBJECT_ID(N'dbo.Tim', N'U') IS NULL
            RAISERROR(N'Tablica dbo.Tim ne postoji.', 16, 1);
        IF OBJECT_ID(N'dbo.Dvorana', N'U') IS NULL
            RAISERROR(N'Tablica dbo.Dvorana ne postoji.', 16, 1);

        /* Provjera: tablice moraju biti prazne */
        IF EXISTS (SELECT 1 FROM dbo.Tim)
            RAISERROR(N'Tablica dbo.Tim nije prazna.', 16, 1);
        IF EXISTS (SELECT 1 FROM dbo.Dvorana)
            RAISERROR(N'Tablica dbo.Dvorana nije prazna.', 16, 1);

        /* Timovi */
        INSERT INTO dbo.Tim (Naziv, Grad, ResponsibleId)
        VALUES
        (N'Cibona', N'Zagreb', -125),
        (N'Zadar', N'Zadar', -125),
        (N'Split', N'Split', -125),
        (N'Cedevita Junior', N'Zagreb', -125),
        (N'Alkar', N'Sinj', -125),
        (N'Osijek', N'Osijek', -125),
        (N'Gorica', N'Velika Gorica', -125),
        (N'Zabok', N'Zabok', -125),
        (N'Dubrovnik', N'Dubrovnik', -125),
        (N'Rijeka', N'Rijeka', -125),
        (N'Kvarner', N'Rijeka', -125),
        (N'Varaždin', N'Varaždin', -125),
        (N'Sarajevo', N'Sarajevo', -125),
        (N'Borac', N'Banja Luka', -125),
        (N'Partizan', N'Beograd', -125),
        (N'Crvena Zvezda', N'Beograd', -125),
        (N'FMP', N'Beograd', -125),
        (N'Budućnost', N'Podgorica', -125),
        (N'Igokea', N'Aleksandrovac', -125),
        (N'Mornar', N'Bar', -125);

        /* Dvorane */
        INSERT INTO dbo.Dvorana (Naziv, Lokacija, Kapacitet, ResponsibleId)
        VALUES
        (N'Dom Dražena Petrovića', N'Zagreb', 5400, -125),
        (N'Arena Zagreb', N'Zagreb', 7000, -125),
        (N'Krešimir Ćosić', N'Zadar', 9000, -125),
        (N'Gripe', N'Split', 6000, -125),
        (N'Gradski vrt', N'Osijek', 3500, -125),
        (N'Dvorana Mladosti', N'Karlovac', 2500, -125),
        (N'Baldekin', N'Šibenik', 3200, -125),
        (N'Višnjik B', N'Zadar', 2500, -125),
        (N'Pionir', N'Beograd', 8000, -125),
        (N'Aleksandar Nikolić', N'Beograd', 7500, -125),
        (N'Morača', N'Podgorica', 5000, -125),
        (N'Skenderija', N'Sarajevo', 5500, -125);

        SELECT COUNT(*) AS BrojTimova FROM dbo.Tim;
        SELECT COUNT(*) AS BrojDvorana FROM dbo.Dvorana;

        PRINT N'FAZA 2 zavrsena: staticki podaci (Tim, Dvorana) su upisani.';

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRAN;
    SELECT @e_message=ERROR_MESSAGE()
    RAISERROR(@e_message, 16, 1);
END CATCH;


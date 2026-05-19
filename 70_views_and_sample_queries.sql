/* ==========================================================
   FAZA 7: SVI VIEW-OVI
   
   View-ovi za izvjestaje - upiti bez parametara.
   Za funkcije s parametrima vidi: 71_functions.sql
   ========================================================== */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* Provjera tablica */
IF OBJECT_ID(N'dbo.Statistika', N'U') IS NULL
    OR OBJECT_ID(N'dbo.Igrac', N'U') IS NULL
    OR OBJECT_ID(N'dbo.Tim', N'U') IS NULL
    OR OBJECT_ID(N'dbo.Utakmica', N'U') IS NULL
    OR OBJECT_ID(N'dbo.Dvorana', N'U') IS NULL
BEGIN
    RAISERROR(N'Nedostaju tablice za kreiranje view-ova. Pokreni FAZU 1.', 16, 1);
    SET NOEXEC ON;
END;
GO

PRINT N'FAZA 7 Start: kreiranje view-ova.';


/* ---------------------------------------------------------
   vwIgracSveUtakmice - Sve statistike svih igraca
   
   Baza za razne izvjestaje - spaja statistike sa utakmicama.
   --------------------------------------------------------- */
CREATE OR ALTER VIEW dbo.vwIgracSveUtakmice
AS
SELECT
	s.StatistikaId,
	s.UtakmicaId,
	u.Datum,
	u.VrijemePocetka,
	u.DvoranaId,
	s.IgracId,
	i.TimId,
	t.Naziv AS TimNaziv,
	i.Ime,
	i.Prezime,
	i.Ime + N' ' + i.Prezime AS PunoIme,
	i.Pozicija,
	u.TimDomaci,
	td.Naziv AS TimDomaciNaziv,
	u.TimGosti,
	tg.Naziv AS TimGostiNaziv,
	CASE WHEN i.TimId = u.TimDomaci THEN N'Domaci' ELSE N'Gosti' END AS TipUtakmice,
	s.Minuta,
	s.Poeni,
	s.Asistencije,
	s.SkokoviOf,
	s.SkokoviDef,
	(s.SkokoviOf + s.SkokoviDef) AS SkokoviUkupno,
	s.UkradeneLopte,
	s.Blokade,
	s.IzgubljeneLopte,
	s.OsobnePogreske,
	s.FGM,
	s.FGA,
	CAST(CASE WHEN s.FGA > 0 THEN CAST(s.FGM AS DECIMAL(5,2)) / s.FGA * 100 ELSE 0 END AS DECIMAL(5,1)) AS FGPct,
	s.FG3M,
	s.FG3A,
	CAST(CASE WHEN s.FG3A > 0 THEN CAST(s.FG3M AS DECIMAL(5,2)) / s.FG3A * 100 ELSE 0 END AS DECIMAL(5,1)) AS FG3Pct,
	s.FTM,
	s.FTA,
	CAST(CASE WHEN s.FTA > 0 THEN CAST(s.FTM AS DECIMAL(5,2)) / s.FTA * 100 ELSE 0 END AS DECIMAL(5,1)) AS FTPct,
	s.CreatedAt
FROM dbo.Statistika s
JOIN dbo.Igrac i ON i.IgracId = s.IgracId
JOIN dbo.Tim t ON t.TimId = i.TimId
JOIN dbo.Utakmica u ON u.UtakmicaId = s.UtakmicaId
JOIN dbo.Tim td ON td.TimId = u.TimDomaci
JOIN dbo.Tim tg ON tg.TimId = u.TimGosti
WHERE i.IsDeleted = 0 
  AND u.IsDeleted = 0;
GO

/* ---------------------------------------------------------
   vwNadolazeceUtakmice - Sve buduce utakmice
   --------------------------------------------------------- */
CREATE OR ALTER VIEW dbo.vwNadolazeceUtakmice
AS
SELECT 
    u.UtakmicaId,
    u.Datum,
    u.VrijemePocetka,
    u.TimDomaci AS TimDomaciId,
    td.Naziv AS Domaci,
    td.Grad AS DomaciGrad,
    u.TimGosti AS TimGostiId,
    tg.Naziv AS Gosti,
    tg.Grad AS GostiGrad,
    u.DvoranaId,
    d.Naziv AS Dvorana,
    d.Lokacija,
    d.Kapacitet
FROM dbo.Utakmica u
JOIN dbo.Tim td ON td.TimId = u.TimDomaci
JOIN dbo.Tim tg ON tg.TimId = u.TimGosti
JOIN dbo.Dvorana d ON d.DvoranaId = u.DvoranaId
WHERE u.Datum >= CAST(GETDATE() AS DATE)
  AND u.IsDeleted = 0
  AND td.IsDeleted = 0
  AND tg.IsDeleted = 0
  AND d.IsDeleted = 0;
GO

/* ---------------------------------------------------------
   vwTop10Strijelaca - Top 10 po ukupnim poenima
   --------------------------------------------------------- */
CREATE OR ALTER VIEW dbo.vwTop10Strijelaca
AS
SELECT TOP 10
    i.IgracId,
    i.Ime,
    i.Prezime,
    i.Ime + N' ' + i.Prezime AS PunoIme,
    i.Pozicija,
    i.TimId,
    t.Naziv AS Tim,
    t.Grad AS TimGrad,
    COUNT(*) AS BrojUtakmica,
    SUM(s.Poeni) AS UkupnoPoena,
    CAST(AVG(CAST(s.Poeni AS DECIMAL(5,1))) AS DECIMAL(5,1)) AS PPG,
    MAX(s.Poeni) AS MaxPoena,
    SUM(s.Asistencije) AS UkupnoAsistencija,
    CAST(AVG(CAST(s.Asistencije AS DECIMAL(5,1))) AS DECIMAL(5,1)) AS APG,
    SUM(s.SkokoviOf + s.SkokoviDef) AS UkupnoSkokova,
    CAST(AVG(CAST(s.SkokoviOf + s.SkokoviDef AS DECIMAL(5,1))) AS DECIMAL(5,1)) AS RPG,
    CAST(CASE 
        WHEN SUM(s.FGA) > 0 
        THEN CAST(SUM(s.FGM) AS DECIMAL(10,2)) / SUM(s.FGA) * 100 
        ELSE 0 
    END AS DECIMAL(5,1)) AS FGPct,
    CAST(CASE 
        WHEN SUM(s.FG3A) > 0 
        THEN CAST(SUM(s.FG3M) AS DECIMAL(10,2)) / SUM(s.FG3A) * 100 
        ELSE 0 
    END AS DECIMAL(5,1)) AS FG3Pct,
    CAST(CASE 
        WHEN SUM(s.FTA) > 0 
        THEN CAST(SUM(s.FTM) AS DECIMAL(10,2)) / SUM(s.FTA) * 100 
        ELSE 0 
    END AS DECIMAL(5,1)) AS FTPct
FROM dbo.Statistika s
JOIN dbo.Igrac i ON i.IgracId = s.IgracId
JOIN dbo.Tim t ON t.TimId = i.TimId
WHERE i.IsDeleted = 0
GROUP BY i.IgracId, i.Ime, i.Prezime, i.Pozicija, i.TimId, t.Naziv, t.Grad
ORDER BY UkupnoPoena DESC;
GO

/* ---------------------------------------------------------
   vwTop10PPG - Top 10 po prosjecnim poenima (min 5 utakmica)
   --------------------------------------------------------- */
CREATE OR ALTER VIEW dbo.vwTop10PPG
AS
SELECT TOP 10
    i.IgracId,
    i.Ime,
    i.Prezime,
    i.Ime + N' ' + i.Prezime AS PunoIme,
    i.Pozicija,
    i.TimId,
    t.Naziv AS Tim,
    COUNT(*) AS BrojUtakmica,
    CAST(AVG(CAST(s.Poeni AS DECIMAL(5,1))) AS DECIMAL(5,1)) AS PPG,
    CAST(AVG(CAST(s.Asistencije AS DECIMAL(5,1))) AS DECIMAL(5,1)) AS APG,
    CAST(AVG(CAST(s.SkokoviOf + s.SkokoviDef AS DECIMAL(5,1))) AS DECIMAL(5,1)) AS RPG
FROM dbo.Statistika s
JOIN dbo.Igrac i ON i.IgracId = s.IgracId
JOIN dbo.Tim t ON t.TimId = i.TimId
WHERE i.IsDeleted = 0
GROUP BY i.IgracId, i.Ime, i.Prezime, i.Pozicija, i.TimId, t.Naziv
HAVING COUNT(*) >= 5
ORDER BY PPG DESC;
GO

/* ==========================================================
   PRIMJERI KORISTENJA VIEW-OVA
   ========================================================== */
PRINT N'=== PRIMJERI KORISTENJA VIEW-OVA ===';

-- Zadnjih 100 statistika
SELECT TOP (100) Datum, PunoIme, TimNaziv, TipUtakmice, Poeni, Asistencije, SkokoviUkupno, FGPct
FROM dbo.vwIgracSveUtakmice
ORDER BY Datum DESC, StatistikaId DESC;

-- Nadolazece utakmice
SELECT * FROM dbo.vwNadolazeceUtakmice ORDER BY Datum, VrijemePocetka;

-- Top 10 strijelaca (ukupno poena)
SELECT * FROM dbo.vwTop10Strijelaca;

-- Top 10 po PPG
SELECT * FROM dbo.vwTop10PPG;

PRINT N'FAZA 7 zavrsena: view-ovi kreirani.';
GO

SET NOEXEC OFF;
GO


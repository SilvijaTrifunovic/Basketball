# 🏀 Basketball Liga - MS SQL

## 📋 Sadržaj

1. [Opis](#1-opis)
   - 1.1 [Zahtjevi](#11-zahtjevi)
   - 1.2 [Funkcionalnosti](#12-funkcionalnosti)
2. [Brzi početak](#2-brzi-početak)
   - 2.1 [Instalacija](#21-instalacija)
   - 2.2 [Konfiguracija volumena](#22-konfiguracija-volumena)
3. [Logička organizacija podataka](#3-logička-organizacija-podataka)
   - 3.1 [Entiteti i njihove relacije](#31-entiteti-i-njihove-relacije)
      - 3.1.1 [ER Dijagram](#311-er-dijagram)
      - 3.1.2 [Sve relacije (FK veze)](#312-sve-relacije-fk-veze)
   - 3.2 [Opis entiteta](#32-opis-entiteta)
   - 3.3 [Poslovna pravila i ograničenja](#33-poslovna-pravila-i-ograničenja)
   - 3.4 [Hijerarhija entiteta](#34-hijerarhija-entiteta-slojevi)
4. [Fizička organizacija podataka](#4-fizička-organizacija-podataka)
   - 4.1 [Tablice - Detaljna struktura](#41-tablice---detaljna-struktura)
   - 4.2 [Audit Log Tablice](#42-audit-log-tablice)
   - 4.3 [Indeksi](#43-indeksi)
   - 4.4 [Triggeri](#44-triggeri)
   - 4.5 [View-ovi](#45-view-ovi)
   - 4.6 [Table-Valued Funkcije (TVF)](#46-table-valued-funkcije-tvf)
5. [Redoslijed izvršavanja skripti](#5-redoslijed-izvršavanja-skripti)
   - 5.1 [Faze izvršavanja](#51-faze-izvršavanja)
   - 5.2 [Tablica skripti](#52-tablica-skripti)
6. [API integracije](#6-api-integracije)
   - 6.1 [Primjeri API endpointa](#61-primjeri-api-endpointa)
   - 6.2 [Primjeri SQL upita za API](#62-primjeri-sql-upita-za-api)
7. [Upute za optimalne SQL upite](#7-upute-za-optimalne-sql-upite)
   - 7.1 [Korištenje View-ova i Funkcija](#71-korištenje-postojećih-view-ova-i-funkcija)
   - 7.2 [Soft Delete filter](#72-soft-delete---obavezni-filter)
   - 7.3 [Upiti po tablicama](#73-upiti-po-tablicama)
   - 7.4 [Rad s triggerima](#74-rad-s-triggerima)
   - 7.5 [Korištenje indeksa](#75-korištenje-indeksa)
   - 7.6 [Česti scenariji](#76-česti-scenariji)
   - 7.7 [Checklist](#77-checklist-prije-izvršavanja)
8. [Backup strategija](#8-strategija-sigurnosne-kopije-podataka)
   - 8.1 [Klasifikacija podataka](#81-klasifikacija-podataka-po-kritičnosti)
   - 8.2 [Raspored backup-a](#82-raspored-backup-a)
   - 8.3 [SQL Server Agent Jobs](#83-sql-server-agent-jobs)
   - 8.4 [Specifičnosti baze](#84-specifičnosti-ove-baze)
   - 8.5 [Scenariji oporavka](#85-scenariji-oporavka)
   - 8.6 [Point-in-Time Recovery](#86-point-in-time-recovery-primjer)
   - 8.7 [Retencijska politika](#87-retencijska-politika)
   - 8.8 [Verifikacija backup-a](#88-verifikacija-backup-a)
   - 8.9 [Checklist backup strategije](#89-checklist-backup-strategije)

---

## 1. Opis

Kompletna MS SQL baza podataka za košarkašku ligu s timovima, igračima, utakmicama i statistikama.

> **Tehnički zadatak:** Dizajn i implementacija relacijske baze podataka za web platformu koja prati statistike, raspored, timove i igrače unutar jedne košarkaške lige.

---

### 1.1 Zahtjevi

| Zahtjev | Implementacija |
|--------------------|----------------|
| **1. ER modeliranje** | ER dijagram s 8 entiteta, FK vezama i M:N relacijama |
| **2. Dizajn baze podataka** | Struktura tablica, PK/FK, relacije, uzorak podataka |
| **3. Audit podataka** | Audit tablice (log_Igrac, log_Utakmica, log_Korisnik) + AFTER triggeri |
| **4. Indeksiranje** | 25+ indeksa optimiziranih za ključne upite |
| **5. SQL skripte** | 16 skripti za tablice, indekse, triggere, view-ove, funkcije |

### 1.2 Funkcionalnosti

| Funkcionalnost | Implementacija |
|----------------|----------------|
| Korisnički sustav (do 100.000) | Korisnik tablica, skalabilna |
| Raspored utakmica (60-80/mj) | Utakmica + vwNadolazeceUtakmice |
| Statistika igrača (15+ kategorija) | 17 kategorija u Statistika tablici |
| Korisnici prate timove/igrače | KorisnikTim, KorisnikIgrac (M:N) |
| Statistike po igraču i timu | fnStatistikaIgraca, vwTop10Strijelaca |
| Statistike domaćih/gostujućih | vwIgracSveUtakmice (TipUtakmice kolona) |
| View za izvještaje igrača | vwIgracSveUtakmice |
| API priprema | 7 endpointa mapiranih na view-ove/funkcije |


## 2. Brzi početak

### 2.1 Instalacija

Pokreni skripte **redom** u SQL Server Management Studio:

| # | Skripta | Opis |
|---|---------|------|
| 00 | `00_seed_config.sql` | Konfiguracija volumena podataka |
| 10 | `10_schema_cleanup.sql` | Tablice + indeksi |
| 11 | `11_audit_log_tables.sql` | Tablice za audit logove |
| 20 | `20_seed_static_data.sql` | Tim (20), Dvorana (12) |
| 30 | `30_seed_core_entities.sql` | Igrac (280), Korisnik |
| 40 | `40_seed_relations.sql` | KorisnikTim, KorisnikIgrac |
| 50 | `50_seed_matches_and_stats.sql` | Utakmica, Statistika |
| 60 | `60_validation_and_success_criteria.sql` | Provjera integriteta |
| 70 | `70_views_and_sample_queries.sql` | View-ovi za izvještaje |
| 71 | `71_functions.sql` | TVF funkcije s parametrima |
| 80 | `80_trigger_igrac_audit.sql` | Audit trigger za Igrac |
| 81 | `81_trigger_utakmica_audit.sql` | Audit trigger za Utakmica |
| 82 | `82_trigger_korisnik_audit.sql` | Audit trigger za Korisnik |
| 85 | `85_trigger_statistika_constraint.sql` | Immutable Statistika |
| 86 | `86_trigger_korisnik_tim_constraint.sql` | Soft delete only |
| 87 | `87_trigger_korisnik_igrac_constraint.sql` | Soft delete only |

> **Napomena:** Skripte 00-50 moraju se izvršiti u jednoj sesiji zbog temp tablice `#SeedConfig`.

### 2.2 Konfiguracija volumena

U `00_seed_config.sql` možeš prilagoditi:

```sql
BrojKorisnika = 100        -- Broj korisnika
IgracaPoTimu = 14          -- Igrača po timu
BrojMjeseci = 3            -- Mjeseci sezone
MinUtakmicaUMjesecu = 60   -- Min utakmica mjesečno
MaxUtakmicaUMjesecu = 80   -- Max utakmica mjesečno
BrojPracenihTimova = 4     -- Timova po korisniku
BrojPracenihIgraca = 3     -- Igrača po korisniku
```

---
## 3. Logička organizacija podataka

### 3.1 Entiteti i njihove relacije

#### 3.1.1 ER Dijagram

```
┌─────────────────┐         ┌─────────────────┐         ┌──────────────────┐
│     Dvorana     │         │       Tim       │         │    Korisnik      │
│─────────────────│         │─────────────────│         │──────────────────│
│ DvoranaId (PK)  │         │ TimId (PK)      │         │ KorisnikId (PK)  │
│ Naziv           │         │ Naziv           │         │ Ime              │
│ Lokacija        │         │ Grad            │         │ Email (UNIQUE)   │
│ Kapacitet       │         │                 │         │ IsActive         │
└────────┬────────┘         └───┬───┬───┬─────┘         └─────┬─────────┬──┘
         │                      │   │   │                     │         │
         │ 1                  1 │   │   │ 1                1  │         │ 1
         │                      │   │   │                     │         │
         │ N                  N │   │   │ N                N  │         │ N
         │         ┌────────────┘   │   └──────────┐          │         │
         │         │ TimDomaci      │              │          │         │
         │         ▼ TimGosti       │              ▼          │         │
         │  ┌──────────────────┐    │    ┌───────────────┐    │  ┌──────┴─────────┐
         └─►│    Utakmica      │    │    │ KorisnikTim   │◄───┘  │ KorisnikIgrac  │
            │──────────────────│    │    │───────────────│       │────────────────│
            │ UtakmicaId (PK)  │    │    │ KorisnikId(FK)│       │ KorisnikId(FK) │
            │ Datum            │    │    │ TimId (FK)    │       │ IgracId (FK)   │
            │ VrijemePocetka   │    │    │ IsDeleted     │       │ IsDeleted      │
            │ TimDomaci (FK)   │    │    └───────────────┘       └──────┬─────────┘
            │ TimGosti (FK)    │    │                                   │
            │ DvoranaId (FK)   │    │ 1                               N │
            └────────┬─────────┘    │                                   │
                     │              │                                   │
                   1 │              ▼ N                                 │
                     │          ┌──────────────┐                        │
                   N │          │    Igrac     │   1                    │
                     │          │──────────────│◄───────────────────────┘
                     ▼          │ IgracId (PK) │                  
              ┌──────────────┐  │ Ime          │                  
              │ Statistika   │  │ Prezime      │
              │──────────────│  │ Pozicija     │
              │StatistikaId  │  │ TimId (FK)   │
              │IgracId (FK)  │  └──────────────┘
              │UtakmicaId(FK)│      ▲
              │Poeni, FGM... │      │
              └──────┬───────┘      │
                     │            N │
                   N │              │
                     └──────────────┘

```


#### 3.1.2 Sve relacije (FK veze)

| Tablica | FK kolona | Referencira |
|---------|-----------|-------------|
| Igrac | TimId | Tim.TimId |
| Utakmica | TimDomaci | Tim.TimId |
| Utakmica | TimGosti | Tim.TimId |
| Utakmica | DvoranaId | Dvorana.DvoranaId |
| Statistika | IgracId | Igrac.IgracId |
| Statistika | UtakmicaId | Utakmica.UtakmicaId |
| KorisnikTim | KorisnikId | Korisnik.KorisnikId |
| KorisnikTim | TimId | Tim.TimId |
| KorisnikIgrac | KorisnikId | Korisnik.KorisnikId |
| KorisnikIgrac | IgracId | Igrac.IgracId |

**M:N veze (Many-to-Many)** su implementirane pomoću **međutablice** (eng. junction/join table) koja ima dva FK-a prema povezanim tablicama.

| Veza | Značenje | Međutablica |
|------|----------|------------------|
| **Korisnik ↔ Tim** | Jedan korisnik može pratiti više timova, jedan tim može imati više pratitelja | KorisnikTim |
| **Korisnik ↔ Igrac** | Jedan korisnik može pratiti više igrača, jedan igrač može imati više pratitelja | KorisnikIgrac |



### 3.2 Opis entiteta

**Pregled tablica:**

| Tablica | Opis | Količina |
|---------|------|----------|
| `Tim` | Košarkaški klubovi | 20 |
| `Dvorana` | Sportske dvorane | 12 |
| `Igrac` | Igrači s pozicijama | 280 |
| `Korisnik` | Korisnici aplikacije | 100+ |
| `Utakmica` | Utakmice s domaćinom i gostima | ~70/mj |
| `Statistika` | Detaljne statistike po utakmici | ~2000/mj |
| `KorisnikTim` | M:N - korisnici prate timove | 4 × korisnici |
| `KorisnikIgrac` | M:N - korisnici prate igrače | 3 × korisnici |


#### 3.2.1 Tim
Košarkaški klub koji sudjeluje u ligi.

| Atribut | Opis | Primjer |
|---------|------|---------|
| TimId | Jedinstveni identifikator tima | 1 |
| Naziv | Službeni naziv kluba | "Cibona" |
| Grad | Grad u kojem tim ima sjedište | "Zagreb" |

**Očekivani broj zapisa:** 20 timova iz regije (Hrvatska, BiH, Srbija, Crna Gora)

#### 3.2.2 Dvorana
Sportska dvorana u kojoj se igraju utakmice.

| Atribut | Opis | Primjer |
|---------|------|---------|
| DvoranaId | Jedinstveni identifikator dvorane | 1 |
| Naziv | Službeni naziv dvorane | "Dom Dražena Petrovića" |
| Lokacija | Grad/adresa dvorane | "Zagreb" |
| Kapacitet | Broj sjedećih mjesta | 5400 |

**Očekivani broj zapisa:** 12 dvorana

#### 3.2.3 Igrac
Profesionalni košarkaš koji igra za jedan tim.

| Atribut | Opis | Primjer |
|---------|------|---------|
| IgracId | Jedinstveni identifikator igrača | 1 |
| Ime | Ime igrača | "Luka" |
| Prezime | Prezime igrača | "Babić" |
| Pozicija | Pozicija na terenu | "Playmaker", "Centar" |
| TimId | FK prema timu kojem pripada | 1 |

**Pozicije:** Playmaker, Bek, Krilo, Krilni centar, Centar  
**Očekivani broj zapisa:** 14 igrača × 20 timova = 280

#### 3.2.4 Korisnik
Registrirani korisnik aplikacije (navijač/fan).

| Atribut | Opis | Primjer |
|---------|------|---------|
| KorisnikId | Jedinstveni identifikator korisnika | 1 |
| Ime | Ime korisnika | "Ivan Horvat" |
| Email | Email adresa (jedinstvena) | "ivan@email.hr" |
| IsActive | Je li račun aktivan | true |

**Očekivani broj zapisa:** 100 - 100,000

#### 3.2.5 Utakmica
Košarkaška utakmica između dva tima.

| Atribut | Opis | Primjer |
|---------|------|---------|
| UtakmicaId | Jedinstveni identifikator utakmice | 1 |
| Datum | Datum odigravanja | 2026-05-15 |
| VrijemePocetka | Vrijeme početka | 19:00 |
| TimDomaci | FK - domaći tim | 1 (Cibona) |
| TimGosti | FK - gostujući tim | 2 (Zadar) |
| DvoranaId | FK - dvorana | 1 |

**Poslovno pravilo:** Tim ne može igrati sam protiv sebe (`TimDomaci <> TimGosti`)  
**Očekivani broj zapisa:** 60-80 utakmica mjesečno

#### 3.2.6 Statistika
Individualna statistika igrača na pojedinačnoj utakmici.

| Atribut | Opis | Raspon |
|---------|------|--------|
| StatistikaId | Jedinstveni identifikator | BIGINT |
| IgracId | FK - igrač | INT |
| UtakmicaId | FK - utakmica | INT |
| Minuta | Odigrane minute | 1-60 |
| Poeni | Ukupno postignutih poena | 0-255 |
| Asistencije | Broj asistencija | 0-255 |
| SkokoviOf | Ofenzivni skokovi | 0-255 |
| SkokoviDef | Defenzivni skokovi | 0-255 |
| UkradeneLopte | Broj ukradenih lopti | 0-255 |
| Blokade | Broj blokada | 0-255 |
| IzgubljeneLopte | Broj izgubljenih lopti | 0-255 |
| OsobnePogreske | Broj faulova | 0-255 |
| FGM | Field Goals Made (pogođeni šutevi) | 0-255 |
| FGA | Field Goals Attempted (pokušaji) | 0-255 |
| FG3M | 3-Point Made (pogođene trice) | 0-255 |
| FG3A | 3-Point Attempted (pokušaji trica) | 0-255 |
| FTM | Free Throws Made (pogođena slobodna) | 0-255 |
| FTA | Free Throws Attempted (pokušaji slobodnih) | 0-255 |

**Poslovna pravila:**
- Igrač može imati samo jednu statistiku po utakmici (UNIQUE IgracId + UtakmicaId)
- Pogođeni šutevi ne mogu biti veći od pokušaja: `FGM <= FGA`, `FG3M <= FG3A`, `FTM <= FTA`
- Pokušaji trica ne mogu biti veći od ukupnih pokušaja: `FG3A <= FGA`
- **Statistika je immutable** - jednom upisani podaci se NE MOGU mijenjati niti brisati

**Formula za izračun poena:** `Poeni = (FGM - FG3M) * 2 + FG3M * 3 + FTM`

#### 3.2.7 KorisnikTim (međutablica - M:N)
Međutablica koja povezuje korisnike s timovima koje prate.

| Atribut | Opis |
|---------|------|
| KorisnikId | PK, FK - korisnik |
| TimId | PK, FK - tim |
| IsDeleted | Soft delete flag |

**Očekivano:** Svaki korisnik prati 4 tima

#### 3.2.8 KorisnikIgrac (međutablica - M:N)
Međutablica koja povezuje korisnike s igračima koje prate.

| Atribut | Opis |
|---------|------|
| KorisnikId | PK, FK - korisnik |
| IgracId | PK, FK - igrač |
| IsDeleted | Soft delete flag |

**Očekivano:** Svaki korisnik prati 3 igrača

### 3.3 Poslovna pravila i ograničenja

#### 3.3.1 Integritetna pravila

| Pravilo | Implementacija | Tablica |
|---------|----------------|---------|
| Tim ne može igrati sam protiv sebe | CHECK constraint | Utakmica |
| Jedan igrač - jedna statistika po utakmici | UNIQUE constraint | Statistika |
| Email korisnika mora biti jedinstven | UNIQUE constraint | Korisnik |
| Kapacitet dvorane mora biti pozitivan | CHECK constraint | Dvorana |
| Pogođeni šutevi ≤ pokušaji | CHECK constraint | Statistika |
| Minute između 1 i 60 | CHECK constraint | Statistika |

#### 3.3.2 Pravila ponašanja
| Pravilo | Opis | Implementacija | Tablica |
|---------|------|----------------| ---------|
| **Soft Delete** | Entiteti se ne brišu fizički | IsDeleted + DeletedAt kolone | Sve osim Statistika |
| **Soft Delete Only (relacije)** | DELETE → UPDATE IsDeleted=1 | INSTEAD OF DELETE trigger | Sve osim Statistika |
| **Immutable Statistika** | Statistika se ne može mijenjati | INSTEAD OF triggeri | Statistika |
| **Audit Trail** | Sve promjene se logiraju | AFTER triggeri → log tablice | Igrac, Utakmica, Korisnik |


#### 3.3.3 Soft Delete obrazac
Sve glavne tablice imaju standardne kolone za soft delete:

```sql
IsDeleted    BIT          NOT NULL DEFAULT 0    -- 0=aktivan, 1=obrisan
DeletedAt    DATETIME2(0) NULL                  -- Vrijeme brisanja
CreatedAt    DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
UpdatedAt    DATETIME2(0) NULL                  -- Vrijeme zadnje izmjene
ResponsibleId INT         NULL                  -- Tko je napravio akciju
```






### 3.4 Hijerarhija entiteta (slojevi)

```
┌─────────────────────────────────────────────────────────────────┐
│ SLOJ A: Statički podaci (rijetko se mijenjaju)                  │
│ ┌─────────────┐  ┌─────────────┐                                │
│ │    Tim      │  │   Dvorana   │                                │
│ │  (20 kom)   │  │  (12 kom)   │                                │
│ └─────────────┘  └─────────────┘                                │
├─────────────────────────────────────────────────────────────────┤
│ SLOJ B: Core entiteti (srednja učestalost promjena)             │
│ ┌─────────────┐  ┌─────────────┐                                │
│ │   Igrac     │  │  Korisnik   │                                │
│ │ (280 kom)   │  │ (100-100k)  │                                │
│ └─────────────┘  └─────────────┘                                │
├─────────────────────────────────────────────────────────────────┤
│ SLOJ C: Transakcijski podaci (visoka učestalost)                │
│ ┌─────────────┐  ┌─────────────┐                                │
│ │  Utakmica   │  │ Statistika  │  ← IMMUTABLE                   │
│ │ (~70/mj)    │  │(~2000/mj)   │                                │
│ └─────────────┘  └─────────────┘                                │
├─────────────────────────────────────────────────────────────────┤
│ SLOJ D: Međutablice (M:N veze)                                  │
│ ┌─────────────┐  ┌─────────────┐                                │
│ │ KorisnikTim │  │KorisnikIgrac│  ← SOFT DELETE ONLY            │
│ │(4 × Korisn.)│  │(3 × Korisn.)│                                │
│ └─────────────┘  └─────────────┘                                │
└─────────────────────────────────────────────────────────────────┘
```


---

## 4. Fizička organizacija podataka

### 4.1 Tablice - Detaljna struktura

#### 4.1.1 dbo.Tim
```sql
CREATE TABLE dbo.Tim (
    TimId         INT           IDENTITY(1,1) PRIMARY KEY,
    Naziv         NVARCHAR(100) NOT NULL,
    Grad          NVARCHAR(100) NOT NULL,
    ResponsibleId INT           NULL,
    IsDeleted     BIT           NOT NULL DEFAULT (0),
    DeletedAt     DATETIME2(0)  NULL,
    CreatedAt     DATETIME2(0)  NOT NULL DEFAULT (SYSUTCDATETIME()),
    UpdatedAt     DATETIME2(0)  NULL
);
```

| Kolona | Tip podatka | Ograničenje | NULL | Default | Opis |
|--------|-------------|-------------|------|---------|------|
| TimId | INT IDENTITY(1,1) | PRIMARY KEY | NO | Auto | Primarni ključ, auto-increment |
| Naziv | NVARCHAR(100) | NOT NULL | NO | - | Naziv tima, podržava Unicode |
| Grad | NVARCHAR(100) | NOT NULL | NO | - | Grad sjedišta |
| ResponsibleId | INT | - | YES | NULL | ID korisnika koji je kreirao/uredio |
| IsDeleted | BIT | NOT NULL | NO | 0 | Soft delete marker |
| DeletedAt | DATETIME2(0) | - | YES | NULL | Timestamp brisanja |
| CreatedAt | DATETIME2(0) | NOT NULL | NO | SYSUTCDATETIME() | Timestamp kreiranja (UTC) |
| UpdatedAt | DATETIME2(0) | - | YES | NULL | Timestamp zadnje izmjene |

#### 4.1.2 dbo.Dvorana
```sql
CREATE TABLE dbo.Dvorana (
    DvoranaId     INT           IDENTITY(1,1) PRIMARY KEY,
    Naziv         NVARCHAR(100) NOT NULL,
    Lokacija      NVARCHAR(100) NOT NULL,
    Kapacitet     INT           NOT NULL CHECK (Kapacitet > 0),
    ResponsibleId INT           NULL,
    IsDeleted     BIT           NOT NULL DEFAULT (0),
    DeletedAt     DATETIME2(0)  NULL,
    CreatedAt     DATETIME2(0)  NOT NULL DEFAULT (SYSUTCDATETIME()),
    UpdatedAt     DATETIME2(0)  NULL
);
```

| Kolona | Tip podatka | Ograničenje | NULL | Default | Opis |
|--------|-------------|-------------|------|---------|------|
| DvoranaId | INT IDENTITY(1,1) | PRIMARY KEY | NO | Auto | Primarni ključ |
| Naziv | NVARCHAR(100) | NOT NULL | NO | - | Naziv dvorane |
| Lokacija | NVARCHAR(100) | NOT NULL | NO | - | Grad/adresa |
| Kapacitet | INT | CHECK > 0 | NO | - | Broj sjedećih mjesta |
| ResponsibleId | INT | - | YES | NULL | ID odgovornog korisnika |
| IsDeleted | BIT | NOT NULL | NO | 0 | Soft delete marker |
| DeletedAt | DATETIME2(0) | - | YES | NULL | Timestamp brisanja |
| CreatedAt | DATETIME2(0) | NOT NULL | NO | SYSUTCDATETIME() | Timestamp kreiranja |
| UpdatedAt | DATETIME2(0) | - | YES | NULL | Timestamp izmjene |

#### 4.1.3 dbo.Korisnik
```sql
CREATE TABLE dbo.Korisnik (
    KorisnikId    INT           IDENTITY(1,1) PRIMARY KEY,
    Ime           NVARCHAR(100) NOT NULL,
    Email         NVARCHAR(255) NOT NULL,
    IsActive      BIT           NOT NULL DEFAULT (1),
    ResponsibleId INT           NULL,
    IsDeleted     BIT           NOT NULL DEFAULT (0),
    DeletedAt     DATETIME2(0)  NULL,
    CreatedAt     DATETIME2(0)  NOT NULL DEFAULT (SYSUTCDATETIME()),
    UpdatedAt     DATETIME2(0)  NULL,
    CONSTRAINT UQ_Korisnik_Email UNIQUE (Email)
);
```

| Kolona | Tip podatka | Ograničenje | NULL | Default | Opis |
|--------|-------------|-------------|------|---------|------|
| KorisnikId | INT IDENTITY(1,1) | PRIMARY KEY | NO | Auto | Primarni ključ |
| Ime | NVARCHAR(100) | NOT NULL | NO | - | Puno ime korisnika |
| Email | NVARCHAR(255) | UNIQUE, NOT NULL | NO | - | Email adresa (jedinstvena) |
| IsActive | BIT | NOT NULL | NO | 1 | Je li račun aktivan |
| ResponsibleId | INT | - | YES | NULL | ID odgovornog korisnika |
| IsDeleted | BIT | NOT NULL | NO | 0 | Soft delete marker |
| DeletedAt | DATETIME2(0) | - | YES | NULL | Timestamp brisanja |
| CreatedAt | DATETIME2(0) | NOT NULL | NO | SYSUTCDATETIME() | Timestamp kreiranja |
| UpdatedAt | DATETIME2(0) | - | YES | NULL | Timestamp izmjene |

#### 4.1.4 dbo.Igrac
```sql
CREATE TABLE dbo.Igrac (
    IgracId       INT           IDENTITY(1,1) PRIMARY KEY,
    Ime           NVARCHAR(100) NOT NULL,
    Prezime       NVARCHAR(100) NOT NULL,
    Pozicija      NVARCHAR(50)  NOT NULL,
    TimId         INT           NOT NULL,
    ResponsibleId INT           NULL,
    IsDeleted     BIT           NOT NULL DEFAULT (0),
    DeletedAt     DATETIME2(0)  NULL,
    CreatedAt     DATETIME2(0)  NOT NULL DEFAULT (SYSUTCDATETIME()),
    UpdatedAt     DATETIME2(0)  NULL,
    CONSTRAINT FK_Igrac_Tim FOREIGN KEY (TimId) REFERENCES dbo.Tim(TimId)
);
```

| Kolona | Tip podatka | Ograničenje | NULL | Default | Opis |
|--------|-------------|-------------|------|---------|------|
| IgracId | INT IDENTITY(1,1) | PRIMARY KEY | NO | Auto | Primarni ključ |
| Ime | NVARCHAR(100) | NOT NULL | NO | - | Ime igrača |
| Prezime | NVARCHAR(100) | NOT NULL | NO | - | Prezime igrača |
| Pozicija | NVARCHAR(50) | NOT NULL | NO | - | Pozicija na terenu |
| TimId | INT | FK → Tim | NO | - | ID tima |
| ResponsibleId | INT | - | YES | NULL | ID odgovornog korisnika |
| IsDeleted | BIT | NOT NULL | NO | 0 | Soft delete marker |
| DeletedAt | DATETIME2(0) | - | YES | NULL | Timestamp brisanja |
| CreatedAt | DATETIME2(0) | NOT NULL | NO | SYSUTCDATETIME() | Timestamp kreiranja |
| UpdatedAt | DATETIME2(0) | - | YES | NULL | Timestamp izmjene |

**Foreign Key:** `FK_Igrac_Tim → dbo.Tim(TimId)`

#### 4.1.5 dbo.Utakmica
```sql
CREATE TABLE dbo.Utakmica (
    UtakmicaId    INT          IDENTITY(1,1) PRIMARY KEY,
    Datum         DATE         NOT NULL,
    VrijemePocetka TIME(0)     NOT NULL,
    TimDomaci     INT          NOT NULL,
    TimGosti      INT          NOT NULL,
    DvoranaId     INT          NOT NULL,
    ResponsibleId INT          NULL,
    IsDeleted     BIT          NOT NULL DEFAULT (0),
    DeletedAt     DATETIME2(0) NULL,
    CreatedAt     DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    UpdatedAt     DATETIME2(0) NULL,
    CONSTRAINT FK_Utakmica_TimDomaci FOREIGN KEY (TimDomaci) REFERENCES dbo.Tim(TimId),
    CONSTRAINT FK_Utakmica_TimGosti  FOREIGN KEY (TimGosti)  REFERENCES dbo.Tim(TimId),
    CONSTRAINT FK_Utakmica_Dvorana   FOREIGN KEY (DvoranaId) REFERENCES dbo.Dvorana(DvoranaId),
    CONSTRAINT CK_Utakmica_RazlicitiTimovi CHECK (TimDomaci <> TimGosti)
);
```

| Kolona | Tip podatka | Ograničenje | NULL | Default | Opis |
|--------|-------------|-------------|------|---------|------|
| UtakmicaId | INT IDENTITY(1,1) | PRIMARY KEY | NO | Auto | Primarni ključ |
| Datum | DATE | NOT NULL | NO | - | Datum utakmice |
| VrijemePocetka | TIME(0) | NOT NULL | NO | - | Vrijeme početka (bez ms) |
| TimDomaci | INT | FK → Tim | NO | - | ID domaćeg tima |
| TimGosti | INT | FK → Tim | NO | - | ID gostujućeg tima |
| DvoranaId | INT | FK → Dvorana | NO | - | ID dvorane |
| ResponsibleId | INT | - | YES | NULL | ID odgovornog korisnika |
| IsDeleted | BIT | NOT NULL | NO | 0 | Soft delete marker |
| DeletedAt | DATETIME2(0) | - | YES | NULL | Timestamp brisanja |
| CreatedAt | DATETIME2(0) | NOT NULL | NO | SYSUTCDATETIME() | Timestamp kreiranja |
| UpdatedAt | DATETIME2(0) | - | YES | NULL | Timestamp izmjene |

**Foreign Keys:**
- `FK_Utakmica_TimDomaci → dbo.Tim(TimId)`
- `FK_Utakmica_TimGosti → dbo.Tim(TimId)`
- `FK_Utakmica_Dvorana → dbo.Dvorana(DvoranaId)`

**Check Constraint:** `CK_Utakmica_RazlicitiTimovi: TimDomaci <> TimGosti`

#### 4.1.6 dbo.Statistika
```sql
CREATE TABLE dbo.Statistika (
    StatistikaId    BIGINT       IDENTITY(1,1) PRIMARY KEY,
    IgracId         INT          NOT NULL,
    UtakmicaId      INT          NOT NULL,
    Minuta          TINYINT      NOT NULL,
    Poeni           TINYINT      NOT NULL,
    Asistencije     TINYINT      NOT NULL,
    SkokoviOf       TINYINT      NOT NULL,
    SkokoviDef      TINYINT      NOT NULL,
    UkradeneLopte   TINYINT      NOT NULL,
    Blokade         TINYINT      NOT NULL,
    IzgubljeneLopte TINYINT      NOT NULL,
    OsobnePogreske  TINYINT      NOT NULL,
    FGM             TINYINT      NOT NULL,
    FGA             TINYINT      NOT NULL,
    FG3M            TINYINT      NOT NULL,
    FG3A            TINYINT      NOT NULL,
    FTM             TINYINT      NOT NULL,
    FTA             TINYINT      NOT NULL,
    ResponsibleId   INT          NULL,
    CreatedAt       DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Statistika_Igrac    FOREIGN KEY (IgracId)    REFERENCES dbo.Igrac(IgracId),
    CONSTRAINT FK_Statistika_Utakmica FOREIGN KEY (UtakmicaId) REFERENCES dbo.Utakmica(UtakmicaId),
    CONSTRAINT UQ_Statistika_IgracUtakmica UNIQUE (IgracId, UtakmicaId),
    CONSTRAINT CK_Stat_Nenegativno CHECK (
        Minuta BETWEEN 1 AND 60 AND Poeni >= 0 AND Asistencije >= 0 AND 
        SkokoviOf >= 0 AND SkokoviDef >= 0 AND UkradeneLopte >= 0 AND 
        Blokade >= 0 AND IzgubljeneLopte >= 0 AND OsobnePogreske >= 0 AND
        FGM >= 0 AND FGA >= 0 AND FG3M >= 0 AND FG3A >= 0 AND FTM >= 0 AND FTA >= 0
    ),
    CONSTRAINT CK_Stat_LogikaSuta CHECK (
        FGM <= FGA AND FG3M <= FG3A AND FTM <= FTA AND FG3A <= FGA
    )
);
```

| Kolona | Tip | Opis | Validacija |
|--------|-----|------|------------|
| StatistikaId | BIGINT IDENTITY | PK | Auto |
| IgracId | INT | FK → Igrac | NOT NULL |
| UtakmicaId | INT | FK → Utakmica | NOT NULL |
| Minuta | TINYINT | Odigrane minute | 1-60 |
| Poeni | TINYINT | Ukupno poena | >= 0 |
| Asistencije | TINYINT | Broj dodavanja za koš | >= 0 |
| SkokoviOf | TINYINT | Ofenzivni skokovi | >= 0 |
| SkokoviDef | TINYINT | Defenzivni skokovi | >= 0 |
| UkradeneLopte | TINYINT | Ukradene lopte (steals) | >= 0 |
| Blokade | TINYINT | Blokirani šutevi | >= 0 |
| IzgubljeneLopte | TINYINT | Turnovers | >= 0 |
| OsobnePogreske | TINYINT | Faulovi | >= 0 |
| FGM | TINYINT | Field Goals Made | <= FGA |
| FGA | TINYINT | Field Goals Attempted | >= FG3A |
| FG3M | TINYINT | 3-Point Made | <= FG3A |
| FG3A | TINYINT | 3-Point Attempted | >= 0 |
| FTM | TINYINT | Free Throws Made | <= FTA |
| FTA | TINYINT | Free Throws Attempted | >= 0 |

**NAPOMENA:** Statistika NEMA kolone IsDeleted, DeletedAt, UpdatedAt jer je **immutable** (INSERT only).

#### 4.1.7 dbo.KorisnikTim (M:N)
```sql
CREATE TABLE dbo.KorisnikTim (
    KorisnikId INT          NOT NULL,
    TimId      INT          NOT NULL,
    IsDeleted  BIT          NOT NULL DEFAULT (0),
    DeletedAt  DATETIME2(0) NULL,
    CreatedAt  DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_KorisnikTim PRIMARY KEY (KorisnikId, TimId),
    CONSTRAINT FK_KorisnikTim_Korisnik FOREIGN KEY (KorisnikId) REFERENCES dbo.Korisnik(KorisnikId),
    CONSTRAINT FK_KorisnikTim_Tim      FOREIGN KEY (TimId)      REFERENCES dbo.Tim(TimId)
);
```

**Kompozitni primarni ključ:** `(KorisnikId, TimId)`

#### 4.1.8 dbo.KorisnikIgrac (M:N)
```sql
CREATE TABLE dbo.KorisnikIgrac (
    KorisnikId INT          NOT NULL,
    IgracId    INT          NOT NULL,
    IsDeleted  BIT          NOT NULL DEFAULT (0),
    DeletedAt  DATETIME2(0) NULL,
    CreatedAt  DATETIME2(0) NOT NULL DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_KorisnikIgrac PRIMARY KEY (KorisnikId, IgracId),
    CONSTRAINT FK_KorisnikIgrac_Korisnik FOREIGN KEY (KorisnikId) REFERENCES dbo.Korisnik(KorisnikId),
    CONSTRAINT FK_KorisnikIgrac_Igrac    FOREIGN KEY (IgracId)    REFERENCES dbo.Igrac(IgracId)
);
```

**Kompozitni primarni ključ:** `(KorisnikId, IgracId)`

---

### 4.2 Audit Log Tablice

Sve promjene na kritičnim tablicama (Igrac, Utakmica, Korisnik) se automatski logiraju u pripadajuće log tablice pomoću AFTER triggera.

#### 4.2.1 Struktura log tablice (primjer: log_Igrac)
```sql
CREATE TABLE dbo.log_Igrac (
    log_IdRow          INT           IDENTITY(1,1) PRIMARY KEY,
    log_DateTS         DATETIME2(0)  NOT NULL DEFAULT (SYSUTCDATETIME()),
    log_IdResponsible  INT           NULL,
    log_Action         CHAR(2)       NOT NULL,  -- 'IN', 'UP', 'DE'
    log_ColumnsUpdated VARCHAR(1500) NULL,
    -- Snapshot svih kolona iz izvorne tablice
    IgracId            INT           NOT NULL,
    Ime                NVARCHAR(100) NULL,
    Prezime            NVARCHAR(100) NULL,
    Pozicija           NVARCHAR(50)  NULL,
    TimId              INT           NULL,
    ResponsibleId      INT           NULL,
    IsDeleted          BIT           NULL,
    DeletedAt          DATETIME2(0)  NULL
);
```

| Kolona | Opis |
|--------|------|
| log_IdRow | Auto-increment ID log zapisa |
| log_DateTS | Timestamp kada je akcija izvršena (UTC) |
| log_IdResponsible | Tko je izvršio akciju (proslijeđuje se kroz temp tablicu) |
| log_Action | Tip akcije: 'IN' (Insert), 'UP' (Update), 'DE' (Delete) |
| log_ColumnsUpdated | Lista kolona koje su promijenjene (samo za UPDATE) |
| *ostale kolone* | Snapshot vrijednosti u trenutku akcije |

#### 4.2.2 Akcije koje se logiraju

| log_Action | Opis | Što se sprema |
|------------|------|---------------|
| `IN` | INSERT | Novi red (iz INSERTED) |
| `UP` | UPDATE - staro | Stare vrijednosti (iz DELETED) |
| `UI` | UPDATE - novo | Nove vrijednosti (iz INSERTED) |
| `DE` | DELETE | Obrisani red (iz DELETED) |

#### 4.2.3 Kako proslijediti ResponsibleId triggeru

Prije izvršavanja UPDATE ili DELETE naredbe, kreirajte temp tablicu:
```sql
-- Prije DELETE na dbo.Igrac:
SELECT [log_IdResponsible] = @KorisnikId INTO #Igrac_TR_LogChanges;

DELETE FROM dbo.Igrac WHERE IgracId = 5;
-- Trigger će pročitati @KorisnikId iz temp tablice
```

---

### 4.3 Indeksi

#### 4.3.1 Tim
| Naziv indeksa | Kolone | Tip | Svrha |
|---------------|--------|-----|-------|
| `PK_Tim` | TimId | Clustered | Primarni ključ |
| `IX_Tim_Naziv_Grad` | Naziv, Grad | Nonclustered | Pretraživanje po nazivu i gradu |
| `IX_Tim_Active` | Naziv INCLUDE (Grad) | Filtered WHERE IsDeleted=0 | Brzi dohvat aktivnih timova |

#### 4.3.2 Dvorana
| Naziv indeksa | Kolone | Tip | Svrha |
|---------------|--------|-----|-------|
| `PK_Dvorana` | DvoranaId | Clustered | Primarni ključ |
| `IX_Dvorana_Active` | Lokacija INCLUDE (Naziv, Kapacitet) | Filtered WHERE IsDeleted=0 | Dohvat dvorana po lokaciji |

#### 4.3.3 Korisnik
| Naziv indeksa | Kolone | Tip | Svrha |
|---------------|--------|-----|-------|
| `PK_Korisnik` | KorisnikId | Clustered | Primarni ključ |
| `UQ_Korisnik_Email` | Email | Unique | Jedinstvenost emaila |
| `IX_Korisnik_CreatedAt` | CreatedAt | Nonclustered | Sortiranje po datumu registracije |
| `IX_Korisnik_IsActive` | IsActive INCLUDE (Ime, Email) | Filtered WHERE IsDeleted=0 | Dohvat aktivnih korisnika |
| `IX_Korisnik_Ime` | Ime INCLUDE (Email, IsActive) | Filtered WHERE IsDeleted=0 | Pretraživanje po imenu |

#### 4.3.4 Igrac
| Naziv indeksa | Kolone | Tip | Svrha |
|---------------|--------|-----|-------|
| `PK_Igrac` | IgracId | Clustered | Primarni ključ |
| `IX_Igrac_TimId` | TimId | Nonclustered | FK lookup |
| `IX_Igrac_TimId_Prezime_Ime` | TimId, Prezime, Ime | Nonclustered | Popis igrača tima sortirano |
| `IX_Igrac_Prezime_Ime` | Prezime, Ime | Filtered WHERE IsDeleted=0 | Pretraživanje igrača |
| `IX_Igrac_Pozicija` | Pozicija INCLUDE (Ime, Prezime, TimId) | Filtered WHERE IsDeleted=0 | Filtriranje po poziciji |

#### 4.3.5 Utakmica
| Naziv indeksa | Kolone | Tip | Svrha |
|---------------|--------|-----|-------|
| `PK_Utakmica` | UtakmicaId | Clustered | Primarni ključ |
| `IX_Utakmica_Datum` | Datum | Nonclustered | Filtriranje po datumu |
| `IX_Utakmica_TimDomaci_Datum` | TimDomaci, Datum | Nonclustered | Raspored tima (domaće) |
| `IX_Utakmica_TimGosti_Datum` | TimGosti, Datum | Nonclustered | Raspored tima (gostujuće) |
| `IX_Utakmica_DvoranaId_Datum` | DvoranaId, Datum | Nonclustered | Raspored dvorane |
| `IX_Utakmica_Datum_Active` | Datum, VrijemePocetka INCLUDE (...) | Filtered WHERE IsDeleted=0 | Nadolazeće utakmice |

#### 4.3.6 Statistika
| Naziv indeksa | Kolone | Tip | Svrha |
|---------------|--------|-----|-------|
| `PK_Statistika` | StatistikaId | Clustered | Primarni ključ |
| `UQ_Statistika_IgracUtakmica` | IgracId, UtakmicaId | Unique | 1 statistika po igraču po utakmici |
| `IX_Statistika_UtakmicaId` | UtakmicaId | Nonclustered | FK lookup |
| `IX_Statistika_IgracId` | IgracId | Nonclustered | FK lookup |
| `IX_Statistika_UtakmicaId_Poeni` | UtakmicaId, Poeni DESC | Nonclustered | Top scoreri na utakmici |
| `IX_Statistika_Poeni_DESC` | Poeni DESC INCLUDE (...) | Covering | Top scoreri (svi) |
| `IX_Statistika_IgracId_Cover` | IgracId INCLUDE (Poeni, Asist...) | Covering | Karijerna statistika |
| `IX_Statistika_UtakmicaId_Cover` | UtakmicaId INCLUDE (...) | Covering | Box score utakmice |

#### 4.3.7 KorisnikTim / KorisnikIgrac
| Naziv indeksa | Kolone | Tip | Svrha |
|---------------|--------|-----|-------|
| `PK_KorisnikTim` | KorisnikId, TimId | Clustered | Kompozitni PK |
| `IX_KorisnikTim_TimId` | TimId | Nonclustered | Tko prati tim X |
| `IX_KorisnikTim_Active` | KorisnikId WHERE IsDeleted=0 | Filtered | Aktivne pretplate korisnika |
| `PK_KorisnikIgrac` | KorisnikId, IgracId | Clustered | Kompozitni PK |
| `IX_KorisnikIgrac_IgracId` | IgracId | Nonclustered | Tko prati igrača X |
| `IX_KorisnikIgrac_Active` | KorisnikId WHERE IsDeleted=0 | Filtered | Aktivne pretplate korisnika |

---

### 4.4 Triggeri

#### 4.4.1 Audit Triggeri (AFTER INSERT, UPDATE, DELETE)

| Trigger | Tablica | Svrha |
|---------|---------|-------|
| `Igrac_TR_LogChanges` | dbo.Igrac | Logira INSERT/UPDATE/DELETE u log_Igrac |
| `Utakmica_TR_LogChanges` | dbo.Utakmica | Logira INSERT/UPDATE/DELETE u log_Utakmica |
| `Korisnik_TR_LogChanges` | dbo.Korisnik | Logira INSERT/UPDATE/DELETE u log_Korisnik |

**Ponašanje:**
- Na INSERT: Zapisuje novi red s log_Action = 'IN'
- Na UPDATE: Zapisuje stari red ('UD') i novi red ('UI')
- Na DELETE: Zapisuje obrisani red s log_Action = 'DE'

**Proslijedi ResponsibleId:**
```sql
-- Prije UPDATE/DELETE kreiraj temp tablicu
SELECT [log_IdResponsible] = @KorisnikId INTO #Igrac_TR_LogChanges;
UPDATE dbo.Igrac SET Pozicija = N'Centar' WHERE IgracId = 5;
```

#### 4.4.2 Constraint Triggeri (INSTEAD OF)

| Trigger | Tablica | Svrha |
|---------|---------|-------|
| `Statistika_TR_PreventUpdate` | dbo.Statistika | Zabranjuje UPDATE - vraća grešku |
| `Statistika_TR_PreventDelete` | dbo.Statistika | Zabranjuje DELETE - vraća grešku |
| `KorisnikTim_TR_SoftDeleteOnly` | dbo.KorisnikTim | Konvertira DELETE u soft delete |
| `KorisnikIgrac_TR_SoftDeleteOnly` | dbo.KorisnikIgrac | Konvertira DELETE u soft delete |

**Primjer soft delete triggera:**
```sql
CREATE TRIGGER dbo.KorisnikTim_TR_SoftDeleteOnly
ON dbo.KorisnikTim
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE kt SET 
        kt.IsDeleted = 1,
        kt.DeletedAt = SYSUTCDATETIME()
    FROM dbo.KorisnikTim kt
    INNER JOIN deleted d ON kt.KorisnikId = d.KorisnikId AND kt.TimId = d.TimId;
END;
```

---

### 4.5 View-ovi

#### 4.5.1 vwIgracSveUtakmice
Sva statistika svih igrača sa detaljima o utakmicama.

```sql
SELECT 
    s.StatistikaId, s.UtakmicaId, u.Datum, u.VrijemePocetka,
    s.IgracId, i.TimId, t.Naziv AS TimNaziv,
    i.Ime, i.Prezime, i.Ime + N' ' + i.Prezime AS PunoIme,
    i.Pozicija, u.TimDomaci, td.Naziv AS TimDomaciNaziv,
    u.TimGosti, tg.Naziv AS TimGostiNaziv,
    CASE WHEN i.TimId = u.TimDomaci THEN N'Domaci' ELSE N'Gosti' END AS TipUtakmice,
    s.Minuta, s.Poeni, s.Asistencije, s.SkokoviOf, s.SkokoviDef,
    (s.SkokoviOf + s.SkokoviDef) AS SkokoviUkupno,
    s.UkradeneLopte, s.Blokade, s.IzgubljeneLopte, s.OsobnePogreske,
    s.FGM, s.FGA, FGPct, s.FG3M, s.FG3A, FG3Pct, s.FTM, s.FTA, FTPct
FROM dbo.Statistika s
JOIN dbo.Igrac i ON i.IgracId = s.IgracId ...
```

**Korištenje:** Izvještaji, analize, dashboard

#### 4.5.2 vwNadolazeceUtakmice
Sve buduće utakmice s detaljima o timovima i dvorani.

```sql
SELECT 
    u.UtakmicaId, u.Datum, u.VrijemePocetka,
    u.TimDomaci AS TimDomaciId, td.Naziv AS Domaci, td.Grad AS DomaciGrad,
    u.TimGosti AS TimGostiId, tg.Naziv AS Gosti, tg.Grad AS GostiGrad,
    u.DvoranaId, d.Naziv AS Dvorana, d.Lokacija, d.Kapacitet
FROM dbo.Utakmica u
WHERE u.Datum >= CAST(GETDATE() AS DATE) AND u.IsDeleted = 0 ...
```

**Korištenje:** API - GET /basketball/matches/upcoming, mobilna aplikacija

#### 4.5.3 vwTop10Strijelaca
Top 10 igrača po ukupnim poenima s agregiranim statistikama.

```sql
SELECT TOP 10
    i.IgracId, i.Ime, i.Prezime, i.Pozicija, t.Naziv AS Tim,
    COUNT(*) AS BrojUtakmica, SUM(s.Poeni) AS UkupnoPoena,
    AVG(s.Poeni) AS PPG, MAX(s.Poeni) AS MaxPoena,
    SUM(s.Asistencije) AS UkupnoAsistencija, AVG(s.Asistencije) AS APG,
    SUM(s.SkokoviOf + s.SkokoviDef) AS UkupnoSkokova, AVG(...) AS RPG,
    FGPct, FG3Pct, FTPct
FROM dbo.Statistika s JOIN dbo.Igrac i ...
GROUP BY ... ORDER BY UkupnoPoena DESC
```

**Korištenje:** API - GET /basketball/statistics/top-scorers, leaderboard

#### 4.5.4 vwProsjekStatistikeTima
Prosječne statistike po timu.

**Korištenje:** Usporedba timova, analiza performansi

---

### 4.6 Table-Valued Funkcije (TVF)

#### 4.6.1 fnIgraciPoPoziciji(@Pozicija)
Vraća sve igrače određene pozicije.

```sql
SELECT * FROM dbo.fnIgraciPoPoziciji(N'Centar');
```

| Kolona | Tip |
|--------|-----|
| IgracId | INT |
| Ime | NVARCHAR(100) |
| Prezime | NVARCHAR(100) |
| PunoIme | NVARCHAR(201) |
| Pozicija | NVARCHAR(50) |
| TimId | INT |
| Tim | NVARCHAR(100) |
| TimGrad | NVARCHAR(100) |

#### 4.6.2 fnStatistikaIgraca(@IgracId)
Vraća karijernu statistiku igrača (agregirano).

```sql
SELECT * FROM dbo.fnStatistikaIgraca(1);
```

| Kolona | Opis |
|--------|------|
| IgracId, Ime, Prezime, Pozicija | Osnovni podaci |
| BrojUtakmica | Ukupno odigranih utakmica |
| UkupnoMinuta, MPG | Minute (ukupno, prosjek) |
| UkupnoPoena, PPG, MaxPoena | Poeni |
| UkupnoAsistencija, APG | Asistencije |
| UkupnoSkokova, RPG | Skokovi |
| UkupnoUkradenihLopti, SPG | Ukradene lopte |
| UkupnoBlokada, BPG | Blokade |
| FGPct, FG3Pct, FTPct | Postoci šuta |

**Korištenje:** API - GET /basketball/players/{id}/stats

#### 4.6.3 fnRasporedTima(@TimId)
Vraća sve utakmice tima (prošle i buduće).

```sql
SELECT * FROM dbo.fnRasporedTima(1) WHERE Datum >= GETDATE();
```

| Kolona | Opis |
|--------|------|
| UtakmicaId | ID utakmice |
| Datum, VrijemePocetka | Kada |
| Uloga | 'Domaci' ili 'Gosti' |
| ProtivnikId, Protivnik, ProtivnikGrad | Protivnički tim |
| DvoranaId, Dvorana, Lokacija, Kapacitet | Gdje |

**Korištenje:** API - GET /basketball/matches/upcoming?teamId=X

#### 4.6.4 fnBoxScoreUtakmice(@UtakmicaId)
Vraća statistiku svih igrača na jednoj utakmici.

```sql
SELECT * FROM dbo.fnBoxScoreUtakmice(1) ORDER BY TipIgraca, Poeni DESC;
```

**Korištenje:** API - GET /basketball/matches/{id}/boxscore

#### 4.6.5 fnZavrseneUtakmiceOd(@OdVremena)
Vraća utakmice završene od određenog vremena (za webhook notifikacije).

```sql
SELECT * FROM dbo.fnZavrseneUtakmiceOd(DATEADD(HOUR, -24, GETDATE()));
```

| Kolona | Opis |
|--------|------|
| UtakmicaId | ID utakmice |
| Datum, VrijemePocetka | Kada je odigrana |
| Domaci, Gosti | Nazivi timova |
| PoeniDomaci, PoeniGosti | Rezultat |
| Pobjednik | Naziv pobjedničkog tima |

**Korištenje:** Webhook - POST /basketball/webhooks/match-completed

---

## 5. Redoslijed izvršavanja skripti

### 5.1 Faze izvršavanja

```
┌─────────────────────────────────────────────────────────────────┐
│ FAZA 0: Konfiguracija                                           │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ 00_seed_config.sql                                          │ │
│ │   - Kreira #SeedConfig temp tablicu                         │ │
│ │   - Definira volumene (BrojKorisnika, BrojMjeseci, ...)     │ │
│ │   - Validira config vrijednosti                             │ │
│ └─────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│ FAZA 1: Schema                                                  │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ 10_schema_cleanup.sql                                       │ │
│ │   - CREATE TABLE (8 tablica) IF NOT EXISTS                  │ │
│ │   - DELETE existing data + RESEED identities                │ │
│ │   - CREATE INDEX (25+ indeksa) IF NOT EXISTS                │ │
│ ├─────────────────────────────────────────────────────────────┤ │
│ │ 11_audit_log_tables.sql                                     │ │
│ │   - CREATE TABLE log_Igrac, log_Utakmica, log_Korisnik      │ │
│ │   - CREATE INDEX za log tablice                             │ │
│ └─────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│ FAZA 2-5: Seed Data                                             │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ 20_seed_static_data.sql    → Tim (20), Dvorana (12)         │ │
│ │ 30_seed_core_entities.sql  → Igrac (280), Korisnik (N)      │ │
│ │ 40_seed_relations.sql      → KorisnikTim, KorisnikIgrac     │ │
│ │ 50_seed_matches_and_stats.sql → Utakmica, Statistika        │ │
│ └─────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│ FAZA 6: Validacija                                              │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ 60_validation_and_success.sql                               │ │
│ │   - Provjera orphan zapisa                                  │ │
│ │   - Provjera distribucije podataka                          │ │
│ └─────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│ FAZA 7: View-ovi i Funkcije                                     │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ 70_views_and_sample_queries.sql → 4 view-a                  │ │
│ │ 71_functions.sql                → 5 TVF funkcija            │ │
│ └─────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│ FAZA 8: Triggeri                                                │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ 80_trigger_igrac_audit.sql      → Igrac_TR_LogChanges       │ │
│ │ 81_trigger_utakmica_audit.sql   → Utakmica_TR_LogChanges    │ │
│ │ 82_trigger_korisnik_audit.sql   → Korisnik_TR_LogChanges    │ │
│ │ 85_trigger_statistika_constraint.sql → PreventUpdate/Delete │ │
│ │ 86_trigger_korisnik_tim_constraint.sql → SoftDeleteOnly     │ │
│ │ 87_trigger_korisnik_igrac_constraint.sql → SoftDeleteOnly   │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Tablica skripti

| # | Skripta | Faza | Opis | Preduvjeti |
|---|---------|------|------|------------|
| 00 | seed_config.sql | Config | #SeedConfig parametri | Nema |
| 10 | schema_cleanup.sql | Schema | Tablice + indeksi | Nema |
| 11 | audit_log_tables.sql | Schema | Log tablice | 10 |
| 20 | seed_static_data.sql | Seed | Tim, Dvorana | 10 |
| 30 | seed_core_entities.sql | Seed | Igrac, Korisnik | 00, 20 |
| 40 | seed_relations.sql | Seed | KorisnikTim, KorisnikIgrac | 00, 30 |
| 50 | seed_matches_and_stats.sql | Seed | Utakmica, Statistika | 00, 20, 30 |
| 60 | validation_and_success.sql | Validate | Provjera integriteta | 50 |
| 70 | views_and_sample_queries.sql | Objects | 4 view-a | 50 |
| 71 | functions.sql | Objects | 5 TVF funkcija | 50 |
| 80 | trigger_igrac_audit.sql | Triggers | Audit Igrac | 11 |
| 81 | trigger_utakmica_audit.sql | Triggers | Audit Utakmica | 11 |
| 82 | trigger_korisnik_audit.sql | Triggers | Audit Korisnik | 11 |
| 85 | trigger_statistika_constraint.sql | Triggers | Immutable Statistika | 10 |
| 86 | trigger_korisnik_tim_constraint.sql | Triggers | Soft delete only | 10 |
| 87 | trigger_korisnik_igrac_constraint.sql | Triggers | Soft delete only | 10 |

**Napomena:** Skripte 00-50 moraju se izvršiti u jednoj sesiji zbog temp tablice #SeedConfig.

---

## 6. API integracije

### 6.1 Primjeri API endpointa i mapiranja SQL objekata na njih

| API Endpoint | HTTP | SQL Objekt | Parametri |
|--------------|------|------------|-----------|
| `/basketball/matches/upcoming` | GET | `vwNadolazeceUtakmice` | - |
| `/basketball/matches/upcoming?teamId=X` | GET | `fnRasporedTima(@TimId)` | teamId |
| `/basketball/matches/{id}/boxscore` | GET | `fnBoxScoreUtakmice(@UtakmicaId)` | id |
| `/basketball/statistics/top-scorers` | GET | `vwTop10Strijelaca` | limit (optional) |
| `/basketball/players/{id}/stats` | GET | `fnStatistikaIgraca(@IgracId)` | id |
| `/basketball/players?position=X` | GET | `fnIgraciPoPoziciji(@Pozicija)` | position |
| `/basketball/webhooks/match-completed` | POST | `fnZavrseneUtakmiceOd(@OdVremena)` | timestamp |

### 6.2 Primjeri SQL upita za API

```sql
-- GET /basketball/matches/upcoming
SELECT * FROM dbo.vwNadolazeceUtakmice 
ORDER BY Datum, VrijemePocetka;

-- GET /basketball/matches/upcoming?teamId=5&days=7
SELECT * FROM dbo.fnRasporedTima(5) 
WHERE Datum BETWEEN GETDATE() AND DATEADD(DAY, 7, GETDATE())
ORDER BY Datum;

-- GET /basketball/statistics/top-scorers?limit=10
SELECT TOP 10 * FROM dbo.vwTop10Strijelaca;

-- GET /basketball/players/123/stats
SELECT * FROM dbo.fnStatistikaIgraca(123);

-- GET /basketball/matches/456/boxscore
SELECT * FROM dbo.fnBoxScoreUtakmice(456) 
ORDER BY TipIgraca, Poeni DESC;

-- Webhook - dohvati završene utakmice u zadnjih 24h
SELECT * FROM dbo.fnZavrseneUtakmiceOd(DATEADD(HOUR, -24, GETDATE())) 
ORDER BY Datum DESC;
```

---

## 7. Upute za optimalne SQL upite

Ova sekcija opisuje preporučene načine upita specifične za Basketball Liga bazu podataka.

### 7.1 Korištenje postojećih View-ova i Funkcija

#### 7.1.1 Preferiraj View-ove nad ad-hoc upitima
```sql
-- LOŠE: pisanje kompleksnog upita ispočetka
SELECT i.Ime, i.Prezime, SUM(s.Poeni) AS UkupnoPoena
FROM dbo.Statistika s
JOIN dbo.Igrac i ON s.IgracId = i.IgracId
JOIN dbo.Tim t ON i.TimId = t.TimId
WHERE i.IsDeleted = 0
GROUP BY i.IgracId, i.Ime, i.Prezime
ORDER BY UkupnoPoena DESC;

-- DOBRO: koristi postojeći view
SELECT * FROM dbo.vwTop10Strijelaca;
```

#### 7.1.2 Koristi TVF funkcije s parametrima
```sql
-- Dohvat rasporeda specifičnog tima
SELECT * FROM dbo.fnRasporedTima(1)  -- TimId = 1 (Cibona)
WHERE Datum >= GETDATE()
ORDER BY Datum;

-- Karijerna statistika igrača
SELECT * FROM dbo.fnStatistikaIgraca(15);  -- IgracId = 15

-- Box score utakmice
SELECT * FROM dbo.fnBoxScoreUtakmice(42)   -- UtakmicaId = 42
ORDER BY TipIgraca, Poeni DESC;

-- Igrači po poziciji
SELECT * FROM dbo.fnIgraciPoPoziciji(N'Centar');
```

### 7.2 Soft Delete - obavezni filter

#### 7.2.1 Uvijek dodaj IsDeleted = 0
Sve tablice osim Statistika imaju soft delete. **Uvijek** filtriraj:

```sql
-- LOŠE: vraća i obrisane zapise
SELECT * FROM dbo.Igrac WHERE TimId = 1;
SELECT * FROM dbo.Tim;
SELECT * FROM dbo.Korisnik WHERE Email LIKE '%@gmail.com';

-- DOBRO: filtriraj soft-deleted
SELECT * FROM dbo.Igrac WHERE TimId = 1 AND IsDeleted = 0;
SELECT * FROM dbo.Tim WHERE IsDeleted = 0;
SELECT * FROM dbo.Korisnik WHERE Email LIKE '%@gmail.com' AND IsDeleted = 0;
```

#### 7.2.2 Međutablice - provjeri IsDeleted
```sql
-- Aktivni pratitelji tima
SELECT k.Ime, k.Email
FROM dbo.KorisnikTim kt
JOIN dbo.Korisnik k ON kt.KorisnikId = k.KorisnikId
WHERE kt.TimId = 1 
  AND kt.IsDeleted = 0      -- međutablica
  AND k.IsDeleted = 0;      -- korisnik
```

### 7.3 Upiti po tablicama

#### 7.3.1 Tim - dohvat aktivnih timova
```sql
-- Svi aktivni timovi
SELECT TimId, Naziv, Grad 
FROM dbo.Tim 
WHERE IsDeleted = 0
ORDER BY Naziv;

-- Tim s brojem igrača
SELECT t.TimId, t.Naziv, t.Grad, COUNT(i.IgracId) AS BrojIgraca
FROM dbo.Tim t
LEFT JOIN dbo.Igrac i ON t.TimId = i.TimId AND i.IsDeleted = 0
WHERE t.IsDeleted = 0
GROUP BY t.TimId, t.Naziv, t.Grad;
```

#### 7.3.2 Igrac - pretraživanje i filtriranje
```sql
-- Igrači tima sortirani po prezimenu (koristi indeks IX_Igrac_TimId_Prezime_Ime)
SELECT IgracId, Ime, Prezime, Pozicija
FROM dbo.Igrac
WHERE TimId = 1 AND IsDeleted = 0
ORDER BY Prezime, Ime;

-- Pretraga po poziciji (koristi filtered indeks IX_Igrac_Pozicija)
SELECT i.*, t.Naziv AS Tim
FROM dbo.Igrac i
JOIN dbo.Tim t ON i.TimId = t.TimId
WHERE i.Pozicija = N'Centar' AND i.IsDeleted = 0;
```

#### 7.3.3 Utakmica - filtriranje po datumu
```sql
-- Nadolazeće utakmice (koristi indeks IX_Utakmica_Datum_Active)
-- BOLJE: koristi view
SELECT * FROM dbo.vwNadolazeceUtakmice ORDER BY Datum, VrijemePocetka;

-- Utakmice u određenom razdoblju
SELECT u.*, td.Naziv AS Domaci, tg.Naziv AS Gosti
FROM dbo.Utakmica u
JOIN dbo.Tim td ON u.TimDomaci = td.TimId
JOIN dbo.Tim tg ON u.TimGosti = tg.TimId
WHERE u.Datum BETWEEN '2026-05-01' AND '2026-05-31'
  AND u.IsDeleted = 0
ORDER BY u.Datum, u.VrijemePocetka;
```

#### 7.3.4 Statistika - agregacije
```sql
-- NAPOMENA: Statistika NEMA IsDeleted (immutable tablica)

-- Prosječna statistika igrača
SELECT 
    i.Ime, i.Prezime,
    COUNT(*) AS BrojUtakmica,
    AVG(CAST(s.Poeni AS DECIMAL(5,2))) AS PPG,
    AVG(CAST(s.Asistencije AS DECIMAL(5,2))) AS APG,
    AVG(CAST(s.SkokoviOf + s.SkokoviDef AS DECIMAL(5,2))) AS RPG
FROM dbo.Statistika s
JOIN dbo.Igrac i ON s.IgracId = i.IgracId
WHERE i.IsDeleted = 0
GROUP BY i.IgracId, i.Ime, i.Prezime
HAVING COUNT(*) >= 5  -- minimum 5 utakmica
ORDER BY PPG DESC;

-- Top scorer na utakmici (koristi indeks IX_Statistika_UtakmicaId_Poeni)
SELECT TOP 1 s.*, i.Ime, i.Prezime
FROM dbo.Statistika s
JOIN dbo.Igrac i ON s.IgracId = i.IgracId
WHERE s.UtakmicaId = 42
ORDER BY s.Poeni DESC;
```

### 7.4 Rad s triggerima

#### 7.4.1 Statistika je IMMUTABLE
```sql
-- ZABRANJENO: UPDATE i DELETE na Statistika tablici
UPDATE dbo.Statistika SET Poeni = 30 WHERE StatistikaId = 1;  -- ERROR!
DELETE FROM dbo.Statistika WHERE StatistikaId = 1;            -- ERROR!

-- DOZVOLJENO: samo INSERT
INSERT INTO dbo.Statistika (IgracId, UtakmicaId, Minuta, Poeni, ...)
VALUES (15, 42, 28, 22, ...);
```

#### 7.4.2 Međutablice - DELETE postaje soft delete
```sql
-- DELETE se automatski pretvara u soft delete (trigger)
DELETE FROM dbo.KorisnikTim WHERE KorisnikId = 5 AND TimId = 1;
-- Rezultat: UPDATE KorisnikTim SET IsDeleted = 1, DeletedAt = SYSUTCDATETIME() ...

-- Za "reaktivaciju" - direktni UPDATE
UPDATE dbo.KorisnikTim 
SET IsDeleted = 0, DeletedAt = NULL
WHERE KorisnikId = 5 AND TimId = 1;
```

#### 7.4.3 Audit log - proslijedi ResponsibleId
```sql
-- Prije UPDATE/DELETE na Igrac, Utakmica ili Korisnik
-- Kreiraj temp tablicu da trigger zna tko izvršava akciju

SELECT [log_IdResponsible] = @TrenutniKorisnikId 
INTO #Igrac_TR_LogChanges;

UPDATE dbo.Igrac 
SET Pozicija = N'Krilni centar', UpdatedAt = SYSUTCDATETIME()
WHERE IgracId = 15;

-- Trigger automatski logira promjenu u log_Igrac
```

### 7.5 Korištenje indeksa

#### 7.5.1 Filtered indeksi za aktivne zapise
```sql
-- Ovi upiti koriste filtered indekse (WHERE IsDeleted = 0):

-- IX_Tim_Active
SELECT Naziv, Grad FROM dbo.Tim WHERE IsDeleted = 0;

-- IX_Igrac_Prezime_Ime  
SELECT * FROM dbo.Igrac WHERE Prezime LIKE N'B%' AND IsDeleted = 0;

-- IX_Korisnik_Ime
SELECT Ime, Email FROM dbo.Korisnik WHERE Ime LIKE N'Ivan%' AND IsDeleted = 0;
```

#### 7.5.2 Covering indeksi za Statistiku
```sql
-- IX_Statistika_IgracId_Cover - dohvat bez pristupa tablici
SELECT IgracId, Poeni, Asistencije, SkokoviOf, SkokoviDef
FROM dbo.Statistika
WHERE IgracId = 15;

-- IX_Statistika_UtakmicaId_Cover - box score bez table lookup
SELECT IgracId, Poeni, Asistencije, FGM, FGA, FG3M, FG3A, FTM, FTA
FROM dbo.Statistika
WHERE UtakmicaId = 42;
```

### 7.6 Česti scenariji

#### 7.6.1 Dashboard - kombinacija view-ova
```sql
-- Top strijelci + nadolazeće utakmice za homepage
SELECT 'strijelci' AS Tip, * FROM dbo.vwTop10Strijelaca;
SELECT 'utakmice' AS Tip, * FROM dbo.vwNadolazeceUtakmice 
WHERE Datum <= DATEADD(DAY, 7, GETDATE());
```

#### 7.6.2 Webhooks - završene utakmice
```sql
-- Dohvati utakmice završene u zadnjih 24 sata
SELECT * FROM dbo.fnZavrseneUtakmiceOd(DATEADD(HOUR, -24, GETDATE()))
ORDER BY Datum DESC;
```

#### 7.6.3 Paginacija igrača
```sql
-- Stranica 3 (redovi 21-30), sortirano po prezimenu
SELECT IgracId, Ime, Prezime, Pozicija, t.Naziv AS Tim
FROM dbo.Igrac i
JOIN dbo.Tim t ON i.TimId = t.TimId
WHERE i.IsDeleted = 0
ORDER BY i.Prezime, i.Ime
OFFSET 20 ROWS FETCH NEXT 10 ROWS ONLY;
```

### 7.7 Checklist prije izvršavanja

| # | Provjera | Primjer |
|---|----------|---------|
| 1 | **IsDeleted = 0** | Dodano na sve tablice osim Statistika |
| 2 | **Koristi View/TVF** | `vwTop10Strijelaca` umjesto ad-hoc upita |
| 3 | **N'...' za Unicode** | `WHERE Ime = N'Petrović'` (NVARCHAR kolone) |
| 4 | **Datum raspon** | `BETWEEN '2026-01-01' AND '2026-12-31'` ne `YEAR(Datum)=2026` |
| 5 | **ResponsibleId za audit** | Temp tablica prije UPDATE/DELETE |
| 6 | **Ne diraj Statistiku** | Samo INSERT, nikad UPDATE/DELETE |

---

## 8. Strategija sigurnosne kopije podataka

### 8.1 Klasifikacija podataka po kritičnosti

| Prioritet | Tablica | Razlog | RPO* |
|-----------|---------|--------|------|
| 🔴 KRITIČNO | Statistika | IMMUTABLE - ne može se rekreirati | 15 min |
| 🔴 KRITIČNO | log_* tablice | Audit trail - pravna obveza | 15 min |
| 🟠 VISOKO | Utakmica | Transakcijski podaci | 1 sat |
| 🟠 VISOKO | Korisnik | Korisnički podaci | 1 sat |
| 🟡 SREDNJE | Igrac | Može se rekreirati iz izvora | 24 sata |
| 🟡 SREDNJE | KorisnikTim, KorisnikIgrac | M:N veze, soft delete | 24 sata |
| 🟢 NISKO | Tim, Dvorana | Statički podaci, lako se obnavljaju | 7 dana |

*RPO = Recovery Point Objective (maksimalno prihvatljiv gubitak podataka)

### 8.2 Raspored backup-a

```
┌─────────────────────────────────────────────────────────────────┐
│ FULL BACKUP - Nedjelja 02:00                                    │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ BACKUP DATABASE BasketballLiga                              │ │
│ │ TO DISK = 'D:\Backup\BasketballLiga_FULL_yyyyMMdd.bak'      │ │
│ │ WITH COMPRESSION, CHECKSUM, INIT;                           │ │
│ └─────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│ DIFFERENTIAL BACKUP - Svaki dan 02:00 (osim nedjelje)           │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ BACKUP DATABASE BasketballLiga                              │ │
│ │ TO DISK = '..._DIFF_yyyyMMdd.bak'                           │ │
│ │ WITH DIFFERENTIAL, COMPRESSION, CHECKSUM;                   │ │
│ └─────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│ TRANSACTION LOG BACKUP - Svakih 15 minuta                       │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ BACKUP LOG BasketballLiga                                   │ │
│ │ TO DISK = '..._LOG_yyyyMMdd_HHmm.trn'                       │ │
│ │ WITH COMPRESSION;                                           │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### 8.3 SQL Server Agent Jobs

```sql
-- Job 1: Weekly Full Backup (nedjelja 02:00)
BACKUP DATABASE [BasketballLiga]
TO DISK = N'D:\Backup\BasketballLiga_FULL_' 
        + FORMAT(GETDATE(), 'yyyyMMdd') + N'.bak'
WITH COMPRESSION, CHECKSUM, INIT, 
     NAME = N'BasketballLiga-Full Weekly';

-- Job 2: Daily Differential (pon-sub 02:00)
BACKUP DATABASE [BasketballLiga]
TO DISK = N'D:\Backup\BasketballLiga_DIFF_' 
        + FORMAT(GETDATE(), 'yyyyMMdd') + N'.bak'
WITH DIFFERENTIAL, COMPRESSION, CHECKSUM,
     NAME = N'BasketballLiga-Diff Daily';

-- Job 3: Transaction Log (svakih 15 min)
BACKUP LOG [BasketballLiga]
TO DISK = N'D:\Backup\BasketballLiga_LOG_' 
        + FORMAT(GETDATE(), 'yyyyMMdd_HHmm') + N'.trn'
WITH COMPRESSION,
     NAME = N'BasketballLiga-Log 15min';
```

### 8.4 Specifičnosti ove baze

#### 8.4.1 Statistika - kritična tablica
```sql
-- Statistika je IMMUTABLE (INSERT-only)
-- Jednom izgubljeni podaci NE MOGU se rekonstruirati
-- Preporuka: BACKUP LOG odmah nakon bulk INSERT-a statistike utakmice

-- Primjer: nakon unosa statistike cijele utakmice
INSERT INTO dbo.Statistika (...) VALUES ...;
BACKUP LOG [BasketballLiga] TO DISK = '..._LOG_AFTER_STATS.trn' WITH COMPRESSION;
```

#### 8.4.2 Soft Delete prednost
```sql
-- Soft delete obrazac ŠTITI od slučajnog gubitka
-- Čak i bez backup-a, "obrisani" podaci ostaju u tablici

-- Oporavak "obrisanog" igrača (ne treba restore!):
UPDATE dbo.Igrac 
SET IsDeleted = 0, DeletedAt = NULL, UpdatedAt = SYSUTCDATETIME()
WHERE IgracId = @IgracId AND IsDeleted = 1;

-- Zato je RPO za Igrac, Tim, Dvorana dulji (24h-7d)
```

#### 8.4.3 Audit log tablice
```sql
-- log_Igrac, log_Utakmica, log_Korisnik rastu kontinuirano
-- Preporuka: arhiviranje starijih od 1 godine

-- Arhiviranje u zasebnu tablicu/bazu:
SELECT * INTO [Archive].dbo.log_Igrac_2025
FROM dbo.log_Igrac
WHERE log_DateTS < '2026-01-01';

DELETE FROM dbo.log_Igrac WHERE log_DateTS < '2026-01-01';
```

### 8.5 Scenariji oporavka

| Scenarij | Postupak | Vrijeme oporavka |
|----------|----------|------------------|
| Slučajno obrisana Statistika | RESTORE LOG do točke prije brisanja | 15-30 min |
| Slučajno obrisani Igrac | UPDATE IsDeleted = 0 (soft delete!) | < 1 min |
| Korupcija baze | RESTORE FULL + DIFF + LOG | 1-2 sata |
| Gubitak servera | RESTORE na novi server | 2-4 sata |
| Vraćanje na jučer 15:00 | Point-in-time recovery | 30-60 min |

### 8.6 Point-in-Time Recovery primjer

```sql
-- Vratiti bazu na stanje 15. svibnja 2026. u 14:30

-- 1. Restore FULL (nedjelja prije)
RESTORE DATABASE BasketballLiga_Restore
FROM DISK = 'D:\Backup\BasketballLiga_FULL_20260510.bak'
WITH NORECOVERY, REPLACE;

-- 2. Restore DIFF (dan prije)
RESTORE DATABASE BasketballLiga_Restore
FROM DISK = 'D:\Backup\BasketballLiga_DIFF_20260514.bak'
WITH NORECOVERY;

-- 3. Restore LOG-ovi do točnog vremena
RESTORE LOG BasketballLiga_Restore
FROM DISK = 'D:\Backup\BasketballLiga_LOG_20260515_0600.trn'
WITH NORECOVERY;
-- ... svi LOG-ovi do 14:30 ...

RESTORE LOG BasketballLiga_Restore
FROM DISK = 'D:\Backup\BasketballLiga_LOG_20260515_1430.trn'
WITH RECOVERY, STOPAT = '2026-05-15T14:30:00';
```

### 8.7 Retencijska politika

| Tip backup-a | Zadržavanje | Lokacija |
|--------------|-------------|----------|
| Full (tjedni) | 4 tjedna lokalno, 1 godina offsite | D:\Backup + Azure Blob |
| Differential | 7 dana | D:\Backup |
| Transaction Log | 7 dana | D:\Backup |
| Arhiva (godišnji) | 7 godina | Azure Cold Storage |

### 8.8 Verifikacija backup-a

```sql
-- Tjedna provjera integriteta backup-a
RESTORE VERIFYONLY 
FROM DISK = 'D:\Backup\BasketballLiga_FULL_20260517.bak'
WITH CHECKSUM;

-- Mjesečna probna obnova na test server
RESTORE DATABASE BasketballLiga_Test
FROM DISK = 'D:\Backup\BasketballLiga_FULL_20260517.bak'
WITH REPLACE, RECOVERY,
     MOVE 'BasketballLiga' TO 'D:\TestDB\BasketballLiga_Test.mdf',
     MOVE 'BasketballLiga_log' TO 'D:\TestDB\BasketballLiga_Test.ldf';

-- Provjera konzistentnosti
DBCC CHECKDB('BasketballLiga_Test') WITH NO_INFOMSGS;
```

### 8.9 Checklist backup strategije

| # | Stavka | Status |
|---|--------|--------|
| 1 | Recovery Model = FULL | ☐ |
| 2 | SQL Agent Jobs konfigurirani | ☐ |
| 3 | Offsite kopija postavljena | ☐ |
| 4 | Testna obnova izvršena | ☐ |
| 5 | Alerting na neuspjele backup-e | ☐ |
| 6 | Dokumentirani RTO/RPO | ☐ |
| 7 | Arhiviranje log tablica | ☐ |

---

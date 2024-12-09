﻿USE CarSharing
GO

-- Inserting all business used locations for Location table
INSERT INTO Location (City, District)
VALUES 
    ('Warszawa', 'Centrum'),
    ('Warszawa', 'Bemowo'),
    ('Warszawa', 'Mokotów'),
    ('Warszawa', 'Praga Północ'),
    ('Warszawa', 'Praga Południe'),
    ('Warszawa', 'Ochota'),
    ('Warszawa', 'Wola'),
    ('Warszawa', 'Bielany'),
    ('Warszawa', 'Żoliborz'),
    ('Kraków', 'Stare Miasto'),
    ('Kraków', 'Kazimierz'),
    ('Kraków', 'Nowa Huta'),
    ('Kraków', 'Podgórze'),
    ('Kraków', 'Grzegórzki'),
    ('Kraków', 'Dębniki'),
    ('Gdańsk', 'Wrzeszcz'),
    ('Gdańsk', 'Śródmieście'),
    ('Gdańsk', 'Oliwa'),
    ('Gdańsk', 'Przymorze'),
    ('Gdańsk', 'Zaspa'),
    ('Gdańsk', 'Osowa'),
    ('Wrocław', 'Stare Miasto'),
    ('Wrocław', 'Krzyki'),
    ('Wrocław', 'Fabryczna'),
    ('Wrocław', 'Śródmieście'),
    ('Wrocław', 'Psie Pole'),
    ('Wrocław', 'Bielany Wrocławskie'),
    ('Poznań', 'Stare Miasto'),
    ('Poznań', 'Jeżyce'),
    ('Poznań', 'Wilda'),
    ('Poznań', 'Łazarz'),
    ('Poznań', 'Grunwald'),
    ('Poznań', 'Rataje'),
    ('Łódź', 'Śródmieście'),
    ('Łódź', 'Widzew'),
    ('Łódź', 'Bałuty'),
    ('Łódź', 'Polesie'),
    ('Łódź', 'Górna'),
    ('Łódź', 'Anders'),
    ('Łódź', 'Retkinia');
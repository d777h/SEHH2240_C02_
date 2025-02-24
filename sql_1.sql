--references:
--  relationship:
--  https://www.geeksforgeeks.org/relationships-in-sql-one-to-one-one-to-many-many-to-many/
--  check constraint:
--  https://www.geeksforgeeks.org/sql-check-constraint/
--  enum:
--  https://www.geeksforgeeks.org/enumerator-enum-in-mysql/

CREATE TABLE Artists --aggregation of artists and bands. artists can be either a band or an individual like a singer. 
(
    artist_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    individual_id INT UNIQUE FOREIGN KEY REFERENCES Individuals(individual_id), 
    band_id INT UNIQUE FOREIGN KEY REFERENCES Bands(band_id) CHECK((individual_id IS NOT NULL AND band_id IS NULL) OR (individual_id IS NULL AND band_id IS NOT NULL)),
    media_id INT UNIQUE FOREIGN KEY REFERENCES Media(media_id), 
    artist_desc VARCHAR(1000),
    address_id INT FOREIGN KEY REFERENCES Addresses(address_id) --optional. for something like studio address or the mailing address
); 

CREATE TABLE Residency --see this as something like a timeslot. referring to artists who are hired full time by the avenue, like an inhouse dj or jazz band
(
    residency_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    residency_weekday ENUM('Sunday', 'Monday', 'Tuesday', 'Wednesday','Thursday', 'Friday', 'Saturday'), 
    residency_starttime TIME NOT NULL, 
    residency_endtime TIME NOT NULL, CHECK(residency_starttime < residency_endtime), 
    residency_startdate DATE NOT NULL,
    residency_enddate DATE CHECK(residency_startdate < residency_enddate), 
    avenue_id INT FOREIGN KEY REFERENCES Avenues(avenue_id), 
); 

CREATE TABLE Lang --languages used by artists and shows alike
(
    lang_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    lang_name VARCHAR(20) NOT NULL UNIQUE, --full name.
    lang_abb CHAR(3) NOT NULL UNIQUE, --abbreviation. iso 3 letters.
);

CREATE TABLE Individuals --band/group members and solo artists. Some individuals might not be a independent artist. 
(
    individual_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    individual_name_cn VARCHAR(255),
    individual_name_en VARCHAR(255) NOT NULL, 
    individual_age TINYINT,
    individual_gender ENUM('M', 'F', 'NON-BINARY', 'OTHERS'),
    individual_debut_year YEAR NOT NULL,
); 

CREATE TABLE Bands 
( 
    band_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    band_name_cn VARCHAR(255), 
    band_name_en VARCHAR(255) NOT NULL,
    formation_date YEAR NOT NULL, 
    disband_date YEAR CHECK(disband_date IS NULL OR formation_date <= disband_date),
); 

CREATE TABLE Instruments --query people who play the same instruments
(
    instrument_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    instrument_name_en VARCHAR(255) NOT NULL UNIQUE, 
    instrument_name_cn VARCHAR(255) NOT NULL UNIQUE, 
);

CREATE TABLE Genres --e.g. pop, rock, hip hop
(
    genre_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    genre_name_en VARCHAR(255) NOT NULL UNIQUE,
    genre_name_cn VARCHAR(255) NOT NULL UNIQUE,
); 

CREATE TABLE Subgenres --e.g. dream pop, shoegaze, boom bap. each genre includes multiple subgenres, but subgenres can only belong to one genre
(
    subgenre_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    subgenre_name_en VARCHAR(255) NOT NULL UNIQUE,
    subgenre_name_cn VARCHAR(255) NOT NULL UNIQUE,
    genre_id INT NOT NULL FOREIGN KEY REFERENCES Genres(genre_id),
); 

CREATE TABLE Avenues_Info
(
    avenue_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    --some avenue might not have fixed operation time no NOT NULL here
    avenue_opentime TIME, 
    avenue_closetime TIME,
    avenue_name_cn VARCHAR(255), 
    avenue_name_en VARCHAR(255) NOT NULL UNIQUE, 
    avenue_capacity SMALLINT NOT NULL,
    avenue_desc VARCHAR(1000), 
    accessibility_id INT NOT NULL UNIQUE FOREIGN KEY REFERENCES Accessibility(accessibility_id),
    address_id INT NOT NULL UNIQUE FOREIGN KEY REFERENCES Addresses(address_id),
    type_id INT NOT NULL FOREIGN KEY REFERENCES Avenue_Types(type_id), 
    avenue_rules_id INT NOT NULL UNIQUE FOREIGN KEY REFERENCES Avenues_Rules(avenue_rules_id), 
);

CREATE TABLE Avenues_Rules --limitation 
(
    avenue_rules_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    avenue_is_outdoor BOOLEAN NOT NULL, --is outdoor if true
    avenue_can_smoke BOOLEAN NOT NULL, --allow to smoke if true
    avenue_can_drink BOOLEAN NOT NULL, --alchohol is allowed if true
    avenue_loud BOOLEAN NOT NULL, --visitors and customers are allowed to talk loudly if true
    avenue_pets BOOLEAN NOT NULL, --visitors and customers are allowed to bring their pet if true
    avenue_underground BOOLEAN, --underground if true, upstair if false, neither if null
    avenue_minimum_spending SMALLINT, --may require spending some money
    avenue_foreigner ENUM('Welcomed', 'Tolerated', 'Not Welcomed') NOT NULL, 
    avenue_attire ENUM('Formal', 'Business Casual', 'Casual', 'Ultra Casual') NOT NULL, 
);

CREATE TABLE Avenue_Types --what kind of avenue is it?
(   
    type_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    type_name VARCHAR(50) NOT NULL UNIQUE, --e.g. cafe, nightclub.
);

CREATE TABLE Accessibility
(
    accessibility_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    accessibility_toilet BOOLEAN NOT NULL,
    accessibility_ramp BOOLEAN NOT NULL, 
    accessibility_elevator BOOLEAN NOT NULL, 
    accessibility_parking BOOLEAN NOT NULL,
); 

CREATE TABLE Websites --accessing multiple social media pages and promotional pages
(
    website_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    website_url VARCHAR(255) NOT NULL,
); 

CREATE TABLE Media --accessing digital contents
(
    media_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    media_link_bandcamp VARCHAR(255), 
    media_link_soundcloud VARCHAR(255), 
    media_link_rym VARCHAR(255), --Rate Your Music
    media_link_youtube VARCHAR(255),
); 

CREATE TABLE Contacts 
(
    contact_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    --phone and email is not set to NOT NULL to provide flexibility
    phone_number VARCHAR(255), 
    email_link VARCHAR(255) CHECK(phone_number IS NOT NULL OR email_link IS NOT NULL), 
); 

CREATE TABLE Addresses 
(
    address_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    district_id SMALLINT NOT NULL FOREIGN KEY REFERENCES Districts(district_id),
    address_street VARCHAR(255) NOT NULL, 
    address_bldg_floor VARCHAR(255) NOT NULL, 
    metro_id INT FOREIGN KEY REFERENCES MTR(metro_id), 
); 

CREATE TABLE Districts --allows easier querying by the 18 districts 
(
    district_id SMALLINT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    district_name VARCHAR(30),
);

CREATE TABLE MTR --allows easier quering by nearby MTR stations. MTR station near the avenue might be located in the same district of the avenue so no relation.
(
    metro_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    metro_name VARCHAR(30),
    district_id SMALLINT NOT NULL FOREIGN KEY REFERENCES Districts(district_id), 
);

CREATE TABLE Events --optional table for organising week or year long events with multiple shows
(
    event_id INT NOT NULL PRIMARY KEY, 
    event_startdate DATE NOT NULL, 
    event_enddate DATE CHECK(event_startdate <= event_enddate),
    event_desc VARCHAR(500), 
); 

CREATE TABLE Shows --one-off show or part of an event
(
    show_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    show_date DATE,
    show_starttime TIME, 
    show_endtime TIME CHECK(show_starttime <= show_endtime),
    show_desc VARCHAR(500),
    event_id INT FOREIGN KEY REFERENCES Events(event_id), --might be part of a larger event. assign shows to an event.
    avenue_id INT NOT NULL FOREIGN KEY REFERENCES Avenues_Info(avenue_id),  
);

--shows and events are not aggregated here beacause both have inherently different property. Also show can be part of event

CREATE TABLE Artists_Subgenres --many artists can have many different subgenres. you can also use this to query by genre, i guess
(
    artist_id INT NOT NULL FOREIGN KEY REFERENCES Artists(artist_id), 
    subgenre_id INT NOT NULL FOREIGN KEY REFERENCES Subgenres(subgenre_id),
    PRIMARY KEY (artist_id, subgenre_id),
); 

CREATE TABLE Shows_Artists --many different shows to many different artists
(
   show_id INT NOT NULL FOREIGN KEY REFERENCES Shows(show_id), 
   artist_id INT NOT NULL FOREIGN KEY REFERENCES Artists(artist_id), 
   PRIMARY KEY (show_id, artist_id),
); 

CREATE TABLE Events_Artists --many different events to many different artists
(
    event_id INT NOT NULL FOREIGN KEY REFERENCES Events(event_id),
    artist_id INT NOT NULL FOREIGN KEY REFERENCES Artists(artist_id),
    PRIMARY KEY(event_id, artist_id), 
);

CREATE TABLE Bands_Individuals --many different bands/groups to many different individuals(memebrs)
(
    band_id INT NOT NULL FOREIGN KEY REFERENCES Bands(band_id), 
    individual_id INT NOT NULL FOREIGN KEY REFERENCES Individuals(individual_id), 
    PRIMARY KEY (band_id, individual_id),   
);

CREATE TABLE Artists_Lang --many different artists to many different languages
( 
    lang_id SMALLINT NOT NULL FOREIGN KEY REFERENCES Lang(lang_id), 
    artist_id INT NOT NULL FOREIGN KEY REFERENCES Artists(artist_id), 
    PRIMARY KEY (lang_id, artist_id), 
);

CREATE TABLE Artists_Website --associating multiple websites with multiple artists
(
    artist_id INT NOT NULL FOREIGN KEY REFERENCES Artists(artist_id), 
    website_id INT NOT NULL FOREIGN KEY REFERENCES Websites(website_id), 
    PRIMARY KEY (artist_id, website_id),
); 

CREATE TABLE Avenues_Info_Website --associating multiple websites with multiple avenues
(
    avenue_id INT NOT NULL FOREIGN KEY REFERENCES Avenues_Info(avenue_id), 
    website_id INT NOT NULL FOREIGN KEY REFERENCES Websites(website_id), 
    PRIMARY KEY (avenue_id, website_id), 
);

CREATE TABLE Avenues_Info_Events --assigning multiple events to multiple avenues through out the possible schedules
(
    avenue_id INT NOT NULL FOREIGN KEY REFERENCES Avenues_Info(avenue_id), 
    event_id INT NOT NULL FOREIGN KEY REFERENCES Events(event_id), 
    PRIMARY KEY(avenue_id, event_id)
); 

CREATE TABLE Avenues_Contacts
(
    avenue_id INT NOT NULL FOREIGN KEY REFERENCES Avenues_Info(avenue_id), 
    contact_id INT NOT NULL FOREIGN KEY REFERENCES Cotnacts(contact_id), 
    PRIMARY KEY(avenue_id, contact_id)
);

CREATE TABLE Artists_Contacts
(
    artists_id INT NOT NULL FOREIGN KEY REFERENCES Artists(artist_id), 
    contact_id INT NOT NULL FOREIGN KEY REFERENCES Contacts(contact_id), 
    PRIMARY KEY(artist_id, contact_id)
); 

CREATE TABLE Events_Contacts
(
    event_id INT NOT NULL FOREIGN KEY REFERENCES Events(event_id), 
    contact_id INT NOT NULL FOREIGN KEY REFERENCES Contacts(contact_id), 
    PRIMARY KEY(event_id, contact_id)
); 

CREATE TABLE Individuals_Instruments --track individual guitarists dummers etc
(
    individual_id INT NOT NULL FOREIGN KEY REFERENCES Individuals(individual_id), 
    instrument_id INT NULL FOREIGN KEY REFERENCES Instruments(instrument_id), 
    PRIMARY KEY(artist_id, instrument_id)
);

CREATE TABLE Events_Residency --multiple events including multiple residency sessions
(
    event_id INT NOT NULL FOREIGN KEY REFERENCES Events(event_id), 
    residency_id INT NOT NULL FOREIGN KEY REFERENCES Residency(residency_id), 
    PRIMARY KEY(event_id, residency_id)
); 

CREATE TABLE Artists_Residency --multiple artists in multiple residency sessions together
(
    artist_id INT NOT NULL FOREIGN KEY REFERENCES Artists(artist_id), 
    residency_id INT NOT NULL FOREIGN KEY REFERENCES Residency(residency_id), 
    PRIMARY KEY(artist_id, residency_id)
); 

CREATE TABLE Events_Lang --multiple events to multiple languages used
(
    event_id INT NOT NULL FOREIGN KEY REFERENCES Events(event_id), 
    lang_id INT NOT NULL FOREIGN KEY REFERENCES Lang(lang_id), 
    PRIMARY KEY(event_id, lang_id)
); 
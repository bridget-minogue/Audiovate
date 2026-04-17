CREATE DATABASE IF NOT EXISTS Audiovate;
USE Audiovate;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `playlistEvent`, `streamEvent`, `track`, `release`, `artist`, `user`;

-- START SCHEMA --
DROP DATABASE IF EXISTS Audiovate;
CREATE DATABASE IF NOT EXISTS Audiovate;
USE Audiovate;

CREATE TABLE user (
  user_id           INT AUTO_INCREMENT PRIMARY KEY,
  first_name        VARCHAR(50),
  last_name         VARCHAR(50),
  role              ENUM('User', 'Admin', 'Manager') DEFAULT 'User',
  email             VARCHAR(75) Unique
);

CREATE TABLE location (
    location_id      INT AUTO_INCREMENT PRIMARY KEY,
    country          VARCHAR(75) NOT NULL,
    region_state     VARCHAR(75) NOT NULL,
    city             VARCHAR(75) NOT NULL,
    postal_code      INT,
    longitude        INT,
    latitude         INT
);

CREATE TABLE platform (
    platform_id      INT AUTO_INCREMENT PRIMARY KEY,
    name             VARCHAR(50) NOT NULL,
    estim_rev_per_unit DECIMAL(11,2)
);

CREATE TABLE artist (
    artist_id      INT AUTO_INCREMENT PRIMARY KEY,
    stage_name     VARCHAR(50),
    bio            TEXT,
    instagram      VARCHAR(100),
    profile_pic    VARCHAR(225),
    tax_id_status  TINYINT(1),
    artist_user_id INT NOT NULL,
    CONSTRAINT fk_artist_user_id
    FOREIGN KEY (artist_user_id) REFERENCES user(user_id)
    ON DELETE CASCADE
);

CREATE TABLE systemLog (
    log_id          INT AUTO_INCREMENT PRIMARY KEY,
    status          TINYINT(1),
    description     TEXT,
    timestamp       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    log_user_id     INT NOT NULL,
    log_admin_id    INT NOT NULL,
    CONSTRAINT fk_log_user_id
    FOREIGN KEY (log_user_id) REFERENCES user(user_id)
    ON DELETE CASCADE,
    CONSTRAINT fk_log_admin_id
    FOREIGN KEY (log_admin_id) REFERENCES user(user_id)
    ON DELETE CASCADE
);

CREATE TABLE helpRequest (
    request_id      INT AUTO_INCREMENT PRIMARY KEY,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    submitted_user_id  INT NOT NULL,
    status             TINYINT(1),
    description        TEXT,
    assigned_admin_id   INT NOT NULL,
    CONSTRAINT fk_submitted_user_id
    FOREIGN KEY (submitted_user_id) REFERENCES user(user_id),
    CONSTRAINT fk_assigned_admin_id
    FOREIGN KEY (assigned_admin_id) REFERENCES user(user_id)
);

CREATE TABLE listener (
    listener_id       INT AUTO_INCREMENT PRIMARY KEY,
    age               INT,
    gender            ENUM('F','M','NB','Other'),
    listener_location_id INT NOT NULL,
    CONSTRAINT fk_listener_location_id
    FOREIGN KEY (listener_location_id) REFERENCES location(location_id)
);

CREATE TABLE playlist (
    playlist_id       INT AUTO_INCREMENT PRIMARY KEY,
    name              VARCHAR(50) NOT NULL,
    type              ENUM('Editorial', 'Algorithm', 'User') NOT NULL,
    p_platform_id     INT NOT NULL,
    CONSTRAINT fk_p_platform_id
    FOREIGN KEY (p_platform_id) REFERENCES platform(platform_id)
);

CREATE TABLE `release` (
    rel_id           INT AUTO_INCREMENT PRIMARY KEY,
    title            VARCHAR(255) NOT NULL,
    type             ENUM('Album', 'Single', 'EP', 'Compilation'),
    status           ENUM('Processing', 'Approved', 'Released', 'Takedown'),
    release_date     DATETIME NOT NULL,
    release_artist_id INT NOT NULL,
    CONSTRAINT fk_release_artist_id
    FOREIGN KEY (release_artist_id) REFERENCES artist(artist_id)
    ON DELETE CASCADE
);

CREATE TABLE manages (
    manages_user_id    INT NOT NULL,
    manages_artist_id  INT NOT NULL,
    PRIMARY KEY(manages_user_id, manages_artist_id),
    CONSTRAINT fk_manages_user_id
    FOREIGN KEY (manages_user_id) REFERENCES user(user_id),
    CONSTRAINT fk_manages_artist_id
    FOREIGN KEY (manages_artist_id) REFERENCES artist(artist_id)
);

CREATE TABLE track (
    track_id          INT AUTO_INCREMENT PRIMARY KEY,
    title             VARCHAR(255) NOT NULL,
    genre             VARCHAR(50) NOT NULL,
    isrc_code         VARCHAR(12) NOT NULL,
    track_artist_id   INT NOT NULL,
    track_release_id  INT NOT NULL,
    CONSTRAINT fk_track_artist_id
    FOREIGN KEY (track_artist_id) REFERENCES artist(artist_id)
    ON DELETE CASCADE,
    CONSTRAINT fk_track_release_id
    FOREIGN KEY (track_release_id) REFERENCES `release`(rel_id)
    ON DELETE CASCADE
);

CREATE TABLE financialReport (
    freport_id       INT AUTO_INCREMENT PRIMARY KEY,
    start_period     DATETIME NOT NULL,
    end_period       DATETIME NOT NULL,
    fr_release_id    INT NOT NULL,
    CONSTRAINT fk_fr_release_id
    FOREIGN KEY (fr_release_id) REFERENCES `release`(rel_id)
);

CREATE TABLE asset (
    asset_id            INT AUTO_INCREMENT PRIMARY KEY,
    file_url            VARCHAR(255) NOT NULL,
    file_type           ENUM('Audio','Artwork', 'Credits'),
    upload_status       TINYINT(1),
    asset_release_id    INT NOT NULL,
    CONSTRAINT fk_asset_release_id
    FOREIGN KEY (asset_release_id) REFERENCES `release`(rel_id)
    ON DELETE CASCADE
);

CREATE TABLE payoutProfiles (
    payout_id         INT AUTO_INCREMENT PRIMARY KEY,
    collab_email      VARCHAR(255) NOT NULL,
    role              VARCHAR(50) NOT NULL,
    split_percentage  DECIMAL(5,2),
    pp_release_id     INT NOT NULL,
    CONSTRAINT fk_pp_release_id
    FOREIGN KEY (pp_release_id) REFERENCES `release`(rel_id)
);

CREATE TABLE streamEvent (
    event_id         INT AUTO_INCREMENT PRIMARY KEY,
    time_stamp       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_skipped       TINYINT(1) NOT NULL,
    rev_generated    DECIMAL(19,4) NOT NULL,
    event_listener_id INT NULL,
    event_track_id    INT NOT NULL,
    event_platform_id INT NOT NULL,
    event_location_id INT NOT NULL,
    CONSTRAINT fk_event_listener_id
    FOREIGN KEY (event_listener_id) REFERENCES listener(listener_id)
    ON DELETE SET NULL,
    CONSTRAINT fk_event_track_id
    FOREIGN KEY (event_track_id) REFERENCES track(track_id)
    ON DELETE RESTRICT,
    CONSTRAINT fk_event_platform_id
    FOREIGN KEY (event_platform_id) REFERENCES platform(platform_id),
    CONSTRAINT fk_event_location_id
    FOREIGN KEY (event_location_id) REFERENCES location(location_id)
);

CREATE TABLE playlistEvent (
    pt_event_id INT NOT NULL,
    pt_playlist_id INT NOT NULL,
    PRIMARY KEY(pt_event_id, pt_playlist_id),
    CONSTRAINT fk_pt_event_id
    FOREIGN KEY (pt_event_id) REFERENCES streamEvent(event_id)
    ON DELETE CASCADE,
    CONSTRAINT fk_pt_playlist_id
    FOREIGN KEY (pt_playlist_id) REFERENCES playlist(playlist_id)
);
-- END SCHEMA --

TRUNCATE TABLE user;
TRUNCATE TABLE artist;
TRUNCATE TABLE location;
TRUNCATE TABLE platform;
TRUNCATE TABLE systemLog;
TRUNCATE TABLE helpRequest;
TRUNCATE TABLE listener;
TRUNCATE TABLE playlist;
TRUNCATE TABLE `release`;
TRUNCATE TABLE manages;
TRUNCATE TABLE track;
TRUNCATE TABLE financialReport;
TRUNCATE TABLE asset;
TRUNCATE TABLE payoutProfiles;
TRUNCATE TABLE streamEvent;
TRUNCATE TABLE playlistEvent;
-- 1. user
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (1, 'Erin', 'Johnson', 'Manager', 'garciajoseph@example.net');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (2, 'John', 'Lee', 'Manager', 'wfreeman@example.com');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (3, 'Troy', 'Herrera', 'Manager', 'steven68@example.net');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (4, 'Kayla', 'Hayes', 'Manager', 'kennethosborn@example.org');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (5, 'Jane', 'Flores', 'Manager', 'xsanders@example.com');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (6, 'Natalie', 'Ross', 'User', 'xshaffer@example.com');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (7, 'Justin', 'Baker', 'User', 'whitney54@example.org');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (8, 'Theresa', 'Moore', 'User', 'ntaylor@example.net');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (9, 'Jennifer', 'Farmer', 'Admin', 'yangnancy@example.com');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (10, 'Stephanie', 'Miller', 'User', 'agolden@example.net');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (11, 'Rebecca', 'Martin', 'User', 'vbrady@example.net');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (12, 'Beth', 'Martin', 'Admin', 'kingjodi@example.com');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (13, 'Rachel', 'Chen', 'Admin', 'thompsonjeffrey@example.net');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (14, 'James', 'Edwards', 'Manager', 'zmckinney@example.com');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (15, 'Susan', 'Garza', 'Manager', 'jennifer27@example.com');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (16, 'Dawn', 'Heath', 'User', 'kyle86@example.net');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (17, 'Gregory', 'Richard', 'Manager', 'lisawarren@example.com');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (18, 'Ryan', 'Dunn', 'Admin', 'jmiller@example.com');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (19, 'Michelle', 'Daugherty', 'User', 'zwalker@example.com');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (20, 'Christopher', 'Washington', 'Manager', 'tlee@example.com');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (21, 'Taylor', 'Kim', 'User', 'andre43@example.net');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (22, 'Christopher', 'Sherman', 'Manager', 'qwalker@example.org');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (23, 'Sharon', 'Smith', 'User', 'christopher68@example.com');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (24, 'Jeffrey', 'Hawkins', 'Admin', 'christinelindsey@example.org');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (25, 'Ashley', 'Tran', 'Manager', 'parksshawn@example.net');

-- 2. location
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (1, 'Holy See (Vatican City State)', 'Rhode Island', 'Willisland', 5899, -26, -1);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (2, 'Hong Kong', 'Alabama', 'New Michaelfurt', 6155, 116, -59);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (3, 'Sierra Leone', 'Maryland', 'Bairdview', 7393, -3, -72);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (4, 'French Guiana', 'Illinois', 'New Jeffrey', 8281, 98, 69);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (5, 'Central African Republic', 'Wisconsin', 'Lake Jasontown', 2267, 25, -49);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (6, 'Martinique', 'Maine', 'North Danielle', 3344, -162, -16);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (7, 'Barbados', 'Connecticut', 'South Debra', 7571, 174, 79);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (8, 'Turkmenistan', 'Michigan', 'North Andrewfort', 5583, -65, -28);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (9, 'Sierra Leone', 'West Virginia', 'Powersport', 7866, 37, -75);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (10, 'Italy', 'Pennsylvania', 'East Crystalfort', 8214, -57, 63);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (11, 'Micronesia', 'Montana', 'North Andre', 2998, 70, -89);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (12, 'Palestinian Territory', 'Maryland', 'Port Sharon', 9750, 108, -13);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (13, 'Zambia', 'Tennessee', 'Nicholasborough', 3658, 9, 87);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (14, 'Mali', 'New Jersey', 'West Jessicaton', 8645, 170, -20);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (15, 'Chad', 'Iowa', 'Wattston', 5913, 164, -8);

-- 3. platform
INSERT INTO platform (platform_id, name, estim_rev_per_unit) VALUES (1, 'Spotify', 0.004);
INSERT INTO platform (platform_id, name, estim_rev_per_unit) VALUES (2, 'Apple Music', 0.01);
INSERT INTO platform (platform_id, name, estim_rev_per_unit) VALUES (3, 'Tidal', 0.012);

-- 4. artist
INSERT INTO artist (artist_id, stage_name, bio, tax_id_status, artist_user_id) VALUES (1, 'hbaxter', 'Other so your determine environment partner.', 1, 1);
INSERT INTO artist (artist_id, stage_name, bio, tax_id_status, artist_user_id) VALUES (2, 'kristin61', 'See all reveal.', 1, 2);
INSERT INTO artist (artist_id, stage_name, bio, tax_id_status, artist_user_id) VALUES (3, 'hsanchez', 'Bed establish bring many claim speech.', 0, 3);
INSERT INTO artist (artist_id, stage_name, bio, tax_id_status, artist_user_id) VALUES (4, 'maxwell28', 'In chance read.', 0, 4);
INSERT INTO artist (artist_id, stage_name, bio, tax_id_status, artist_user_id) VALUES (5, 'bsullivan', 'Center half let feel those people.', 1, 5);
INSERT INTO artist (artist_id, stage_name, bio, tax_id_status, artist_user_id) VALUES (6, 'stacy91', 'Until black organization represent.', 1, 6);
INSERT INTO artist (artist_id, stage_name, bio, tax_id_status, artist_user_id) VALUES (7, 'rgrant', 'She tree fall small girl perhaps.', 0, 7);
INSERT INTO artist (artist_id, stage_name, bio, tax_id_status, artist_user_id) VALUES (8, 'qrichardson', 'Indeed return different each set.', 1, 8);
INSERT INTO artist (artist_id, stage_name, bio, tax_id_status, artist_user_id) VALUES (9, 'georgejones', 'House scientist account their weight produce.', 1, 9);
INSERT INTO artist (artist_id, stage_name, bio, tax_id_status, artist_user_id) VALUES (10, 'ashley33', 'Prevent back wish visit dinner.', 1, 10);
INSERT INTO artist (artist_id, stage_name, bio, tax_id_status, artist_user_id) VALUES (11, 'colemanjose', 'Country manager where teacher development social.', 1, 11);
INSERT INTO artist (artist_id, stage_name, bio, tax_id_status, artist_user_id) VALUES (12, 'dbeltran', 'Administration knowledge dark these.', 0, 12);

-- 5. systemLog
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (1, 0, 'Still team job allow.', 12, 3);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (2, 1, 'Increase heart level affect heavy.', 3, 3);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (3, 0, 'Law wind program.', 7, 1);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (4, 1, 'Speak most remain to unit visit force recent.', 18, 1);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (5, 1, 'Tv work box concern off senior her.', 14, 3);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (6, 1, 'Good purpose room property real sort bad.', 1, 2);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (7, 0, 'Reflect gun gun member evening.', 3, 3);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (8, 1, 'Send budget face term president.', 7, 2);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (9, 0, 'Training key card compare if.', 21, 3);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (10, 1, 'Hotel population away last.', 15, 2);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (11, 1, 'Image else meeting note voice market eight senior.', 24, 3);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (12, 0, 'Visit point generation ask.', 8, 3);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (13, 0, 'Stage teacher perform adult along whatever left.', 16, 1);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (14, 1, 'Bar show central dream choice high perform.', 3, 3);

-- 6. helpRequest
INSERT INTO helpRequest (request_id, submitted_user_id, status, description, assigned_admin_id) VALUES (1, 4, 0, 'Only need social how figure late.', 1);
INSERT INTO helpRequest (request_id, submitted_user_id, status, description, assigned_admin_id) VALUES (2, 8, 1, 'Peace we class eight key.', 2);
INSERT INTO helpRequest (request_id, submitted_user_id, status, description, assigned_admin_id) VALUES (3, 19, 0, 'Attack score hand hold tough board not.', 3);
INSERT INTO helpRequest (request_id, submitted_user_id, status, description, assigned_admin_id) VALUES (4, 24, 0, 'Then than class media picture.', 3);
INSERT INTO helpRequest (request_id, submitted_user_id, status, description, assigned_admin_id) VALUES (5, 1, 0, 'Raise story long recognize.', 3);
INSERT INTO helpRequest (request_id, submitted_user_id, status, description, assigned_admin_id) VALUES (6, 5, 1, 'Much pay call can baby.', 2);
INSERT INTO helpRequest (request_id, submitted_user_id, status, description, assigned_admin_id) VALUES (7, 22, 0, 'Trial manager send popular visit.', 2);
INSERT INTO helpRequest (request_id, submitted_user_id, status, description, assigned_admin_id) VALUES (8, 3, 0, 'Within kind American blood.', 3);
INSERT INTO helpRequest (request_id, submitted_user_id, status, description, assigned_admin_id) VALUES (9, 15, 0, 'Themselves cover TV student.', 1);

-- 7. listener
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (1, 69, 'M', 5);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (2, 38, 'F', 8);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (3, 54, 'NB', 6);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (4, 25, 'F', 1);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (5, 71, 'NB', 6);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (6, 80, 'NB', 5);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (7, 28, 'M', 13);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (8, 69, 'NB', 15);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (9, 58, 'NB', 15);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (10, 47, 'F', 9);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (11, 40, 'M', 8);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (12, 58, 'M', 3);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (13, 35, 'NB', 13);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (14, 32, 'Other', 7);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (15, 17, 'Other', 5);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (16, 37, 'NB', 11);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (17, 53, 'M', 12);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (18, 67, 'Other', 3);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (19, 39, 'M', 9);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (20, 37, 'M', 1);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (21, 30, 'F', 5);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (22, 72, 'NB', 11);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (23, 24, 'Other', 14);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (24, 78, 'Other', 3);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (25, 60, 'NB', 12);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (26, 27, 'Other', 13);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (27, 73, 'NB', 1);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (28, 32, 'Other', 5);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (29, 78, 'M', 14);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (30, 57, 'M', 2);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (31, 56, 'NB', 5);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (32, 66, 'M', 15);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (33, 37, 'F', 6);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (34, 75, 'F', 1);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (35, 48, 'F', 4);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (36, 17, 'NB', 12);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (37, 19, 'F', 5);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (38, 20, 'F', 9);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (39, 43, 'Other', 15);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (40, 67, 'F', 7);

-- 8. playlist
INSERT INTO playlist (playlist_id, name, type, p_platform_id) VALUES (1, 'Fill Mix', 'Editorial', 2);
INSERT INTO playlist (playlist_id, name, type, p_platform_id) VALUES (2, 'Themselves Mix', 'Algorithm', 2);
INSERT INTO playlist (playlist_id, name, type, p_platform_id) VALUES (3, 'There Mix', 'User', 2);
INSERT INTO playlist (playlist_id, name, type, p_platform_id) VALUES (4, 'Full Mix', 'Algorithm', 1);
INSERT INTO playlist (playlist_id, name, type, p_platform_id) VALUES (5, 'Perhaps Mix', 'Algorithm', 3);
INSERT INTO playlist (playlist_id, name, type, p_platform_id) VALUES (6, 'Open Mix', 'Editorial', 3);
INSERT INTO playlist (playlist_id, name, type, p_platform_id) VALUES (7, 'Could Mix', 'Editorial', 1);
INSERT INTO playlist (playlist_id, name, type, p_platform_id) VALUES (8, 'Pm Mix', 'Algorithm', 1);
INSERT INTO playlist (playlist_id, name, type, p_platform_id) VALUES (9, 'Family Mix', 'Editorial', 1);

-- 9. `release`
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (1, 'Quality-focused even-keeled capability', 'Compilation', 'Takedown', '2026-02-07 10:21:44.264580', 11);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (2, 'Organized 24/7 complexity', 'Single', 'Approved', '2026-02-16 01:12:03.645078', 12);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (3, 'Organic upward-trending hardware', 'Album', 'Takedown', '2026-03-18 20:54:51.076330', 5);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (4, 'Configurable system-worthy concept', 'Single', 'Released', '2026-02-08 00:47:18.210981', 11);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (5, 'Cross-platform 24hour encryption', 'Compilation', 'Approved', '2026-02-05 05:26:37.639613', 2);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (6, 'Synergized impactful conglomeration', 'EP', 'Approved', '2026-04-15 15:06:59.455015', 5);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (7, 'Business-focused uniform protocol', 'EP', 'Takedown', '2026-02-14 14:19:55.095993', 9);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (8, 'Reverse-engineered coherent customer loyalty', 'Album', 'Takedown', '2026-01-16 14:31:22.130667', 9);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (9, 'Innovative interactive migration', 'Album', 'Takedown', '2026-03-28 05:02:55.633993', 9);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (10, 'Open-source analyzing ability', 'EP', 'Takedown', '2026-01-12 19:26:54.740275', 2);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (11, 'Balanced logistical middleware', 'Album', 'Approved', '2026-01-02 17:26:43.481191', 11);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (12, 'Polarized exuding info-mediaries', 'EP', 'Approved', '2026-01-06 01:19:32.535197', 8);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (13, 'Proactive background throughput', 'Single', 'Processing', '2026-02-03 01:26:00.012900', 7);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (14, 'Switchable scalable implementation', 'EP', 'Takedown', '2026-04-10 23:13:17.696508', 10);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (15, 'Sharable incremental middleware', 'Single', 'Approved', '2026-01-23 08:45:24.391859', 4);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (16, 'Up-sized multimedia methodology', 'EP', 'Approved', '2026-01-12 01:28:38.786378', 3);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (17, 'Cross-platform responsive circuit', 'Single', 'Processing', '2026-01-31 18:56:14.290039', 12);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (18, 'Programmable executive process improvement', 'EP', 'Approved', '2026-01-30 04:13:44.390325', 1);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (19, 'Exclusive coherent encoding', 'EP', 'Approved', '2026-03-22 09:19:22.164347', 8);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (20, 'Open-architected interactive application', 'EP', 'Released', '2026-03-10 08:29:34.565576', 7);

-- 10. manages
INSERT INTO manages (manages_user_id, manages_artist_id) VALUES (1, 1);
INSERT INTO manages (manages_user_id, manages_artist_id) VALUES (2, 2);
INSERT INTO manages (manages_user_id, manages_artist_id) VALUES (3, 3);
INSERT INTO manages (manages_user_id, manages_artist_id) VALUES (4, 4);
INSERT INTO manages (manages_user_id, manages_artist_id) VALUES (5, 5);
INSERT INTO manages (manages_user_id, manages_artist_id) VALUES (6, 6);
INSERT INTO manages (manages_user_id, manages_artist_id) VALUES (7, 7);
INSERT INTO manages (manages_user_id, manages_artist_id) VALUES (8, 8);
INSERT INTO manages (manages_user_id, manages_artist_id) VALUES (9, 9);
INSERT INTO manages (manages_user_id, manages_artist_id) VALUES (10, 10);
INSERT INTO manages (manages_user_id, manages_artist_id) VALUES (11, 11);
INSERT INTO manages (manages_user_id, manages_artist_id) VALUES (12, 12);

-- 11. track
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (1, 'Redefine Frictionless Solutions', 'Pop', 'ZK2141859379', 3, 17);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (2, 'Harness Distributed Info-Mediaries', 'Pop', 'PW8192246614', 3, 6);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (3, 'Drive 24/7 Synergies', 'Pop', 'US5093627500', 5, 12);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (4, 'Strategize Dot-Com E-Markets', 'Lo-Fi', 'ND1137508907', 5, 17);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (5, 'E-Enable Web-Enabled Schemas', 'Pop', 'YD4266227891', 3, 11);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (6, 'Enhance B2C Web Services', 'Rock', 'KS0793668763', 7, 7);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (7, 'Disintermediate Leading-Edge Systems', 'Lo-Fi', 'AU3391561296', 6, 18);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (8, 'Grow World-Class Web Services', 'Pop', 'MN0805338660', 9, 10);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (9, 'Matrix Revolutionary Info-Mediaries', 'Lo-Fi', 'OH5290348656', 12, 7);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (10, 'Embrace Ubiquitous E-Markets', 'Pop', 'UX9954301121', 4, 13);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (11, 'Evolve Interactive Paradigms', 'Lo-Fi', 'MB3395132273', 11, 14);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (12, 'Matrix Front-End Content', 'Pop', 'UW7071885404', 3, 7);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (13, 'Cultivate Visionary Convergence', 'Rock', 'GT4932257974', 3, 1);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (14, 'Re-Intermediate Revolutionary Initiatives', 'Pop', 'PR5124763679', 4, 20);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (15, 'Matrix Proactive Roi', 'Lo-Fi', 'FE0926768619', 6, 17);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (16, 'E-Enable Revolutionary Paradigms', 'Rock', 'IL9651594486', 4, 6);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (17, 'Productize Innovative Technologies', 'Lo-Fi', 'UC9038623904', 1, 2);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (18, 'Aggregate Ubiquitous Channels', 'Pop', 'ST3393231319', 4, 5);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (19, 'Enable B2C E-Business', 'Rock', 'KE0568816805', 2, 12);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (20, 'Re-Contextualize B2B Deliverables', 'Pop', 'OU6371714818', 1, 15);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (21, 'Harness Frictionless Metrics', 'Pop', 'FQ3173634953', 3, 6);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (22, 'Productize Customized Web-Readiness', 'Rock', 'CX9537185409', 10, 1);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (23, 'Generate Synergistic Technologies', 'Rock', 'DM8736897320', 8, 3);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (24, 'Re-Intermediate Plug-And-Play Functionalities', 'Pop', 'AL1599249287', 9, 2);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (25, 'Incentivize Enterprise Eyeballs', 'Rock', 'UY9657063240', 2, 5);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (26, 'Re-Contextualize Collaborative Web-Readiness', 'Lo-Fi', 'OZ0847917069', 12, 18);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (27, 'Deliver Wireless Web Services', 'Pop', 'SX6142567471', 5, 20);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (28, 'Leverage User-Centric Applications', 'Lo-Fi', 'BD5142902124', 2, 15);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (29, 'Generate Dynamic Web-Readiness', 'Pop', 'BG9919878782', 2, 8);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (30, 'Transition Next-Generation Initiatives', 'Lo-Fi', 'TV7718074048', 3, 10);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (31, 'Disintermediate Cutting-Edge Synergies', 'Lo-Fi', 'QH9900608694', 12, 19);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (32, 'Strategize Out-Of-The-Box Users', 'Lo-Fi', 'LK3069366298', 3, 14);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (33, 'Strategize Innovative Platforms', 'Lo-Fi', 'XY3762944669', 8, 7);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (34, 'Matrix Mission-Critical Systems', 'Pop', 'DA2511217095', 1, 4);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (35, 'Leverage Bleeding-Edge Content', 'Pop', 'ML6220565715', 12, 20);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (36, 'Expedite Dot-Com E-Tailers', 'Lo-Fi', 'NR9676044044', 5, 4);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (37, 'Empower Vertical E-Business', 'Lo-Fi', 'FF4853104663', 6, 9);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (38, 'Unleash One-To-One Channels', 'Pop', 'TZ2198967563', 7, 10);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (39, 'Grow Synergistic Niches', 'Lo-Fi', 'OQ0174637637', 5, 11);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (40, 'Re-Intermediate Strategic Portals', 'Pop', 'HO6731787316', 2, 13);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (41, 'Synthesize Enterprise Solutions', 'Lo-Fi', 'MZ6505644861', 10, 5);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (42, 'Deploy Seamless Info-Mediaries', 'Lo-Fi', 'BV6562994626', 8, 1);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (43, 'Engineer Next-Generation Channels', 'Pop', 'EA8115694199', 10, 19);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (44, 'Reinvent 24/365 Models', 'Lo-Fi', 'LF7211872598', 4, 20);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (45, 'Orchestrate Plug-And-Play Action-Items', 'Lo-Fi', 'KL5455450848', 1, 11);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (46, 'Maximize Revolutionary Functionalities', 'Pop', 'FP2645823848', 3, 12);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (47, 'Generate Dot-Com Bandwidth', 'Pop', 'BX1298624128', 7, 16);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (48, 'Grow Rich Platforms', 'Rock', 'BE3210213330', 4, 15);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (49, 'Productize Enterprise Technologies', 'Rock', 'NY0838511235', 7, 2);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (50, 'Brand Web-Enabled Channels', 'Lo-Fi', 'ZE0809887903', 4, 3);

-- 12. financialReport
INSERT INTO financialReport (freport_id, start_period, end_period, fr_release_id) VALUES (1, '2026-01-01 00:00:00', '2026-03-31 23:59:59', 17);
INSERT INTO financialReport (freport_id, start_period, end_period, fr_release_id) VALUES (2, '2026-01-01 00:00:00', '2026-03-31 23:59:59', 19);
INSERT INTO financialReport (freport_id, start_period, end_period, fr_release_id) VALUES (3, '2026-01-01 00:00:00', '2026-03-31 23:59:59', 8);
INSERT INTO financialReport (freport_id, start_period, end_period, fr_release_id) VALUES (4, '2026-01-01 00:00:00', '2026-03-31 23:59:59', 12);
INSERT INTO financialReport (freport_id, start_period, end_period, fr_release_id) VALUES (5, '2026-01-01 00:00:00', '2026-03-31 23:59:59', 10);
INSERT INTO financialReport (freport_id, start_period, end_period, fr_release_id) VALUES (6, '2026-01-01 00:00:00', '2026-03-31 23:59:59', 13);
INSERT INTO financialReport (freport_id, start_period, end_period, fr_release_id) VALUES (7, '2026-01-01 00:00:00', '2026-03-31 23:59:59', 10);
INSERT INTO financialReport (freport_id, start_period, end_period, fr_release_id) VALUES (8, '2026-01-01 00:00:00', '2026-03-31 23:59:59', 8);
INSERT INTO financialReport (freport_id, start_period, end_period, fr_release_id) VALUES (9, '2026-01-01 00:00:00', '2026-03-31 23:59:59', 12);

-- 13. asset
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (1, 'http://www.rogers.biz/', 'Credits', 1, 12);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (2, 'http://roberts-ward.net/', 'Audio', 1, 9);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (3, 'http://www.brooks.com/', 'Artwork', 1, 15);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (4, 'http://www.hood-guzman.biz/', 'Audio', 1, 17);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (5, 'http://www.orozco.com/', 'Credits', 1, 10);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (6, 'https://www.young.biz/', 'Credits', 1, 4);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (7, 'https://franklin.org/', 'Artwork', 1, 10);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (8, 'http://www.bailey.com/', 'Audio', 1, 11);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (9, 'http://www.nelson.com/', 'Audio', 1, 20);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (10, 'http://www.acevedo-sparks.com/', 'Credits', 1, 19);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (11, 'https://rodriguez.org/', 'Credits', 1, 15);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (12, 'http://www.chang.com/', 'Credits', 1, 5);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (13, 'https://holt.com/', 'Credits', 1, 18);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (14, 'https://smith.com/', 'Audio', 1, 4);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (15, 'http://www.grant-schroeder.com/', 'Artwork', 1, 15);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (16, 'http://hartman.com/', 'Artwork', 1, 5);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (17, 'https://www.phillips.org/', 'Artwork', 1, 6);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (18, 'http://johnson-brennan.org/', 'Audio', 1, 15);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (19, 'https://reynolds.com/', 'Credits', 1, 1);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (20, 'https://www.allen-robinson.com/', 'Artwork', 1, 17);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (21, 'https://www.galvan.biz/', 'Artwork', 1, 5);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (22, 'https://brooks.com/', 'Credits', 1, 2);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (23, 'http://www.hanson-hansen.biz/', 'Credits', 1, 2);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (24, 'http://bonilla-blackwell.com/', 'Audio', 1, 10);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (25, 'https://cowan.com/', 'Credits', 1, 17);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (26, 'http://www.mooney.com/', 'Artwork', 1, 16);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (27, 'https://fry.biz/', 'Audio', 1, 16);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (28, 'https://greene.com/', 'Audio', 1, 13);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (29, 'http://www.hamilton-gentry.com/', 'Artwork', 1, 19);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (30, 'http://www.dean.com/', 'Audio', 1, 1);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (31, 'http://www.thomas-george.com/', 'Audio', 1, 14);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (32, 'http://www.clark.com/', 'Artwork', 1, 20);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (33, 'http://smith.biz/', 'Audio', 1, 12);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (34, 'https://www.king.com/', 'Audio', 1, 8);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (35, 'http://www.morales-parker.com/', 'Artwork', 1, 19);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (36, 'http://www.edwards-morris.com/', 'Artwork', 1, 8);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (37, 'http://horton.biz/', 'Audio', 1, 7);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (38, 'http://newton.com/', 'Artwork', 1, 17);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (39, 'https://stephens-ferguson.com/', 'Credits', 1, 7);

-- 14. payoutProfiles
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (1, 'usmall@example.com', 'Producer', 50.00, 1);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (2, 'iperez@example.com', 'Producer', 50.00, 2);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (3, 'briannataylor@example.com', 'Producer', 50.00, 3);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (4, 'stephenwoods@example.com', 'Producer', 50.00, 4);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (5, 'jacobmoran@example.org', 'Producer', 50.00, 5);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (6, 'sreynolds@example.com', 'Producer', 50.00, 6);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (7, 'ronnie33@example.com', 'Producer', 50.00, 7);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (8, 'ebrown@example.com', 'Producer', 50.00, 8);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (9, 'lisa00@example.org', 'Producer', 50.00, 9);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (10, 'kaitlyngonzalez@example.net', 'Producer', 50.00, 10);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (11, 'smithmark@example.com', 'Producer', 50.00, 11);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (12, 'dtorres@example.com', 'Producer', 50.00, 12);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (13, 'johnsonrobert@example.org', 'Producer', 50.00, 13);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (14, 'jillian95@example.com', 'Producer', 50.00, 14);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (15, 'nathanmurphy@example.net', 'Producer', 50.00, 15);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (16, 'victoria69@example.net', 'Producer', 50.00, 16);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (17, 'richard18@example.org', 'Producer', 50.00, 17);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (18, 'alan21@example.org', 'Producer', 50.00, 18);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (19, 'davisyolanda@example.org', 'Producer', 50.00, 19);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (20, 'ingramgregory@example.org', 'Producer', 50.00, 20);

-- 15. streamEvent
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (1, '2026-03-18 17:20:58.765937', 1, 0.01, 37, 50, 2, 10);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (2, '2026-03-23 17:30:17.293655', 1, 0.004, 12, 5, 1, 1);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (3, '2026-03-31 22:01:27.788828', 0, 0.012, 29, 41, 3, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (4, '2026-04-16 07:15:25.489447', 0, 0.004, 6, 35, 1, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (5, '2026-03-27 09:14:38.982109', 0, 0.004, 2, 1, 1, 7);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (6, '2026-03-29 16:16:24.263364', 0, 0.004, 2, 40, 1, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (7, '2026-04-16 12:43:29.804660', 0, 0.012, 21, 44, 3, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (8, '2026-04-06 13:51:38.354300', 1, 0.004, 1, 41, 1, 1);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (9, '2026-03-30 12:49:32.948657', 1, 0.01, 1, 18, 2, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (10, '2026-03-19 02:43:22.134553', 0, 0.01, 31, 26, 2, 7);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (11, '2026-04-15 19:20:19.127255', 1, 0.012, 36, 47, 3, 2);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (12, '2026-03-30 06:46:39.776547', 1, 0.004, 8, 43, 1, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (13, '2026-03-27 18:39:56.050032', 0, 0.01, 1, 30, 2, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (14, '2026-04-09 03:24:57.616122', 0, 0.012, 32, 45, 3, 13);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (15, '2026-04-02 03:10:44.078006', 1, 0.01, 2, 50, 2, 12);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (16, '2026-03-28 17:57:30.089435', 1, 0.012, 12, 39, 3, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (17, '2026-03-27 04:14:36.626771', 1, 0.004, 17, 7, 1, 12);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (18, '2026-04-12 12:43:09.409573', 1, 0.01, 38, 50, 2, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (19, '2026-03-22 12:26:09.149994', 1, 0.004, 35, 17, 1, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (20, '2026-04-13 17:27:44.754049', 1, 0.012, 3, 3, 3, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (21, '2026-04-06 05:02:20.770030', 1, 0.004, 22, 28, 1, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (22, '2026-03-18 14:27:02.177068', 1, 0.012, 13, 25, 3, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (23, '2026-04-16 05:23:44.921364', 1, 0.01, 26, 19, 2, 7);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (24, '2026-04-02 20:18:31.497781', 0, 0.012, 37, 43, 3, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (25, '2026-04-06 13:21:17.288144', 0, 0.012, 22, 11, 3, 7);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (26, '2026-04-11 08:50:37.844120', 1, 0.004, 36, 18, 1, 12);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (27, '2026-03-19 09:15:34.494035', 1, 0.01, 39, 15, 2, 13);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (28, '2026-03-30 06:43:06.173172', 1, 0.012, 1, 21, 3, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (29, '2026-04-16 15:39:09.867249', 1, 0.012, 2, 46, 3, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (30, '2026-03-27 11:15:32.808514', 1, 0.004, 24, 30, 1, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (31, '2026-03-30 00:11:27.625740', 0, 0.01, 39, 8, 2, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (32, '2026-03-20 07:45:06.741769', 1, 0.012, 12, 6, 3, 4);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (33, '2026-03-23 10:16:09.083874', 1, 0.01, 40, 49, 2, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (34, '2026-03-24 19:42:35.814443', 1, 0.01, 10, 8, 2, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (35, '2026-03-29 13:38:45.879483', 1, 0.01, 6, 2, 2, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (36, '2026-04-06 09:01:50.353637', 1, 0.012, 39, 36, 3, 6);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (37, '2026-04-15 13:57:25.094503', 1, 0.01, 2, 47, 2, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (38, '2026-04-05 19:11:29.533195', 0, 0.012, 12, 46, 3, 4);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (39, '2026-03-20 18:41:10.566900', 1, 0.004, 27, 22, 1, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (40, '2026-04-06 12:57:45.520148', 1, 0.004, 27, 40, 1, 1);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (41, '2026-04-08 10:23:25.351510', 1, 0.004, 23, 19, 1, 1);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (42, '2026-03-28 03:58:32.900073', 1, 0.012, 1, 22, 3, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (43, '2026-03-28 23:14:32.788178', 0, 0.01, 14, 14, 2, 4);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (44, '2026-04-02 09:17:16.121816', 1, 0.004, 31, 39, 1, 12);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (45, '2026-04-05 20:03:49.388574', 0, 0.004, 2, 48, 1, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (46, '2026-04-08 15:37:43.679536', 0, 0.01, 1, 49, 2, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (47, '2026-04-02 12:38:01.277203', 0, 0.01, 24, 11, 2, 7);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (48, '2026-03-25 12:51:34.306690', 0, 0.004, 2, 12, 1, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (49, '2026-03-21 15:28:59.153030', 1, 0.012, 2, 8, 3, 1);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (50, '2026-03-20 00:30:09.670401', 1, 0.01, 34, 45, 2, 10);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (51, '2026-03-19 18:11:43.985258', 1, 0.01, 18, 40, 2, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (52, '2026-03-27 12:12:07.213653', 0, 0.012, 31, 3, 3, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (53, '2026-04-09 00:20:36.691721', 1, 0.012, 13, 17, 3, 7);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (54, '2026-03-18 14:28:44.472196', 1, 0.004, 15, 32, 1, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (55, '2026-03-21 23:21:05.291734', 0, 0.01, 8, 8, 2, 6);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (56, '2026-04-11 19:56:36.801418', 1, 0.012, 21, 17, 3, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (57, '2026-03-31 04:06:20.100658', 0, 0.012, 4, 17, 3, 1);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (58, '2026-04-02 00:51:29.969049', 1, 0.012, 6, 16, 3, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (59, '2026-03-31 14:34:14.262881', 0, 0.012, 10, 13, 3, 4);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (60, '2026-04-07 00:03:59.251627', 0, 0.004, 21, 7, 1, 12);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (61, '2026-04-09 04:00:55.334276', 1, 0.004, 3, 46, 1, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (62, '2026-03-29 16:16:44.472431', 1, 0.004, 5, 40, 1, 6);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (63, '2026-03-30 18:46:37.750256', 0, 0.012, 18, 24, 3, 12);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (64, '2026-03-27 12:38:36.636979', 1, 0.004, 13, 8, 1, 13);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (65, '2026-04-14 10:17:17.231738', 0, 0.012, 8, 22, 3, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (66, '2026-03-25 00:55:08.225079', 0, 0.012, 3, 42, 3, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (67, '2026-04-04 20:00:27.571077', 0, 0.004, 15, 28, 1, 4);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (68, '2026-03-19 23:23:48.074995', 0, 0.012, 20, 13, 3, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (69, '2026-04-03 22:21:42.064763', 0, 0.012, 35, 34, 3, 12);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (70, '2026-03-28 12:16:13.397974', 0, 0.012, 29, 43, 3, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (71, '2026-04-10 17:36:18.508622', 0, 0.012, 1, 23, 3, 10);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (72, '2026-03-26 23:48:27.613667', 0, 0.012, 37, 44, 3, 12);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (73, '2026-03-25 09:02:56.357988', 0, 0.01, 18, 12, 2, 1);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (74, '2026-03-22 11:03:26.411452', 0, 0.004, 37, 28, 1, 6);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (75, '2026-04-07 23:08:39.004331', 0, 0.004, 24, 12, 1, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (76, '2026-04-11 16:56:10.220574', 0, 0.004, 3, 7, 1, 2);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (77, '2026-04-08 23:07:44.503286', 1, 0.012, 38, 44, 3, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (78, '2026-04-15 23:58:26.790878', 0, 0.012, 34, 45, 3, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (79, '2026-03-21 23:44:35.339398', 1, 0.004, 33, 12, 1, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (80, '2026-03-26 14:44:43.348836', 0, 0.012, 6, 49, 3, 1);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (81, '2026-04-01 07:43:45.290853', 1, 0.004, 36, 32, 1, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (82, '2026-03-23 21:45:59.100740', 1, 0.01, 36, 14, 2, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (83, '2026-03-29 06:47:42.596818', 0, 0.012, 38, 18, 3, 9);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (84, '2026-04-16 07:07:26.072544', 0, 0.004, 14, 12, 1, 6);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (85, '2026-04-08 01:57:40.813007', 0, 0.004, 35, 47, 1, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (86, '2026-04-07 23:26:29.633889', 1, 0.01, 12, 43, 2, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (87, '2026-04-09 16:12:56.914979', 1, 0.01, 40, 25, 2, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (88, '2026-03-23 10:17:54.868419', 1, 0.004, 17, 21, 1, 9);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (89, '2026-03-31 15:38:23.912688', 0, 0.012, 25, 32, 3, 6);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (90, '2026-04-16 01:48:44.884189', 1, 0.01, 22, 33, 2, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (91, '2026-03-21 00:08:27.916255', 1, 0.004, 28, 13, 1, 4);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (92, '2026-04-06 23:20:08.276400', 0, 0.01, 7, 3, 2, 4);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (93, '2026-04-10 08:16:45.673960', 1, 0.01, 32, 36, 2, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (94, '2026-03-29 19:54:21.069227', 1, 0.012, 22, 45, 3, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (95, '2026-03-23 17:52:24.016121', 0, 0.004, 7, 40, 1, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (96, '2026-03-22 22:45:40.039819', 1, 0.004, 29, 15, 1, 1);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (97, '2026-03-21 14:40:17.572683', 1, 0.012, 13, 50, 3, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (98, '2026-03-31 15:02:02.955647', 0, 0.012, 11, 6, 3, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (99, '2026-03-18 17:38:25.130507', 1, 0.004, 13, 37, 1, 9);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (100, '2026-04-07 20:51:02.693367', 1, 0.01, 40, 25, 2, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (101, '2026-04-06 10:34:54.191787', 1, 0.01, 25, 42, 2, 12);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (102, '2026-03-21 05:48:28.978040', 0, 0.01, 12, 7, 2, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (103, '2026-04-04 17:19:40.725543', 1, 0.012, 3, 42, 3, 10);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (104, '2026-03-28 15:59:15.867181', 0, 0.004, 15, 32, 1, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (105, '2026-03-24 21:21:30.702912', 0, 0.012, 22, 27, 3, 6);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (106, '2026-04-14 17:23:36.203001', 0, 0.01, 40, 47, 2, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (107, '2026-03-22 16:14:27.788474', 1, 0.012, 24, 40, 3, 9);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (108, '2026-04-15 12:32:14.041689', 0, 0.004, 6, 29, 1, 2);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (109, '2026-04-08 05:08:14.097718', 0, 0.012, 19, 27, 3, 1);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (110, '2026-03-23 00:25:23.264396', 0, 0.01, 28, 7, 2, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (111, '2026-04-02 13:47:06.514094', 1, 0.004, 32, 43, 1, 4);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (112, '2026-04-11 23:46:23.785433', 0, 0.01, 11, 15, 2, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (113, '2026-03-20 14:01:43.785564', 1, 0.01, 34, 26, 2, 13);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (114, '2026-04-05 01:50:33.807501', 1, 0.004, 8, 40, 1, 1);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (115, '2026-04-12 13:17:51.273519', 1, 0.004, 26, 50, 1, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (116, '2026-04-16 08:24:46.300183', 1, 0.012, 12, 36, 3, 4);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (117, '2026-03-25 01:02:32.509961', 1, 0.01, 12, 9, 2, 6);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (118, '2026-04-04 06:56:06.343802', 1, 0.004, 15, 15, 1, 6);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (119, '2026-04-14 07:05:20.520881', 0, 0.012, 13, 50, 3, 10);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (120, '2026-03-28 22:01:21.913772', 0, 0.004, 17, 37, 1, 12);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (121, '2026-03-19 05:29:51.068509', 1, 0.01, 31, 11, 2, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (122, '2026-04-10 17:35:30.343791', 1, 0.01, 33, 18, 2, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (123, '2026-04-12 02:31:28.778748', 0, 0.01, 32, 43, 2, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (124, '2026-04-12 16:39:24.939893', 0, 0.01, 9, 49, 2, 2);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (125, '2026-03-25 12:40:37.193687', 0, 0.004, 7, 28, 1, 9);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (126, '2026-03-31 19:44:00.672141', 0, 0.004, 9, 26, 1, 9);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (127, '2026-04-02 20:18:20.493993', 0, 0.012, 29, 41, 3, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (128, '2026-04-14 17:51:03.249464', 0, 0.01, 1, 50, 2, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (129, '2026-04-11 12:06:25.370243', 0, 0.01, 38, 13, 2, 9);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (130, '2026-03-29 12:08:28.595851', 0, 0.004, 20, 30, 1, 4);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (131, '2026-03-27 03:49:54.599002', 0, 0.004, 9, 42, 1, 10);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (132, '2026-03-26 23:57:45.750555', 1, 0.01, 39, 33, 2, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (133, '2026-03-30 22:45:25.092006', 1, 0.01, 24, 5, 2, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (134, '2026-03-26 02:44:04.288501', 0, 0.012, 5, 50, 3, 4);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (135, '2026-03-23 04:40:17.639767', 1, 0.012, 26, 22, 3, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (136, '2026-04-10 00:40:05.107635', 1, 0.004, 1, 3, 1, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (137, '2026-04-02 02:43:37.139140', 1, 0.012, 29, 49, 3, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (138, '2026-04-07 14:17:48.195328', 1, 0.012, 39, 7, 3, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (139, '2026-04-03 00:18:32.949926', 1, 0.01, 34, 7, 2, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (140, '2026-04-05 07:08:40.420189', 0, 0.004, 11, 46, 1, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (141, '2026-04-09 02:07:13.361628', 0, 0.004, 19, 40, 1, 2);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (142, '2026-03-27 20:47:11.908678', 1, 0.004, 27, 2, 1, 1);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (143, '2026-04-01 06:47:37.409818', 0, 0.01, 3, 30, 2, 13);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (144, '2026-04-08 14:33:56.498870', 1, 0.004, 9, 7, 1, 1);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (145, '2026-04-01 21:04:53.677943', 1, 0.01, 13, 44, 2, 9);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (146, '2026-04-12 03:38:15.991239', 1, 0.012, 40, 47, 3, 12);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (147, '2026-03-25 04:44:38.803866', 0, 0.01, 36, 4, 2, 6);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (148, '2026-04-15 15:49:44.914253', 1, 0.004, 24, 47, 1, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (149, '2026-04-15 10:32:40.871757', 0, 0.004, 31, 26, 1, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (150, '2026-03-28 05:49:49.513438', 1, 0.01, 22, 16, 2, 12);

-- 16. playlistEvent
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (121, 8);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (1, 9);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (117, 6);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (27, 1);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (84, 7);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (51, 8);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (99, 2);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (125, 5);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (8, 3);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (115, 3);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (146, 3);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (75, 4);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (139, 4);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (80, 6);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (25, 7);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (29, 5);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (89, 9);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (90, 3);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (92, 6);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (96, 4);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (138, 2);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (149, 2);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (54, 2);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (137, 3);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (114, 3);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (141, 1);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (94, 5);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (65, 8);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (44, 9);

SET FOREIGN_KEY_CHECKS = 1;
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
  role              ENUM('User', 'Admin', 'Label Head', 'Data Analyst') DEFAULT 'User',
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
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (1, 'Gary', 'Mitchell', 'Admin', 'marcus81@example.org');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (2, 'Joel', 'Castillo', 'Label Head', 'hamiltonbrian@example.com');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (3, 'Joel', 'Marshall', 'Label Head', 'ojones@example.net');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (4, 'Eric', 'Stewart', 'Label Head', 'xwalker@example.org');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (5, 'Cody', 'Lopez', 'User', 'vosborne@example.com');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (6, 'Mark', 'Brown', 'User', 'lisa11@example.net');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (7, 'Ethan', 'Bowen', 'Data Analyst', 'jacob73@example.net');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (8, 'Sara', 'Kane', 'Label Head', 'bwilliams@example.com');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (9, 'Robert', 'Baker', 'User', 'lori12@example.net');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (10, 'Brenda', 'Frederick', 'Label Head', 'larrygrant@example.org');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (11, 'Barry', 'Smith', 'Data Analyst', 'tuckertiffany@example.org');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (12, 'Carlos', 'Hughes', 'Admin', 'toddbrad@example.net');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (13, 'Aaron', 'Taylor', 'Data Analyst', 'tiffany34@example.org');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (14, 'Katherine', 'Price', 'Data Analyst', 'kimvictor@example.net');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (15, 'Donald', 'Burton', 'User', 'jesusmitchell@example.com');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (16, 'Jeffery', 'Robertson', 'Label Head', 'smithnathan@example.net');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (17, 'Kelly', 'Mack', 'Label Head', 'frybrian@example.net');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (18, 'Alfred', 'Briggs', 'Label Head', 'juanknight@example.com');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (19, 'Carla', 'Brown', 'Admin', 'valenciamichael@example.com');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (20, 'Brittany', 'Smith', 'Label Head', 'christine05@example.net');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (21, 'Jose', 'Brown', 'Admin', 'george21@example.org');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (22, 'Jessica', 'Rojas', 'User', 'simstammy@example.net');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (23, 'Thomas', 'Edwards', 'Admin', 'mbarnes@example.net');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (24, 'Ryan', 'Ramirez', 'Label Head', 'upatterson@example.com');
INSERT INTO `user` (user_id, first_name, last_name, role, email) VALUES (25, 'James', 'Peters', 'Data Analyst', 'hduffy@example.com');

-- 2. location
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (1, 'Fiji', 'New York', 'Bondstad', 2625, -154, -18);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (2, 'Lithuania', 'Michigan', 'Mariaton', 2421, -23, 53);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (3, 'Guyana', 'Georgia', 'Lopezside', 6331, -108, -52);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (4, 'Tanzania', 'Florida', 'East Rayfurt', 2633, 37, 30);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (5, 'Lebanon', 'Delaware', 'Tarafort', 2139, -31, -83);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (6, 'Papua New Guinea', 'New York', 'Lake Mistyview', 8317, 60, -80);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (7, 'Saint Lucia', 'West Virginia', 'Sallyton', 9586, -126, 29);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (8, 'Dominica', 'Nevada', 'Hawkinsborough', 5555, 123, 21);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (9, 'Austria', 'Massachusetts', 'Kennethberg', 6207, -77, -29);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (10, 'Nigeria', 'South Carolina', 'Petersonview', 7774, 162, -60);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (11, 'Vietnam', 'Iowa', 'South David', 6785, 69, 57);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (12, 'Chile', 'Hawaii', 'Lambertland', 8088, 9, 90);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (13, 'Cuba', 'Oregon', 'South Morganburgh', 4777, -167, 39);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (14, 'Mayotte', 'Michigan', 'Brendanshire', 5123, 135, 88);
INSERT INTO location (location_id, country, region_state, city, postal_code, longitude, latitude) VALUES (15, 'Senegal', 'Tennessee', 'East Shane', 8631, -30, 89);

-- 3. platform
INSERT INTO platform (platform_id, name, estim_rev_per_unit) VALUES (1, 'Spotify', 0.004);
INSERT INTO platform (platform_id, name, estim_rev_per_unit) VALUES (2, 'Apple Music', 0.01);
INSERT INTO platform (platform_id, name, estim_rev_per_unit) VALUES (3, 'Tidal', 0.012);

-- 4. artist
INSERT INTO artist (artist_id, stage_name, bio, tax_id_status, artist_user_id) VALUES (1, 'burkejay', 'Bed issue space crime the time already.', 0, 1);
INSERT INTO artist (artist_id, stage_name, bio, tax_id_status, artist_user_id) VALUES (2, 'mkelley', 'Usually myself home return.', 0, 2);
INSERT INTO artist (artist_id, stage_name, bio, tax_id_status, artist_user_id) VALUES (3, 'kimhernandez', 'Green side response trouble field rock usually.', 0, 3);
INSERT INTO artist (artist_id, stage_name, bio, tax_id_status, artist_user_id) VALUES (4, 'umitchell', 'End trial prevent.', 0, 4);
INSERT INTO artist (artist_id, stage_name, bio, tax_id_status, artist_user_id) VALUES (5, 'aliciaanderson', 'Movie chance all institution beat.', 0, 5);

-- 5. systemLog
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (1, 1, 'Understand notice chance throughout pick have look.', 2, 1);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (2, 0, 'First wind pick.', 6, 2);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (3, 0, 'Trade forward some.', 4, 2);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (4, 1, 'Chance sense trouble like.', 10, 1);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (5, 1, 'Movement process guy option son network.', 16, 3);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (6, 0, 'Technology point front answer grow term name.', 4, 3);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (7, 0, 'Table dinner meet.', 15, 1);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (8, 0, 'Small never something science focus something.', 8, 1);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (9, 0, 'Wish require call policy night.', 23, 3);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (10, 1, 'Mrs lot protect economy.', 7, 1);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (11, 0, 'Particularly picture agency win try note season.', 21, 1);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (12, 0, 'Production dark suffer.', 12, 2);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (13, 0, 'From dinner huge police improve.', 12, 1);
INSERT INTO systemLog (log_id, status, description, log_user_id, log_admin_id) VALUES (14, 1, 'Accept hear arrive true.', 9, 3);

-- 6. helpRequest
INSERT INTO helpRequest (request_id, submitted_user_id, status, description, assigned_admin_id) VALUES (1, 7, 0, 'Product professional body among edge old son him.', 2);
INSERT INTO helpRequest (request_id, submitted_user_id, status, description, assigned_admin_id) VALUES (2, 7, 1, 'Market security officer describe quite should bank.', 1);
INSERT INTO helpRequest (request_id, submitted_user_id, status, description, assigned_admin_id) VALUES (3, 2, 0, 'Financial a often.', 1);
INSERT INTO helpRequest (request_id, submitted_user_id, status, description, assigned_admin_id) VALUES (4, 15, 1, 'Series system leg major.', 1);
INSERT INTO helpRequest (request_id, submitted_user_id, status, description, assigned_admin_id) VALUES (5, 22, 0, 'Manage something similar because fall medical threat.', 1);
INSERT INTO helpRequest (request_id, submitted_user_id, status, description, assigned_admin_id) VALUES (6, 5, 0, 'Improve center interview positive short TV.', 2);
INSERT INTO helpRequest (request_id, submitted_user_id, status, description, assigned_admin_id) VALUES (7, 1, 1, 'Clear yourself build.', 3);
INSERT INTO helpRequest (request_id, submitted_user_id, status, description, assigned_admin_id) VALUES (8, 18, 1, 'Body industry read tell.', 1);
INSERT INTO helpRequest (request_id, submitted_user_id, status, description, assigned_admin_id) VALUES (9, 5, 0, 'Sure conference class executive.', 1);

-- 7. listener
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (1, 60, 'M', 9);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (2, 58, 'M', 11);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (3, 37, 'M', 6);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (4, 63, 'Other', 4);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (5, 53, 'NB', 8);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (6, 72, 'NB', 5);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (7, 40, 'NB', 2);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (8, 70, 'F', 10);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (9, 78, 'M', 8);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (10, 48, 'F', 11);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (11, 67, 'Other', 8);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (12, 57, 'F', 10);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (13, 54, 'F', 14);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (14, 60, 'F', 10);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (15, 35, 'M', 1);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (16, 48, 'NB', 8);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (17, 64, 'F', 13);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (18, 36, 'Other', 1);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (19, 78, 'Other', 13);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (20, 55, 'NB', 13);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (21, 14, 'Other', 9);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (22, 43, 'NB', 2);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (23, 56, 'Other', 5);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (24, 14, 'Other', 6);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (25, 15, 'M', 1);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (26, 25, 'M', 7);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (27, 62, 'F', 8);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (28, 19, 'F', 10);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (29, 45, 'F', 3);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (30, 42, 'M', 11);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (31, 70, 'F', 6);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (32, 35, 'NB', 9);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (33, 60, 'Other', 14);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (34, 30, 'Other', 4);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (35, 31, 'NB', 12);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (36, 50, 'NB', 7);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (37, 17, 'F', 8);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (38, 71, 'M', 12);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (39, 59, 'Other', 14);
INSERT INTO listener (listener_id, age, gender, listener_location_id) VALUES (40, 50, 'M', 4);

-- 8. playlist
INSERT INTO playlist (playlist_id, name, type, p_platform_id) VALUES (1, 'Vote Mix', 'Algorithm', 1);
INSERT INTO playlist (playlist_id, name, type, p_platform_id) VALUES (2, 'Station Mix', 'User', 2);
INSERT INTO playlist (playlist_id, name, type, p_platform_id) VALUES (3, 'Traditional Mix', 'User', 3);
INSERT INTO playlist (playlist_id, name, type, p_platform_id) VALUES (4, 'Stand Mix', 'Algorithm', 3);
INSERT INTO playlist (playlist_id, name, type, p_platform_id) VALUES (5, 'Memory Mix', 'Algorithm', 2);
INSERT INTO playlist (playlist_id, name, type, p_platform_id) VALUES (6, 'Piece Mix', 'Algorithm', 1);
INSERT INTO playlist (playlist_id, name, type, p_platform_id) VALUES (7, 'Fast Mix', 'Algorithm', 1);
INSERT INTO playlist (playlist_id, name, type, p_platform_id) VALUES (8, 'Charge Mix', 'Editorial', 2);
INSERT INTO playlist (playlist_id, name, type, p_platform_id) VALUES (9, 'Remember Mix', 'Algorithm', 1);

-- 9. `release`
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (1, 'Pre-emptive bottom-line success', 'Compilation', 'Takedown', '2026-01-14 06:12:21.638835', 1);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (2, 'Distributed disintermediate archive', 'Single', 'Takedown', '2026-01-28 06:05:02.648461', 5);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (3, 'Multi-channeled cohesive benchmark', 'EP', 'Processing', '2026-01-23 21:04:54.305574', 11);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (4, 'Function-based coherent firmware', 'Single', 'Approved', '2026-04-06 14:07:15.266184', 4);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (5, 'Digitized leadingedge protocol', 'Single', 'Processing', '2026-01-31 06:42:03.956467', 8);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (6, 'Triple-buffered bi-directional function', 'Compilation', 'Takedown', '2026-03-30 13:38:44.511863', 7);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (7, 'Advanced context-sensitive toolset', 'Album', 'Approved', '2026-02-21 00:41:40.029166', 11);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (8, 'Diverse regional capability', 'Album', 'Released', '2026-02-02 00:46:37.254684', 8);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (9, 'Progressive holistic service-desk', 'EP', 'Approved', '2026-03-17 06:52:43.688656', 3);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (10, 'Reactive multimedia analyzer', 'Compilation', 'Approved', '2026-02-10 06:42:08.921416', 6);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (11, 'Total transitional hardware', 'Compilation', 'Approved', '2026-03-24 19:54:10.791114', 11);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (12, 'Automated methodical secured line', 'Album', 'Approved', '2026-02-04 06:41:10.634544', 1);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (13, 'Proactive contextually-based focus group', 'Album', 'Released', '2026-02-21 01:56:18.971114', 7);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (14, 'Profit-focused motivating projection', 'EP', 'Approved', '2026-01-09 05:19:23.556654', 1);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (15, 'Versatile 6thgeneration intranet', 'Single', 'Approved', '2026-01-25 07:08:22.754785', 10);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (16, 'Upgradable non-volatile firmware', 'Album', 'Takedown', '2026-04-01 05:33:58.831128', 1);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (17, 'Cross-group foreground info-mediaries', 'EP', 'Approved', '2026-03-12 06:43:45.341260', 2);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (18, 'Innovative real-time middleware', 'Compilation', 'Processing', '2026-04-07 22:59:32.284516', 8);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (19, 'Profound leadingedge intranet', 'Album', 'Approved', '2026-03-18 21:55:09.042409', 8);
INSERT INTO `release` (rel_id, title, type, status, release_date, release_artist_id) VALUES (20, 'Ameliorated transitional secured line', 'Album', 'Released', '2026-01-02 20:26:19.317417', 12);

-- 10. manages
-- Artists managing themselves
INSERT INTO manages (manages_user_id, manages_artist_id) VALUES (5, 1);
INSERT INTO manages (manages_user_id, manages_artist_id) VALUES (6, 2);
INSERT INTO manages (manages_user_id, manages_artist_id) VALUES (9, 3);
INSERT INTO manages (manages_user_id, manages_artist_id) VALUES (15, 4);
INSERT INTO manages (manages_user_id, manages_artist_id) VALUES (22, 5);
-- Additional management assignments (No Admins)
INSERT IGNORE INTO manages (manages_user_id, manages_artist_id) VALUES (2, 1);
INSERT IGNORE INTO manages (manages_user_id, manages_artist_id) VALUES (6, 3);
INSERT IGNORE INTO manages (manages_user_id, manages_artist_id) VALUES (3, 4);
INSERT IGNORE INTO manages (manages_user_id, manages_artist_id) VALUES (2, 5);
INSERT IGNORE INTO manages (manages_user_id, manages_artist_id) VALUES (6, 5);
INSERT IGNORE INTO manages (manages_user_id, manages_artist_id) VALUES (22, 2);
INSERT IGNORE INTO manages (manages_user_id, manages_artist_id) VALUES (18, 1);
INSERT IGNORE INTO manages (manages_user_id, manages_artist_id) VALUES (9, 4);
INSERT IGNORE INTO manages (manages_user_id, manages_artist_id) VALUES (8, 1);
INSERT IGNORE INTO manages (manages_user_id, manages_artist_id) VALUES (5, 1);
INSERT IGNORE INTO manages (manages_user_id, manages_artist_id) VALUES (22, 4);
INSERT IGNORE INTO manages (manages_user_id, manages_artist_id) VALUES (22, 1);
INSERT IGNORE INTO manages (manages_user_id, manages_artist_id) VALUES (22, 4);
INSERT IGNORE INTO manages (manages_user_id, manages_artist_id) VALUES (11, 2);
INSERT IGNORE INTO manages (manages_user_id, manages_artist_id) VALUES (8, 2);

-- 11. track
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (1, 'Innovate Seamless Mindshare', 'Pop', 'UG0492923570', 8, 20);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (2, 'Visualize Open-Source E-Tailers', 'Pop', 'AD2408867484', 6, 12);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (3, 'Evolve Innovative Metrics', 'Rock', 'LN4401480959', 5, 17);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (4, 'Disintermediate Virtual Partnerships', 'Rock', 'XV2153653491', 3, 17);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (5, 'Syndicate Open-Source Partnerships', 'Lo-Fi', 'PM2786302249', 12, 2);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (6, 'Synergize Clicks-And-Mortar E-Services', 'Pop', 'XR8409902662', 4, 20);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (7, 'Monetize Best-Of-Breed Communities', 'Pop', 'GF9241371239', 12, 15);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (8, 'Target Transparent Technologies', 'Pop', 'HK4818571961', 7, 2);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (9, 'Empower Mission-Critical Partnerships', 'Rock', 'BN9421044904', 2, 6);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (10, 'Leverage Visionary E-Commerce', 'Rock', 'LP7610187528', 4, 3);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (11, 'Extend Real-Time Info-Mediaries', 'Pop', 'WM8261532437', 4, 2);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (12, 'Synthesize Clicks-And-Mortar Applications', 'Rock', 'WX4929650938', 6, 10);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (13, 'Orchestrate Virtual Synergies', 'Rock', 'ZK1693741447', 12, 19);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (14, 'Syndicate Transparent Networks', 'Pop', 'OJ8393187465', 9, 19);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (15, 'Iterate Clicks-And-Mortar Infrastructures', 'Lo-Fi', 'GT6304635980', 4, 8);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (16, 'Repurpose Granular Bandwidth', 'Rock', 'OI1669332311', 11, 18);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (17, 'Exploit Enterprise Interfaces', 'Rock', 'YB3967508543', 7, 8);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (18, 'Re-Contextualize Turn-Key Markets', 'Lo-Fi', 'NV9923372866', 3, 13);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (19, 'Aggregate E-Business Models', 'Lo-Fi', 'UH5227345311', 10, 5);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (20, 'Target 24/7 Systems', 'Pop', 'LS7394660090', 9, 20);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (21, 'Drive Best-Of-Breed Methodologies', 'Rock', 'JY6776618419', 8, 16);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (22, 'Syndicate 24/7 Interfaces', 'Rock', 'AU6962085798', 8, 14);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (23, 'Morph Revolutionary Models', 'Rock', 'KW7510594207', 7, 17);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (24, 'Enhance Vertical Deliverables', 'Pop', 'PA8578661576', 8, 8);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (25, 'Syndicate Visionary Systems', 'Pop', 'BW0212833574', 9, 1);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (26, 'Grow Plug-And-Play Info-Mediaries', 'Lo-Fi', 'GJ3961777323', 12, 5);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (27, 'Scale Dynamic Web Services', 'Rock', 'HL6303790255', 7, 5);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (28, 'Implement Efficient E-Commerce', 'Rock', 'NE1887380927', 12, 17);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (29, 'Strategize 24/365 Applications', 'Rock', 'AH3285777090', 1, 18);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (30, 'Seize Front-End E-Business', 'Pop', 'NW4290667813', 4, 16);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (31, 'Envisioneer Magnetic Metrics', 'Pop', 'NZ4765012723', 12, 5);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (32, 'Seize Collaborative E-Tailers', 'Rock', 'YC5555373747', 9, 19);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (33, 'Drive Scalable Convergence', 'Pop', 'XH7385634354', 9, 7);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (34, 'Grow Plug-And-Play Relationships', 'Pop', 'SO4948788152', 10, 1);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (35, 'Envisioneer World-Class Portals', 'Lo-Fi', 'WC3191516681', 9, 8);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (36, 'Re-Contextualize B2C Supply-Chains', 'Pop', 'JF3474203853', 5, 13);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (37, 'Mesh Dot-Com Markets', 'Rock', 'GU0392685367', 2, 20);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (38, 'Exploit Viral Platforms', 'Lo-Fi', 'QX0497879073', 9, 18);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (39, 'Grow Revolutionary Solutions', 'Lo-Fi', 'RD5786079488', 7, 9);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (40, 'Engineer Ubiquitous Vortals', 'Lo-Fi', 'RB3530520461', 2, 11);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (41, 'Brand Enterprise Users', 'Rock', 'ME3139348911', 5, 8);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (42, 'Whiteboard B2C Communities', 'Lo-Fi', 'WC9799124108', 11, 15);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (43, 'Maximize Extensible Supply-Chains', 'Pop', 'IJ5032642645', 7, 20);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (44, 'Revolutionize Vertical Interfaces', 'Lo-Fi', 'HO0674782939', 2, 2);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (45, 'Envisioneer Distributed Portals', 'Lo-Fi', 'EU6995653736', 4, 8);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (46, 'Engineer Collaborative Communities', 'Lo-Fi', 'KM7849637086', 12, 6);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (47, 'Incentivize Collaborative Portals', 'Lo-Fi', 'KQ3791802180', 5, 5);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (48, 'Engage One-To-One Deliverables', 'Rock', 'NN0843140955', 11, 1);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (49, 'Scale Plug-And-Play E-Services', 'Pop', 'DW6345722413', 9, 15);
INSERT INTO track (track_id, title, genre, isrc_code, track_artist_id, track_release_id) VALUES (50, 'Generate Plug-And-Play Relationships', 'Pop', 'LV2615912438', 1, 2);

-- 12. financialReport
INSERT INTO financialReport (freport_id, start_period, end_period, fr_release_id) VALUES (1, '2026-01-01 00:00:00', '2026-03-31 23:59:59', 9);
INSERT INTO financialReport (freport_id, start_period, end_period, fr_release_id) VALUES (2, '2026-01-01 00:00:00', '2026-03-31 23:59:59', 8);
INSERT INTO financialReport (freport_id, start_period, end_period, fr_release_id) VALUES (3, '2026-01-01 00:00:00', '2026-03-31 23:59:59', 9);
INSERT INTO financialReport (freport_id, start_period, end_period, fr_release_id) VALUES (4, '2026-01-01 00:00:00', '2026-03-31 23:59:59', 16);
INSERT INTO financialReport (freport_id, start_period, end_period, fr_release_id) VALUES (5, '2026-01-01 00:00:00', '2026-03-31 23:59:59', 16);
INSERT INTO financialReport (freport_id, start_period, end_period, fr_release_id) VALUES (6, '2026-01-01 00:00:00', '2026-03-31 23:59:59', 1);
INSERT INTO financialReport (freport_id, start_period, end_period, fr_release_id) VALUES (7, '2026-01-01 00:00:00', '2026-03-31 23:59:59', 16);
INSERT INTO financialReport (freport_id, start_period, end_period, fr_release_id) VALUES (8, '2026-01-01 00:00:00', '2026-03-31 23:59:59', 18);
INSERT INTO financialReport (freport_id, start_period, end_period, fr_release_id) VALUES (9, '2026-01-01 00:00:00', '2026-03-31 23:59:59', 11);

-- 13. asset
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (1, 'http://www.brewer-jones.com/', 'Audio', 1, 19);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (2, 'https://www.davis.com/', 'Artwork', 1, 1);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (3, 'https://rodriguez-caldwell.com/', 'Audio', 1, 9);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (4, 'http://mcdonald.com/', 'Artwork', 1, 12);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (5, 'http://powers.info/', 'Artwork', 1, 3);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (6, 'http://russell-sims.com/', 'Credits', 1, 17);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (7, 'http://howell.net/', 'Artwork', 1, 17);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (8, 'https://landry-singh.com/', 'Credits', 1, 2);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (9, 'https://www.sullivan-oneill.org/', 'Audio', 1, 12);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (10, 'https://www.martin.com/', 'Credits', 1, 9);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (11, 'https://allen.com/', 'Audio', 1, 10);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (12, 'http://www.hampton.info/', 'Credits', 1, 11);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (13, 'https://www.carter.com/', 'Artwork', 1, 5);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (14, 'https://www.george.org/', 'Artwork', 1, 1);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (15, 'https://grant.com/', 'Audio', 1, 3);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (16, 'http://www.martin.com/', 'Artwork', 1, 15);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (17, 'https://horton-walker.com/', 'Credits', 1, 10);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (18, 'http://white.net/', 'Audio', 1, 16);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (19, 'https://brooks.com/', 'Artwork', 1, 17);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (20, 'http://www.crosby.org/', 'Audio', 1, 17);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (21, 'https://www.gutierrez.info/', 'Artwork', 1, 18);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (22, 'http://www.bell-cruz.com/', 'Credits', 1, 14);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (23, 'https://www.johnson-young.com/', 'Audio', 1, 20);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (24, 'http://hamilton.info/', 'Audio', 1, 2);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (25, 'http://baxter.net/', 'Credits', 1, 13);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (26, 'http://jones-rhodes.org/', 'Credits', 1, 12);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (27, 'http://www.arroyo.com/', 'Audio', 1, 6);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (28, 'http://bean-diaz.com/', 'Credits', 1, 13);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (29, 'http://www.rios.info/', 'Artwork', 1, 9);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (30, 'http://martinez-mack.com/', 'Audio', 1, 16);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (31, 'https://jacobs.com/', 'Audio', 1, 17);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (32, 'https://www.hale.org/', 'Audio', 1, 2);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (33, 'http://york.info/', 'Audio', 1, 13);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (34, 'http://www.jimenez.biz/', 'Artwork', 1, 7);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (35, 'http://scott.biz/', 'Audio', 1, 3);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (36, 'https://www.williams-baird.com/', 'Audio', 1, 1);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (37, 'https://martinez-wright.com/', 'Artwork', 1, 2);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (38, 'https://www.adams.info/', 'Artwork', 1, 3);
INSERT INTO asset (asset_id, file_url, file_type, upload_status, asset_release_id) VALUES (39, 'http://www.henderson-anderson.com/', 'Credits', 1, 10);

-- 14. payoutProfiles
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (1, 'wchristensen@example.net', 'Producer', 50.00, 1);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (2, 'crystalmays@example.net', 'Producer', 50.00, 2);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (3, 'alanparker@example.net', 'Producer', 50.00, 3);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (4, 'tylerrice@example.com', 'Producer', 50.00, 4);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (5, 'watsonkevin@example.net', 'Producer', 50.00, 5);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (6, 'evansbrandon@example.com', 'Producer', 50.00, 6);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (7, 'nbenton@example.com', 'Producer', 50.00, 7);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (8, 'jodom@example.org', 'Producer', 50.00, 8);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (9, 'tamara54@example.org', 'Producer', 50.00, 9);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (10, 'johnsonjohn@example.com', 'Producer', 50.00, 10);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (11, 'oconnelljose@example.net', 'Producer', 50.00, 11);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (12, 'cameronmandy@example.org', 'Producer', 50.00, 12);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (13, 'joshua91@example.com', 'Producer', 50.00, 13);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (14, 'daniel55@example.net', 'Producer', 50.00, 14);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (15, 'bholland@example.com', 'Producer', 50.00, 15);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (16, 'antoniowalls@example.org', 'Producer', 50.00, 16);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (17, 'bakerleroy@example.org', 'Producer', 50.00, 17);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (18, 'erichernandez@example.com', 'Producer', 50.00, 18);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (19, 'sarahmejia@example.org', 'Producer', 50.00, 19);
INSERT INTO payoutProfiles (payout_id, collab_email, role, split_percentage, pp_release_id) VALUES (20, 'devonhinton@example.net', 'Producer', 50.00, 20);

-- 15. streamEvent
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (1, '2026-04-16 05:39:34.349319', 1, 0.004, 28, 28, 1, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (2, '2026-04-05 08:38:49.754034', 1, 0.004, 26, 48, 1, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (3, '2026-04-04 20:51:30.409366', 1, 0.012, 17, 48, 3, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (4, '2026-03-24 13:45:22.945257', 0, 0.012, 25, 49, 3, 10);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (5, '2026-03-28 02:45:16.937234', 1, 0.004, 14, 38, 1, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (6, '2026-03-28 10:34:32.563658', 1, 0.004, 5, 32, 1, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (7, '2026-03-30 21:53:09.283437', 1, 0.01, 30, 4, 2, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (8, '2026-04-08 14:13:11.759796', 0, 0.01, 29, 14, 2, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (9, '2026-03-27 01:39:34.942989', 0, 0.004, 4, 36, 1, 9);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (10, '2026-04-13 22:48:22.610365', 0, 0.012, 39, 48, 3, 1);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (11, '2026-04-04 10:03:28.683312', 1, 0.012, 20, 33, 3, 2);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (12, '2026-03-20 12:52:13.590848', 1, 0.01, 3, 36, 2, 10);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (13, '2026-04-08 17:02:35.788491', 0, 0.004, 3, 18, 1, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (14, '2026-03-25 00:26:58.958318', 1, 0.012, 26, 5, 3, 10);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (15, '2026-04-09 03:09:00.939233', 0, 0.012, 22, 13, 3, 7);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (16, '2026-03-22 04:23:28.834055', 0, 0.012, 2, 32, 3, 9);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (17, '2026-04-08 21:29:37.605818', 0, 0.01, 5, 15, 2, 10);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (18, '2026-04-12 16:40:19.171731', 0, 0.012, 19, 22, 3, 10);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (19, '2026-04-09 17:34:01.295493', 0, 0.012, 28, 32, 3, 9);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (20, '2026-04-05 16:58:13.556014', 0, 0.004, 35, 4, 1, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (21, '2026-04-15 20:20:13.009967', 0, 0.004, 31, 18, 1, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (22, '2026-03-31 06:11:36.536630', 0, 0.012, 16, 16, 3, 9);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (23, '2026-04-09 04:44:26.309055', 1, 0.01, 26, 22, 2, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (24, '2026-04-03 03:56:19.071947', 0, 0.01, 32, 50, 2, 4);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (25, '2026-04-12 15:38:51.800533', 0, 0.004, 24, 41, 1, 4);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (26, '2026-04-16 20:51:33.239871', 0, 0.004, 19, 18, 1, 4);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (27, '2026-03-25 07:19:02.753806', 0, 0.004, 18, 14, 1, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (28, '2026-03-28 20:06:57.002545', 0, 0.004, 15, 38, 1, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (29, '2026-04-02 11:04:22.408468', 0, 0.012, 8, 26, 3, 7);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (30, '2026-04-12 06:38:25.594313', 1, 0.01, 30, 47, 2, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (31, '2026-04-09 14:27:14.839655', 0, 0.004, 3, 3, 1, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (32, '2026-04-06 21:45:22.887105', 0, 0.004, 18, 8, 1, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (33, '2026-04-06 14:07:57.457808', 0, 0.012, 14, 13, 3, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (34, '2026-03-20 17:48:32.299911', 0, 0.01, 35, 50, 2, 7);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (35, '2026-04-12 19:15:01.270557', 1, 0.004, 28, 41, 1, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (36, '2026-04-07 12:41:46.263120', 0, 0.01, 25, 26, 2, 6);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (37, '2026-03-22 01:10:02.319391', 0, 0.004, 4, 6, 1, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (38, '2026-04-05 03:29:10.207987', 0, 0.004, 9, 33, 1, 6);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (39, '2026-03-26 18:48:32.480449', 0, 0.012, 31, 40, 3, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (40, '2026-03-23 18:29:13.986552', 1, 0.01, 31, 25, 2, 12);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (41, '2026-04-12 03:57:37.304958', 1, 0.012, 36, 44, 3, 7);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (42, '2026-04-15 19:01:43.661371', 1, 0.012, 8, 17, 3, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (43, '2026-03-28 14:05:14.888391', 1, 0.01, 15, 34, 2, 9);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (44, '2026-03-23 12:42:54.592927', 0, 0.01, 29, 41, 2, 9);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (45, '2026-04-14 11:45:47.536390', 0, 0.01, 19, 25, 2, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (46, '2026-04-15 10:52:29.261628', 1, 0.012, 11, 42, 3, 12);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (47, '2026-04-11 19:19:08.916371', 1, 0.01, 15, 50, 2, 4);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (48, '2026-03-23 09:12:08.158690', 1, 0.004, 6, 13, 1, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (49, '2026-04-03 00:01:17.927722', 0, 0.012, 8, 20, 3, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (50, '2026-04-06 05:26:15.079904', 1, 0.012, 1, 10, 3, 1);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (51, '2026-04-08 04:34:21.870077', 0, 0.004, 31, 13, 1, 1);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (52, '2026-03-28 20:23:54.505856', 0, 0.01, 19, 10, 2, 4);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (53, '2026-04-05 22:16:14.668903', 0, 0.01, 15, 21, 2, 10);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (54, '2026-03-23 22:22:50.769852', 0, 0.004, 11, 1, 1, 4);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (55, '2026-04-04 21:26:09.706291', 1, 0.01, 11, 47, 2, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (56, '2026-04-12 15:38:25.679012', 1, 0.004, 40, 13, 1, 1);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (57, '2026-04-13 03:44:54.813954', 1, 0.01, 35, 35, 2, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (58, '2026-04-08 10:31:58.133429', 1, 0.01, 9, 35, 2, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (59, '2026-03-21 05:32:57.848396', 0, 0.012, 20, 24, 3, 10);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (60, '2026-03-28 09:34:16.324823', 1, 0.01, 33, 16, 2, 7);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (61, '2026-04-08 22:36:23.250808', 1, 0.012, 18, 6, 3, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (62, '2026-03-18 10:28:06.770543', 0, 0.012, 2, 2, 3, 12);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (63, '2026-03-28 19:51:45.442469', 0, 0.01, 28, 3, 2, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (64, '2026-04-12 02:20:52.552876', 1, 0.004, 40, 17, 1, 13);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (65, '2026-04-13 17:50:48.354377', 0, 0.01, 3, 22, 2, 6);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (66, '2026-04-03 02:36:22.110927', 0, 0.01, 5, 15, 2, 10);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (67, '2026-03-23 17:05:36.700510', 1, 0.004, 8, 34, 1, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (68, '2026-03-25 09:16:25.175608', 0, 0.01, 16, 28, 2, 12);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (69, '2026-03-28 23:45:09.213998', 0, 0.004, 5, 12, 1, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (70, '2026-03-23 11:14:47.881303', 0, 0.012, 29, 39, 3, 6);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (71, '2026-04-02 22:33:09.372528', 0, 0.004, 26, 40, 1, 6);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (72, '2026-04-01 15:33:53.472476', 1, 0.012, 25, 42, 3, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (73, '2026-04-12 12:27:26.531336', 1, 0.012, 38, 6, 3, 12);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (74, '2026-03-24 14:46:19.308103', 1, 0.01, 11, 32, 2, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (75, '2026-04-15 17:53:08.447488', 1, 0.01, 14, 19, 2, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (76, '2026-03-26 06:30:36.385104', 1, 0.004, 12, 16, 1, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (77, '2026-04-14 19:04:58.724697', 1, 0.01, 17, 10, 2, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (78, '2026-03-25 16:40:28.201756', 1, 0.004, 33, 36, 1, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (79, '2026-04-10 04:50:40.665370', 1, 0.01, 4, 24, 2, 12);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (80, '2026-04-02 03:16:46.601627', 0, 0.012, 27, 13, 3, 7);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (81, '2026-03-22 22:32:08.661467', 1, 0.01, 23, 28, 2, 2);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (82, '2026-04-12 09:59:47.006475', 1, 0.004, 7, 15, 1, 4);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (83, '2026-04-11 22:12:46.561928', 0, 0.01, 21, 26, 2, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (84, '2026-04-15 02:14:18.482778', 1, 0.012, 16, 3, 3, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (85, '2026-04-12 04:59:00.056686', 0, 0.01, 29, 28, 2, 9);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (86, '2026-03-31 21:02:47.644658', 1, 0.004, 33, 14, 1, 9);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (87, '2026-03-30 20:59:30.561510', 0, 0.01, 2, 10, 2, 13);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (88, '2026-04-07 01:12:50.924498', 1, 0.004, 16, 18, 1, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (89, '2026-04-01 07:12:34.451132', 1, 0.004, 14, 26, 1, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (90, '2026-04-06 01:07:21.971059', 1, 0.01, 38, 26, 2, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (91, '2026-03-20 20:37:03.290231', 1, 0.01, 3, 32, 2, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (92, '2026-04-15 14:29:26.943571', 1, 0.004, 11, 37, 1, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (93, '2026-03-28 14:49:39.116770', 1, 0.012, 30, 8, 3, 2);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (94, '2026-04-13 06:38:52.575664', 0, 0.012, 31, 30, 3, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (95, '2026-04-13 08:07:15.508004', 1, 0.01, 35, 15, 2, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (96, '2026-04-08 21:50:20.845262', 0, 0.01, 11, 40, 2, 7);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (97, '2026-03-22 07:15:41.758497', 1, 0.01, 5, 25, 2, 13);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (98, '2026-03-20 20:48:26.558997', 0, 0.004, 19, 24, 1, 12);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (99, '2026-04-03 23:38:20.103037', 0, 0.012, 13, 41, 3, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (100, '2026-03-19 02:56:48.891244', 0, 0.004, 4, 4, 1, 13);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (101, '2026-04-14 11:40:26.914491', 0, 0.01, 30, 27, 2, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (102, '2026-04-16 03:23:02.044549', 1, 0.01, 9, 24, 2, 7);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (103, '2026-03-29 20:18:25.253599', 0, 0.01, 8, 39, 2, 4);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (104, '2026-04-02 17:17:26.247696', 1, 0.012, 19, 7, 3, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (105, '2026-04-08 11:20:54.586972', 1, 0.004, 35, 13, 1, 13);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (106, '2026-03-23 19:50:33.896349', 0, 0.004, 14, 40, 1, 2);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (107, '2026-04-11 23:20:10.610260', 1, 0.012, 8, 35, 3, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (108, '2026-03-19 02:25:58.287704', 0, 0.012, 37, 12, 3, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (109, '2026-03-31 15:09:10.700297', 1, 0.01, 22, 48, 2, 6);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (110, '2026-03-28 22:27:17.361040', 1, 0.012, 1, 12, 3, 9);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (111, '2026-03-23 07:06:47.854420', 1, 0.004, 5, 34, 1, 13);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (112, '2026-04-13 14:33:11.286791', 0, 0.01, 20, 39, 2, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (113, '2026-03-20 15:59:54.150175', 0, 0.004, 18, 11, 1, 12);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (114, '2026-04-13 22:44:50.019574', 0, 0.012, 6, 4, 3, 2);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (115, '2026-03-27 01:20:57.455572', 1, 0.004, 1, 39, 1, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (116, '2026-03-25 21:08:25.110763', 1, 0.01, 7, 17, 2, 3);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (117, '2026-04-02 04:57:13.754218', 0, 0.004, 28, 37, 1, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (118, '2026-04-07 17:20:10.770512', 1, 0.01, 17, 15, 2, 6);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (119, '2026-04-16 20:03:41.597522', 0, 0.012, 22, 34, 3, 13);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (120, '2026-03-19 19:50:37.333527', 0, 0.012, 2, 28, 3, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (121, '2026-04-09 14:18:48.620129', 0, 0.004, 13, 30, 1, 14);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (122, '2026-03-27 21:58:16.023987', 0, 0.01, 33, 26, 2, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (123, '2026-04-03 22:27:43.275058', 1, 0.012, 39, 42, 3, 10);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (124, '2026-04-07 16:18:16.561493', 0, 0.004, 20, 25, 1, 7);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (125, '2026-03-31 05:32:16.280091', 1, 0.01, 39, 47, 2, 2);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (126, '2026-04-16 00:48:38.028104', 1, 0.01, 27, 29, 2, 10);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (127, '2026-04-14 19:47:16.360480', 1, 0.004, 35, 30, 1, 15);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (128, '2026-04-09 13:44:39.643390', 1, 0.01, 37, 4, 2, 4);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (129, '2026-03-29 06:45:54.298765', 0, 0.012, 6, 19, 3, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (130, '2026-04-02 09:02:38.305201', 1, 0.004, 31, 13, 1, 10);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (131, '2026-04-16 19:46:33.925585', 0, 0.01, 24, 30, 2, 6);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (132, '2026-04-06 01:23:25.684049', 1, 0.01, 30, 9, 2, 9);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (133, '2026-03-27 08:23:00.826475', 0, 0.004, 1, 47, 1, 9);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (134, '2026-04-04 08:28:24.537104', 0, 0.01, 34, 49, 2, 6);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (135, '2026-04-01 02:41:12.165883', 1, 0.012, 29, 16, 3, 12);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (136, '2026-04-14 15:06:32.921409', 0, 0.01, 4, 24, 2, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (137, '2026-04-15 08:18:14.010907', 1, 0.012, 12, 24, 3, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (138, '2026-03-31 02:42:56.900496', 1, 0.01, 36, 14, 2, 7);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (139, '2026-04-07 08:02:13.805476', 0, 0.01, 39, 15, 2, 5);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (140, '2026-04-01 21:41:56.018904', 1, 0.01, 11, 13, 2, 11);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (141, '2026-03-24 08:32:40.950278', 1, 0.01, 9, 41, 2, 9);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (142, '2026-03-21 21:43:44.440509', 1, 0.004, 3, 48, 1, 8);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (143, '2026-04-14 03:18:40.273851', 1, 0.004, 18, 13, 1, 9);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (144, '2026-03-26 13:20:33.644937', 0, 0.01, 37, 32, 2, 1);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (145, '2026-03-27 12:07:01.730181', 0, 0.012, 39, 41, 3, 4);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (146, '2026-03-30 00:20:24.757994', 0, 0.012, 14, 49, 3, 13);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (147, '2026-04-13 12:23:19.532763', 0, 0.01, 36, 5, 2, 10);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (148, '2026-03-20 08:14:37.014934', 1, 0.012, 34, 33, 3, 1);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (149, '2026-04-07 16:00:35.224850', 1, 0.004, 20, 33, 1, 6);
INSERT INTO streamEvent (event_id, time_stamp, is_skipped, rev_generated, event_listener_id, event_track_id, event_platform_id, event_location_id) VALUES (150, '2026-03-20 22:50:33.520853', 0, 0.012, 17, 26, 3, 9);

-- 16. playlistEvent
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (26, 2);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (128, 2);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (15, 6);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (51, 4);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (76, 7);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (83, 7);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (47, 5);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (50, 1);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (114, 4);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (90, 5);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (127, 5);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (35, 8);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (136, 8);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (62, 1);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (24, 8);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (16, 2);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (23, 9);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (69, 8);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (12, 7);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (31, 2);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (124, 7);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (134, 6);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (46, 6);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (61, 6);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (115, 1);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (118, 1);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (53, 4);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (126, 3);
INSERT IGNORE INTO playlistEvent (pt_event_id, pt_playlist_id) VALUES (88, 1);

SET FOREIGN_KEY_CHECKS = 1;
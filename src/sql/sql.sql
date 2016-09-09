CREATE DATABASE IF NOT EXISTS sqli;
USE sqli;
CREATE TABLE IF NOT EXISTS users (
    user_id SMALLINT NOT NULL,
    username VARCHAR(20),
    nom VARCHAR(20),
    prenom VARCHAR(20),
    email VARCHAR(20),
    PRIMARY KEY (user_id)
)
ENGINE=INNODB;

INSERT INTO sqli (username, nom, prenom, email) VALUES
('toto', 'toto', 'toto', 'toto@test.com'),
('tata', 'tata', 'tata', 'tata@test.com'),
('titi', 'titi', 'titi', 'titi@test.com');

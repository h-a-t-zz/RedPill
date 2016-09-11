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

INSERT INTO sqli.users (user_id, username, nom, prenom, email) VALUES ('0','y.kazar', 'Yassir', 'Kazar', 'yassir@yogosha.com');
INSERT INTO sqli.users (user_id, username, nom, prenom, email) VALUES ('1','f.epelboin', 'Fabrice', 'Epelboin', 'fabrice@yogosha.com');

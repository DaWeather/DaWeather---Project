-- phpMyAdmin SQL Dump
-- version 4.0.4
-- http://www.phpmyadmin.net
--
-- Client: localhost
-- Généré le: Mer 04 Février 2015 à 08:56
-- Version du serveur: 5.6.12-log
-- Version de PHP: 5.4.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+01:00";

SET GLOBAL event_scheduler = ON; 

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de données: `daweather`
--
CREATE DATABASE IF NOT EXISTS `daweather` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `daweather`;

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `cumul_H_DATA_PLUIE`()
BEGIN
	DECLARE v_finished INTEGER DEFAULT 0;
	DECLARE cumul FLOAT;
	DECLARE nb INT;

	DECLARE cumulPluie_cursor CURSOR FOR 
		SELECT SUM(m_data_pluie.cumul), COUNT(*) as nb 
		FROM m_data_pluie
		WHERE hour(date)=hour(now())-1;
		
	 DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET v_finished = 1;
		
	OPEN cumulPluie_cursor;
		
	get_values: LOOP
	
		FETCH cumulPluie_cursor INTO cumul, nb;
		
		IF v_finished = 1 THEN
			LEAVE get_values;
		END IF;
		
		IF nb > 0 THEN
			INSERT INTO h_data_pluie (date, cumul, STATION_idStation) VALUES (NOW(), cumul, 1);
		END IF;
		
	END LOOP get_values;
	
	CLOSE cumulPluie_cursor;
	
	TRUNCATE TABLE m_data_pluie;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cumul_J_DATA_PLUIE`()
BEGIN
	DECLARE v_finished INTEGER DEFAULT 0;
	DECLARE v_cumul FLOAT;
	DECLARE nb INT;

	DECLARE cumulPluie_cursor CURSOR FOR 
		SELECT SUM(h_data_pluie.cumul), COUNT(*) as nb
		FROM h_data_pluie
		WHERE day(date)=day(now())-1;
		
	 DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET v_finished = 1;
		
	OPEN cumulPluie_cursor;
		
	get_values: LOOP
	
		FETCH cumulPluie_cursor INTO v_cumul, nb;
		
		IF v_finished = 1 THEN
			LEAVE get_values;
		END IF;
		
		IF nb > 0 THEN
			INSERT INTO j_data_pluie (date, cumul, STATION_idStation) VALUES (NOW(), v_cumul, 1);
		END IF;
		
	END LOOP get_values;
	
	CLOSE cumulPluie_cursor;
	
	TRUNCATE TABLE h_data_pluie;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cumul_M_DATA_PLUIE`()
BEGIN
	DECLARE v_finished INTEGER DEFAULT 0;
	DECLARE cumul FLOAT;
	DECLARE nb INT;

	DECLARE cumulPluie_cursor CURSOR FOR 
		SELECT SUM(valeur), COUNT(*) as nb
		FROM s_data_pluie
		WHERE hour(date)=hour(now()) AND minute(date)=minute(now())-1;
		
	 DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET v_finished = 1;
		
	OPEN cumulPluie_cursor;
		
	get_values: LOOP
	
		FETCH cumulPluie_cursor INTO cumul, nb;
		
		IF v_finished = 1 THEN
			LEAVE get_values;
		END IF;
		
		IF nb > 0 THEN
			INSERT INTO m_data_pluie (date, cumul, STATION_idStation) VALUES (NOW(), cumul,1);
		END IF;
		
	END LOOP get_values;
	
	CLOSE cumulPluie_cursor;
	
	TRUNCATE TABLE s_data_pluie;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `max_H_DATA_VENTI`()
BEGIN
	DECLARE v_finished INTEGER DEFAULT 0;
	DECLARE max FLOAT;
	DECLARE direct FLOAT;
	DECLARE nb INT;
    
	DECLARE maxVentI_cursor CURSOR FOR 
		SELECT m_data_venti.max as max, direction, COUNT(*) as nb 
		FROM m_data_venti
		WHERE m_data_venti.max = ( SELECT MAX(m_data_venti.max) FROM m_data_venti WHERE hour(date)=hour(now())-1);
		
	 DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET v_finished = 1;
		
	OPEN maxVentI_cursor;
		
	get_values: LOOP
	
		FETCH maxVentI_cursor INTO max, direct, nb;
		
		IF v_finished = 1 THEN
			LEAVE get_values;
		END IF;
		
		IF nb > 0 THEN
			INSERT INTO h_data_venti (date, max, direction, STATION_idStation) VALUES (NOW(), max, direct,1);
		END IF;
		
	END LOOP get_values;
	
	CLOSE maxVentI_cursor;
    
    TRUNCATE m_data_venti;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `max_J_DATA_VENTI`()
BEGIN
	DECLARE v_finished INTEGER DEFAULT 0;
	DECLARE maximum FLOAT;
	DECLARE direct FLOAT;
	DECLARE nb INT;
    
	DECLARE maxVentI_cursor CURSOR FOR 
		SELECT h_data_venti.max as maximum, direction, COUNT(*) as nb
		FROM h_data_venti
		WHERE h_data_venti.max = ( SELECT MAX(h_data_venti.max) FROM h_data_venti WHERE day(date)=day(now())-1);
		
	 DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET v_finished = 1;
		
	OPEN maxVentI_cursor;
		
	get_values: LOOP
	
		FETCH maxVentI_cursor INTO maximum, direct, nb;
		
		IF v_finished = 1 THEN
			LEAVE get_values;
		END IF;
		
		IF nb > 0 THEN
			INSERT INTO j_data_venti (date, max, direction, STATION_idStation) VALUES (NOW(), maximum, direct, 1);
		END IF;
		
	END LOOP get_values;
	
	CLOSE maxVentI_cursor;
	
	TRUNCATE TABLE h_data_venti;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `max_M_DATA_VENTI`()
BEGIN
	DECLARE v_finished INTEGER DEFAULT 0;
	DECLARE max FLOAT;
	DECLARE direct FLOAT;
	DECLARE nb INT;
    
	DECLARE maxVentI_cursor CURSOR FOR 
		SELECT valeur as max, direction, COUNT(*) as nb 
		FROM s_data_vent
		WHERE valeur = ( SELECT MAX(valeur) FROM s_data_vent WHERE minute(date)=minute(now())-1);
		
	 DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET v_finished = 1;
		
	OPEN maxVentI_cursor;
		
	get_values: LOOP
	
		FETCH maxVentI_cursor INTO max, direct, nb;
		
		IF v_finished = 1 THEN
			LEAVE get_values;
		END IF;
		
		IF nb > 0 THEN
			INSERT INTO m_data_venti (date, max, direction, STATION_idStation) VALUES (NOW(), max, direct,1);
		END IF;
		
	END LOOP get_values;
	
	CLOSE maxVentI_cursor;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `moyenne_H_DATA_HUM`()
BEGIN
	DECLARE v_finished INTEGER DEFAULT 0;
	DECLARE moyenne FLOAT;
	DECLARE nb INT;

	DECLARE moyHum_cursor CURSOR FOR 
		SELECT avg(m_data_hum.moyenne) as moyenne, COUNT(*) as nb
		FROM m_data_hum
		WHERE hour(date)=hour(now())-1;
		
	 DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET v_finished = 1;
		
	OPEN moyHum_cursor;
		
	get_values: LOOP
	
		FETCH moyHum_cursor INTO moyenne, nb;
		
		IF v_finished = 1 THEN
			LEAVE get_values;
		END IF;
		
		IF nb > 0 THEN
			INSERT INTO h_data_hum (date, moyenne, STATION_idStation) VALUES (NOW(), moyenne, 1);
		END IF;
		
	END LOOP get_values;
	
	CLOSE moyHum_cursor;
	
	TRUNCATE TABLE m_data_hum;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `moyenne_H_DATA_PRE`()
BEGIN
	DECLARE v_finished INTEGER DEFAULT 0;
	DECLARE moyenne FLOAT;
	DECLARE nb INT;

	DECLARE moyPress_cursor CURSOR FOR 
		SELECT avg(m_data_pre.moyenne) as moyenne, COUNT(*) as nb
		FROM m_data_pre
		WHERE hour(date)=hour(now())-1;
		
	 DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET v_finished = 1;
		
	OPEN moyPress_cursor;
		
	get_values: LOOP
	
		FETCH moyPress_cursor INTO moyenne, nb;
		
		IF v_finished = 1 THEN
			LEAVE get_values;
		END IF;
		
		IF nb > 0 THEN
			INSERT INTO h_data_pre (date, moyenne, STATION_idStation) VALUES (NOW(), moyenne,1);
		END IF;
		
	END LOOP get_values;
	
	CLOSE moyPress_cursor;
	
	TRUNCATE TABLE m_data_pre;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `moyenne_H_DATA_TEMP`()
BEGIN
	DECLARE v_finished INTEGER DEFAULT 0;
	DECLARE moyenne FLOAT;
	DECLARE min FLOAT;
	DECLARE max FLOAT;
	DECLARE nb INT;

	DECLARE valTemp_cursor CURSOR FOR 
		SELECT avg(m_data_temp.moyenne) as moyenne, min(m_data_temp.moyenne) as min, max(m_data_temp.moyenne) as max, COUNT(*) as nb
		FROM m_data_temp
		WHERE hour(date)=hour(now())-1;
		
	 DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET v_finished = 1;
		
	OPEN valTemp_cursor;
		
	get_values: LOOP
	
		FETCH valTemp_cursor INTO moyenne, min, max, nb;
		
		IF v_finished = 1 THEN
			LEAVE get_values;
		END IF;
		
		IF nb > 0 THEN
			INSERT INTO h_data_temp (date, moyenne, min, max, STATION_idStation) VALUES (NOW(), moyenne, min, max,1);
		END IF;
		
	END LOOP get_values;
	
	CLOSE valTemp_cursor;
	
	TRUNCATE TABLE m_data_temp;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `moyenne_H_DATA_VENTM`()
BEGIN
	DECLARE v_finished INTEGER DEFAULT 0;
    DECLARE moyenne FLOAT;
	DECLARE direct FLOAT;
	DECLARE nb INT;
	
	DECLARE moyVentM_cursor CURSOR FOR        
		SELECT AVG(m_data_ventm.moyenne) as moyenne, AVG(m_data_ventm.direction) as direction, COUNT(*) as nb
		FROM m_data_ventm
        WHERE hour(date)=hour(now())-1;
		
	 DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET v_finished = 1;
		
	OPEN moyVentM_cursor;
		
	get_values: LOOP
	
		FETCH moyVentM_cursor INTO moyenne, direct, nb;
		
		IF v_finished = 1 THEN
			LEAVE get_values;
		END IF;
		
		IF nb > 0 THEN
			INSERT INTO h_data_ventm (date, moyenne, direction, STATION_idStation) VALUES (NOW(), moyenne, direct,1);
		END IF;
		
	END LOOP get_values;
	
	CLOSE moyVentM_cursor;
	
	TRUNCATE TABLE m_data_ventm;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `moyenne_J_DATA_HUM`()
BEGIN
	DECLARE v_finished INTEGER DEFAULT 0;
	DECLARE moyenne FLOAT;
	DECLARE minimum FLOAT;
	DECLARE maximum FLOAT;
	DECLARE nb INT;

	DECLARE moyHum_cursor CURSOR FOR 
		SELECT avg(h_data_hum.moyenne) as moyenne, min(h_data_hum.moyenne) as minimum, max(h_data_hum.moyenne) as maximum, COUNT(*) as nb
		FROM h_data_hum
		WHERE day(date)=day(now())-1;
		
	 DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET v_finished = 1;
		
	OPEN moyHum_cursor;
		
	get_values: LOOP
	
		FETCH moyHum_cursor INTO moyenne, minimum, maximum, nb;
		
		IF v_finished = 1 THEN
			LEAVE get_values;
		END IF;
		
		IF nb > 0 THEN
			INSERT INTO j_data_hum (date, moyenne, min, max, STATION_idStation) VALUES (NOW(), moyenne, minimum, maximum, 1);
		END IF;
		
	END LOOP get_values;
	
	CLOSE moyHum_cursor;
	
	TRUNCATE TABLE h_data_hum;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `moyenne_J_DATA_PRE`()
BEGIN
	DECLARE v_finished INTEGER DEFAULT 0;
	DECLARE moyenne FLOAT;
	DECLARE minimum FLOAT;
	DECLARE maximum FLOAT;
	DECLARE nb INT;

	DECLARE moyPress_cursor CURSOR FOR 
		SELECT avg(h_data_pre.moyenne) as moyenne, min(h_data_pre.moyenne) as minimum, max(h_data_pre.moyenne) as maximum, COUNT(*) as nb
		FROM h_data_pre
		WHERE day(date)=day(now())-1;
		
	 DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET v_finished = 1;
		
	OPEN moyPress_cursor;
		
	get_values: LOOP
	
		FETCH moyPress_cursor INTO moyenne, minimum, maximum, nb;
		
		IF v_finished = 1 THEN
			LEAVE get_values;
		END IF;
		
		IF nb > 0 THEN
			INSERT INTO j_data_pre (date, moyenne, min, max, STATION_idStation) VALUES (NOW(), moyenne, minimum, maximum, 1);
		END IF;
		
	END LOOP get_values;
	
	CLOSE moyPress_cursor;
	
	TRUNCATE TABLE h_data_pre;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `moyenne_J_DATA_TEMP`()
BEGIN
	DECLARE v_finished INTEGER DEFAULT 0;
	DECLARE moyenne FLOAT;
	DECLARE min FLOAT;
	DECLARE max FLOAT;
	DECLARE nb INT;

	DECLARE valTemp_cursor CURSOR FOR 
		SELECT avg(h_data_temp.moyenne) as moyenne, min(h_data_temp.min) as min, max(h_data_temp.max) as max, COUNT(*) as nb
		FROM h_data_temp
		WHERE day(date)=day(now())-1;
		
	 DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET v_finished = 1;
		
	OPEN valTemp_cursor;
		
	get_values: LOOP
	
		FETCH valTemp_cursor INTO moyenne, min, max, nb;
		
		IF v_finished = 1 THEN
			LEAVE get_values;
		END IF;
		
		IF nb > 0 THEN
			INSERT INTO j_data_temp (date, moyenne, min, max, STATION_idStation) VALUES (NOW(), moyenne, min, max,1);
		END IF;
		
	END LOOP get_values;
	
	CLOSE valTemp_cursor;
	
	TRUNCATE TABLE h_data_temp;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `moyenne_J_DATA_VENTM`()
BEGIN
	DECLARE v_finished INTEGER DEFAULT 0;
	DECLARE moyenne FLOAT;
	DECLARE direct FLOAT;
	DECLARE nb INT;
    
	DECLARE moyVent_cursor CURSOR FOR 
		SELECT AVG(h_data_ventm.moyenne) as moyenne, AVG(h_data_ventm.direction) as direction, COUNT(*) as nb
		FROM h_data_ventm
        WHERE day(date)=day(now())-1;
		
	 DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET v_finished = 1;
		
	OPEN moyVent_cursor;
		
	get_values: LOOP
	
		FETCH moyVent_cursor INTO moyenne, direct, nb;
		
		IF v_finished = 1 THEN
			LEAVE get_values;
		END IF;
		
		IF nb > 0 THEN
			INSERT INTO j_data_ventm (date, moyenne, direction, STATION_idStation) VALUES (NOW(), moyenne, direct, 1);
		END IF;
		
	END LOOP get_values;
	
	CLOSE moyVent_cursor;
	
	TRUNCATE TABLE h_data_ventm;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `moyenne_M_DATA_HUM`()
BEGIN
	DECLARE v_finished INTEGER DEFAULT 0;
	DECLARE moyenne FLOAT;
	DECLARE nb INT;

	DECLARE moyHum_cursor CURSOR FOR 
		SELECT avg(valeur) as moyenne, COUNT(*) as nb
		FROM s_data_hum
		WHERE hour(date)=hour(now()) AND minute(date)=minute(now())-1;
		
	 DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET v_finished = 1;
		
	OPEN moyHum_cursor;
		
	get_values: LOOP
	
		FETCH moyHum_cursor INTO moyenne, nb;
		
		IF v_finished = 1 THEN
			LEAVE get_values;
		END IF;
		
		IF nb > 0 THEN
			INSERT INTO m_data_hum (date, moyenne, STATION_idStation) VALUES (NOW(), moyenne, 1);
		END IF;
		
	END LOOP get_values;
	
	CLOSE moyHum_cursor;
	
	TRUNCATE TABLE s_data_hum;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `moyenne_M_DATA_PRE`()
BEGIN
	DECLARE v_finished INTEGER DEFAULT 0;
	DECLARE moyenne FLOAT;
	DECLARE nb INT;
	
	DECLARE moyPress_cursor CURSOR FOR
		SELECT avg(valeur) as moyenne, COUNT(*) as nb
		FROM s_data_pre
		WHERE hour(date)=hour(now()) AND minute(date)=minute(now())-1;
		
	 DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET v_finished = 1;
		
	OPEN moyPress_cursor;
		
	get_values: LOOP
	
		FETCH moyPress_cursor INTO moyenne, nb;
		
		IF v_finished = 1 THEN
			LEAVE get_values;
		END IF;
		
		IF nb > 0 THEN
			INSERT INTO m_data_pre (date, moyenne, STATION_idStation) VALUES (NOW(), moyenne,1);
		END IF;
		
	END LOOP get_values;
	
	CLOSE moyPress_cursor;
	
	TRUNCATE TABLE s_data_pre;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `moyenne_M_DATA_TEMP`()
BEGIN
	DECLARE v_finished INTEGER DEFAULT 0;
	DECLARE moyenne FLOAT;
	DECLARE nb INT;

	DECLARE moyTemp_cursor CURSOR FOR 
		SELECT avg(valeur) as moyenne, COUNT(*) as nb
		FROM s_data_temp
		WHERE hour(date)=hour(now()) AND minute(date)=minute(now())-1;
		
	 DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET v_finished = 1;
		
	OPEN moyTemp_cursor;
		
	get_values: LOOP
	
		FETCH moyTemp_cursor INTO moyenne, nb;
		
		IF v_finished = 1 THEN
			LEAVE get_values;
		END IF;
		
		IF nb > 0 THEN
			INSERT INTO m_data_temp (date, moyenne,STATION_idStation) VALUES (NOW(), moyenne,1);
		END IF;
		
	END LOOP get_values;
	
	CLOSE moyTemp_cursor;
	
	TRUNCATE TABLE s_data_temp;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `moyenne_M_DATA_VENTM`()
BEGIN
	DECLARE v_finished INTEGER DEFAULT 0;
    DECLARE moyenne FLOAT;
	DECLARE direct FLOAT;
	DECLARE nb INT;
	
	DECLARE moyVentM_cursor CURSOR FOR        
		SELECT AVG(valeur) as moyenne, AVG(direction) as direction, COUNT(*) as nb
		FROM s_data_vent;
		
	 DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET v_finished = 1;
		
	OPEN moyVentM_cursor;
		
	get_values: LOOP
	
		FETCH moyVentM_cursor INTO moyenne, direct, nb;
		
		IF v_finished = 1 THEN
			LEAVE get_values;
		END IF;
		
		IF nb > 0 THEN
			INSERT INTO m_data_ventm (date, moyenne, direction, STATION_idStation) VALUES (NOW(), moyenne, direct,1);
		END IF;
		
	END LOOP get_values;
	
	CLOSE moyVentM_cursor;
	
	TRUNCATE TABLE s_data_vent;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `h_data_hum`
--

CREATE TABLE IF NOT EXISTS `h_data_hum` (
  `idH_DATA_HUM` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `moyenne` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idH_DATA_HUM`),
  KEY `fk_S_DATA_HUM_STATION1_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `h_data_pluie`
--

CREATE TABLE IF NOT EXISTS `h_data_pluie` (
  `idH_DATA_PLUIE` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `cumul` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idH_DATA_PLUIE`),
  KEY `fk_S_DATA_HUM_STATION1_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `h_data_pre`
--

CREATE TABLE IF NOT EXISTS `h_data_pre` (
  `idH_DATA_PRE` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `moyenne` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idH_DATA_PRE`),
  KEY `fk_S_DATA_HUM_STATION1_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `h_data_temp`
--

CREATE TABLE IF NOT EXISTS `h_data_temp` (
  `idH_DATA_TEMP` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `moyenne` float DEFAULT NULL,
  `min` float DEFAULT NULL,
  `max` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idH_DATA_TEMP`),
  KEY `fk_S_DATA_TEMP_STATION_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `h_data_venti`
--

CREATE TABLE IF NOT EXISTS `h_data_venti` (
  `idH_DATA_VENTI` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `max` float DEFAULT NULL,
  `direction` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idH_DATA_VENTI`),
  KEY `fk_S_DATA_HUM_STATION1_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `h_data_ventm`
--

CREATE TABLE IF NOT EXISTS `h_data_ventm` (
  `idH_DATA_VENTM` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `moyenne` float DEFAULT NULL,
  `direction` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idH_DATA_VENTM`),
  KEY `fk_S_DATA_HUM_STATION1_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `j_data_hum`
--

CREATE TABLE IF NOT EXISTS `j_data_hum` (
  `idJ_DATA_HUM` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `moyenne` float DEFAULT NULL,
  `min` float DEFAULT NULL,
  `max` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idJ_DATA_HUM`),
  KEY `fk_S_DATA_HUM_STATION1_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `j_data_pluie`
--

CREATE TABLE IF NOT EXISTS `j_data_pluie` (
  `idJ_DATA_PLUIE` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `cumul` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idJ_DATA_PLUIE`),
  KEY `fk_S_DATA_HUM_STATION1_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `j_data_pre`
--

CREATE TABLE IF NOT EXISTS `j_data_pre` (
  `idJ_DATA_PRE` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `moyenne` float DEFAULT NULL,
  `min` float DEFAULT NULL,
  `max` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idJ_DATA_PRE`),
  KEY `fk_S_DATA_HUM_STATION1_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `j_data_temp`
--

CREATE TABLE IF NOT EXISTS `j_data_temp` (
  `idJ_DATA_TEMP` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `moyenne` float DEFAULT NULL,
  `min` float DEFAULT NULL,
  `max` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idJ_DATA_TEMP`),
  KEY `fk_S_DATA_TEMP_STATION_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `j_data_venti`
--

CREATE TABLE IF NOT EXISTS `j_data_venti` (
  `idJ_DATA_VENTI` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `max` float DEFAULT NULL,
  `direction` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idJ_DATA_VENTI`),
  KEY `fk_S_DATA_HUM_STATION1_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `j_data_ventm`
--

CREATE TABLE IF NOT EXISTS `j_data_ventm` (
  `idJ_DATA_VENTM` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `moyenne` float DEFAULT NULL,
  `direction` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idJ_DATA_VENTM`),
  KEY `fk_S_DATA_HUM_STATION1_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `m_data_hum`
--

CREATE TABLE IF NOT EXISTS `m_data_hum` (
  `idM_DATA_HUM` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `moyenne` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idM_DATA_HUM`),
  KEY `fk_S_DATA_HUM_STATION1_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `m_data_pluie`
--

CREATE TABLE IF NOT EXISTS `m_data_pluie` (
  `idM_DATA_PLUIE` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `cumul` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idM_DATA_PLUIE`),
  KEY `fk_S_DATA_HUM_STATION1_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `m_data_pre`
--

CREATE TABLE IF NOT EXISTS `m_data_pre` (
  `idM_DATA_PRE` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `moyenne` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idM_DATA_PRE`),
  KEY `fk_S_DATA_HUM_STATION1_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `m_data_temp`
--

CREATE TABLE IF NOT EXISTS `m_data_temp` (
  `idM_DATA_TEMP` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `moyenne` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idM_DATA_TEMP`),
  KEY `fk_S_DATA_TEMP_STATION_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `m_data_venti`
--

CREATE TABLE IF NOT EXISTS `m_data_venti` (
  `idM_DATA_VENTI` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `max` float DEFAULT NULL,
  `direction` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idM_DATA_VENTI`),
  KEY `fk_S_DATA_HUM_STATION1_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `m_data_ventm`
--

CREATE TABLE IF NOT EXISTS `m_data_ventm` (
  `idM_DATA_VENTM` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `moyenne` float DEFAULT NULL,
  `direction` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idM_DATA_VENTM`),
  KEY `fk_S_DATA_HUM_STATION1_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `station`
--

CREATE TABLE IF NOT EXISTS `station` (
  `idStation` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(45) DEFAULT NULL,
  `lieu` varchar(45) DEFAULT NULL,
  `altitude` int(11) DEFAULT NULL,
  `date_installation` datetime DEFAULT NULL,
  `private_key` varchar(200) DEFAULT NULL,
  `email` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`idStation`)
) ENGINE=MYISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Contenu de la table `station`
--

INSERT INTO `station` (`idStation`, `nom`, `lieu`, `altitude`, `date_installation`, `private_key`, `email`) VALUES
(1, 'test', 'Gradignan', 40, '2015-01-27 00:00:00', '257254', 'test@daweather.com');

-- --------------------------------------------------------

--
-- Structure de la table `s_data_hum`
--

CREATE TABLE IF NOT EXISTS `s_data_hum` (
  `idS_DATA_HUM` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `valeur` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idS_DATA_HUM`),
  KEY `fk_S_DATA_HUM_STATION1_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `s_data_pluie`
--

CREATE TABLE IF NOT EXISTS `s_data_pluie` (
  `idS_DATA_PLUIE` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `valeur` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idS_DATA_PLUIE`),
  KEY `fk_S_DATA_HUM_STATION1_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `s_data_pre`
--

CREATE TABLE IF NOT EXISTS `s_data_pre` (
  `idS_DATA_PRE` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `valeur` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idS_DATA_PRE`),
  KEY `fk_S_DATA_HUM_STATION1_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `s_data_temp`
--

CREATE TABLE IF NOT EXISTS `s_data_temp` (
  `idS_DATA_TEMP` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `valeur` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idS_DATA_TEMP`),
  KEY `fk_S_DATA_TEMP_STATION_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `s_data_vent`
--

CREATE TABLE IF NOT EXISTS `s_data_vent` (
  `idS_DATA_VENTI` int(11) NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `valeur` float DEFAULT NULL,
  `direction` float DEFAULT NULL,
  `STATION_idStation` int(11) NOT NULL,
  PRIMARY KEY (`idS_DATA_VENTI`),
  KEY `fk_S_DATA_HUM_STATION1_idx` (`STATION_idStation`)
) ENGINE=MYISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

--
-- Contraintes pour les tables exportées
--

--
-- Contraintes pour la table `h_data_hum`
--
ALTER TABLE `h_data_hum`
  ADD CONSTRAINT `fk_S_DATA_HUM_STATION110` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `h_data_pluie`
--
ALTER TABLE `h_data_pluie`
  ADD CONSTRAINT `fk_S_DATA_HUM_STATION10010` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `h_data_pre`
--
ALTER TABLE `h_data_pre`
  ADD CONSTRAINT `fk_S_DATA_HUM_STATION1010` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `h_data_temp`
--
ALTER TABLE `h_data_temp`
  ADD CONSTRAINT `fk_S_DATA_TEMP_STATION00` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `h_data_venti`
--
ALTER TABLE `h_data_venti`
  ADD CONSTRAINT `fk_S_DATA_HUM_STATION100010` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `h_data_ventm`
--
ALTER TABLE `h_data_ventm`
  ADD CONSTRAINT `fk_S_DATA_HUM_STATION1000000` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `j_data_hum`
--
ALTER TABLE `j_data_hum`
  ADD CONSTRAINT `fk_S_DATA_HUM_STATION111` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `j_data_pluie`
--
ALTER TABLE `j_data_pluie`
  ADD CONSTRAINT `fk_S_DATA_HUM_STATION10011` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `j_data_pre`
--
ALTER TABLE `j_data_pre`
  ADD CONSTRAINT `fk_S_DATA_HUM_STATION1011` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `j_data_temp`
--
ALTER TABLE `j_data_temp`
  ADD CONSTRAINT `fk_S_DATA_TEMP_STATION01` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `j_data_venti`
--
ALTER TABLE `j_data_venti`
  ADD CONSTRAINT `fk_S_DATA_HUM_STATION100011` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `j_data_ventm`
--
ALTER TABLE `j_data_ventm`
  ADD CONSTRAINT `fk_S_DATA_HUM_STATION1000001` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `m_data_hum`
--
ALTER TABLE `m_data_hum`
  ADD CONSTRAINT `fk_S_DATA_HUM_STATION11` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `m_data_pluie`
--
ALTER TABLE `m_data_pluie`
  ADD CONSTRAINT `fk_S_DATA_HUM_STATION1001` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `m_data_pre`
--
ALTER TABLE `m_data_pre`
  ADD CONSTRAINT `fk_S_DATA_HUM_STATION101` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `m_data_temp`
--
ALTER TABLE `m_data_temp`
  ADD CONSTRAINT `fk_S_DATA_TEMP_STATION0` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `m_data_venti`
--
ALTER TABLE `m_data_venti`
  ADD CONSTRAINT `fk_S_DATA_HUM_STATION10001` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `m_data_ventm`
--
ALTER TABLE `m_data_ventm`
  ADD CONSTRAINT `fk_S_DATA_HUM_STATION100000` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `s_data_hum`
--
ALTER TABLE `s_data_hum`
  ADD CONSTRAINT `fk_S_DATA_HUM_STATION1` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `s_data_pluie`
--
ALTER TABLE `s_data_pluie`
  ADD CONSTRAINT `fk_S_DATA_HUM_STATION100` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `s_data_pre`
--
ALTER TABLE `s_data_pre`
  ADD CONSTRAINT `fk_S_DATA_HUM_STATION10` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `s_data_temp`
--
ALTER TABLE `s_data_temp`
  ADD CONSTRAINT `fk_S_DATA_TEMP_STATION` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Contraintes pour la table `s_data_vent`
--
ALTER TABLE `s_data_vent`
  ADD CONSTRAINT `fk_S_DATA_HUM_STATION1000` FOREIGN KEY (`STATION_idStation`) REFERENCES `station` (`idStation`) ON DELETE NO ACTION ON UPDATE NO ACTION;

DELIMITER $$
--
-- Événements
--
CREATE DEFINER=`root`@`localhost` EVENT `toutesLesDixMinutes` ON SCHEDULE EVERY 10 MINUTE STARTS '2015-01-01 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
			-- on convertit les secondes (de vents) en minutes et on supprime les secondes de la minutes. 
			CALL moyenne_M_DATA_VENTM();
		END$$

CREATE DEFINER=`root`@`localhost` EVENT `toutesLesMinutes` ON SCHEDULE EVERY 1 MINUTE STARTS '2015-01-01 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
			-- on convertit les secondes (de température, pression, humidité, pluie) en minutes et on supprime les secondes de la minute. 
			CALL max_M_DATA_VENTI();
			CALL moyenne_M_DATA_TEMP();
			CALL cumul_M_DATA_PLUIE();
			CALL moyenne_M_DATA_PRE();
			CALL moyenne_M_DATA_HUM();
		END$$

CREATE DEFINER=`root`@`localhost` EVENT `toutesLesHeures` ON SCHEDULE EVERY 1 HOUR STARTS '2015-01-01 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
			-- on convertit les minutes en heures
			CALL max_H_DATA_VENTI();
			CALL moyenne_H_DATA_VENTM();
			CALL moyenne_H_DATA_TEMP();
			CALL cumul_H_DATA_PLUIE();
			CALL moyenne_H_DATA_PRE();
			CALL moyenne_H_DATA_HUM();
		END$$

CREATE DEFINER=`root`@`localhost` EVENT `tousLesJours` ON SCHEDULE EVERY 1 DAY STARTS '2015-01-01 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
			-- tous les jours, on convertit les heures de la veilles en jours et on supprime les heures de la veille.
			CALL max_J_DATA_VENTI();
			CALL moyenne_J_DATA_VENTM();
			CALL moyenne_J_DATA_TEMP();
			CALL cumul_J_DATA_PLUIE();
			CALL moyenne_J_DATA_PRE();
			CALL moyenne_J_DATA_HUM();
		END$$

CREATE DEFINER=`root`@`localhost` EVENT `tousLesAns` ON SCHEDULE EVERY 13 MONTH STARTS '2015-01-01 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    		-- on supprime toutes les occurences des tables J_ qui portent sur le premier mois enregistré.
			DELETE FROM j_data_venti WHERE (YEAR(j_data_venti.date) = YEAR(NOW())-1) && (MONTH(j_data_venti.date) = MONTH(NOW())-1);
			DELETE FROM j_data_ventm WHERE (YEAR(j_data_ventm.date) = YEAR(NOW())-1) && (MONTH(j_data_ventm.date) = MONTH(NOW())-1);
			DELETE FROM j_data_temp WHERE (YEAR(j_data_temp.date) = YEAR(NOW())-1) && (MONTH(j_data_temp.date) = MONTH(NOW())-1);
			DELETE FROM j_data_pluie WHERE (YEAR(j_data_pluie.date) = YEAR(NOW())-1) && (MONTH(j_data_pluie.date) = MONTH(NOW())-1);
			DELETE FROM j_data_pre WHERE (YEAR(j_data_pre.date) = YEAR(NOW())-1) && (MONTH(j_data_pre.date) = MONTH(NOW())-1);
			DELETE FROM j_data_hum WHERE (YEAR(j_data_hum.date) = YEAR(NOW())-1) && (MONTH(j_data_hum.date) = MONTH(NOW())-1);
		END$$

DELIMITER ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

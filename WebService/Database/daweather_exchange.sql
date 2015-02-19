SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+01:00";

CREATE DATABASE `daweather_exchange` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `daweather_exchange`;

CREATE TABLE IF NOT EXISTS `REQUEST` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `station_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `request` text NOT NULL,
  `response` text,
  `date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_REQUEST_STATION1_idx` (`station_id`),
  KEY `fk_REQUEST_USER1_idx` (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=53 ;

CREATE TABLE IF NOT EXISTS `STATION` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `nom` varchar(50) NOT NULL,
  `lieu` varchar(45) DEFAULT NULL,
  `altitude` varchar(45) DEFAULT NULL,
  `date_installation` datetime NOT NULL,
  `date_dernierPull` datetime DEFAULT NULL,
  `ip` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id_UNIQUE` (`user_id`),
  KEY `fk_STATION_USER_idx` (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

CREATE TABLE IF NOT EXISTS `USER` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(200) NOT NULL,
  `email` varchar(60) NOT NULL,
  `password` text NOT NULL,
  `remember_token` varchar(200) DEFAULT NULL,
  `privatekey` text NOT NULL,
  `dateInscription` datetime NOT NULL,
  `dateDerniereConnexion` datetime DEFAULT NULL,
  `ipDerniereConnexion` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_UNIQUE` (`email`),
  UNIQUE KEY `nom_UNIQUE` (`nom`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

ALTER TABLE `REQUEST`
  ADD CONSTRAINT `fk_REQUEST_STATION1` FOREIGN KEY (`station_id`) REFERENCES `STATION` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_REQUEST_USER1` FOREIGN KEY (`user_id`) REFERENCES `USER` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `STATION`
  ADD CONSTRAINT `fk_STATION_USER` FOREIGN KEY (`user_id`) REFERENCES `USER` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

DELIMITER $$
CREATE DEFINER=`pt_daweather`@`localhost` EVENT `tousLesHeures` ON SCHEDULE EVERY 2 HOUR STARTS '2015-01-01 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
DELETE FROM REQUEST WHERE MINUTE(`date`) < MINUTE(NOW())-5;
END$$
DELIMITER ;

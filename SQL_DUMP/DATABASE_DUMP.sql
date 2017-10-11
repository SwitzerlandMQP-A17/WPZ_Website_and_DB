CREATE DATABASE  IF NOT EXISTS `WPZ_Database_Prototype` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `WPZ_Database_Prototype`;
-- MySQL dump 10.13  Distrib 5.7.17, for macos10.12 (x86_64)
--
-- Host: localhost    Database: WPZ_Database_Prototype
-- ------------------------------------------------------
-- Server version	5.7.19

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Auftraggeber`
--

DROP TABLE IF EXISTS `Auftraggeber`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Auftraggeber` (
  `AuftraggeberID` int(11) NOT NULL AUTO_INCREMENT,
  `Auftraggeber` varchar(500) NOT NULL,
  `Adresse_Part1` varchar(500) DEFAULT NULL,
  `Adresse_Part2` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`AuftraggeberID`)
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Bauart`
--

DROP TABLE IF EXISTS `Bauart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Bauart` (
  `BauartID` int(11) NOT NULL AUTO_INCREMENT,
  `Bauart` varchar(500) NOT NULL,
  `Bauart_Bezeichnung_DE` varchar(2000) DEFAULT NULL,
  `Bauart_Bezeichnung_EN` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`BauartID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `BauartInfo`
--

DROP TABLE IF EXISTS `BauartInfo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `BauartInfo` (
  `IndexID` int(11) NOT NULL AUTO_INCREMENT,
  `InfoID` int(11) NOT NULL,
  `BauartID` int(11) NOT NULL,
  PRIMARY KEY (`IndexID`),
  UNIQUE KEY `InfoID` (`InfoID`,`BauartID`),
  KEY `FK_BauartInfo_BauartID` (`BauartID`),
  CONSTRAINT `FK_BauartInfo_BauartID` FOREIGN KEY (`BauartID`) REFERENCES `Bauart` (`BauartID`) ON DELETE CASCADE,
  CONSTRAINT `FK_BauartInfo_InfoID` FOREIGN KEY (`InfoID`) REFERENCES `Info` (`InfoID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=124 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Bedingung`
--

DROP TABLE IF EXISTS `Bedingung`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Bedingung` (
  `BedingungID` int(11) NOT NULL AUTO_INCREMENT,
  `Bedingung` varchar(200) NOT NULL,
  `Umgebungstemperatur` int(11) DEFAULT NULL,
  `Wasserversorgungstemperatur_Part1` int(11) DEFAULT NULL,
  `Wasserversorgungstemperatur_Part2` int(11) DEFAULT NULL,
  `Standardwert` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`BedingungID`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `test_standardwert_insert` BEFORE INSERT ON `Bedingung`
FOR EACH ROW
BEGIN
    IF (NEW.Standardwert NOT RLIKE '[0-1]') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Trying to insert a non-binary value [0-1].';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `test_standardwert_update` BEFORE UPDATE ON `Bedingung`
FOR EACH ROW
BEGIN
    IF (NEW.Standardwert NOT RLIKE '[0-1]') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Trying to insert a non-binary value [0-1].';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `BedingungenRelativ`
--

DROP TABLE IF EXISTS `BedingungenRelativ`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `BedingungenRelativ` (
  `IndexID` int(11) NOT NULL AUTO_INCREMENT,
  `BedingungID1` int(11) NOT NULL,
  `BedingungID2` int(11) NOT NULL,
  PRIMARY KEY (`IndexID`),
  KEY `BedingungID_idx` (`BedingungID1`),
  KEY `BedingungID_idx1` (`BedingungID2`),
  CONSTRAINT `FK_BedingungID1` FOREIGN KEY (`BedingungID1`) REFERENCES `Bedingung` (`BedingungID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_BedingungID2` FOREIGN KEY (`BedingungID2`) REFERENCES `Bedingung` (`BedingungID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Heizungstyp`
--

DROP TABLE IF EXISTS `Heizungstyp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Heizungstyp` (
  `HeizungstypID` int(11) NOT NULL AUTO_INCREMENT,
  `Heizungstyp` varchar(500) NOT NULL,
  `Heizungstyp_Bezeichnung_DE` varchar(2000) DEFAULT NULL,
  `Heizungstyp_Bezeichnung_EN` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`HeizungstypID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Info`
--

DROP TABLE IF EXISTS `Info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Info` (
  `InfoID` int(11) NOT NULL AUTO_INCREMENT,
  `Geraet` varchar(500) NOT NULL,
  `Geraet_Part1` varchar(500) DEFAULT NULL,
  `Geraet_Part2` varchar(500) DEFAULT NULL,
  `Pruefnummer` varchar(9) NOT NULL COMMENT '/^\\d\\d\\d-\\d\\d-\\d\\d$/',
  `Kaeltemittel_Typ1` varchar(500) NOT NULL,
  `Kaeltemittelmenge_Typ1` decimal(20,4) DEFAULT NULL,
  `Kaeltemittel_Typ2` varchar(500) DEFAULT NULL,
  `Kaeltemittelmenge_Typ2` decimal(20,4) DEFAULT NULL,
  `Produktart` varchar(500) DEFAULT NULL,
  `Bivalenzpunkt` varchar(500) DEFAULT NULL,
  `Bivalenzpunkt_Wert_1` int(11) DEFAULT NULL,
  `Bivalenzpunkt_Wert_2` int(11) DEFAULT NULL,
  `Volumenstrom_Standard` decimal(20,4) DEFAULT NULL,
  `Volumenstrom_V35` decimal(20,4) DEFAULT NULL,
  `Volumenstrom_V45` decimal(20,4) DEFAULT NULL,
  `Volumenstrom_V55` decimal(20,4) DEFAULT NULL,
  `SCOP` decimal(20,4) DEFAULT NULL,
  `Schall_Aussen` decimal(20,4) DEFAULT NULL,
  `Schall_Aussen_Bedingung` varchar(200) DEFAULT NULL,
  `Schall_Innen` decimal(20,4) DEFAULT NULL,
  `Schall_Innen_Bedingung` varchar(200) DEFAULT NULL,
  `Bemerkung` varchar(2000) DEFAULT NULL,
  `Bild` longblob,
  `Sichtbarkeit` tinyint(1) NOT NULL,
  PRIMARY KEY (`InfoID`)
) ENGINE=InnoDB AUTO_INCREMENT=212 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `test_pruefnummer_insert` BEFORE INSERT ON `Info`
FOR EACH ROW
BEGIN
    IF NOT (CHAR_LENGTH( NEW.Pruefnummer ) = 9) OR (NEW.Pruefnummer NOT RLIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Trying to insert an incorrectly formated pruefnummer.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `test_pruefnummer_update` BEFORE UPDATE ON `Info`
FOR EACH ROW
BEGIN
    IF NOT (CHAR_LENGTH( NEW.Pruefnummer ) = 9) OR (NEW.Pruefnummer NOT RLIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Trying to update with an incorrectly formated pruefnummer.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Kategorie`
--

DROP TABLE IF EXISTS `Kategorie`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Kategorie` (
  `KategorieID` int(11) NOT NULL AUTO_INCREMENT,
  `Kategorie` varchar(500) NOT NULL,
  `Kategorie_Bezeichnung_DE` varchar(2000) DEFAULT NULL,
  `Kategorie_Bezeichnung_EN` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`KategorieID`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Norm`
--

DROP TABLE IF EXISTS `Norm`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Norm` (
  `NormID` int(11) NOT NULL AUTO_INCREMENT,
  `Norm` varchar(500) NOT NULL,
  `Norm_Standard` int(11) NOT NULL,
  `Norm_Year` int(11) NOT NULL,
  PRIMARY KEY (`NormID`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `NormInfo`
--

DROP TABLE IF EXISTS `NormInfo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `NormInfo` (
  `IndexID` int(11) NOT NULL AUTO_INCREMENT,
  `NormID` int(11) NOT NULL,
  `InfoID` int(11) NOT NULL,
  PRIMARY KEY (`IndexID`),
  UNIQUE KEY `NormID` (`NormID`,`InfoID`),
  KEY `FK_NormInfo_InfoID` (`InfoID`),
  CONSTRAINT `FK_NormInfo_InfoID` FOREIGN KEY (`InfoID`) REFERENCES `Info` (`InfoID`) ON DELETE CASCADE,
  CONSTRAINT `FK_NormInfo_NormID` FOREIGN KEY (`NormID`) REFERENCES `Norm` (`NormID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=388 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Resultat`
--

DROP TABLE IF EXISTS `Resultat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Resultat` (
  `IndexID` int(11) NOT NULL AUTO_INCREMENT,
  `ResultatID` int(11) NOT NULL,
  `BedingungID` int(11) NOT NULL,
  `Heizleistung` decimal(20,4) DEFAULT NULL,
  `Leistungsaufnahme` decimal(20,4) DEFAULT NULL,
  `COP` decimal(20,4) DEFAULT NULL,
  `Luftfeuchtigkeit` int(11) DEFAULT NULL,
  PRIMARY KEY (`IndexID`),
  KEY `FK_Resultat_BedingungID` (`BedingungID`),
  CONSTRAINT `FK_Resultat_BedingungID` FOREIGN KEY (`BedingungID`) REFERENCES `Bedingung` (`BedingungID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1490 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Verbindung`
--

DROP TABLE IF EXISTS `Verbindung`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Verbindung` (
  `VerbindungID` int(11) NOT NULL AUTO_INCREMENT,
  `KategorieID` int(11) NOT NULL DEFAULT '-1',
  `HeizungstypID` int(11) NOT NULL,
  `AuftraggeberID` int(11) NOT NULL,
  `InfoID` int(11) NOT NULL DEFAULT '-1',
  `ResultatID` int(11) NOT NULL DEFAULT '-1',
  `Datum` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '/^\\d\\d\\d\\d-\\d\\d-\\d\\d \\d\\d:\\d\\d:\\d\\d$/',
  PRIMARY KEY (`VerbindungID`),
  KEY `FK_Verbindung_KategorieID` (`KategorieID`),
  KEY `FK_Verbindung_HeizungstypID` (`HeizungstypID`),
  KEY `FK_Verbindung_AuftraggeberID` (`AuftraggeberID`),
  CONSTRAINT `FK_Verbindung_AuftraggeberID` FOREIGN KEY (`AuftraggeberID`) REFERENCES `Auftraggeber` (`AuftraggeberID`) ON DELETE CASCADE,
  CONSTRAINT `FK_Verbindung_HeizungstypID` FOREIGN KEY (`HeizungstypID`) REFERENCES `Heizungstyp` (`HeizungstypID`) ON DELETE CASCADE,
  CONSTRAINT `FK_Verbindung_KategorieID` FOREIGN KEY (`KategorieID`) REFERENCES `Kategorie` (`KategorieID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=213 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'WPZ_Database_Prototype'
--

--
-- Dumping routines for database 'WPZ_Database_Prototype'
--
/*!50003 DROP PROCEDURE IF EXISTS `AddAuftraggeberLookup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddAuftraggeberLookup`(
            IN Auftraggeber_ VARCHAR(200),
            IN Adresse_Part1_ VARCHAR(200),
            IN Adresse_Part2_ VARCHAR(200),
            OUT Auftraggeber_ID INT
        )
BEGIN
        IF EXISTS (SELECT * FROM Auftraggeber AS A WHERE A.Auftraggeber = Auftraggeber_ AND A.Adresse_Part1 = Adresse_Part1_ AND A.Adresse_Part2 = Adresse_Part2_) THEN
            BEGIN
                SELECT A.AuftraggeberID FROM Auftraggeber AS A WHERE A.Auftraggeber = Auftraggeber_ AND A.Adresse_Part1 = Adresse_Part1_ AND A.Adresse_Part2 = Adresse_Part2_ LIMIT 1 INTO Auftraggeber_ID;
            END;
        ELSE
            BEGIN
                INSERT Auftraggeber (Auftraggeber,Adresse_Part1,Adresse_Part2) VALUES (Auftraggeber_, Adresse_Part1_, Adresse_Part2_);
                SELECT LAST_INSERT_ID() INTO Auftraggeber_ID;
            END;
		END IF;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddBauartInfoLookup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddBauartInfoLookup`(
            IN BauartID_ INT,
            IN InfoID_ INT
        )
BEGIN
        INSERT BauartInfo (InfoID, BauartID) VALUES (InfoID_, BauartID_);
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddBauartLookup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddBauartLookup`(
            IN Bauart VARCHAR(200),
            IN Bezeichnung_DE varchar(2000),
            IN Bezeichnung_EN varchar(2000),
            OUT BauartID INT
        )
BEGIN
        INSERT Bauart (Bauart,Bauart_Bezeichnung_DE,Bauart_Bezeichnung_EN) VALUES (Bauart, Bezeichnung_DE, Bezeichnung_EN);
        SELECT LAST_INSERT_ID() INTO BauartID;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddBedingungenRelativLookup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddBedingungenRelativLookup`(
		IN B_ID1 INT,
        IN B_ID2 INT
)
BEGIN
		INSERT INTO BedingungenRelativ (BedingungID1, BedingungID2) VALUES (B_ID1, B_ID2), (B_ID2, B_ID1);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddBedingungLookup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddBedingungLookup`(
        IN Bedingung_ VARCHAR(200),
        IN Umgebungstemperatur_ INT,
		IN Wasserversorgungstemperatur_Part1_ INT,
		IN Wasserversorgungstemperatur_Part2_ INT,
		IN Standardwert_ INT,
        OUT Bedingung_ID INT
    )
BEGIN
        IF EXISTS (SELECT * FROM Bedingung AS B WHERE B.Bedingung = Bedingung_ ) THEN
            BEGIN
                SELECT B.BedingungID FROM Bedingung AS B WHERE B.Bedingung = Bedingung_ LIMIT 1 INTO Bedingung_ID;
            END;
        ELSE
            BEGIN
                INSERT Bedingung (Bedingung,Umgebungstemperatur,Wasserversorgungstemperatur_Part1,Wasserversorgungstemperatur_Part2,Standardwert) VALUES (Bedingung_, Umgebungstemperatur_, Wasserversorgungstemperatur_Part1_, Wasserversorgungstemperatur_Part2_, Standardwert_);
				SELECT LAST_INSERT_ID() INTO Bedingung_ID;
            END;
		END IF;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddHeizungstypLookup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddHeizungstypLookup`(
            IN Heizungstyp VARCHAR(200),
            IN Heizungstyp_Bezeichnung_DE varchar(2000),
            IN Heizungstyp_Bezeichnung_EN varchar(2000),
            OUT HeizungstypID INT
        )
BEGIN
        INSERT Heizungstyp (Heizungstyp,Heizungstyp_Bezeichnung_DE,Heizungstyp_Bezeichnung_EN) VALUES (Heizungstyp, Heizungstyp_Bezeichnung_DE, Heizungstyp_Bezeichnung_EN);
        SELECT LAST_INSERT_ID() INTO HeizungstypID;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddInfoLookup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddInfoLookup`(
            IN Geraet varchar(200),
            IN Geraet_Part1 varchar(200),
            IN Geraet_Part2 varchar(200),
            IN Pruefnummer varchar(9),
            IN Kaeltemittel_Typ1 varchar(200),
            IN Kaeltemittelmenge_Typ1 decimal(20, 4),
            IN Kaeltemittel_Typ2 varchar(200),
            IN Kaeltemittelmenge_Typ2 decimal(20, 4),
            IN Produktart varchar(200),
            IN Bivalenzpunkt varchar(200),
            IN Bivalenzpunkt_Wert_1 int,
            IN Bivalenzpunkt_Wert_2 int,
            IN Volumenstrom_Standard decimal(20, 4),
            IN Volumenstrom_V35 decimal(20, 4),
            IN Volumenstrom_V45 decimal(20, 4),
            IN Volumenstrom_V55 decimal(20, 4),
            IN SCOP decimal(20, 4),
            IN Schall_Aussen decimal(20, 4),
            IN Schall_Aussen_Bedingung varchar(200),
            IN Schall_Innen decimal(20, 4),
            IN Schall_Innen_Bedingung varchar(200),
            IN Bemerkung varchar(200),
            IN Bild LONGBLOB,
            IN Sichtbarkeit TINYINT,
            OUT InfoID int
        )
BEGIN
        INSERT INTO Info (Geraet, Geraet_Part1, Geraet_Part2, Pruefnummer, Kaeltemittel_Typ1, Kaeltemittelmenge_Typ1, Kaeltemittel_Typ2, Kaeltemittelmenge_Typ2, Produktart, Bivalenzpunkt, Bivalenzpunkt_Wert_1, Bivalenzpunkt_Wert_2, Volumenstrom_Standard, Volumenstrom_V35, Volumenstrom_V45, Volumenstrom_V55, SCOP, Schall_Aussen, Schall_Aussen_Bedingung, Schall_Innen, Schall_Innen_Bedingung, Bemerkung, Bild, Sichtbarkeit) VALUES (Geraet, Geraet_Part1, Geraet_Part2, Pruefnummer, Kaeltemittel_Typ1, Kaeltemittelmenge_Typ1, Kaeltemittel_Typ2, Kaeltemittelmenge_Typ2, Produktart, Bivalenzpunkt, Bivalenzpunkt_Wert_1, Bivalenzpunkt_Wert_2, Volumenstrom_Standard, Volumenstrom_V35, Volumenstrom_V45, Volumenstrom_V55, SCOP, Schall_Aussen, Schall_Aussen_Bedingung, Schall_Innen, Schall_Innen_Bedingung, Bemerkung, Bild, Sichtbarkeit);
        SELECT LAST_INSERT_ID() INTO InfoID;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddNormInfoLookup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddNormInfoLookup`(
            IN NormID_ int,
            IN InfoID_ int
        )
BEGIN
        INSERT NormInfo (NormID, InfoID) VALUES (NormID_, InfoID_);
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddNormLookup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddNormLookup`(
            IN Norm VARCHAR(200),
            IN Norm_Standard VARCHAR(200),
            IN Norm_Year VARCHAR(200),
            OUT NormID INT
        )
BEGIN
        INSERT Norm (Norm, Norm_Standard, Norm_Year) VALUES (Norm, Norm_Standard, Norm_Year);
        SELECT LAST_INSERT_ID() INTO NormID;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddResultatLookup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddResultatLookup`(
            IN Resultat_ID INT,
            IN Bedingung_ID INT,
            IN Heizleistung_ DECIMAL(18, 4),
            IN Leistungsaufnahme_ DECIMAL(18, 4),
            IN COP_ DECIMAL(20, 4),
            IN Luftfeuchtigkeit_ INT,
            OUT Result_ID INT
        )
BEGIN
		IF Resultat_ID IS NULL THEN
			SET @R_ID = (SELECT MAX(ResultatID) FROM Resultat LIMIT 1) + 1;
			INSERT Resultat (ResultatID, BedingungID, Heizleistung, Leistungsaufnahme, COP, Luftfeuchtigkeit) VALUES (@R_ID, Bedingung_ID, Heizleistung_, Leistungsaufnahme_, COP_, Luftfeuchtigkeit_);
            SELECT @R_ID INTO Result_ID;
		ELSE
			INSERT Resultat (ResultatID, BedingungID, Heizleistung, Leistungsaufnahme, COP, Luftfeuchtigkeit) VALUES (Resultat_ID, Bedingung_ID, Heizleistung_, Leistungsaufnahme_, COP_, Luftfeuchtigkeit_);
			SELECT Resultat_ID INTO Result_ID;
        END IF;        
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddVerbindungLookup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddVerbindungLookup`(
            IN KategorieID_ int,
            IN HeizungstypID_ int,
            IN AuftraggeberID_ int,
            IN InfoID_ int,
            IN ResultatID_ int,
            IN Datum_ DATETIME,
            OUT VerbindungID int
        )
BEGIN
        INSERT Verbindung (KategorieID, HeizungstypID, AuftraggeberID, InfoID, ResultatID, Datum) VALUES (KategorieID_, HeizungstypID_, AuftraggeberID_, InfoID_, ResultatID_, Datum_);
        SELECT LAST_INSERT_ID() INTO VerbindungID;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAdvancedInfo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAdvancedInfo`(
		IN TestNumber Varchar(9),
        IN Info_ID INT
	)
BEGIN
		
        SET @BauartVal = (SELECT GROUP_CONCAT(B.Bauart SEPARATOR ' / ') FROM Bauart AS B, BauartInfo AS BI, Info AS I WHERE I.Pruefnummer = TestNumber AND I.InfoID = Info_ID AND I.InfoID = BI.InfoID AND BI.BauartID = B.BauartID);
		SET @BauartDesc_DE = (SELECT GROUP_CONCAT(B.Bauart_Bezeichnung_DE SEPARATOR ' / ') FROM Bauart AS B, BauartInfo AS BI, Info AS I WHERE I.Pruefnummer = TestNumber AND I.InfoID = Info_ID AND I.InfoID = BI.InfoID AND BI.BauartID = B.BauartID);
		SET @BauartDesc_EN = (SELECT GROUP_CONCAT(B.Bauart_Bezeichnung_EN SEPARATOR ' / ') FROM Bauart AS B, BauartInfo AS BI, Info AS I WHERE I.Pruefnummer = TestNumber AND I.InfoID = Info_ID AND I.InfoID = BI.InfoID AND BI.BauartID = B.BauartID);
		SET @NormVal = (SELECT GROUP_CONCAT(N.Norm SEPARATOR ' / ') FROM Norm AS N, NormInfo AS NI, Info AS I WHERE I.Pruefnummer = TestNumber AND I.InfoID = Info_ID AND I.InfoID = NI.InfoID AND NI.NormID = N.NormID);

		SELECT A.Auftraggeber,
					A.Adresse_Part1,
					A.Adresse_Part2,
					@BauartVal AS Bauart,
					@BauartDesc_DE AS Bauart_Bezeichnung_DE,
					@BauartDesc_EN AS Bauart_Bezeichnung_EN,
					H.Heizungstyp,
					H.Heizungstyp_Bezeichnung_DE,
					H.Heizungstyp_Bezeichnung_EN,
					I.Geraet,
					I.Pruefnummer,
					I.Kaeltemittel_Typ1,
					I.Kaeltemittelmenge_Typ1,
					I.Kaeltemittel_Typ2,
					I.Kaeltemittelmenge_Typ2,
					I.Produktart,
					I.Bivalenzpunkt,
					I.Volumenstrom_Standard,
					I.Volumenstrom_V35,
					I.Volumenstrom_V45,
					I.Volumenstrom_V55,
					I.SCOP,
					I.Schall_Aussen,
					I.Schall_Aussen_Bedingung,
					I.Schall_Innen,
					I.Schall_Innen_Bedingung,
					I.Bemerkung,
					K.Kategorie,
					K.Kategorie_Bezeichnung_DE,
					K.Kategorie_Bezeichnung_EN,
					@NormVal AS Norm
        FROM Auftraggeber AS A,
                    Heizungstyp AS H,
                    (SELECT * FROM Info WHERE Pruefnummer = TestNumber AND InfoID = Info_ID) AS I,
                    Kategorie AS K,
                    Verbindung AS V
		WHERE
                    I.InfoID = V.InfoID
                    AND A.AuftraggeberID = V.AuftraggeberID
                    AND H.HeizungstypID = V.HeizungstypID
                    AND K.KategorieID = V.KategorieID;
                    
		SELECT B.Bedingung,
                       B.Standardwert,
                       R.Heizleistung,
                       R.Leistungsaufnahme,
                       R.COP,
                       R.Luftfeuchtigkeit
        FROM Bedingung AS B,
                    (SELECT InfoID FROM Info WHERE Pruefnummer = TestNumber AND InfoID = Info_ID) AS I,
                    Resultat AS R,
                    Verbindung AS V
		WHERE
					I.InfoID = V.InfoID
                    AND V.ResultatID = R.ResultatID
                    AND B.BedingungID = R.BedingungID;
        
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetBedingungID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetBedingungID`(
        IN Bedingung_innen VARCHAR(200),
        OUT ID int
    )
BEGIN
        Select BedingungID FROM Bedingung WHERE Bedingung = Bedingung_innen LIMIT 1 INTO ID;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetComparisonInfo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetComparisonInfo`(
            IN InfoID1 INT,
            IN InfoID2 INT, 
            IN InfoID3 INT, 
            IN InfoID4 INT, 
            IN InfoID5 INT,
            IN Standard_BedingungID INT
        )
BEGIN
		IF InfoID1 IS NOT NULL THEN
				SELECT A.Auftraggeber, 
								I.Geraet, 
								I.Kaeltemittel_Typ1, 
								I.Kaeltemittelmenge_Typ1,  
								I.Kaeltemittel_Typ2, 
								I.Kaeltemittelmenge_Typ2, 
								I.Schall_Aussen,
                                I.Schall_Aussen_Bedingung,
                                I.Schall_Innen,
                                I.Schall_Innen_Bedingung,
								H.Heizungstyp_Bezeichnung_DE, 
                                H.Heizungstyp_Bezeichnung_EN,
								I.SCOP, 
								I.InfoID, 
								R.Heizleistung, 
								R.Leistungsaufnahme, 
								R.COP, 
								B.Bedingung, 
								I.Bemerkung,
								I.Pruefnummer,
                                (SELECT Bauart FROM Bauart AS BA, BauartInfo AS B WHERE B.InfoID = I.InfoID AND B.BauartID = BA.BauartID AND (BA.BauartID = 4 OR BA.BauartID = 5) LIMIT 1) AS Bauart
				FROM Info AS I, 
						Auftraggeber AS A, 
                        Bedingung AS B, 
                        Resultat AS R, 
                        Verbindung AS V, 
                        Heizungstyp AS H 
                WHERE V.InfoID = InfoID1 
						AND I.InfoID = InfoID1 
                        AND R.ResultatID = V.ResultatID 
                        AND B.BedingungID = Standard_BedingungID 
                        AND R.BedingungID = Standard_BedingungID 
                        AND V.AuftraggeberID = A.AuftraggeberID 
                        AND V.HeizungstypID = H.HeizungstypID;
        ELSE
			SELECT 'NULL';
        END IF;
        
        IF InfoID2 IS NOT NULL THEN
				SELECT A.Auftraggeber, 
								I.Geraet, 
								I.Kaeltemittel_Typ1, 
								I.Kaeltemittelmenge_Typ1,  
								I.Kaeltemittel_Typ2, 
								I.Kaeltemittelmenge_Typ2, 
								I.Schall_Aussen,
                                I.Schall_Aussen_Bedingung,
                                I.Schall_Innen,
                                I.Schall_Innen_Bedingung,
								H.Heizungstyp_Bezeichnung_DE, 
                                H.Heizungstyp_Bezeichnung_EN,
								I.SCOP, 
								I.InfoID, 
								R.Heizleistung, 
								R.Leistungsaufnahme, 
								R.COP, 
								B.Bedingung, 
								I.Bemerkung,
								I.Pruefnummer,
                                (SELECT Bauart FROM Bauart AS BA, BauartInfo AS B WHERE B.InfoID = I.InfoID AND B.BauartID = BA.BauartID AND (BA.BauartID = 4 OR BA.BauartID = 5) LIMIT 1) AS Bauart
				FROM Info AS I, 
						Auftraggeber AS A, 
                        Bedingung AS B, 
                        Resultat AS R, 
                        Verbindung AS V, 
                        Heizungstyp AS H 
                WHERE V.InfoID = InfoID2 
						AND I.InfoID = InfoID2 
                        AND R.ResultatID = V.ResultatID 
                        AND B.BedingungID = Standard_BedingungID 
                        AND R.BedingungID = Standard_BedingungID 
                        AND V.AuftraggeberID = A.AuftraggeberID 
                        AND V.HeizungstypID = H.HeizungstypID;
        ELSE
			SELECT 'NULL';
        END IF;
        
        IF InfoID3 IS NOT NULL THEN
				SELECT A.Auftraggeber, 
								I.Geraet, 
								I.Kaeltemittel_Typ1, 
								I.Kaeltemittelmenge_Typ1,  
								I.Kaeltemittel_Typ2, 
								I.Kaeltemittelmenge_Typ2, 
								I.Schall_Aussen,
                                I.Schall_Aussen_Bedingung,
                                I.Schall_Innen,
                                I.Schall_Innen_Bedingung,
								H.Heizungstyp_Bezeichnung_DE, 
                                H.Heizungstyp_Bezeichnung_EN,
								I.SCOP, 
								I.InfoID, 
								R.Heizleistung, 
								R.Leistungsaufnahme, 
								R.COP, 
								B.Bedingung, 
								I.Bemerkung,
								I.Pruefnummer,
                                (SELECT Bauart FROM Bauart AS BA, BauartInfo AS B WHERE B.InfoID = I.InfoID AND B.BauartID = BA.BauartID AND (BA.BauartID = 4 OR BA.BauartID = 5) LIMIT 1) AS Bauart
				FROM Info AS I, 
						Auftraggeber AS A, 
                        Bedingung AS B, 
                        Resultat AS R, 
                        Verbindung AS V, 
                        Heizungstyp AS H 
                WHERE V.InfoID = InfoID3 
						AND I.InfoID = InfoID3 
                        AND R.ResultatID = V.ResultatID 
                        AND B.BedingungID = Standard_BedingungID 
                        AND R.BedingungID = Standard_BedingungID 
                        AND V.AuftraggeberID = A.AuftraggeberID 
                        AND V.HeizungstypID = H.HeizungstypID;
        ELSE
			SELECT 'NULL';
        END IF;
        
        IF InfoID4 IS NOT NULL THEN
				SELECT A.Auftraggeber, 
								I.Geraet, 
								I.Kaeltemittel_Typ1, 
								I.Kaeltemittelmenge_Typ1,  
								I.Kaeltemittel_Typ2, 
								I.Kaeltemittelmenge_Typ2, 
								I.Schall_Aussen,
                                I.Schall_Aussen_Bedingung,
                                I.Schall_Innen,
                                I.Schall_Innen_Bedingung,
								H.Heizungstyp_Bezeichnung_DE, 
                                H.Heizungstyp_Bezeichnung_EN,
								I.SCOP, 
								I.InfoID, 
								R.Heizleistung, 
								R.Leistungsaufnahme, 
								R.COP, 
								B.Bedingung, 
								I.Bemerkung,
								I.Pruefnummer,
                                (SELECT Bauart FROM Bauart AS BA, BauartInfo AS B WHERE B.InfoID = I.InfoID AND B.BauartID = BA.BauartID AND (BA.BauartID = 4 OR BA.BauartID = 5) LIMIT 1) AS Bauart
				FROM Info AS I, 
						Auftraggeber AS A, 
                        Bedingung AS B, 
                        Resultat AS R, 
                        Verbindung AS V, 
                        Heizungstyp AS H 
                WHERE V.InfoID = InfoID4 
						AND I.InfoID = InfoID4 
                        AND R.ResultatID = V.ResultatID 
                        AND B.BedingungID = Standard_BedingungID 
                        AND R.BedingungID = Standard_BedingungID 
                        AND V.AuftraggeberID = A.AuftraggeberID 
                        AND V.HeizungstypID = H.HeizungstypID;
        ELSE
			SELECT 'NULL';
        END IF;
        
        IF InfoID5 IS NOT NULL THEN
			SELECT A.Auftraggeber, 
								I.Geraet, 
								I.Kaeltemittel_Typ1, 
								I.Kaeltemittelmenge_Typ1,  
								I.Kaeltemittel_Typ2, 
								I.Kaeltemittelmenge_Typ2, 
								I.Schall_Aussen,
                                I.Schall_Aussen_Bedingung,
                                I.Schall_Innen,
                                I.Schall_Innen_Bedingung,
								H.Heizungstyp_Bezeichnung_DE, 
                                H.Heizungstyp_Bezeichnung_EN,
								I.SCOP, 
								I.InfoID, 
								R.Heizleistung, 
								R.Leistungsaufnahme, 
								R.COP, 
								B.Bedingung, 
								I.Bemerkung,
								I.Pruefnummer,
                                (SELECT Bauart FROM Bauart AS BA, BauartInfo AS B WHERE B.InfoID = I.InfoID AND B.BauartID = BA.BauartID AND (BA.BauartID = 4 OR BA.BauartID = 5) LIMIT 1) AS Bauart
				FROM Info AS I, 
						Auftraggeber AS A, 
                        Bedingung AS B, 
                        Resultat AS R, 
                        Verbindung AS V, 
                        Heizungstyp AS H 
                WHERE V.InfoID = InfoID5 
						AND I.InfoID = InfoID5 
                        AND R.ResultatID = V.ResultatID 
                        AND B.BedingungID = Standard_BedingungID 
                        AND R.BedingungID = Standard_BedingungID 
                        AND V.AuftraggeberID = A.AuftraggeberID 
                        AND V.HeizungstypID = H.HeizungstypID;
        ELSE
			SELECT 'NULL';
        END IF;
            
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetMaxResultatID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMaxResultatID`(
            OUT Resultat_ID int
        )
BEGIN
        SET @result_ID = (SELECT MAX(ResultatID) FROM Resultat LIMIT 1);
        IF (@result_ID IS NULL) THEN
            SET @result_ID = 0;
        END IF; 
        SELECT @result_ID + 1 INTO Resultat_ID;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetNormID` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetNormID`(
            IN Norm_ VARCHAR(200),
            OUT Norm_ID INT
        )
BEGIN
    
			SET @ID = (SELECT NormID FROM Norm WHERE Norm = Norm_ LIMIT 1);
            SELECT @ID INTO Norm_ID;
            
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InsertTestResult` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertTestResult`(
            IN CustomerID INT,
            IN GeraetPart1 VARCHAR(100),
            IN GeraetPart2 VARCHAR(100),
            IN TestNumber VARCHAR(9),
            IN Category_ID INT,
            IN HeatingType_ID INT,
            IN Result_ID INT,
            IN Bauart_ID INT,
            IN Produktart_ VARCHAR(10),
            IN Refrigerant_Type1 VARCHAR(50),
            IN Refrigerant_Capacity1 DECIMAL(20,4),
            IN Refrigerant_Type2 VARCHAR(50),
            IN Refrigerant_Capacity2 DECIMAL(20,4),
            IN Volume_Flow_Standard DECIMAL(20,4),
            IN Volume_Flow_V35 DECIMAL(20,4),
            IN Volume_Flow_V45 DECIMAL(20,4),
            IN Volume_Flow_V55 DECIMAL(20,4),
            IN SCOP_ DECIMAL(20,4),
            IN Bivalence_Point VARCHAR(100),
            IN Bivalence_Point_Val1 INT,
            IN Bivalence_Point_Val2 INT,
            IN Volume_Outdoor DECIMAL(20,4),
            IN Volume_Outdoor_Conditions VARCHAR(50),
            IN Volume_Indoor DECIMAL(20,4),
            IN Volume_Indoor_Conditions VARCHAR(50),
            IN Comments VARCHAR(200),
            IN Visibility TINYINT,
            OUT Info_ID INT
        )
BEGIN
    
			SET @AuftraggeberID = CustomerID;
                    
            CALL AddInfoLookup(
					CONCAT_WS(' ', GeraetPart1, GeraetPart2), 
                    GeraetPart1, 
                    GeraetPart2, 
                    TestNumber, 
                    Refrigerant_Type1, 
                    Refrigerant_Capacity1, 
                    Refrigerant_Type2, 
                    Refrigerant_Capacity2, 
                    Produktart_, 
                    Bivalence_Point, 
                    Bivalence_Point_Val1, 
                    Bivalence_Point_Val2, 
                    Volume_Flow_Standard,
                    Volume_Flow_V35,
                    Volume_Flow_V45,
                    Volume_Flow_V55,
                    SCOP_,
                    Volume_Outdoor,
                    Volume_Outdoor_Conditions,
                    Volume_Indoor,
                    Volume_Indoor_Conditions,
                    Comments,
                    NULL,
                    Visibility,
                    @InfoID);
                    
			CALL AddBauartInfoLookup(Bauart_ID, @InfoID);
                    
			CALL AddVerbindungLookup(
					Category_ID,
                    HeatingType_ID,
                    @AuftraggeberID,
                    @InfoID,
                    @ResultatID,
                    NOW(),
                    @VerbindungID);
			
            SELECT @InfoID INTO Info_ID;
            
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `LoadInfoForInsert` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `LoadInfoForInsert`(
        
    )
BEGIN
		
        SELECT * FROM Kategorie;
        SELECT * FROM Heizungstyp;
        SELECT * FROM Auftraggeber ORDER BY Auftraggeber;
        SELECT * FROM Bauart;
        SELECT NormID, Norm FROM Norm ORDER BY Norm_Standard, Norm_Year;
        SELECT BedingungID, Bedingung, Standardwert FROM Bedingung ORDER BY SUBSTRING(Bedingung, 1, 1) ASC, SIGN(Umgebungstemperatur) DESC, ABS(Umgebungstemperatur)DESC;
    
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SearchForPumps` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SearchForPumps`(
            IN Pump_Category1 INT,
            IN Pump_Category2 INT,
            IN User_Heating_Type INT,
            IN User_Power_Consumption DECIMAL(20, 4),
            IN User_Temp INT,
            IN Water_Supply_Temp INT,
            IN Recursive_Stack_Num INT
        )
BEGIN
		SET max_sp_recursion_depth=1;
        /* FIND THE TEST CONDITION THAT BEST FITS THE USER PROVIDED INFORMATION */
		SET @Regex = CASE Pump_Category1 WHEN 1 THEN '^A' WHEN 2 THEN '^B' ELSE '^W' END;
        SET @Secondary_Heating_Type = IF(User_Heating_Type != 2, User_Heating_Type, 0);
        SET @Closest_Condition = (SELECT BedingungID FROM 
					(SELECT R.BedingungID, Count(R.BedingungID) AS Num_Results 
					FROM 
							(SELECT B.BedingungID, B.Bedingung, ABS(MIN(B.Umgebungstemperatur - User_Temp)) AS Min_Val, ABS(MIN(B.Wasserversorgungstemperatur_Part2 - Water_Supply_Temp)) AS Min_Temp
							FROM 
								(SELECT B.BedingungID, B.Bedingung, B.Umgebungstemperatur, B.Wasserversorgungstemperatur_Part1, B.Wasserversorgungstemperatur_Part2, B.Standardwert 
									FROM Bedingung AS B, Verbindung AS V, Resultat AS R 
                                    WHERE B.Bedingung RLIKE @Regex 
											AND (V.HeizungstypID = 2 OR V.HeizungstypID = @Secondary_Heating_Type)
                                            AND V.ResultatID = R.ResultatID 
                                            AND R.BedingungID = B.BedingungID) AS B 
							WHERE Umgebungstemperatur IS NOT NULL 
                            GROUP BY (BedingungID) 
                            ORDER BY Min_Val ASC, Min_Temp ASC, BedingungID ASC) AS B,
							Resultat AS R
					WHERE R.BedingungID = B.BedingungID
					GROUP BY R.BedingungID
					ORDER BY B.Min_Temp ASC, B.Min_Val ASC, Num_Results DESC) AS B LIMIT 1);
        
        #SELECT Bedingung, User_Heating_Type, @Secondary_Heating_Type from Bedingung where BedingungID = @Closest_Condition;
        #SELECT * FROM Bedingung WHERE BedingungID = @Closest_Condition;
        
        /* CALCULATE THE INPUT POWER */
        IF Pump_Category1 = 1 THEN
			SET @Power = (User_Power_Consumption * (1 + (0.02 * (User_Temp - (SELECT Umgebungstemperatur FROM Bedingung WHERE BedingungID = @Closest_Condition LIMIT 1)))));
        ELSE 
			SET @Power = (User_Power_Consumption * (1 + (0.027 * (User_Temp - (SELECT Umgebungstemperatur FROM Bedingung WHERE BedingungID = @Closest_Condition LIMIT 1)))) * (1 - (0.005 * (Water_Supply_Temp - (SELECT Wasserversorgungstemperatur_Part2 FROM Bedingung WHERE BedingungID = @Closest_Condition LIMIT 1)))));
        END IF;
        #SELECT @Power AS Power;
        
        /* CALCULATE WITHIN +- 15% OF THE CALCULATED AND QUERY THE PUMPS THAT ARE WITHIN THAT RANGE */
        SET @Percentage = 0.20;
        SET @Percent_Value = round(@Power * @Percentage, 4);
        SET @Plus_Value = @Power + @Percent_Value;
        SET @Minus_Value = @Power - @Percent_Value;
        
        #SELECT @Plus_Value AS Plus_15, @Minus_Value AS Minus_15;
        
        IF (Recursive_Stack_Num < 1) THEN
        
				IF EXISTS (SELECT * FROM Resultat WHERE ResultatID IN 
												(SELECT ResultatID 
												FROM Resultat AS R
												WHERE (R.BedingungID IN (SELECT BedingungID2 FROM BedingungenRelativ WHERE BedingungID1 = @Closest_Condition) OR R.BedingungID = @Closest_Condition) AND R.Heizleistung >= @Minus_Value AND R.Heizleistung <= @Plus_Value
												ORDER BY ResultatID ASC)) THEN
						
						SELECT 
											A.Auftraggeber, 
											I.Geraet, 
											I.Kaeltemittel_Typ1, 
											H.Heizungstyp_Bezeichnung_DE,
											H.Heizungstyp_Bezeichnung_EN,
											I.InfoID, 
											I.Schall_Aussen, 
											R.Heizleistung, 
											R.COP, 
											B.Bedingung, 
											B.BedingungID,
											I.Bemerkung,
											I.Pruefnummer,
											@Power AS CalculatedPower,
											(SELECT Bauart FROM Bauart AS BA, BauartInfo AS B WHERE B.InfoID = I.InfoID AND B.BauartID = BA.BauartID AND (BA.BauartID = 4 OR BA.BauartID = 5) LIMIT 1) AS Bauart,
											(SELECT Heizleistung FROM Resultat WHERE BedingungID = @Closest_Condition AND ResultatID = R.ResultatID) AS ClosestPower,
											(SELECT Bedingung FROM Bedingung WHERE BedingungID = @Closest_Condition) AS ExtrapolatedCondition,
                                            R.ResultatID
										FROM 
											Info AS I, 
											(SELECT * FROM Heizungstyp WHERE HeizungstypID = @Secondary_Heating_Type OR HeizungstypID = 2) AS H, 
											(SELECT * FROM Verbindung WHERE KategorieID = Pump_Category1 OR KategorieID = Pump_Category2) AS V, 
											(SELECT * FROM Auftraggeber) AS A, 
											(SELECT * FROM Resultat WHERE ResultatID IN 
													(SELECT ResultatID 
													FROM Resultat AS R
													WHERE (R.BedingungID IN (SELECT BedingungID2 FROM BedingungenRelativ WHERE BedingungID1 = @Closest_Condition) OR R.BedingungID = @Closest_Condition) AND R.Heizleistung >= @Minus_Value AND R.Heizleistung <= @Plus_Value
													ORDER BY ResultatID ASC)) AS R, 
											(SELECT * FROM Bedingung WHERE Wasserversorgungstemperatur_Part2 = Water_Supply_Temp) AS B
										WHERE 
											V.InfoID = I.InfoID 
											AND V.AuftraggeberID = A.AuftraggeberID 
											AND V.HeizungstypID = H.HeizungstypID 
											AND V.ResultatID = R.ResultatID 
											AND R.BedingungID = B.BedingungID
											AND B.Standardwert = 1
										ORDER BY ABS((@Power) - (ClosestPower)) ASC;
						
				ELSE
				
						CALL SearchForPumps(Pump_Category1, Pump_Category2, 2, User_Power_Consumption, User_Temp, Water_Supply_Temp, (Recursive_Stack_Num + 1));
							
				END IF;
        
        ELSE
			
					SELECT 
								A.Auftraggeber, 
								I.Geraet, 
								I.Kaeltemittel_Typ1, 
								H.Heizungstyp_Bezeichnung_DE,
								H.Heizungstyp_Bezeichnung_EN,
								I.InfoID, 
								I.Schall_Aussen, 
								R.Heizleistung, 
								R.COP, 
								B.Bedingung, 
								B.BedingungID,
								I.Bemerkung,
								I.Pruefnummer,
								@Power AS CalculatedPower,
								(SELECT Bauart FROM Bauart AS BA, BauartInfo AS B WHERE B.InfoID = I.InfoID AND B.BauartID = BA.BauartID AND (BA.BauartID = 4 OR BA.BauartID = 5) LIMIT 1) AS Bauart,
								(SELECT Heizleistung FROM Resultat WHERE BedingungID = @Closest_Condition AND ResultatID = R.ResultatID) AS ClosestPower,
								(SELECT Bedingung FROM Bedingung WHERE BedingungID = @Closest_Condition) AS ExtrapolatedCondition,
                                R.ResultatID
							FROM 
								Info AS I, 
								(SELECT * FROM Heizungstyp WHERE HeizungstypID = @Secondary_Heating_Type OR HeizungstypID = 2) AS H, 
								(SELECT * FROM Verbindung WHERE KategorieID = Pump_Category1 OR KategorieID = Pump_Category2) AS V, 
								(SELECT * FROM Auftraggeber) AS A, 
								(SELECT * FROM Resultat WHERE ResultatID IN 
										(SELECT ResultatID 
										FROM Resultat AS R
										WHERE (R.BedingungID IN (SELECT BedingungID2 FROM BedingungenRelativ WHERE BedingungID1 = @Closest_Condition) OR R.BedingungID = @Closest_Condition) AND R.Heizleistung >= @Minus_Value AND R.Heizleistung <= @Plus_Value
										ORDER BY ResultatID ASC)) AS R, 
								(SELECT * FROM Bedingung WHERE Wasserversorgungstemperatur_Part2 = Water_Supply_Temp) AS B
							WHERE 
								V.InfoID = I.InfoID 
								AND V.AuftraggeberID = A.AuftraggeberID 
								AND V.HeizungstypID = H.HeizungstypID 
								AND V.ResultatID = R.ResultatID 
								AND R.BedingungID = B.BedingungID
								AND B.Standardwert = 1
							ORDER BY ABS((@Power) - (ClosestPower)) ASC;
            
        END IF;
        
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SearchForPumpsByElectricity` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SearchForPumpsByElectricity`(
			IN Pump_Category1 INT,
            IN Pump_Category2 INT,
            IN User_Heating_Type INT,
            IN Elec_Amount INT,
            IN Had_Water_Heater TINYINT
        )
BEGIN
		SET @Regex = CASE Pump_Category1 WHEN 1 THEN '^A' WHEN 2 THEN '^B' ELSE '^W' END;
        SET @Heating_Type_Regex = CONCAT(@Regex, IF(User_Heating_Type = 3, '.*55$', '.*35$'));
		SET @t_annual = IF(Had_Water_Heater = 0, 2300, 2700);
        SET @Secondary_Heating_Type = IF(User_Heating_Type != 2, User_Heating_Type, 0);
        SET @Power = (Elec_Amount / @t_annual);
        
        /* CALCULATE WITHIN +- 15% OF THE CALCULATED AND QUERY THE PUMPS THAT ARE WITHIN THAT RANGE */
        SET @Percentage = 0.20;
        SET @Percent_Value = round(@Power * @Percentage, 4);
        SET @Plus_Value = @Power + @Percent_Value;
        SET @Minus_Value = @Power - @Percent_Value;
        
        #SELECT @Power AS Power, @Plus_Value AS Plus_15, @Minus_Value AS Minus_15;
        
        SELECT 
			A.Auftraggeber, 
			I.Geraet, 
			I.Kaeltemittel_Typ1, 
            H.Heizungstyp_Bezeichnung_DE, 
            H.Heizungstyp_Bezeichnung_EN,
            I.InfoID, 
            I.Schall_Aussen, 
            R.Heizleistung, 
            R.COP, 
            B.Bedingung, 
            B.BedingungID,
            I.Bemerkung,
            I.Pruefnummer,
            @Power AS CalculatedPower,
            (SELECT Bauart FROM Bauart AS BA, BauartInfo AS B WHERE B.InfoID = I.InfoID AND B.BauartID = BA.BauartID AND (BA.BauartID = 4 OR BA.BauartID = 5) LIMIT 1) AS Bauart
        FROM 
			Info AS I, 
            (SELECT * FROM Heizungstyp WHERE HeizungstypID = 2 OR HeizungstypID = @Secondary_Heating_Type) AS H, 
            (SELECT * FROM Verbindung WHERE KategorieID = Pump_Category1 OR KategorieID = Pump_Category2) AS V, 
            (SELECT * FROM Auftraggeber) AS A, 
            (SELECT * FROM Resultat WHERE ResultatID IN 
					(SELECT ResultatID 
					FROM Resultat AS R
					WHERE R.Heizleistung >= @Minus_Value AND R.Heizleistung <= @Plus_Value
					ORDER BY R.ResultatID ASC)) AS R, 
            (SELECT * FROM Bedingung WHERE Bedingung RLIKE @Heating_Type_Regex) AS B 
        WHERE 
			V.InfoID = I.InfoID 
			AND V.AuftraggeberID = A.AuftraggeberID 
            AND V.HeizungstypID = H.HeizungstypID 
            AND V.ResultatID = R.ResultatID 
            AND R.BedingungID = B.BedingungID
            AND B.Standardwert = 1
        ORDER BY ABS((@Power) - (R.Heizleistung)) ASC;
            
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SearchForPumpsByGas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SearchForPumpsByGas`(
			IN Pump_Category1 INT,
            IN Pump_Category2 INT,
            IN User_Heating_Type INT,
            IN Gas_Amount INT,
            IN Had_Water_Heater TINYINT
        )
BEGIN
		SET @Secondary_Heating_Type = IF(User_Heating_Type != 2, User_Heating_Type, 0);
        SET @Regex = CASE Pump_Category1 WHEN 1 THEN '^A' WHEN 2 THEN '^B' ELSE '^W' END;
        SET @Heating_Type_Regex = CONCAT(@Regex, IF(User_Heating_Type = 3, '.*55$', '.*35$'));
		SET @t_annual = IF(Had_Water_Heater = 0, 2300, 2700);
        SET @Efficiency_old = 0.9;
        SET @Heating_Value = 10;
        
        #SELECT Gas_Amount, @Heating_Value, @t_annual, @Efficiency_old;
        
        SET @Power = ((Gas_Amount * @Heating_Value) / @t_annual) * (@Efficiency_old);
        
        /* CALCULATE WITHIN +- 15% OF THE CALCULATED AND QUERY THE PUMPS THAT ARE WITHIN THAT RANGE */
        SET @Percentage = 0.20;
        SET @Percent_Value = round(@Power * @Percentage, 4);
        SET @Plus_Value = @Power + @Percent_Value;
        SET @Minus_Value = @Power - @Percent_Value;
        
        #SELECT @Power AS Power, @Plus_Value AS Plus_15, @Minus_Value AS Minus_15;
        
        SELECT 
			A.Auftraggeber, 
			I.Geraet, 
			I.Kaeltemittel_Typ1, 
            H.Heizungstyp_Bezeichnung_DE, 
            H.Heizungstyp_Bezeichnung_EN,
            I.InfoID, 
            I.Schall_Aussen, 
            R.Heizleistung, 
            R.COP, 
            B.Bedingung, 
            B.BedingungID,
            I.Bemerkung,
            I.Pruefnummer,
            @Power AS CalculatedPower,
            (SELECT Bauart FROM Bauart AS BA, BauartInfo AS B WHERE B.InfoID = I.InfoID AND B.BauartID = BA.BauartID AND (BA.BauartID = 4 OR BA.BauartID = 5) LIMIT 1) AS Bauart
        FROM 
			Info AS I, 
            (SELECT * FROM Heizungstyp WHERE HeizungstypID = 2 OR HeizungstypID = @Secondary_Heating_Type) AS H, 
            (SELECT * FROM Verbindung WHERE KategorieID = Pump_Category1 OR KategorieID = Pump_Category2) AS V, 
            (SELECT * FROM Auftraggeber) AS A, 
            (SELECT * FROM Resultat WHERE ResultatID IN 
					(SELECT ResultatID 
					FROM Resultat AS R
					WHERE R.Heizleistung >= @Minus_Value AND R.Heizleistung <= @Plus_Value
					ORDER BY R.ResultatID ASC)) AS R, 
            (SELECT * FROM Bedingung WHERE Bedingung RLIKE @Heating_Type_Regex) AS B 
        WHERE 
			V.InfoID = I.InfoID 
			AND V.AuftraggeberID = A.AuftraggeberID 
            AND V.HeizungstypID = H.HeizungstypID 
            AND V.ResultatID = R.ResultatID 
            AND R.BedingungID = B.BedingungID
            AND B.Standardwert = 1
        ORDER BY ABS((@Power) - (R.Heizleistung)) ASC;
            
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SearchForPumpsByOil` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SearchForPumpsByOil`(
			IN Pump_Category1 INT,
            IN Pump_Category2 INT,
            IN User_Heating_Type INT,
            IN Oil_Amount INT,
            IN Had_Water_Heater TINYINT
        )
BEGIN
		SET @Secondary_Heating_Type = IF(User_Heating_Type != 2, User_Heating_Type, 0);
		SET @Regex = CASE Pump_Category1 WHEN 1 THEN '^A' WHEN 2 THEN '^B' ELSE '^W' END;
        SET @Heating_Type_Regex = CONCAT(@Regex, IF(User_Heating_Type = 3, '.*55$', '.*35$'));
		SET @t_annual = IF(Had_Water_Heater = 0, 2300, 2700);
        SET @Efficiency_old = 0.8;
        SET @Heating_Value = 9;
        
        #SELECT Oil_Amount, @Heating_Value, @t_annual, @Efficiency_old;
        
        SET @Power = ((Oil_Amount * @Heating_Value) / @t_annual) * (@Efficiency_old);
        
        /* CALCULATE WITHIN +- 15% OF THE CALCULATED AND QUERY THE PUMPS THAT ARE WITHIN THAT RANGE */
        SET @Percentage = 0.20;
        SET @Percent_Value = round(@Power * @Percentage, 4);
        SET @Plus_Value = @Power + @Percent_Value;
        SET @Minus_Value = @Power - @Percent_Value;
        
        #SELECT @Power AS Power, @Plus_Value AS Plus_15, @Minus_Value AS Minus_15;
        
        SELECT 
			A.Auftraggeber, 
			I.Geraet, 
			I.Kaeltemittel_Typ1, 
            H.Heizungstyp_Bezeichnung_DE, 
            H.Heizungstyp_Bezeichnung_EN,
            I.InfoID, 
            I.Schall_Aussen, 
            R.Heizleistung, 
            R.COP, 
            B.Bedingung, 
            B.BedingungID,
            I.Bemerkung,
            I.Pruefnummer,
            @Power AS CalculatedPower,
            (SELECT Bauart FROM Bauart AS BA, BauartInfo AS B WHERE B.InfoID = I.InfoID AND B.BauartID = BA.BauartID AND (BA.BauartID = 4 OR BA.BauartID = 5) LIMIT 1) AS Bauart
        FROM 
			Info AS I, 
            (SELECT * FROM Heizungstyp WHERE HeizungstypID = 2 OR HeizungstypID = @Secondary_Heating_Type) AS H, 
            (SELECT * FROM Verbindung WHERE KategorieID = Pump_Category1 OR KategorieID = Pump_Category2) AS V, 
            (SELECT * FROM Auftraggeber) AS A, 
            (SELECT * FROM Resultat WHERE ResultatID IN 
					(SELECT ResultatID 
					FROM Resultat AS R
					WHERE R.Heizleistung >= @Minus_Value AND R.Heizleistung <= @Plus_Value
					ORDER BY R.ResultatID ASC)) AS R, 
            (SELECT * FROM Bedingung WHERE Bedingung RLIKE @Heating_Type_Regex) AS B 
        WHERE 
			V.InfoID = I.InfoID 
			AND V.AuftraggeberID = A.AuftraggeberID 
            AND V.HeizungstypID = H.HeizungstypID 
            AND V.ResultatID = R.ResultatID 
            AND R.BedingungID = B.BedingungID
            AND B.Standardwert = 1
        ORDER BY ABS((@Power) - (R.Heizleistung)) ASC;
            
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-10-11 17:13:19

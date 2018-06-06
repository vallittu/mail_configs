-- -----------------------------------------------------
-- Schema mail
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mail` DEFAULT CHARACTER SET utf8 ;
USE `mail` ;

-- -----------------------------------------------------
-- Table `mail`.`domain`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mail`.`domain` (
  `domain` VARCHAR(255) NOT NULL,
  `id` INT(10) NOT NULL,
  PRIMARY KEY (`domain`),
  INDEX `id` (`id` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'Table for storing all domains that mail system should consider as local domains and accept mail for local delivery.
‘domain’ :has_many ‘user’';


-- -----------------------------------------------------
-- Table `mail`.`user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mail`.`user` (
  `username` VARCHAR(255) NOT NULL,
  `domain` VARCHAR(255) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `fullname` VARCHAR(255) NOT NULL,
  `last_modified` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `uid` INT(10) NOT NULL,
  `gid` INT(10) NOT NULL,
  `home` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`username`, `domain`),
  INDEX `domain_idx` (`domain` ASC),
  INDEX `uid` (`uid` ASC),
  CONSTRAINT `fk_domain`
    FOREIGN KEY (`domain`)
    REFERENCES `mail`.`domain` (`domain`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COMMENT = 'Table for storing local users for all existing domains. Primary key combination of ‘username’ and ‘domain’
Every user belongs to domain, Foreign key constraint from mail.user’domain’ to mail.domain’domain’.
If domain is deleted, then user should be also deleted, so for fk -> ‘ON DELETE CASCADE’.
‘user’ :belongs_to_one ‘domain’
‘user’ :has_many ‘alias’';


-- -----------------------------------------------------
-- Table `mail`.`alias`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mail`.`alias` (
  `alias` VARCHAR(255) NOT NULL,
  `username` VARCHAR(255) NOT NULL,
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `last_modified` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `domain` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`alias`, `username`, `domain`),
  INDEX `id` (`id` ASC),
  INDEX `alias` (`alias` ASC, `username` ASC),
  INDEX `username_idx` (`username` ASC, `domain` ASC),
  CONSTRAINT `fk_userdomain`
    FOREIGN KEY (`username` , `domain`)
    REFERENCES `mail`.`user` (`username` , `domain`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 123458
DEFAULT CHARACTER SET = utf8
COMMENT = 'Table for all user aliases.
User can have multiple aliases (under single domain.)
If user is deleted, aliases have to be also deleted, so ‘ON DELETE CASCADE’
‘alias’ :belongs_to_one ‘user’';

USE `mail` ;

-- -----------------------------------------------------
-- procedure change_password
-- -----------------------------------------------------

DELIMITER $$
USE `mail`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `change_password`(oldpass text, newpass text, username_p text, domain_p text)
    MODIFIES SQL DATA
BEGIN

    DECLARE error text;
    
    SET error = 'incorrect current password';
    
SELECT /* Check old password */
    ''
INTO error FROM
    user
WHERE
    username = username_p AND domain = domain_p
        AND password = ENCRYPT(oldpass, password);
    
UPDATE user /* Update new password */
SET 
    password = newpass
WHERE
    username = username_p AND domain = domain_p
        AND password = ENCRYPT(oldpass, password);

END$$

DELIMITER ;
CREATE USER 'mail';

GRANT EXECUTE ON ROUTINE `mail`.* TO 'mail';
GRANT SELECT ON TABLE `mail`.* TO 'mail';

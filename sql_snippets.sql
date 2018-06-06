-- create a sha512-crypt hash from password
SELECT ENCRYPT('Password123', CONCAT('$6$', SUBSTRING(SHA(RAND()), -16)));

-- check password against hash
SELECT username, domain FROM user
WHERE username = 'example' and domain = 'example.com'
AND password = encrypt('Password123', password);


/* Change password procedure for webmail interface */
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

END




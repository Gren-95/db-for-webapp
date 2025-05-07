-- Create application user with limited permissions
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'secure_password';
GRANT SELECT, INSERT, UPDATE ON internet_bank.* TO 'app_user'@'localhost';

-- Create admin user with full permissions
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'admin_secure_password';
GRANT ALL PRIVILEGES ON internet_bank.* TO 'admin_user'@'localhost';

-- Create auditor user with read-only permissions
CREATE USER 'auditor_user'@'localhost' IDENTIFIED BY 'auditor_secure_password';
GRANT SELECT ON internet_bank.* TO 'auditor_user'@'localhost';

-- Example of how to backup the database
-- Run this command from terminal:
-- mysqldump -u root -p internet_bank > backup_$(date +%Y%m%d).sql

-- Example of how to restore from backup
-- Run this command from terminal:
-- mysql -u root -p internet_bank < backup_20240315.sql

-- Create a stored procedure for transferring money between accounts
DELIMITER //
CREATE PROCEDURE transfer_money(
    IN p_from_account_id INT,
    IN p_to_account_id INT,
    IN p_amount DECIMAL(15,2),
    IN p_description TEXT,
    IN p_user_id INT,
    IN p_ip_address VARCHAR(45)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        INSERT INTO audit_logs (user_id, action_type, action_description, ip_address)
        VALUES (p_user_id, 'TRANSFER_FAILED', CONCAT('Failed transfer of ', p_amount, ' EUR'), p_ip_address);
    END;

    START TRANSACTION;
    
    -- Check if sender has sufficient funds
    IF EXISTS (
        SELECT 1 FROM accounts 
        WHERE account_id = p_from_account_id 
        AND balance >= p_amount
    ) THEN
        -- Update sender's balance
        UPDATE accounts 
        SET balance = balance - p_amount 
        WHERE account_id = p_from_account_id;
        
        -- Update receiver's balance
        UPDATE accounts 
        SET balance = balance + p_amount 
        WHERE account_id = p_to_account_id;
        
        -- Record the transaction
        INSERT INTO transactions 
        (from_account_id, to_account_id, amount, transaction_type, status, description) 
        VALUES 
        (p_from_account_id, p_to_account_id, p_amount, 'TRANSFER', 'COMPLETED', p_description);
        
        -- Log the transaction
        INSERT INTO audit_logs 
        (user_id, action_type, action_description, ip_address) 
        VALUES 
        (p_user_id, 'TRANSFER', CONCAT('Transfer of ', p_amount, ' EUR completed'), p_ip_address);
        
        COMMIT;
    ELSE
        -- Record failed transaction
        INSERT INTO transactions 
        (from_account_id, to_account_id, amount, transaction_type, status, description) 
        VALUES 
        (p_from_account_id, p_to_account_id, p_amount, 'TRANSFER', 'FAILED', 'Insufficient funds');
        
        ROLLBACK;
    END IF;
END //
DELIMITER ; 
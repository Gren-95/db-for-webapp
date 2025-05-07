USE internet_bank;

-- Insert sample users
INSERT INTO users (username, password_hash, email, first_name, last_name) VALUES
('john.doe', '$2a$10$example_hash', 'john.doe@example.com', 'John', 'Doe'),
('jane.smith', '$2a$10$example_hash', 'jane.smith@example.com', 'Jane', 'Smith'),
('admin', '$2a$10$example_hash', 'admin@example.com', 'Admin', 'User');

-- Assign roles to users
INSERT INTO user_roles (user_id, role_id) VALUES
(1, 2), -- John Doe as USER
(2, 2), -- Jane Smith as USER
(3, 1); -- Admin as ADMIN

-- Create sample accounts
INSERT INTO accounts (user_id, account_number, account_type, balance) VALUES
(1, 'EE123456789012345678', 'CHECKING', 1000.00),
(1, 'EE234567890123456789', 'SAVINGS', 5000.00),
(2, 'EE345678901234567890', 'CHECKING', 2500.00),
(2, 'EE456789012345678901', 'SAVINGS', 10000.00);

-- Example transaction (transfer between accounts)
BEGIN;
    -- Update sender's balance
    UPDATE accounts 
    SET balance = balance - 500.00 
    WHERE account_id = 1;
    
    -- Update receiver's balance
    UPDATE accounts 
    SET balance = balance + 500.00 
    WHERE account_id = 3;
    
    -- Record the transaction
    INSERT INTO transactions 
    (from_account_id, to_account_id, amount, transaction_type, status, description) 
    VALUES 
    (1, 3, 500.00, 'TRANSFER', 'COMPLETED', 'Monthly rent payment');
    
    -- Log the transaction
    INSERT INTO audit_logs 
    (user_id, action_type, action_description, ip_address) 
    VALUES 
    (1, 'TRANSFER', 'Transfer of 500.00 EUR from account EE123456789012345678 to EE345678901234567890', '192.168.1.1');
COMMIT;

-- Example of a failed transaction (insufficient funds)
BEGIN;
    -- Try to transfer more than available
    UPDATE accounts 
    SET balance = balance - 2000.00 
    WHERE account_id = 1;
    
    -- Record the failed transaction
    INSERT INTO transactions 
    (from_account_id, to_account_id, amount, transaction_type, status, description) 
    VALUES 
    (1, 3, 2000.00, 'TRANSFER', 'FAILED', 'Failed transfer due to insufficient funds');
    
    -- Log the failed attempt
    INSERT INTO audit_logs 
    (user_id, action_type, action_description, ip_address) 
    VALUES 
    (1, 'TRANSFER_FAILED', 'Failed transfer attempt of 2000.00 EUR', '192.168.1.1');
ROLLBACK; 
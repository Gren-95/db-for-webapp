# Internet Banking Database

This repository contains the database structure and sample data for an internet banking system. The database is designed to handle user accounts, transactions, and audit logging.

## Database Structure

The database consists of the following main tables:
- `users`: Stores user information
- `roles`: Defines user roles (ADMIN, USER, AUDITOR)
- `user_roles`: Manages many-to-many relationship between users and roles
- `accounts`: Stores bank accounts information
- `transactions`: Records all financial transactions
- `audit_logs`: Tracks all system activities

## Setup Instructions

1. Create the database and tables:
```bash
mysql -u root -p < createtables.sql
```

2. Load sample data:
```bash
mysql -u root -p < sampledata.sql
```

3. Set up user permissions:
```bash
mysql -u root -p < permissions.sql
```

## Database Users

The system creates three types of users:
1. `app_user`: Application user with limited permissions (SELECT, INSERT, UPDATE)
2. `admin_user`: Administrator with full database access
3. `auditor_user`: Read-only access for auditing purposes

## Backup and Restore

To backup the database:
```bash
mysqldump -u root -p internet_bank > backup_$(date +%Y%m%d).sql
```

To restore from backup:
```bash
mysql -u root -p internet_bank < backup_20240315.sql
```

## Stored Procedures

The database includes a stored procedure `transfer_money` that handles money transfers between accounts with proper transaction management and error handling.

## Security Features

- Password hashing for user authentication
- Role-based access control
- Audit logging for all transactions
- Transaction management for data consistency
- Proper indexing for performance optimization

## ER Diagram

The database follows these relationships:
- Users can have multiple roles (many-to-many)
- Users can have multiple accounts (one-to-many)
- Accounts can have multiple transactions (one-to-many)
- All transactions are logged in audit_logs

## Notes

- All monetary values are stored as DECIMAL(15,2)
- Timestamps are used for tracking creation and modification times
- Foreign key constraints ensure data integrity
- Indexes are created for frequently queried columns 
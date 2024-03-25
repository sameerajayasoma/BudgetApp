-- AUTO-GENERATED FILE.
-- This file is an auto-generated file by Ballerina persistence layer for the migrate command.
-- Please verify the generated scripts and execute them against the target DB server.

ALTER TABLE ExpenseItem
DROP COLUMN date;

ALTER TABLE ExpenseItem MODIFY `dateTime` DATETIME NOT NULL;

ALTER TABLE ExpenseItem MODIFY `createdAt` DATETIME NOT NULL;

ALTER TABLE ExpenseItem MODIFY `updatedAt` DATETIME NOT NULL;






-- AUTO-GENERATED FILE.
-- This file is an auto-generated file by Ballerina persistence layer for the migrate command.
-- Please verify the generated scripts and execute them against the target DB server.

ALTER TABLE ExpenseItem
ADD COLUMN dateTime DATETIME;

ALTER TABLE ExpenseItem
ADD COLUMN createdAt TIMESTAMP;

ALTER TABLE ExpenseItem
ADD COLUMN updatedAt TIMESTAMP;


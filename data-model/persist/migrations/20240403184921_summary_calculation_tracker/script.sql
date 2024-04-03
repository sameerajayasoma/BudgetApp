-- AUTO-GENERATED FILE.
-- This file is an auto-generated file by Ballerina persistence layer for the migrate command.
-- Please verify the generated scripts and execute them against the target DB server.

-- There are bugs in the generated code
-- CREATE TABLE SummaryCalculationTracker (
--     id VARCHAR PRIMARY KEY,
--     lastCalculatedDate DATE,
--     updatedAt TIMESTAMP
-- );

-- ALTER TABLE DailyExpenseSummary
-- ADD COLUMN createdAt TIMESTAMP;

-- ALTER TABLE DailyExpenseSummary
-- ADD COLUMN updatedAt TIMESTAMP;


-- The correct code is below
CREATE TABLE SummaryCalculationTracker (
    `id` VARCHAR(191) PRIMARY KEY,
    `lastCalculatedDate` DATE NOT NULL,
    `updatedAt` TIMESTAMP NOT NULL
);

ALTER TABLE DailyExpenseSummary
ADD COLUMN `createdAt` TIMESTAMP NOT NULL;

ALTER TABLE DailyExpenseSummary
ADD COLUMN `updatedAt` TIMESTAMP NOT NULL;
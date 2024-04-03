-- AUTO-GENERATED FILE.
-- This file is an auto-generated file by Ballerina persistence layer for the migrate command.
-- Please verify the generated scripts and execute them against the target DB server.

-- Following two generated queries contain errors 
-- TODO Report errors

-- CREATE TABLE DailyExpenseSummary (
--     id VARCHAR PRIMARY KEY,
--     date DATE,
--     totalAmount DECIMAL(65,30),
--     expensecategoryId VARCHAR
-- );

-- ALTER TABLE DailyExpenseSummary
-- ADD CONSTRAINT FK_DailyExpenseSummary_ExpenseCategory FOREIGN KEY (expensecategoryId) REFERENCES ExpenseCategory(id);


-- Hear are the corrected queries. I had to manually update them.
CREATE TABLE DailyExpenseSummary (
    `id` VARCHAR(191) NOT NULL,
    `date` DATE NOT NULL,
    `totalAmount` DECIMAL(65,30) NOT NULL,
    `expensecategoryId` VARCHAR(191) NOT NULL
);

ALTER TABLE DailyExpenseSummary
ADD CONSTRAINT FK_DailyExpenseSummary_ExpenseCategory FOREIGN KEY (`expensecategoryId`) REFERENCES ExpenseCategory(`id`);


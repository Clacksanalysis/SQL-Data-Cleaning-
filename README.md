## 🧹 Data Cleaning Process – Layoffs Dataset
This section outlines the SQL steps taken to clean and standardize the layoffs dataset in preparation for analysis. Key tasks include removing duplicates, standardizing text values, correcting inconsistent country and industry names, handling null values, and converting date formats. These steps help ensure data accuracy and reliability for deeper insights.

-- DATA CLEANING
```sql
-- Creating a duplicate database
SELECT * FROM layoffs;

CREATE TABLE layoff_duplicate LIKE layoffs;

SELECT * FROM layoff_duplicate;

INSERT INTO layoff_duplicate
SELECT * FROM layoffs;

-- Finding Duplicates
SELECT *, 
    ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS Row_num
FROM layoff_duplicate;

WITH duplicate_CTE AS (
    SELECT *, 
        ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS Row_num
    FROM layoff_duplicate
)
SELECT * 
FROM duplicate_CTE 
WHERE Row_num > 1;

-- Creating new table to store and clean duplicates
CREATE TABLE `layoff_duplicate2` (
    `company` TEXT,
    `location` TEXT,
    `industry` TEXT,
    `total_laid_off` INT DEFAULT NULL,
    `percentage_laid_off` TEXT,
    `date` TEXT,
    `stage` TEXT,
    `country` TEXT,
    `funds_raised_millions` INT DEFAULT NULL,
    `row_num` INT
) ENGINE=INNODB DEFAULT CHARSET=UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI;

SELECT * FROM layoff_duplicate2;

INSERT INTO layoff_duplicate2
SELECT *, 
    ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS Row_num
FROM layoff_duplicate;

-- Removing duplicates
DELETE FROM layoff_duplicate2 
WHERE Row_num > 1;

SELECT * FROM layoff_duplicate2;

-- Standardizing Data
SELECT company, TRIM(company) AS Trimmed
FROM layoff_duplicate2;

UPDATE layoff_duplicate2 
SET company = TRIM(company);

-- Cleaning up industry column
SELECT DISTINCT industry 
FROM layoff_duplicate2
ORDER BY 1;

SELECT * 
FROM layoff_duplicate2
WHERE industry LIKE 'crypto%';

UPDATE layoff_duplicate2 
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Checking location column
SELECT DISTINCT location 
FROM layoff_duplicate2
ORDER BY 1;

-- Cleaning up country column
SELECT DISTINCT country 
FROM layoff_duplicate2
ORDER BY 1;

SELECT * 
FROM layoff_duplicate2
WHERE country LIKE 'United States.%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) 
FROM layoff_duplicate2
ORDER BY 1;

UPDATE layoff_duplicate2 
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Changing date from text to DATE format
SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoff_duplicate2;

UPDATE layoff_duplicate2 
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date` FROM layoff_duplicate2;

ALTER TABLE layoff_duplicate2
MODIFY COLUMN `date` DATE;

-- Handling NULLs
SELECT * 
FROM layoff_duplicate2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

UPDATE layoff_duplicate2 
SET industry = NULL 
WHERE industry = '';

SELECT * 
FROM layoff_duplicate2
WHERE industry IS NULL OR industry = '';

-- Populating missing industries based on company and location match
SELECT * 
FROM layoff_duplicate2 t1
JOIN layoff_duplicate2 t2 
    ON t1.company = t2.company AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '') AND t2.industry IS NOT NULL;

UPDATE layoff_duplicate2 t1
JOIN layoff_duplicate2 t2 
    ON t1.company = t2.company 
SET t1.industry = t2.industry 
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- Final cleaning
SELECT * FROM layoff_duplicate2 WHERE company LIKE 'bally%';

DELETE FROM layoff_duplicate2 
WHERE percentage_laid_off IS NULL AND total_laid_off IS NULL;

-- Drop row number column
ALTER TABLE layoff_duplicate2
DROP COLUMN row_num;

SELECT * FROM layoff_duplicate2;

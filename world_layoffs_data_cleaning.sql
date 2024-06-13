-- Data Cleaning


SELECT *
FROM layoffs;

-- Remove Duplicates
-- Standardize the Null Value
-- Null Values or blank values
-- Remove any columns

-- Removing duplicates

CREATE TABLE layoffs_staging
LIKE layoffs;


SELECT * 
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
from layoffs;

-- using staging from here
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location,
industry, total_laid_off, percentage_laid_off, 'date', stage
, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


SELECT * 
FROM layoffs_staging
WHERE company = 'Casper';


WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location,
industry, total_laid_off, percentage_laid_off, 'date', stage
, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE 
FROM duplicate_cte
WHERE row_num > 1;


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location,
industry, total_laid_off, percentage_laid_off, 'date', stage
, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging2;

-- Standardizing the data

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);


SELECT DISTINCT industry
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

 
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;


UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

--  Set 'None' values in the date column to NULL
UPDATE layoffs_staging2
SET date = NULL
WHERE date = 'None';

--  Update the date column with dates in the correct format
UPDATE layoffs_staging2
SET date = STR_TO_DATE(date, '%m/%d/%Y')
WHERE date IS NOT NULL;

-- Modify the date column type to DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN date DATE;

-- Update 'None' values in total_laid_off to NULL
UPDATE layoffs_staging2
SET total_laid_off = NULL
WHERE total_laid_off = 'None';

--  Update 'None' values in percentage_laid_off to NULL
UPDATE layoffs_staging2
SET percentage_laid_off = NULL
WHERE percentage_laid_off = 'None';

-- Update 'None' values in industry to NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = 'None';

-- Update 'None' values in funds_raised_millions to NULL
UPDATE layoffs_staging2
SET funds_raised_millions = NULL
WHERE funds_raised_millions = 'None';

-- Update 'None' values in stage to NULL
UPDATE layoffs_staging2
SET stage = NULL
WHERE stage = 'None';

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT * 
FROM layoffs_staging2
WHERE company LIKE 'Bally%';


SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry is NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;



UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry is NULL 
AND t2.industry IS NOT NULL;

SELECT * 
FROM layoffs_staging2;


SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT * 
FROM layoffs_staging2;

-- Removing columns

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


-- IN this project we will try to clean our data to use it in the analysis and gain useful insight and accurate results from it
-- WE follow some steps like remove duplicate and standrize data and solving the issue of the null value and removing unnecessary columns and rows


SET SQL_SAFE_UPDATES = 0;
-- In this steps we create the database that we will work on
CREATE DATABASE world_layoffs;
-- In this query we define the data base that we will work on
USE world_layoffs;

-- After creating database and insert tables and data in we need to take alook at the data
SELECT *
FROM layoffs;




-- After we take abrief about our data we will create stageing table. we will work on this table and we will cleaning data. the reason we want to work on this copy because we want to save row data for any issuse happen
-- In this step we start creating acopy table or the table we will start working on
CREATE TABLE layoffs_staging
LIKE layoffs;

-- We will take alook at the table
SELECT *
FROM layoffs_staging;

-- In this steps we will insert the mean data on the copy table
INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

-- we will take another look after inserting data
SELECT *
FROM layoffs_staging;


-- To make our data clean we need some steps to do to reach this stage
-- 1. Check duplicate and remove any
-- 2. Standrize data and fix errors
-- 3. look at null and blank values and see what is thier affect
-- 4. Remove any columns or rows that is not necessary

-- 1. Remove duplicate

-- let us take look at the layoffs_staging table
SELECT *
FROM layoffs_staging;

-- In this steps we will try to discover duplicate value and try to remove it to make our data more clean

WITH remove_duplicate AS(
SELECT * , 
ROW_NUMBER() OVER(PARTITION BY company , location , industry ,
							total_laid_off , percentage_laid_off , `date` , stage , country , funds_raised_millions) AS row_num
FROM layoffs_staging)

SELECT *
FROM remove_duplicate
WHERE row_num > 1;

ALTER TABLE layoffs_staging DROP row_num ;


-- In this stage we are still in the process of removing duplicates so we will create new table that have the same data but we will add a new columns called row_num that will helps discover duplicates easier
 CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO `world_layoffs`.`layoffs_staging2`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
ROW_NUMBER() OVER(PARTITION BY company , location , industry ,
							total_laid_off , percentage_laid_off , `date` , stage , country , funds_raised_millions) AS row_num
FROM layoffs_staging;


SELECT *
FROM layoffs_staging2;
-- In this stage we try to show all duplicates data
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Now we clean our date from duplicates values
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- we take another look to our data
SELECT *
FROM layoffs_staging;

-- 2. Standardize data
-- for all the next query we will try to show every single columns and we will try to solve any issuse
-- At first we will show the first columns his name company
SELECT DISTINCT company , TRIM(company) 
FROM layoffs_staging2;

-- We use this query to delete all and unncessary white space 
UPDATE layoffs_staging2
SET company = TRIM(company) ;

SELECT * 
FROM layoffs_staging2;

-- Now we will show the second columns his name location
SELECT DISTINCT location
FROM layoffs_staging
ORDER BY 1;


-- Now we will show the third column and his name industry
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;
-- In this steps we try to see why industry are null or blank
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = ''
ORDER BY industry;
-- IN this query we try to see if there is a company have the same name so we could have inforamtion to fixed null or blank values in industry
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Airbnb%';

-- IN this query we change the blank value to null value to help us fix the null vakues
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';


SELECT * 
FROM  layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL ;

-- IN this query we update all the null value by using self join to see if there is value matches the null value in the industry by using company as the value to match 
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL ;

    

-- Now we will update some data in industry value that have multiple name for the same value
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;


-- Now we will show the six column and his name date in this stage we try to update the data type we try to convert text data to date data
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- we change the column type
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;

-- Now we will show the eight column and his name country
SELECT DISTINCT country , TRIM( TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;
-- In this column we find that some value are same but have some character add to the end of some so we try to solve this problem to make data more clean
UPDATE layoffs_staging2
SET country  = TRIM(TRAILING '.' FROM country);


SELECT DISTINCT country 
FROM layoffs_staging2
ORDER BY 1;


SELECT *
FROM layoffs_staging2;



-- 3. look at null values
SELECT *
FROM layoffs_staging2;

-- The null vaules in total_laid_off , percentage_laid_off and funds_raised_millions look normal. so i don't want to change it


-- 4. Remove columns or rows that we think we don't need it

-- Now we look at the data to see the null values 
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;

-- IN this step we try to see the null value where the total_laid_off and percentage_laid_off are together
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;


SELECT *
FROM layoffs_staging2;

-- Now we will delete the null values
DELETE 
FROM layoffs_staging2
WHERE  total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- IN this step we delete the column row_num because we don't need them any more after helping us deleting duplicates values 
ALTER TABLE layoffs_staging2 DROP row_num;

-- Now we took a final look after cleaning our data and making it ready for analysis
SELECT *
FROM layoffs_staging2;


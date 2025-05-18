-- DATA CLEANING 

-- crating a Deuplicate database 
SELECT * 
FROM layoffs ;

create table layoff_duplicate
like layoffs; 

select *
from layoff_duplicate ;

insert layoff_duplicate 
select * from layoffs;

-- finding Duplicates 

select *, 
	row_number() over( partition by company ,location, industry, total_laid_off, percentage_laid_off, `date`,stage,country,funds_raised_millions )
		as Row_num
From layoff_duplicate ;

with duplicate_CTE as 
(
select *, 
	row_number() over( partition by company,location, industry, total_laid_off, percentage_laid_off, `date`,stage,country,funds_raised_millions )
		as Row_num
From layoff_duplicate 
)
select * 
from duplicate_CTE 
Where Row_num > 1;




CREATE TABLE `layoff_duplicate2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


select *
from layoff_duplicate2 ;

insert layoff_duplicate2
select *, 
	row_number() over( partition by company ,location, industry, total_laid_off, percentage_laid_off, `date`,stage,country,funds_raised_millions )
		as Row_num
From layoff_duplicate ;

-- Removing deuplicates 
Delete 
from layoff_duplicate2
where Row_num >1 ;

select *
from layoff_duplicate2;

-- Standardizing Data 
Select company, (Trim(company) ) as Trimmed 
From layoff_duplicate2;


update layoff_duplicate2
set company = Trimmed ;

select distinct industry
from layoff_duplicate2
order by 1;

select * 
from layoff_duplicate2
where industry  like 'crypto%';

update layoff_duplicate2 
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct location 
from layoff_duplicate2
order by 1;

-- checked and the location column is ok

select distinct country 
from layoff_duplicate2
order by 1;
-- found wrong names of country 
select * 
from layoff_duplicate2
where country like 'United States.%';

Select distinct country, TRIM(Trailing '.' From Country) 
from layoff_duplicate2
order by 1;

update layoff_duplicate2 
set country = TRIM(Trailing '.' From Country)  
where country like 'United States%';

-- changing the date from text to date 
select `date`,
str_to_date(`date`,'%m/%d/%Y')
from layoff_duplicate2;

update layoff_duplicate2
set `date` = str_to_date(`date`,'%m/%d/%Y');


select  `date`
from layoff_duplicate2;
-- changeing the date format
alter table layoff_duplicate2
modify column `date` Date ;

select * 
From layoff_duplicate2
where total_laid_off is null 
and percentage_laid_off is null;

update layoff_duplicate2
set industry = null
where industry = '';

select *
from layoff_duplicate2
where industry is null
or industry = '';

-- checking for null values

select *
from layoff_duplicate2
where industry is Null
or industry = '';

select * 
from layoff_duplicate2
where company = 'Airbnb';


-- populating the data 

select *
from layoff_duplicate2 t1
join layoff_duplicate2 t2
	on t1.company= t2.company
    and t1.location=t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoff_duplicate2 t1
join layoff_duplicate2 t2
	on t1.company = t2.company
set t1.industry  = t2.industry 
where t1.industry is null 
and t2.industry is Not null ;

select *
from layoff_duplicate2
where Company like 'bally%';


delete
from layoff_duplicate2
where percentage_laid_off is null
and total_laid_off is null ;

select *
from layoff_duplicate2;


alter table layoff_duplicate2
drop column row_num;

select *
from layoff_duplicate2;

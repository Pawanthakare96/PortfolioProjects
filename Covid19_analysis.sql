

select * from covid_deaths
select * from covid_vaccinations

-- we required cases and deaths according to populations

select iso_code,location,population,total_cases,new_cases,total_deaths
from covid_deaths
order by iso_code

-- Total Deaths VS Total Cases

select iso_code,location,population,date,total_cases,total_deaths,((total_deaths/total_cases)*100) as death_rate
from covid_deaths
where iso_code like '%IND%'

-- Total Deaths VS Total Populations

select iso_code,location,population,date,total_deaths,
((total_deaths/population)*100) as death_rate_resp_population
from covid_deaths
where iso_code like '%IND%'

---COUNTRY WITH HIGHEST INFECTION RATE OVER TOTAL POPULATION

select iso_code,location,population,max(total_cases) as highest_infection,
max((total_cases/population)*100) as infection_rate
from covid_deaths
group by iso_code,location,population
order by infection_rate desc

---COUNTRY WITH HIGHEST DEATH OVER POPULATION
SELECT iso_code,location,MAX(cast(total_deaths AS SIGNED INTEGER)) AS total_death_count
FROM covid_deaths
GROUP BY
  iso_code,
  location
ORDER BY total_death_count DESC;

---CONTINENT WITH HIGHEST DEATH OVER POPULATION
SELECT CONTINENT,MAX(cast(total_deaths AS SIGNED INTEGER)) AS total_death_count
FROM covid_deaths
WHERE CONTINENT IS NOT NULL
GROUP BY
  CONTINENT
ORDER BY total_death_count DESC;

---GLOBAL DEATH COUNT
select date,SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths,((SUM(new_deaths)/SUM(new_cases))*100) AS Death_rate
from covid_deaths
GROUP BY DATE
order by date asc

select SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths,((SUM(new_deaths)/SUM(new_cases))*100) AS Death_rate
from covid_deaths
order by date asc


--JOINING COVID_DATHS AND COVID_VACCINATIONS
select * from covid_deaths cd
left outer join covid_vaccinations cv
on cd.location = cv.location and cd.date=cv.date_vac

-- Total Population vs Total Vaccination
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(new_vaccinations) over (partition by cd.location order by cd.location,cd.date) With_Rollup_vaccination
 from covid_deaths cd
join covid_vaccinations cv
on cd.location = cv.location and cd.date=cv.date_vac
order by 1,2,3,4,5 desc

--USING CTE  POPULATIN VS VACCINATION
WITH population_vaccination (continent,location,date,population,new_vaccinations,With_Rollup_vaccination)
as
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(new_vaccinations) over (partition by cd.location order by cd.location,cd.date) With_Rollup_vaccination
 from covid_deaths cd
join covid_vaccinations cv
on cd.location = cv.location and cd.date=cv.date_vac
)
select location,population,new_vaccinations,((With_Rollup_vaccination/population)*100) as vaccination_rate
from population_vaccination


----TEMPORARY TABLE

create temporary table Percentage_vaccination(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(new_vaccinations) over (partition by cd.location order by cd.location,cd.date) With_Rollup_vaccination
 from covid_deaths cd
join covid_vaccinations cv
on cd.location = cv.location and cd.date=cv.date_vac
order by 1,2,3,4,5 desc
)
select * from Percentage_vaccination

--VIEWS-
--CREATE VIEW TO STORE DATA FOR OUR ANALYSIS--

CREATE VIEW percentage_population_vaccinated as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(new_vaccinations) over (partition by cd.location order by cd.location,cd.date) With_Rollup_vaccination
 from covid_deaths cd
join covid_vaccinations cv
on cd.location = cv.location and cd.date=cv.date_vac
order by 1,2,3,4,5 desc
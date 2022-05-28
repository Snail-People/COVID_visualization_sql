-- Total Cases vs Total Deaths in the US--

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
FROM `focus-standard-319913.covid_data.covid_deaths`
WHERE location = 'United States'


-- Total Cases vs Population in the US--

SELECT location, date, population, total_cases,total_deaths, (total_cases/population)* 100 as InfectedPopulationPercentage
FROM `focus-standard-319913.covid_data.covid_deaths`
WHERE location = 'United States'

-- Looking at countries with the highest infection rates compared to population --
-- (only looks at populations of a million or higher) --

SELECT location, population, MAX(total_cases) as HighestCaseCount, MAX((total_cases/population))* 100 as PercentofPopulationInfected
FROM `focus-standard-319913.covid_data.covid_deaths`
WHERE population > 1000000
GROUP BY location, population
ORDER BY PercentofPopulationInfected desc


-- Countries with the highest death counts --

SELECT location, population, MAX(cast(total_deaths as bigint)) as TotalDeaths
FROM `focus-standard-319913.covid_data.covid_deaths`
WHERE population > 1000000 AND continent is not null
GROUP BY location, population
ORDER BY TotalDeaths desc


-- Highest death Counts by Continent --

SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeaths
FROM `focus-standard-319913.covid_data.covid_deaths`
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeaths desc


-- Total Population vs Vaccinated --
SELECT death.continent, death.location, death.date, vax.new_vaccinations, population,
SUM(vax.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as TotalVaccinated,
(SUM(vax.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date)/population)*100 as PercentVaccinated
FROM `focus-standard-319913.covid_data.covid_deaths` as death
JOIN `focus-standard-319913.covid_data.covid_vaccinations` as vax
  ON death.location = vax.location
  AND death.date = vax.date
WHERE death.continent is not null AND vax.new_vaccinations is not null
-- This query has a problem; total vaccines will outnumber the actual population as people will need to have at LEAST 2 vaccinations to be
-- fully vaccinated. So instead we'll look at the difference between those who are vaccinated vs. fully vaccinated



-- Percent of People Vaccinated, Fully vaccinated, and Hospitalization Rates --
SELECT death.continent, death.location, death.date, vax.new_vaccinations, population, total_vaccinations,
(people_vaccinated/population)*100 AS PercentVaccinated,
(people_fully_vaccinated/population)*100 AS PercentFULLYVaccinated,
death.hosp_patients, death.icu_patients, death.total_deaths
FROM `focus-standard-319913.covid_data.covid_deaths` as death
JOIN `focus-standard-319913.covid_data.covid_vaccinations` as vax
  ON death.location = vax.location
  AND death.date = vax.date
WHERE death.continent is not null AND death.population > 10000000
ORDER BY death.continent, death.location, death.date


-- Vaccines vs. cases vs. deaths --
SELECT death.continent, death.location, death.date, death.total_cases, death.new_cases, death.total_deaths, death.new_deaths, vax.total_vaccinations, vax.new_vaccinations
FROM `focus-standard-319913.covid_data.covid_deaths` as death
JOIN `focus-standard-319913.covid_data.covid_vaccinations` as vax
  ON death.location = vax.location
  AND death.date = vax.date
WHERE death.continent is not null AND death.population > 10000000
ORDER BY death.continent, death.location, death.date
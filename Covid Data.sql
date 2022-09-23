SELECT * 
FROM CovidDeaths.coviddeaths
ORDER BY 3,4;

SELECT * 
FROM CovidDeaths.covidvaccinations
ORDER BY 3,4;

SELECT Location,date,total_cases, new_cases, total_deaths, population
FROM CovidDeaths.coviddeaths
ORDER BY 1,2;

-- Looking at Total Cases VS Total Deaths
-- Shows Likelihood of dying if you contract Covid in your country

SELECT Location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths.coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

-- Looking at Total Cases VS Population

SELECT Location,date,total_cases, population, (total_cases/population)*100 AS CasesPercentage
FROM CovidDeaths.coviddeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

-- Looking at Countries with highest infection rates

SELECT Location, MAX(total_cases)as HighestInfectionCount, population, MAX((total_cases/population))*100 AS CasesPercentage
FROM CovidDeaths.coviddeaths
-- WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY CasesPercentage DESC;

-- Showing Countries with highest death rates

SELECT Location, MAX(total_deaths) as HighestDeathCount
FROM CovidDeaths.coviddeaths
WHERE Continent != ""
GROUP BY location
ORDER BY HighestDeathCount DESC;

-- Showing Continents with highest death rates

SELECT continent, MAX(total_deaths) as HighestDeathCount
FROM CovidDeaths.coviddeaths
WHERE Continent != ""
GROUP BY continent
ORDER BY HighestDeathCount DESC;

-- Global Numbers

SELECT date,SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths.coviddeaths
WHERE Continent != ""
GROUP BY date
ORDER BY 1;

-- Looking at Total Population VS Vaccination by joining two tables

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
FROM CovidDeaths.coviddeaths AS DEA
JOIN CovidDeaths.covidvaccinations AS VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.Continent != ""
ORDER BY 2,3;



SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(VAC.new_vaccinations) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS CUM_new_vaccinations
FROM CovidDeaths.coviddeaths AS DEA
JOIN CovidDeaths.covidvaccinations AS VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.Continent != ""
ORDER BY 2,3;


WITH PopvsVac (continent, location, date, population, new_vaccinations, CUM_new_vaccinations)
AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(VAC.new_vaccinations) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS CUM_new_vaccinations
FROM CovidDeaths.coviddeaths AS DEA
JOIN CovidDeaths.covidvaccinations AS VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.Continent != ""
-- ORDER BY 2,3; (can't use order by in CTE)
)
SELECT *, (CUM_new_vaccinations/population)*100
FROM PopvsVac;


-- Creating new table

CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CUM_new_vaccinations numeric
);
INSERT INTO PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(VAC.new_vaccinations) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS CUM_new_vaccinations
FROM CovidDeaths.coviddeaths AS DEA
JOIN CovidDeaths.covidvaccinations AS VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.Continent != ""
ORDER BY 2,3;

SELECT *, (CUM_new_vaccinations/population)*100
FROM PercentPopulationVaccinated;

-- Creating view to store data for visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(VAC.new_vaccinations) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS CUM_new_vaccinations
FROM CovidDeaths.coviddeaths AS DEA
JOIN CovidDeaths.covidvaccinations AS VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.Continent != ""
-- ORDER BY 2,3;
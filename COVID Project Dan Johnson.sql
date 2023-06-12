SELECT *
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM [Portfolio Project]..CovidVaccinations
--ORDER BY 3,4

--Picking the data I'll be using for this study

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total cases against Total Deaths calculation
-- Shows percentage chance of dying if you get COVID in the USA

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentageOfDeath
FROM [Portfolio Project]..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Total cases compared against population
-- Percentage of population that got infected

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentageOfInfectionVSPopulation
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Which countries have the highest infection rate?

SELECT location, MAX(total_cases) AS HighestCOVIDCount, population, MAX((total_cases/population))*100 AS PercentOfInfectionVSPopulation
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY population, location
ORDER BY PercentOfInfectionVSPopulation DESC

-- Highest amount of people who died in countries with highest percentage of infection?

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC



-- Separating death count by continent

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Continents with highest death count

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS PercentageOfDeath
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Total population vs total vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations,

FROM [Portfolio Project]..CovidDeaths AS dea
JOIN [Portfolio Project]..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, TotalVaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
FROM [Portfolio Project]..CovidDeaths AS dea
JOIN [Portfolio Project]..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (TotalVaccinations/Population)*100 AS PercentageofPopVaccinated
FROM PopvsVac

-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
FROM [Portfolio Project]..CovidDeaths AS dea
JOIN [Portfolio Project]..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (TotalVaccinations/Population)*100 AS PercentageofPopVaccinated
FROM #PercentPopulationVaccinated

-- CREATING VIEWS FOR LATER DATA VIZ

-- Total percentage of population Vaccinated
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
FROM [Portfolio Project]..CovidDeaths AS dea
JOIN [Portfolio Project]..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

-- Total Deaths by Continent

CREATE VIEW DeathCountByContinent AS 
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent

SELECT * 
FROM DeathCountByContinent

-- Top 10 countries with highest infection rate percentage compared to population

CREATE VIEW InfectionPercentageTotalPopulation AS
SELECT location, MAX(total_cases) AS HighestCOVIDCount, population, MAX((total_cases/population))*100 AS PercentOfInfectionVSPopulation
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY population, location
--ORDER BY PercentOfInfectionVSPopulation DESC

SELECT TOP 10 * 
FROM InfectionPercentageTotalPopulation
ORDER BY PercentOfInfectionVSPopulation DESC


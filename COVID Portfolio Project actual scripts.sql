Select *
From PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

Select *
From PortfolioProject..CovidVaccinations
WHERE continent is not null
order by 3,4

-- Select Data that I'm using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs. Total Deaths
-- Shows liklihood of dying if you contract Covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

-- Looking at Total Cases vs. Population
-- Shows what percentage of population contracted Covid

SELECT location, date, population, total_cases,  (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location = 'United States'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location = 'United States'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continents with highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location = 'United States'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
--Looking by date

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location = 'United States'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Looking at final number

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location = 'United States'
WHERE continent is not null
-- GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs. Vaccinations 
-- Employ rolling total number of new vaccinations, partitioned by country location
-- Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST (vac.new_vaccinations AS int)) OVER (Partition by dea.location
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST (vac.new_vaccinations AS int)) OVER (Partition by dea.location
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating views to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST (vac.new_vaccinations AS int)) OVER (Partition by dea.location
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

CREATE VIEW HighestInfectionCount AS
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location = 'United States'
WHERE continent is not null
GROUP BY location, population
--ORDER BY PercentPopulationInfected DESC

SELECT *
FROM HighestInfectionCount


CREATE VIEW HighestDeathCount  AS
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location = 'United States'
WHERE continent is not null
GROUP BY location
--ORDER BY TotalDeathCount DESC

SELECT *
FROM HighestDeathCount

CREATE VIEW TotalCovidDeaths AS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location = 'United States'
WHERE continent is not null
-- GROUP BY date
--ORDER BY 1,2

SELECT *
FROM TotalCovidDeaths

CREATE VIEW PercentofPopulationInfected  AS
SELECT location, date, population, total_cases,  (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
--ORDER BY 1,2

SELECT *
FROM PercentofPopulationInfected


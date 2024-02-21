

--all data in CovidDeaths table

SELECT * 
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3,4 

--all data in CovidVaccine table
SELECT *
FROM PortfolioProject.dbo.CovidVaccine
ORDER BY 3,4


--Select data that we are using

SELECT location, date, total_cases,new_cases, total_deaths,population
FROM PortfolioProject..CovidDeaths
order by 1,2 


-- Looking at Total cases vs Total Deaths

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
order by 1,2 



-- Looking at Total cases vs Total Deaths in United States

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases * 100) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2 

--Looking at Total cases vs population in United States(percentage of population got Covid)

SELECT location, date, total_cases,population, (total_cases/population) * 100 AS CovidCasesOverPopulation
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2 


--Looking at countries with Highest Infection rate compared to population

SELECT location, MAX(total_cases) as HighestInfectionCount,population, (MAX(total_cases*100))/population AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
order by PercentagePopulationInfected DESC

--countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
order by TotalDeathCount DESC

-- Showing continent with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
order by TotalDeathCount DESC


--Across the world, daily new cases, daily new deaths and death percentage 

SELECT date,SUM(new_cases) as dailycases, SUM(cast(new_deaths as INT)) as dailydeaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as DailyDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER by 1


--Across the world, total cases, total deaths and total death percenatage until date
SELECT SUM(new_cases) as totalcases, SUM(cast(new_deaths as INT)) as totaldeaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER by 1


--join covid death table and covid vaccine table 

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccine vac
ON dea.location= vac.location
and dea.date=vac.date

--Looking at total population vs vaccination using CTE

With Popvsvac(continent,location,date,population,New_vaccinations,RollingPeopleVaccinated) 
as
(
SELECT dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as INT)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccine vac
ON dea.location= vac.location
and dea.date=vac.date
WHERE dea.continent IS NOT NULL

)
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM Popvsvac
ORDER BY location



--TEMP table for total population vs vaccination 
DROP TABLE if exists #percentpopulationvaccinated
CREATE table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)

INSERT into #percentpopulationvaccinated
SELECT dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as INT)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccine vac
ON dea.location= vac.location
and dea.date=vac.date
WHERE dea.continent IS NOT NULL


select *,(RollingPeopleVaccinated/population)*100
FROM #percentpopulationvaccinated


--creating view to store data for later visualisations

CREATE View percentpopulationvaccinated as
SELECT dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as INT)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccine vac
ON dea.location= vac.location
and dea.date=vac.date
WHERE dea.continent IS NOT NULL


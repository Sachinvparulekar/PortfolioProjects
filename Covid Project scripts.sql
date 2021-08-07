/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Select Data that we are going to be starting with

Select * 
From PortfolioProjects..CovidDeaths
order by 3,4

--Select * 
--From PortfolioProjects..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..CovidDeaths
order by 1,2


-- Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
Where location like '%states%'
order by 1,2



-- Total Cases VS Population
--Shows what percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
 PercentPopulationInfected
From PortfolioProjects..CovidDeaths
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


--Showing Countries with higesht Death Count Population

Select location,Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
order by  TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population


Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by  TotalDeathCount desc



-- GLOBAL NUMBERS


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))
/SUM(new_cases)* 100 as DeathPercentage
From PortfolioProjects..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths as dea
Join PortfolioProjects..CovidVaccinations as vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query



With PopvsVac (Continent, location, Date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



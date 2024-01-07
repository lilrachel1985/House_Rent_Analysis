Select *
 From CovidExploration..CovidDeaths
 WHERE continent is not null
 order by 3,4

-- Select *
 --From CovidExploration..CovidVaccinations
 --order by 3,4

Select location,date,total_cases,new_cases,total_deaths,population
 From CovidExploration..CovidDeaths
 ORDER BY 1,2


--Looking for Total Cases vs Total Deaths
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
 From CovidExploration..CovidDeaths
 Where location like '%states%'
 ORDER BY 1,2

 --Looking at Total Cases vs Population
 Select location,date,Population,total_cases,(total_cases/population)*100 as PercentagePopulationInfected
 From CovidExploration..CovidDeaths
 Where location like '%states%'
 ORDER BY 1,2

 --Looking at countries with highest infection rate compared to population
 Select location,Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
 From CovidExploration..CovidDeaths
 GROUP BY location,Population
 order by PercentPopulationInfected desc

--Countries with Highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidExploration..CovidDeaths
WHERE continent is not null
Group by location
ORDER BY TotalDeathCount desc

--by continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidExploration..CovidDeaths
WHERE continent is not null
Group by continent
ORDER BY TotalDeathCount desc

--Global Numbers
Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int))as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidExploration..CovidDeaths
where continent is not null
--Group by date
order by 1,2

--Total Population vs Vaccinations
With PopVsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select deaths.continent,deaths.location,deaths.date,deaths.population, vaccine.new_vaccinations
, SUM(CONVERT(int,vaccine.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) AS RollingPeopleVaccinated
From CovidExploration..CovidDeaths deaths
Join CovidExploration..CovidVaccinations vaccine
       on deaths.location=vaccine.location
	   and deaths.date=vaccine.date
where deaths.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
from PopVsVac






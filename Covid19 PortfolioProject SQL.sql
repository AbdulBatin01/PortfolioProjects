Select * 
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3, 4

--Select * 
--from PortfolioProject.dbo.CovidVaccinations
--order by 3, 4


--Select Data to use
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
order by 1,2


--Total cases vs Total Deaths
Select Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where location like '%canada%'
order by 1,2

--Total Cases VS Popiulation
Select Location, date population, total_cases, (total_cases/population)*100 as CasePercentage
From PortfolioProject.dbo.CovidDeaths
--where location like '%canada%'
order by 1,2

--Countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as CasePercentage
From PortfolioProject.dbo.CovidDeaths
group by location,population
--where location like '%canada%'
order by CasePercentage desc

--countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location,population
--where location like '%canada%'
order by TotalDeathCount desc


--DIVISION BY CONTINENT

--Continents with highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers
Select SUM(new_cases) as TotalNewCases, SUM(CAST(new_deaths as int)) as TotalNewDeaths,  
(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where continent is not null
--group by date
order by 1,2


--JOINING DEATHS AND VACCINATIONS TABLES
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
--USE CTE
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table
Drop Table if exists #PercentPopVac 
Create Table #PercentPopVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopVac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopVac


--Creating View to store data

Create View PercentPopVac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


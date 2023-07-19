


select *
from PortfolioProjects..CovidDeaths
where continent is not null
order by 3, 4


--select *
--from PortfolioProjects..CovidVaccinations
--order by 3, 4


--Selecting Data that will be using.

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..CovidDeaths
where continent is not null
--where location like '%Grenada%'
order by 1, 2


--Looking at Total cases vs Total deaths(Death percentage)
-- Shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where location like '%nigeria%' and continent is not null
group by location, date, total_cases,total_deaths
order by 1, 2


-- Looking at the Total cases vs Population
--Shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population) *100 as CovidContractedPercentage
from PortfolioProjects..CovidDeaths
where location like '%gambia%' and continent is not null
group by location, date, population, total_cases
order by 1, 2


--Countries with the highest infection rate compared to the population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population) *100) as CovidContractedPercentage
from PortfolioProjects..CovidDeaths
--where location like '%gambia%'
where continent is not null
group by location, population
order by CovidContractedPercentage DESC


--Countries with the highest death count compared to the population

select location, MAX(CONVERT(int, total_deaths)) as TotalDeathCount --MAX((total_deaths/population) *100) as CovidContractedPercentage
from PortfolioProjects..CovidDeaths
--where location like '%gambia%'
where continent is not null and location like '%nigeria%'
group by location
order by TotalDeathCount DESC


--BY CONTINENT
--Showing continents with the highest death count

select continent, MAX(CONVERT(int, total_deaths)) as TotalDeathCount --MAX((total_deaths/population) *100) as CovidContractedPercentage
from PortfolioProjects..CovidDeaths
--where location like '%gambia%'
where continent is not null
group by continent
order by TotalDeathCount DESC


--Global Numbers
--Total New Cases, Total New Deaths, Total Death Percentage

select SUM(new_cases) TotalNewCases, SUM(CONVERT(int, new_deaths)) TotalNewDeaths, ((SUM(CONVERT(int ,new_deaths)))/(SUM(new_cases)))*100 DeathPercentage
from PortfolioProjects..CovidDeaths
--where location like '%gambia%'
where continent is not null
--group by date
order by 1, 2


--Total population vs Vaccinations
--Rolling People Vaccinated 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PArtition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location and
	dea.date = vac.date

where dea.continent is not null and dea.location like '%canada%'
order by 1, 2, 3


--Using a CTE

with popvsvac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PArtition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location and
	dea.date = vac.date

where dea.continent is not null and dea.location like '%canada%'

)
select *, (RollingPeopleVaccinated/Population) *100
from popvsvac
order by 1, 2, 3


--Using a Temp Table

DROP table if EXISTS #PercentPopulationVaccinated
CREATE table #PercentPopulationVaccinated
(
Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PArtition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location and
	dea.date = vac.date

--where dea.continent is not null and dea.location like '%canada%'

select *, (RollingPeopleVaccinated/Population) *100
from #PercentPopulationVaccinated



--Creating View to store data for later visualizations

Create View ThePercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PArtition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	on dea.location = vac.location and
	dea.date = vac.date

where dea.continent is not null 

Select *
from ThePercentPopulationVaccinated
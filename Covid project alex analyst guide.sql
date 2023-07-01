select *
from [portproj1.1]..CovidDeaths$
where continent is null
order by 3,4

--select *
--from [portproj1.1]..CovidVaccinations$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from [portproj1.1]..CovidDeaths$
order by 1,2

-- looking at the total cases vs total deaths
-- shows the likelihood of dying if you get caught Covid in canada
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as deathpercentage
from [portproj1.1]..CovidDeaths$
where location like 'canada'
order by 1,2

-- Looking at the total cases vs population
-- shows the percentage of people getting Covid in canada 
select location, date, total_cases, population, (total_cases/population) * 100 as covidpercentage
from [portproj1.1]..CovidDeaths$
where location like 'canada'
order by 1,2

--looking at countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, max((total_cases/population) * 100) as INFECTEDpercentage
from [portproj1.1]..CovidDeaths$
group by Location, population
order by INFECTEDpercentage


-- showing continents with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDEATHCount
from [portproj1.1]..CovidDeaths$
where continent is not null
group by continent
order by TotalDEATHCount desc

-- breaking into the global numbers
select date, sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast (new_deaths as int))/sum(new_cases) * 100 as deathpercentages
from [portproj1.1]..CovidDeaths$
where continent is not null
group by date
order by 1,2

--Looking at Population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [portproj1.1]..CovidDeaths$ as dea
join [portproj1.1]..CovidVaccinations$ as vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte
with popvsvac (Continent, Location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [portproj1.1]..CovidDeaths$ as dea
join [portproj1.1]..CovidVaccinations$ as vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
)

select *, (rollingpeoplevaccinated/population) * 100 as vaccinatefdpercentage
from popvsvac

--temp table
drop table if exists #percentagepopulationvaccinated
create table #percentagepopulationvaccinated
(continent nvarchar(255), location nvarchar(255), date datetime, population numeric, new_vaccinations numeric, rollingpeoplevaccinated numeric)

insert into #percentagepopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [portproj1.1]..CovidDeaths$ as dea
join [portproj1.1]..CovidVaccinations$ as vac
 on dea.location = vac.location
 and dea.date = vac.date
--where dea.continent is not null
order by 2,3

select *, (rollingpeoplevaccinated/population) * 100 as vaccinatefdpercentage
from #percentagepopulationvaccinated

--creating view to store data into tableau visualization later
Create view percentagepopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [portproj1.1]..CovidDeaths$ as dea
join [portproj1.1]..CovidVaccinations$ as vac
 on dea.location = vac.location
 and dea.date = vac.date
--where dea.continent is not null
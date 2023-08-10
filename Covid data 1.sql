-- Total cases vs total deaths (chances or possibilities of dying)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%Nigeria%'
order by 1,2

-- looking at the total cases vs population
-- shows what percentage of the population got covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentageInfected
from CovidDeaths
where location like '%Nigeria%'
order by 1,2

-- Looking at countries with highest infection rate compared to population
select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as MaxPercentageInfected
from CovidDeaths
--where location like '%Nigeria%'
group by location, population
order by MaxPercentageInfected desc

-- looking at the countries with the hightest death count per population
select location, population, max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is null
group by location, population
order by HighestDeathCount desc

-- global numbers
select sum(new_cases) as DailyNewCases, sum(cast(new_deaths as int)) as DailyNewDeaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as GlobalDeathPercentage
from CovidDeaths
--where location like '%Nigeria%'
where continent is not null
--group by date
order by 1,2

-- Total population vs total vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as cummulative_vaccinations
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using a CTE to determine the number of people vacinnated per population
with PopVsVac (continent, location, date, population, new_vaccinations, cummulative_vaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as cummulative_vaccinations
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (cummulative_vaccinations/population)*100
from PopVsVac

--Using Temp table for the above task
drop table if exists #PopVsVac
create table #PopVsVac
(continent nvarchar (255),
location varchar (255),
date datetime,
population numeric, 
new_vaccinations numeric,
cummulative_vaccinations numeric
)
insert into #PopVsVac
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as cummulative_vaccinations
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *, (cummulative_vaccinations/population)*100 as percentage_vacinnated_daily
from #PopVsVac

--creating view to store data for later visualization

create view percentage_population_vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as cummulative_vaccinations
from CovidDeaths as dea
join CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

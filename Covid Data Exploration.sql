--likelyhood of dying if you contract covid in your country
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where total_deaths != 0 and location like '%georgia%'
order by 1,2

--total cases vs population
--shows what percentage of population got covid
select location, date, population,total_cases, (total_cases/population)*100 as ContractPopulation
from CovidDeaths$
where location like '%georgia%'
order by 1,2

--countries with highest infection rate compared to population
select location, population ,max(total_cases) as HighestInfection, max((total_cases/population)*100) as ContractPopulation
from CovidDeaths$
group by population, location
order by ContractPopulation desc


--countries with the highest death count
select location ,max(cast(total_deaths as int)) as HighestDeath
from CovidDeaths$
where continent is not null
group by location 
order by HighestDeath desc

--countries with the highest death count per population
select location, population ,max(cast(total_deaths as int)) as HighestDeath, max((total_deaths/population)*100) as Death_Percentage
from CovidDeaths$
group by location, population
order by Death_Percentage desc

--break down by continent
--continents with the highest death per population
select continent, max(cast(total_deaths as int)) as HighestDeath
from CovidDeaths$
where continent is not null
group by continent
order by HighestDeath desc

--global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast (new_deaths as int)) / sum(new_cases)*100 as deathPercentage
from CovidDeaths$
where continent is not null
--group by date
order by 1,2

--total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast (vac.new_vaccinations as int))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ as dea
join CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE
with popvsvac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast (vac.new_vaccinations as int))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ as dea
join CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)

select *, (RollingPeopleVaccinated/population)*100
from popvsvac


--use temporary table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast (vac.new_vaccinations as int))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ as dea
join CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--creating view for vaccinated people percentage
create view PercentPopulationVaccinated
as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast (vac.new_vaccinations as int))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ as dea
join CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated


--creating view for percentage of people who got covid in Georgia
create view covidVacc
as
select location, date, population,total_cases, (total_cases/population)*100 as ContractPopulation
from CovidDeaths$
where location like '%georgia%'

select * from covidVacc

--creating view for highest deaths per population
create view DeathPop as
select location, population ,max(cast(total_deaths as int)) as HighestDeath, max((total_deaths/population)*100) as Death_Percentage
from CovidDeaths$
group by location, population

select * from DeathPop

--creatin view for each continent
create view Continents
as
select continent, max(cast(total_deaths as int)) as HighestDeath
from CovidDeaths$
where continent is not null
group by continent

select * from Continents

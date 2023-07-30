select * from PortfolioProject..Deaths$
where continent is not null
order by 3,4

-- select * from PortfolioProject..Vaccinations$
-- order by 3,4


-- select Data that we are going to be using

select Location, date, total_cases, new_cases,total_deaths, population_density from PortfolioProject..Deaths$
order by 1,2


-- looking at Total Cases vs Total Deaths

Select Location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..Deaths$
where continent is not null
order by 1,2


--looking in India

Select Location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..Deaths$
where continent is not null
and location like '%India%'  
order by 1,2


-- looking at total cases vs population 
-- shows what percentage of population got covid

Select Location, date,population_density, total_cases,  
(CONVERT (float, total_cases) / NULLIF(CONVERT(float, population_density), 0)) * 100 AS PercentagePopulationInfected
from PortfolioProject..Deaths$
where continent is not null
and location like '%India%'
order by 1,2



-- looking at countries with Highest Infection Rate compared to Population

Select Location, population_density, MAX(total_cases) as HighestInfectionRate,  
MAX((CONVERT (float, total_cases) / NULLIF(CONVERT(float, population_density), 0))) * 100 AS PercentagePopulationInfected
from PortfolioProject..Deaths$
--where location like '%India%'
group by Location, population_density
order by PercentagePopulationInfected desc


--Showing Countries with Highest Death Count Per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCounts
from PortfolioProject..Deaths$
where continent is not null
--where location like '%India%'
group by Location
order by TotalDeathCounts desc


--LETS BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCounts
from PortfolioProject..Deaths$
where continent is not null
--where location like '%India%'
group by continent
order by TotalDeathCounts desc


--SHOWING THE CONTINETS WITH THE HIGHEST DEATHS COUNT PER POPULATION

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCounts
from PortfolioProject..Deaths$
where continent is not null
--where location like '%India%'
group by continent
order by TotalDeathCounts desc


--GLOBAL NUMBERS

Select SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths,
SUM(new_deaths)/SUM(new_cases)* 100 AS Deathpercentage
from PortfolioProject..Deaths$
where continent is not null
--group by date
order by 1,2


--LOOKING AT TOTAL POPULATION VS VACCINATIONS

select dea.continent, dea.location,dea.date, dea.population_density, vac.new_vaccinations,
Sum(Convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from PortfolioProject..Deaths$ dea 
Join PortfolioProject..Vaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3 



-- USE CTE

with PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated )
as
( 
select dea.continent, dea.location,dea.date, dea.population_density, vac.new_vaccinations,
Sum(Convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from PortfolioProject..Deaths$ dea 
Join PortfolioProject..Vaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3 
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingpeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date, dea.population_density, vac.new_vaccinations,
Sum(Convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from PortfolioProject..Deaths$ dea 
Join PortfolioProject..Vaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
--where dea.continent is not null
--order by 2,3 

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--CREATING VIEW T0 STORE DATA FOR LATER VISUALIZATION.

CREATE VIEW PercenttPopulationVaccinated as 
select dea.continent, dea.location,dea.date, dea.population_density, vac.new_vaccinations,
Sum(Convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from PortfolioProject..Deaths$ dea 
Join PortfolioProject..Vaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3 

select * from PercenttPopulationVaccinated
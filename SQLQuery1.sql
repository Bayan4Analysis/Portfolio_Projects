select *
from Portfolio_Project_AAR..CovidDeaths
order by 3, 4


--select *
--from Portfolio_Project_AAR..CovidVaccinations
--order by 3, 4


-- Select dat for using

select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project_AAR..CovidDeaths
order by 1,2


-- Looking at Total_cases vs Total_deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percentage
from Portfolio_Project_AAR..CovidDeaths
where location like '%Jordan%'					   /* To identify the dying likelihood if contract covid in your country*/
order by 1,2


-- Looking at Total_cases vs Population in My country

/*Select location, date, total_cases, population, (total_cases/population)*100 as Infection_Percentage
from Portfolio_Project_AAR..CovidDeaths
where location like '%Jordan%'	
order by 1,2 */


-- Looking at Total_cases vs Population in the World

Select location, date, total_cases, population, (total_cases/population)*100 as Infection_Percentage
from Portfolio_Project_AAR..CovidDeaths
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to their Populations 

Select  location, population, max(total_cases) as Highest_infected_Cases, max((total_cases/population))*100 as Highest_Infection_Percentage
from Portfolio_Project_AAR..CovidDeaths
group by location, population
order by 4 desc


-- Looking at Countries with Highest Deaths Rate compared to their Populations 

Select  location, population, max(total_deaths) as Max_Deaths, max((total_deaths/population))*100 as Max_Deaths_Percentage
from Portfolio_Project_AAR..CovidDeaths
group by location, population
order by 4 desc


-- Looking at Countries with Highest Deaths Count compared to their Populations 

Select  location,  max(cast(total_deaths as int)) as Max_Deaths
from Portfolio_Project_AAR..CovidDeaths
where continent is not null                  /* To avoid comaparing Continent with Countries*/
group by location
order by 2 desc


-- Comparing regarding to the Continents of the Highest Deaths 

Select  location,  max(cast(total_deaths as int)) as Max_Deaths
from Portfolio_Project_AAR..CovidDeaths
where continent is null                 
group by location
order by 2 desc


-- Global Statistics for New Records
-- (1) Looking at the Total Cases & Deaths By Date

Select  date, sum(new_cases) as Total_Cases,  sum(cast(new_deaths as int)) as Total_Deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Sum_Percentage
from Portfolio_Project_AAR..CovidDeaths
where continent is not null				/* To avoid divide by {0} */
group by date
order by 1,2


-- (2) Looking at the Whole Total Cases & Deaths

Select  sum(new_cases) as Total_Cases,  sum(cast(new_deaths as int)) as Total_Deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as  Deaths_Percentage
from Portfolio_Project_AAR..CovidDeaths
where continent is not null				/* To avoid divide by {0} */


-- Joining The Two Tables: Deaths & Vaccination

/* Looking at Vaccination Vs. Population */

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Portfolio_Project_AAR..CovidDeaths  dea
join Portfolio_Project_AAR..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- (1) Calculate the Rolling Vaccinations by Location

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_Vaccinations
from Portfolio_Project_AAR..CovidDeaths  dea
join Portfolio_Project_AAR..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- (2) Use CTE >> to calculate Vaccinated (%)

with Pop_vs_Vac (continent, date, location, population, new_vaccinatons, Rolling_Vaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_Vaccinations
from Portfolio_Project_AAR..CovidDeaths  dea
join Portfolio_Project_AAR..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select*,  (Rolling_Vaccinations/population)*100 as Rolling_Vaccinations_Percentage
from Pop_vs_Vac


-- (3) Temp_Table

drop table if exists #percent_population_vaccinated

create table #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinatons numeric,
Rolling_Vaccinations numeric)

insert into #percent_population_vaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_Vaccinations
from Portfolio_Project_AAR..CovidDeaths  dea
join Portfolio_Project_AAR..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
-- where dea.continent is not null

select*,  (Rolling_Vaccinations/population)*100 as Rolling_Vaccinations_Percentage
from #percent_population_vaccinated


-- Creating View to store data for Later Visualization

Create View percent_population_vaccinations as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_Vaccinations
from Portfolio_Project_AAR..CovidDeaths  dea
join Portfolio_Project_AAR..CovidVaccinations vac
	 on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select *
from percent_population_vaccinations

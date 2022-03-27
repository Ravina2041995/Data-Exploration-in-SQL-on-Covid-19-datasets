Select * from 
PortfolioProjectCovidDataExtraction..['Covid 19 Death$']

Select location,date, total_cases,new_cases,total_deaths,population
from PortfolioProjectCovidDataExtraction..['Covid 19 Death$']

--Total cases vs death for India 
--Shows likehood of dying if you had covid in india
Select total_cases,total_deaths,location,date, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjectCovidDataExtraction..['Covid 19 Death$']
Where location like 'India' and continent is not null
order by location

----Total cases vs death for population 
--Shows what percentage of populations got Covid
Select total_cases,total_deaths,location,date,population, (total_cases/population)*100 as Covid_Population
from PortfolioProjectCovidDataExtraction..['Covid 19 Death$']
Where continent is not null
order by location,date


--Looking at countries with highest infection rate compared to population
Select location,population,max(total_cases) as highestInfectionCount, max((total_cases/population))*100 as PercentageOfPopulation
from PortfolioProjectCovidDataExtraction..['Covid 19 Death$']
Where continent is not null
Group by location,population
order by PercentageOfPopulation desc

--Showing countries with highest death count per population

Select location,population,max(total_deaths) as highestDeath, max((total_deaths/population))*100 as Percentage_Of_Death_Population
from PortfolioProjectCovidDataExtraction..['Covid 19 Death$']
Where continent is not null
Group by location,population
order by Percentage_Of_Death_Population desc


--Showing countries with highest death count per population

Select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjectCovidDataExtraction..['Covid 19 Death$']
Where continent is not null
Group by location
order by TotalDeathCount desc

---But it is also showing Asia and world wise, so let's gets rid of it
Select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjectCovidDataExtraction..['Covid 19 Death$']
Where continent is not null
Group by location
order by TotalDeathCount desc

--lets see data by continent
Select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjectCovidDataExtraction..['Covid 19 Death$']
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Here north America is putting output only based on US not cannada 

Select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjectCovidDataExtraction..['Covid 19 Death$']
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global numbers

Select date,Sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_death,sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProjectCovidDataExtraction..['Covid 19 Death$']
Where continent is not null
Group by date
order by 1,2

-- Total cases
Select Sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_death,sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProjectCovidDataExtraction..['Covid 19 Death$']
Where continent is not null
order by 1,2

Select *
from PortfolioProjectCovidDataExtraction..['Covid 19 Vaccine$']

--Join 2 tables

Select *
from PortfolioProjectCovidDataExtraction..['Covid 19 Death$'] as dea
Join PortfolioProjectCovidDataExtraction..['Covid 19 Vaccine$'] vac
	on dea.location = vac.location
	and dea.date = vac.date

--Looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, 
dea.population, vac.new_vaccinations
from PortfolioProjectCovidDataExtraction..['Covid 19 Death$'] as dea
Join PortfolioProjectCovidDataExtraction..['Covid 19 Vaccine$'] as vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 1,2,3

--Looking as total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProjectCovidDataExtraction..['Covid 19 Death$'] as dea
Join PortfolioProjectCovidDataExtraction..['Covid 19 Vaccine$'] as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProjectCovidDataExtraction..['Covid 19 Death$'] as dea
Join PortfolioProjectCovidDataExtraction..['Covid 19 Vaccine$'] as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProjectCovidDataExtraction..['Covid 19 Death$'] as dea
Join PortfolioProjectCovidDataExtraction..['Covid 19 Vaccine$'] as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



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
from PortfolioProjectCovidDataExtraction..['Covid 19 Death$'] as dea
Join PortfolioProjectCovidDataExtraction..['Covid 19 Vaccine$'] as vac
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
from PortfolioProjectCovidDataExtraction..['Covid 19 Death$'] as dea
Join PortfolioProjectCovidDataExtraction..['Covid 19 Vaccine$'] as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select the data we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2 

--Looking at the total cases vs total deaths
--Shows the likelihood of death if infected with Covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2 

--Looking at the total cases vs the population
--Shows that percentage of population was infected with Covid
Select location, date, population, total_cases, (total_cases/population)*100 AS PercentOfPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2 

--Looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentOfPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by population, location
Order by PercentOfPopulationInfected desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the countries with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--GLOBAL NUMBERS
Select SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
Order by 1,2

--Total numbers
Select SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS _Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage --, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
Order by 1,2


--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingVaccinationNumbers
, (RollingVaccinationNumbers/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
Order by 2,3

---Use a CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinationNumbers)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingVaccinationNumbers
--, (RollingVaccinationNumbers/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingVaccinationNumbers/population)*100
From PopvsVac


--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationNumbers numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingVaccinationNumbers
--, (RollingVaccinationNumbers/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingVaccinationNumbers/population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingVaccinationNumbers
--, (RollingVaccinationNumbers/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated
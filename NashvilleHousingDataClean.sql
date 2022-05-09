--Let's take a look at the data


Select *
from PortfolioProject..NashvilleHousing

--Standardize the date format

Select SaleDate, CONVERT(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

--The above did not work, not sure why

--Create new column and convert the date into that column

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDate, SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing

--Populate Property Address data

Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

Select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is Null
order by ParcelID

--ParcelID looks to be paired with PropertyAddress so we can use the ParcelID with a paired PropertyAddress to fill in the null values on PropertyAddress

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress , ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Address, City, State
--The comma in PropertyAddress separates the street address from the town/city. Need to split

Select PropertyAddress
From PortfolioProject..NashvilleHousing

--Gives us the address and city separate
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

--Let's add them to the table now

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

----------------------------------------------------------------------------------------------------------------------------------------------------------

--Let's look at Owner Address
Select OwnerAddress
From PortfolioProject..NashvilleHousing

--Parsename looks for '.' so we should replace the commas with periods
--Parsename reads backwards from period separation

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3) as Address,
PARSENAME(Replace(OwnerAddress, ',', '.'), 2) as City,
PARSENAME(Replace(OwnerAddress, ',', '.'), 1) as State
From PortfolioProject..NashvilleHousing

--Now same as before, add them into the table

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

---------------------------------------------------------------------------------------------------------------------

--Let's look at the SoldAsVacant Column

Select Distinct(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing

--We have N, Yes, Y, and No. We should make that consistent to N/Y

Update NashvilleHousing
Set SoldAsVacant = 'No'
Where SoldAsVacant = 'N'

Update NashvilleHousing
Set SoldAsVacant = 'Yes'
Where SoldAsVacant = 'Y'

/*
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
Group by SoldAsVacant
*/

--Alternate method, probably better and should have done first

/*
Select SoldAsVacant
,	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 Else SoldAsVacant
		 END
From PortfolioProject..NashvilleHousing
*/
/*
Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 Else SoldAsVacant
		 END
*/

------------------------------------------------------------------------------------------------------------------------------

--Let's remove duplicates (Note to self, don't delete data typically. Look into temp tables)

With RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER(
	Partition BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
)

DELETE
From RowNumCTE
Where row_num > 1

-------------------------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns (Same as above, don't do this to whole raw data. Just for practice)

Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
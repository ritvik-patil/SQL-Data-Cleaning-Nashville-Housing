/*

Cleaning Data in SQL Queries

*/

USE PortfolioProject;

SELECT * FROM NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM NashvilleHousing;

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
ADD SaleDateCoverted DATE;

UPDATE NashvilleHousing
SET SaleDateCoverted = CONVERT(Date,SaleDate);

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;

SELECT SaleDateCoverted
FROM NashvilleHousing;

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress is null;
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, 
b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- Seperate PropertyAddress into (Address, City) columns-- Using SUBSTRING method
SELECT PropertyAddress
FROM NashvilleHousing;


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

SELECT PropertyAddress,PropertySplitAddress,PropertySplitCity
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress;

SELECT *
FROM NashvilleHousing;

-- Seperate Owner Address into (Address,City,State) columns-- Using PARSENAME method
SELECT OwnerAddress
FROM NashvilleHousing;

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

SELECT OwnerAddress,OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress;

SELECT *
FROM NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2;

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing;

Update NashvilleHousing
SET SoldAsVacant = 
  CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertySplitAddress,
				 SalePrice,
				 SaleDateCoverted,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
From NashvilleHousing
--ORDER BY ParcelID;
)
--SELECT * 
--FROM RowNumCTE
--WHERE row_num>1
--ORDER BY PropertySplitAddress;
DELETE
FROM RowNumCTE
WHERE row_num>1;
--ORDER BY PropertySplitAddress;

SELECT*
From NashvilleHousing;


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From NashvilleHousing;


ALTER TABLE NashvilleHousing
DROP COLUMN TaxDistrict;




-----------------------------------------------------------------------------------------------
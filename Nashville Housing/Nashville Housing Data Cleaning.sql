																				-- Data Cleaning --

 
-- Creating Table -- 

CREATE TABLE NashvilleHousing (
    UniqueID INT NOT NULL,
    ParcelID VARCHAR(255) NOT NULL,
    LandUse VARCHAR(255) NOT NULL,
    PropertyAddress VARCHAR(255),
    SaleDate VARCHAR(255),
    SalePrice VARCHAR(255),
    LegalReference VARCHAR(255),
    SoldAsVacant VARCHAR(10),
    OwnerName VARCHAR(255),
    OwnerAddress VARCHAR(255),
    Acreage FLOAT,
    TaxDistrict VARCHAR(255),
    LandValue FLOAT,
    BuildingValue FLOAT,
    TotalValue FLOAT,
    YearBuilt FLOAT,
    Bedrooms FLOAT,
    FullBath FLOAT,
    HalfBath FLOAT
);

SELECT *
FROM NashvilleHousing;

 
 
 -- Standardizing Date Format --
 
                                                                    

SELECT SaleDate, STR_TO_DATE(SaleDate, '%M %d, %Y') AS SaleDateConverted
FROM NashvilleHousing;

-- Update the SaleDate column to the new date format 
UPDATE NashvilleHousing
SET SaleDate = STR_TO_DATE(SaleDate, '%M %d, %Y');


  
-- Populating Property Address --



SELECT *
FROM NashvilleHousing
-- WHERE PropertyAddress IS NULL;
ORDER BY ParcelID;

-- Find rows with missing PropertyAddress
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
       COALESCE(a.PropertyAddress, b.PropertyAddress) AS NewPropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


-- Update rows with missing PropertyAddress
UPDATE NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;



 -- Breaking Out Address into Individual Columns --



Select PropertyAddress
From NashvilleHousing;

-- Display the PropertyAddress split into Address and City/State
SELECT 
  SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address,
  TRIM(SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1)) AS City
FROM NashvilleHousing;

-- Adding columns
ALTER TABLE NashvilleHousing
ADD COLUMN PropertySplitAddress VARCHAR(255),
ADD COLUMN PropertySplitCity VARCHAR(255);

-- Updating PropertySplitAddress and PropertySplitCity columns with split PropertyAddress values
UPDATE NashvilleHousing
SET PropertySplitAddress = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', 1)),
    PropertySplitCity = TRIM(SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1));

    

Select *
From NashvilleHousing;

SELECT OwnerAddress
FROM NashvilleHousing;


-- Display the OwnerAddress split into Address, City, and State
SELECT
  TRIM(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1)) AS OwnerSplitAddress,
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2), '.', -1)) AS OwnerSplitCity,
  TRIM(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1)) AS OwnerSplitState
FROM NashvilleHousing;

-- Adding columns for OwnerSplitAddress, OwnerSplitCity, and OwnerSplitState
ALTER TABLE NashvilleHousing
ADD COLUMN OwnerSplitAddress VARCHAR(255),
ADD COLUMN OwnerSplitCity VARCHAR(255),
ADD COLUMN OwnerSplitState VARCHAR(255);

-- Updating OwnerSplitAddress, OwnerSplitCity, and OwnerSplitState columns with split OwnerAddress values
UPDATE NashvilleHousing
SET OwnerSplitAddress = TRIM(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1)),
    OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2), '.', -1)),
    OwnerSplitState = TRIM(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1));




SELECT *
FROM NashvilleHousing;



  -- Change Y and N to Yes and No in "Sold as Vacant" field --



SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;



SELECT SoldAsVacant,
       CASE 
           WHEN SoldAsVacant = 'Y' THEN 'Yes'
           WHEN SoldAsVacant = 'N' THEN 'No'
           ELSE SoldAsVacant
       END AS SoldAsVacantNew
FROM NashvilleHousing;


UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
                      WHEN SoldAsVacant = 'Y' THEN 'Yes'
                      WHEN SoldAsVacant = 'N' THEN 'No'
                      ELSE SoldAsVacant
                   END;



 -- Removing duplicates --
 


WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;




DELETE FROM NashvilleHousing
WHERE UniqueID IN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
                   ORDER BY UniqueID
               ) AS row_num
        FROM NashvilleHousing
    ) AS duplicates
    WHERE row_num > 1
);
                   
              
SELECT *
FROM NashvilleHousing;



 -- Delete Unused Columns --



SELECT *
FROM NashvilleHousing;


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;
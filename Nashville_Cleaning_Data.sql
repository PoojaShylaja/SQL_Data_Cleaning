/*

Cleaning Data in SQL Queries

*/

SELECT * 
FROM NashvilleHousing

-------------------------------------------------------------------------------------------------------------

--standardize date format
SELECT SaleDate
FROM NashvilleHousing

SELECT SaleDate,CAST(SaleDate AS date) AS Sale_Date
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD ConvertedSaleDate Date;

UPDATE NashvilleHousing
SET ConvertedSaleDate = CONVERT(Date,SaleDate)

---------------------------------------------------------------------------------------------------------------
--Populate property address  (ParcelId and Property address same)

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID,a.propertyaddress,b.ParcelID,b.propertyaddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS null
ORDER BY a.ParcelID

UPDATE a -- (when using update keep the aliasing name when using join)
SET	PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS null


------------------------------------------------------------------------------------------------------

--Breaking out address into individual columns(address,city,state)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing

----FOR OWNER ADDRESS

SELECT OwnerAddress 
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerPropertyAddress NVARCHAR(255)

ALTER TABLE NashvilleHousing
ADD OwnerPropertyCity NVARCHAR(255)

ALTER TABLE NashvilleHousing
ADD OwnerPropertystate NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerPropertyAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE NashvilleHousing
SET OwnerPropertyCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE NashvilleHousing
SET OwnerPropertyState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM NashvilleHousing

--------------------------------------------------------------------------------------------------------------------- 

---change  y or n to yes or no in the table

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant ='N' THEN 'NO'
      WHEN SoldAsVacant = 'Y' THEN 'NO'
	  ELSE SoldAsVacant
	  END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant ='N' THEN 'NO'
						 WHEN SoldAsVacant = 'Y' THEN 'NO'
						 ELSE SoldAsVacant
					     END

---------------------------------------------------------------------------------------------

---Remove duplicates
WITH rownumCTE AS (
SELECT *,
ROW_Number()  OVER (PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY UniqueID ) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)

select *
FROM rownumCTE
WHERE row_num >1
ORDER BY PropertyAddress

WITH rownumCTE AS (
SELECT *,
ROW_Number()  OVER (PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY UniqueID ) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)

delete
FROM rownumCTE
WHERE row_num >1

-------------------

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,SaleDate

------------------------------------------------------------------


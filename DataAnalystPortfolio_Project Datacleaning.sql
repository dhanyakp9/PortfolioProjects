--All data from the table

SELECT * 
FROM dbo.NashvilleHousing

--Standardize Sale Date format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM dbo.NashvilleHousing

		--add new column for Converted saledate

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;
		--update the value 
UPDATE NashvilleHousing
SET SaleDateConverted= CONVERT(Date,SaleDate)

		--makesure the changes appeared 
SELECT SaleDate, SaleDateConverted
FROM dbo.NashvilleHousing

----------------------------------------------------------------------

--populate Property Address data

			--when parcel ids are same, then property address also the same.

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	on a.ParcelID= b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is NULL



UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	on a.ParcelID= b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is NULL

-----------------------------------------------------------------------------------
--Breaking out Address into Individual colums (Address, City,State)

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
FROM dbo.NashvilleHousing

--add a column
ALTER TABLE NashvilleHousing
ADD StreetAddress VARCHAR(250);

--update the value 
UPDATE NashvilleHousing
SET StreetAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE NashvilleHousing
ADD City VARCHAR(250);

UPDATE NashvilleHousing
SET City= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) 


--Owner address splitting using PARSENAME 
SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),1),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
FROM dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(250);

UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity VARCHAR(250);
UPDATE NashvilleHousing
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState VARCHAR(250);
UPDATE NashvilleHousing
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)



--------------------------------------------------------------
-- Y to Yes and N to No

SELECT DISTINCT (SoldAsVacant), count(SoldAsVacant) 
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT  SoldAsVacant,
CASE When SoldAsVacant='Y' THEN 'Yes'
	When SoldAsVacant= 'N' THEN 'No'
	ELSE SoldAsVacant
	END
		FROM dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =CASE When SoldAsVacant='Y' THEN 'Yes'
	When SoldAsVacant= 'N' THEN 'No'
	ELSE SoldAsVacant
	END


	--------------------------------------------------------------
	--Remove Duplicates

WITH ROWNUMCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY UniqueID) as rownum
FROM dbo.NashvilleHousing)
DELETE 
FROM ROWNUMCTE
Where rownum>1


------------------------------------------------------------------------

	--Delete unused columns

	ALTER TABLE dbo.NashvilleHousing
	DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate
USE NashvilleHousing

select*
FROM DBO.NashvilleHousing

--Standardize Date Format

SELECT SaleDate
FROM DBO.NashvilleHousing

SELECT SaleDate, CONVERT(date,SaleDate) as SaleDateConverted
FROM DBO.NashvilleHousing

ALTER TABLE DBO.NashvilleHousing
ADD SaleDateConverted Date

UPDATE DBO.NashvilleHousing
SET SaleDateConverted =  CONVERT(date,SaleDate)

SELECT SaleDateConverted
FROM DBO.NashvilleHousing

ALTER TABLE DBO.NashvilleHousing
DROP COLUMN SaleDate

--Populate Property Address data

SELECT PropertyAddress
FROM DBO.NashvilleHousing
WHERE PropertyAddress is NULL

SELECT *
FROM DBO.NashvilleHousing
--WHERE PropertyAddress is NULL
order by parcelID

SELECT a.parcelID,b.parcelID,a.PropertyAddress,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress) As AmendedPropertyName
FROM DBO.NashvilleHousing A
JOIN DBO.NashvilleHousing B
	ON  a.parcelID = b.parcelID
	AND a.uniqueID != b.uniqueID
WHERE a.PropertyAddress is NULL

UPDATE A
SET a.PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM DBO.NashvilleHousing A
JOIN DBO.NashvilleHousing B
	ON  a.parcelID = b.parcelID
	AND a.uniqueID != b.uniqueID
WHERE a.PropertyAddress is NULL

SELECT *
FROM DBO.NashvilleHousing
WHERE PropertyAddress is NULL

--Breaking out Address Into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM DBO.NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 1, (CHARINDEX( ',', PropertyAddress) -1 )), 
SUBSTRING(PropertyAddress, (CHARINDEX( ',', PropertyAddress) +1 ), len(PropertyAddress)) 
FROM DBO.NashvilleHousing

ALTER TABLE DBO.NashvilleHousing
ADD PropertyAddressSplit NVARCHAR(255)

ALTER TABLE DBO.NashvilleHousing
DROP COLUMN PropertyAddressSplit

UPDATE DBO.NashvilleHousing
SET PropertyAddressSplit =  SUBSTRING(PropertyAddress, 1, (CHARINDEX( ',', PropertyAddress) -1 ))

ALTER TABLE DBO.NashvilleHousing
ADD SplitPropertyAddressCity NVARCHAR(255)

ALTER TABLE DBO.NashvilleHousing
DROP COLUMN SplitPropertyAddressCity

UPDATE DBO.NashvilleHousing
SET SplitPropertyAddressCity =  SUBSTRING(PropertyAddress, (CHARINDEX( ',', PropertyAddress) +1 ), len(PropertyAddress))

--Spliting OWNER Address

SELECT OWNERAddress
FROM DBO.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


--Change Y and N to "Yes" and "No" in SoldAsVacant column 


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From dbo.NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant,
CASE 
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
From dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE 
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
From dbo.NashvilleHousing

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


Select *
From PortfolioProject.dbo.NashvilleHousing


-- Delete Unused Columns

Select *
From dbo.NashvilleHousing


ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

dir=$1
if [ $# -eq 0 ]; then
    dir="test_files"
    echo -e "No arguments provided, using default folder: $dir \n"
fi

if [ ! -d $dir ]; then
  echo "Directory $dir does not exist!"
  exit 1
fi

# fetch names of all png images into array
declare -a imageFiles
for file in $dir/*.png
do 
  imageFiles=(${imageFiles[@]} "$file") 
done

# shuffle .png file names
shuffled=( $(shuf -e "${imageFiles[@]}") )

for i in "${!imageFiles[@]}"
do
  oldName=${imageFiles[$i]}
  newName=${shuffled[$i]}
  
  oldNameWithoutDir=${oldName##*/}
  newNameWithoutDir=${newName##*/}
  
  oldJsonName=${oldName%%.png}.json
  # Must add suffix _new to avoid overriding files
  newJsonName=${newName%%.png}.json_new

  oldNumber=${oldNameWithoutDir%%.png}
  newNumber=${newNameWithoutDir%%.png}

  # Must add suffix _new to avoid overriding files
  echo "Rename ${oldName##*/} into ${newName##*/} "
  mv ${imageFiles[$i]} ${shuffled[$i]}_new
 
  echo "Rename $oldJsonName into $newJsonName "
  mv $oldJsonName $newJsonName

  echo "Update JSON file ($oldNumber to $newNumber)"

  sed -i "s/$oldNameWithoutDir/$newNameWithoutDir/g" $newJsonName
  sed -i "s/\"edition\"\: $oldNumber/\"edition\"\: $newNumber/g" $newJsonName
  sed -i "s/#$oldNumber/#$newNumber/g" $newJsonName

  echo -e "\n"
done

# rename files to remove _new suffix
for file in $dir/*_new; do
    mv -- "$file" "${file%%_new}"
done

pwd

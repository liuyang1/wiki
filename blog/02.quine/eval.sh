ridiculous() {
    echo "$1 is ridiculous"
}

s=`ridiculous god`
echo $s

eval "ridiculous god"

# Find the parent directory containing the setup.py file.
echo "Looking for setup.py..."
cd "$PWD/$(dirname $0)"
while true
do
    if [ -e "setup.py" ]
    then
        base_directory=$PWD
        break
    elif [ $PWD = "/" ]
    then
        echo "Error: setup.py not found."
        exit 1
    else
        cd ..
    fi
done

# Create a venv if one doesn't exist.
if ! [ -d ".venv" ]
then
    echo "Creating virtual environment..."
    python -m venv .venv
fi

# Activate the venv.
. .venv/bin/activate
python --version

# Install build dependencies.
echo "Installing build dependencies..."
python -m pip install build

# If not already present, clone the AutoTrace repository.
if ! [ -d "third-party" ]
then
    echo "Cloning AutoTrace repository..."
    mkdir third-party
    cd third-party
    git clone https://github.com/autotrace/autotrace.git
    cd autotrace
    git reset --hard fcd9043f6227979ea2b21ac5d9f796325bdb1343
    cd distribute/win/3rdparty
    unzip glib-dev_2.34.3-1_win64.zip -d glib
    cd $base_directory
fi

# Build distributions.
echo "Building distributions..."
python -m build

echo "Finished."

# Find the parent directory containing the setup.py file.
echo "Looking for setup.py..."
cd "$PWD/$(dirname $0)"
while true
do
    if [ -e "setup.py" ]
    then
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

# Update autotrace submodule.
if ! [ -d "third-party/autotrace/src" ]
then
    echo "Updating autotrace submodule..."
    git submodule update --init
fi

# Extract GLib headers.
if ! [ -d "third-party/glib" ]
then
    echo "Extracting GLib headers..."
    unzip third-party/autotrace/distribute/win/3rdparty/glib-dev_2.34.3-1_win64.zip -d third-party/glib
fi

# Build distributions.
echo "Building distributions..."
python -m build

echo "Finished."

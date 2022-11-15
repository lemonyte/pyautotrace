# Save original working directory.
$OriginalLocation = Get-Location

# Find the parent directory containing the setup.py file.
Write-Host "Looking for setup.py..."
while ($True)
{
    if (Test-Path "setup.py")
    {
        $Root = Get-Location
        break
    }
    else
    {
        Set-Location ".."
    }
}

# Create a venv if one doesn't exist.
if (-not (Test-Path ".venv"))
{
    Write-Host "Creating virtual environment..."
    python -m venv .venv
}

# Activate the venv.
. ".venv\Scripts\Activate.ps1"

# Install build dependencies.
Write-Host "Installing build dependencies..."
pip install -r requirements-dev.txt

# If not already present, download the AutoTrace repository.
if (-not (Test-Path "third-party"))
{
    Write-Host "Downloading AutoTrace repository..."
    New-Item "third-party" -ItemType Directory
    Set-Location "third-party"
    git clone https://github.com/autotrace/autotrace.git
    Set-Location "autotrace"
    git reset --hard fcd9043f6227979ea2b21ac5d9f796325bdb1343
    Set-Location "distribute\win\3rdparty"
    Expand-Archive "glib-dev_2.34.3-1_win64.zip" -DestinationPath "glib"
    Set-Location $Root
}

# Clean build files.
Write-Host "Cleaning build files..."
python setup.py clean --all
if (Test-Path "build")
{
    Remove-Item "build" -Recurse
}

# Build distributions.
Write-Host "Building distributions..."
python setup.py sdist
python setup.py bdist_wheel

# Restore original working directory.
Set-Location $OriginalLocation

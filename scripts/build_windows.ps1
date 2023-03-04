# Save original working directory.
$OriginalLocation = Get-Location

try
{
    # Find the parent directory containing the setup.py file.
    Write-Host "Looking for setup.py..."
    while ($True)
    {
        if (Test-Path "setup.py")
        {
            $BaseDirectory = Get-Location
            break
        }
        elseif ((Get-Location).Path -eq "$(Split-Path $PSScriptRoot -Qualifier)\")
        {
            Write-Host "Error: setup.py not found."
            exit 1
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
    python --version

    # Install build dependencies.
    Write-Host "Installing build dependencies..."
    pip install -r requirements-dev.txt

    # If not already present, clone the AutoTrace repository.
    if (-not (Test-Path "third-party"))
    {
        Write-Host "Cloning AutoTrace repository..."
        New-Item "third-party" -ItemType Directory | Out-Null
        Set-Location "third-party"
        git clone https://github.com/autotrace/autotrace.git
        Set-Location "autotrace"
        git reset --hard fcd9043f6227979ea2b21ac5d9f796325bdb1343
        Set-Location $BaseDirectory
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

    Write-Host "Finished."
}
finally
{
    # Restore original working directory.
    Set-Location $OriginalLocation
}

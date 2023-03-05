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
    python -m pip install build

    # Update autotrace submodule.
    if (-not (Test-Path "third-party\autotrace\src"))
    {
        Write-Host "Updating autotrace submodule..."
        git submodule update --init
    }

    # Extract GLib headers.
    if (-not (Test-Path "third-party\glib"))
    {
        Write-Host "Extracting GLib headers..."
        Expand-Archive "third-party\autotrace\distribute\win\3rdparty\glib-dev_2.34.3-1_win64.zip" -DestinationPath "third-party\glib"
    }

    # Build distributions.
    Write-Host "Building distributions..."
    python -m build

    Write-Host "Finished."
}
finally
{
    # Restore original working directory.
    Set-Location $OriginalLocation
}

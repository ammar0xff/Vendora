@echo off
:: erp.bat — wrapper for manage.py on Windows
:: Installed to System32 by install.bat so it works from any terminal
python "%~dp0manage.py" %*

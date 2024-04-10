$day_of_today = Get-Date -Format "yyyyMMdd"
$installation_dir = "C:\Users\stecot\OneDrive - CTRL Informatique Ltée\GitHub\azure-pricer\" 
$excel_files_dir = Join-Path $installation_dir "output\"
$max_number_of_xls_files = 30

$excel_file_of_today = Join-Path $excel_files_dir "Azure-Quote-Tool-$day_of_today.xlsx"
$readme_file_template = Join-Path $excel_files_dir "README.MD.template"
$readme_file = Join-Path $installation_dir "README.MD"

Set-Location $installation_dir

git pull
Write-Host "UPDATING CODE FROM REPO"

python $installation_dir\xls_generator.py $excel_file_of_today

if (-not (Test-Path $excel_file_of_today)) {
    Write-Host "ERROR"
    exit
}

(Get-Content $readme_file_template).replace('__DATE__', $day_of_today) | Set-Content $readme_file

Get-ChildItem $excel_files_dir -Filter "Azure-Quote-Tool-*.xlsx" |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$max_number_of_xls_files) } |
    ForEach-Object { git rm $_.FullName }

Set-Location $installation_dir
git add $excel_file_of_today $readme_file
git commit -m "Automatic build of $day_of_today"
git push

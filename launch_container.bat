cd /D "%~dp0"
set "PWD=."
docker rm -f devenv
docker compose run --build --name devenv --rm --service-ports devenv

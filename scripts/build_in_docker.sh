set -eu -o pipefail

SCRIPT_DIR="${BASH_SOURCE[0]}"
while [ -h "$SCRIPT_DIR" ] ; do SCRIPT_DIR="$(readlink "$SCRIPT_DIR")"; done
PROJECT_DIR="$( cd -P "$( dirname "$SCRIPT_DIR" )/.." && pwd )"
DIST_DIR="${PROJECT_DIR}/scap/content/guides/openscap"
SSG_VER_FILE="${PROJECT_DIR}/.github/workflows/dependabot_hack.yml"
SSG_VER="v$(grep 'ComplianceAsCode/content' "$SSG_VER_FILE" | grep -oE '[0-9]+(\.[0-9]+){1,3}')"

echo "Removing old ssg-build container..."
docker container stop ssg-build || true

echo "Building the ssg-build image using version ${SSG_VER}..."
docker build --build-arg SSG_VER="$SSG_VER" -t ssg-build -f "${PROJECT_DIR}/scripts/Dockerfile" .

echo "Running the ssg-build container..."
docker run --rm -dit --name ssg-build ssg-build

echo "Copying the ssg content from the container..."
docker cp -q ssg-build:/tmp/dist/. "${DIST_DIR}/"

echo "Stopping the ssg-build container..."
docker container stop ssg-build

echo "Done!"

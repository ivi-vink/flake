#!/bin/sh
echo "##vso[task.setvariable variable=version;isOutput=true]$VERSION";
cd "$CHART_CONTEXT_PATH" || { echo "Coulnd't find ./destination"; ls; exit 1; }
case "$BUILD_SOURCEBRANCH" in
  refs/heads/*)
    echo "Seting version to sha prerelease $VERSION"
    yq -i '
      .appVersion = ("'"$VERSION"'" | . style="double")
      | .version = "0.0.0-'"$VERSION"'"
    ' Chart.yaml
    ;;
  refs/tags/*)
    echo "Seting version to tag $VERSION"
    yq -i '
      .appVersion = ("'"$VERSION"'" | . style="double")
      | .version = "'"$VERSION"'"
    ' Chart.yaml
    ;;
esac
cd ..

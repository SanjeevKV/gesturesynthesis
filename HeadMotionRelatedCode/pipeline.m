function pipeline(mocapOutputPath,coordinatesPath,handDistancePath, handMarkersPath, headMarkersPath, headMarkerCount, eulerAnglesPath)
  parseAllFBX(mocapOutputPath,coordinatesPath)
  getDistanceBetweenHandsAll(coordinatesPath, handDistancePath, handMarkersPath)
  prepareAllEulerAngles(coordinatesPath, eulerAnglesPath, headMarkerCount, headMarkersPath)
end
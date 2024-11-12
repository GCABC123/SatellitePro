import ee
import folium
import os
from datetime import datetime, timedelta


# Retrieve the gee_key environment variable
gee_key = os.environ.get("gee_key")

# Verify if the key is available
if gee_key:
    print("Google Earth Engine API Key:", gee_key)
else:
#   print("API Key not found")


def authenticate_and_initialize(api_key):
    """Initialize Google Earth Engine with an API key."""
    try:
        # Use ServiceAccountCredentials with API key for initialization
        credentials = ee.ServiceAccountCredentials('', api_key)
        ee.Initialize(credentials)
        print("Google Earth Engine initialized successfully with API key.")
    except ee.EEException as e:
        print(f"Error initializing Google Earth Engine: {e}")

def get_image_collection(collection_id, start_date, end_date, latitude, longitude):
    """Retrieve the specified image collection and filter by date and location."""
    try:
        # Load and filter the image collection by date and location
        collection = ee.ImageCollection(collection_id).filterDate(start_date, end_date).filterBounds(
            ee.Geometry.Point(longitude, latitude))
        return collection
    except ee.EEException as e:
        print(f"Error accessing image collection {collection_id}: {e}")
        return None

def create_map(latitude, longitude, image):
    """Create a folium map with the specified image overlay."""
    # Center the map on the specified location
    map_center = [latitude, longitude]
    my_map = folium.Map(location=map_center, zoom_start=10)

    # Add the satellite image overlay to the map
    map_id_dict = ee.Image(image).getMapId({'min': 0, 'max': 3000, 'bands': ['B4', 'B3', 'B2']})
    folium.TileLayer(
        tiles=map_id_dict['tile_fetcher'].url_format,
        attr='Google Earth Engine',
        overlay=True,
        name='Satellite Image'
    ).add_to(my_map)

    # Add layer control to toggle layers
    folium.LayerControl().add_to(my_map)
    
    return my_map

# --- Begin Script Execution ---

# Replace 'YOUR_API_KEY' with your actual API key here
api_key = 'geeKey'

# Step 1: Initialize Earth Engine
authenticate_and_initialize(api_key)

# List of available imagery collections for user selection
IMAGERY_OPTIONS = {
    "1": ("Sentinel-2 (COPERNICUS/S2)", "True color, high resolution (10m), updated every 5 days"),
    "2": ("Landsat 8 (LANDSAT/LC08/C01/T1_SR)", "Medium resolution (30m), visible and infrared, since 2013"),
    "3": ("MODIS Terra (MODIS/006/MOD09GA)", "Daily imagery, medium resolution (500m), since 2000"),
    "4": ("MODIS Aqua (MODIS/006/MYD09GA)", "Daily imagery, medium resolution (500m), since 2002"),
    "5": ("Sentinel-1 SAR (COPERNICUS/S1_GRD)", "Synthetic-aperture radar, all-weather, medium resolution (10m)"),
    "6": ("Landsat 7 (LANDSAT/LE07/C01/T1_SR)", "Medium resolution (30m), visible and infrared, since 1999"),
    "7": ("Global Land Surface Temperature (MODIS/006/MOD11A1)", "Daily temperature, medium resolution (1km)"),
    "8": ("GOES-16 (NOAA/GOES/16/MCMIPF)", "Geostationary satellite, near real-time imagery for the Americas"),
    "9": ("ASTER (NASA/ASTER/GDEM)", "High-resolution DEM, used for elevation data"),
    "10": ("Global Human Settlement Layer (JRC/GHSL)", "Global human footprint, useful for urban analysis"),
    "11": ("Landsat 5 (LANDSAT/LT05/C01/T1_SR)", "Historical imagery, medium resolution (30m), 1984-2012"),
    "12": ("TerraClimate (IDAHO_EPSCOR/TERRACLIMATE)", "Monthly climate data, 1970-present, useful for environmental analysis"),
}

# Step 3: Collect user input
selected_option = "1"  # Replace with dynamic user input if needed
latitude = 45.6026  # Replace with user input for latitude
longitude = -73.5167  # Replace with user input for longitude
days_back = 30  # Replace with user input for days back

# Step 4: Calculate date range based on user input
end_date = datetime.now().strftime('%Y-%m-%d')
start_date = (datetime.now() - timedelta(days=days_back)).strftime('%Y-%m-%d')

# Step 5: Retrieve and filter the image collection based on user input
collection_id = IMAGERY_OPTIONS.get(selected_option, "COPERNICUS/S2")
collection = get_image_collection(collection_id, start_date, end_date, latitude, longitude)

# Step 6: Check if collection is accessible and contains images
if collection is None:
    print("Failed to load the selected image collection.")
else:
    # Select the most recent image in the collection
    image = collection.sort('system:time_start', False).first()
    
    # Step 7: Create and save the map with folium
    my_map = create_map(latitude, longitude, image)
    my_map.save("satellite_image_map.html")
    print("Map has been generated and saved as 'satellite_image_map.html'. Open it in a browser to view.")

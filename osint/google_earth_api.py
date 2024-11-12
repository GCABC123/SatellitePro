import ee
import folium
import os
import requests
from datetime import datetime, timedelta
from io import StringIO


# Retrieve the gee_key environment variable
gee_key = os.environ.get("gee_key")

# Verify if the key is available
if not gee_key:
    print("Error: Google Earth Engine API key not found.")
    exit(1)

def authenticate_and_initialize(api_key):
    """Initialize Google Earth Engine with an API key."""
    try:
        credentials = ee.ServiceAccountCredentials('', api_key)
        ee.Initialize(credentials)
        print("Google Earth Engine initialized successfully.")
    except ee.EEException as e:
        print(f"Error initializing Google Earth Engine: {e}")
        exit(1)

# Step 1: Get user input for IP address
ip_address = input("Enter the IP address (IPv4 or IPv6): ").strip()

# Step 2: Send API request to check IP info
ip_api_url = f"http://ip-api.com/json/{ip_address}?fields=16986111"
response = requests.get(ip_api_url).json()

# Step 3: Check response for mobile, proxy, or hosting flags
if response.get("status") != "success":
    print("Error: Could not retrieve data for the IP address.")
    exit(1)

# Validate IP type: exit if it's mobile, proxy, or hosting
if response.get("mobile") or response.get("proxy") or response.get("hosting"):
    print("The IP address is identified as a mobile, proxy, or hosting address. Exiting.")
    exit(1)

# Retrieve latitude and longitude from the IP API response
latitude = response.get("lat")
longitude = response.get("lon")
print(f"Location for IP {ip_address}: Latitude {latitude}, Longitude {longitude}")

# Updated list of available imagery collections with new options
IMAGERY_OPTIONS = {
    "1": ("COPERNICUS/S2", "Sentinel-2: True color, high resolution (10m), updated every 5 days"),
    "2": ("LANDSAT/LC08/C01/T1_SR", "Landsat 8: Medium resolution (30m), visible and infrared, since 2013"),
    "3": ("MODIS/006/MOD09GA", "MODIS Terra: Daily imagery, medium resolution (500m), since 2000"),
    "4": ("MODIS/006/MYD09GA", "MODIS Aqua: Daily imagery, medium resolution (500m), since 2002"),
    "5": ("COPERNICUS/S1_GRD", "Sentinel-1 SAR: Synthetic-aperture radar, all-weather, medium resolution (10m)"),
    "6": ("NASA/GPM_L3/IMERG_V06", "Global Precipitation Measurement: Rainfall estimation, updated every 30 minutes"),
    "7": ("NOAA/VIIRS/DNB/MONTHLY_V1/VCMCFG", "Nighttime Lights: Monthly nighttime illumination data"),
    "8": ("MODIS/006/MOD13A1", "Vegetation Health: NDVI and EVI, updated every 16 days"),
    "9": ("NASA/ASTER/GDEM", "ASTER: Elevation data for terrain height and topography"),
    "10": ("CIESIN/GPWv411/GPW_Population_Density", "Population Density: Human density per sq km"),
    "11": ("LANDSAT/LT05/C01/T1_SR", "Landsat 5: Historical imagery, medium resolution (30m), 1984-2012"),
    "12": ("NOAA/VIIRS/001/VNP09GA", "Daytime View: VIIRS True color, updated daily"),
}

# Display options and prompt user for selection
print("Available Imagery Options:")
for key, (collection_id, description) in IMAGERY_OPTIONS.items():
    print(f"{key}: {description}")

selected_option = input("Select imagery option (1-12): ").strip()
collection_id, _ = IMAGERY_OPTIONS.get(selected_option, ("COPERNICUS/S2", ""))

# Prompt for date range in days
try:
    days_back = int(input("Enter the number of days back for imagery data: ").strip())
except ValueError:
    print("Invalid input. Defaulting to 30 days back.")
    days_back = 30

# Calculate date range based on user input
end_date = datetime.now().strftime('%Y-%m-%d')
start_date = (datetime.now() - timedelta(days=days_back)).strftime('%Y-%m-%d')

# Initialize Earth Engine
authenticate_and_initialize(gee_key)

# Step 4: Retrieve and filter the image collection
def get_image_collection(collection_id, start_date, end_date, latitude, longitude):
    """Retrieve the specified image collection and filter by date and location."""
    try:
        collection = ee.ImageCollection(collection_id).filterDate(start_date, end_date).filterBounds(
            ee.Geometry.Point(longitude, latitude))
        return collection
    except ee.EEException as e:
        print(f"Error accessing image collection {collection_id}: {e}")
        return None

collection = get_image_collection(collection_id, start_date, end_date, latitude, longitude)

# Check if collection contains images
if collection is None:
    print("Failed to load the selected image collection.")
else:
    # Select the most recent image in the collection
    image = collection.sort('system:time_start', False).first()
    
    # Step 5: Create and save the map with folium
    def create_map(latitude, longitude, image):
        """Create a folium map with the specified image overlay."""
        map_center = [latitude, longitude]
        my_map = folium.Map(location=map_center, zoom_start=10)
        map_id_dict = ee.Image(image).getMapId({'min': 0, 'max': 3000, 'bands': ['B4', 'B3', 'B2']})
        folium.TileLayer(
            tiles=map_id_dict['tile_fetcher'].url_format,
            attr='Google Earth Engine',
            overlay=True,
            name='Satellite Image'
        ).add_to(my_map)
        folium.LayerControl().add_to(my_map)
        return my_map

    my_map = create_map(latitude, longitude, image)
    my_map.save("satellite_image_map.html")
    print("Map has been generated and saved as 'satellite_image_map.html'. Open it in a browser to view.")

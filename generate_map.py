# generate_map.py
import folium
import webbrowser

# Coordinates to be displayed on the map (example coordinates for customization)
latitude = 37.7749  # Example: San Francisco
longitude = -122.4194

# Create a map centered on the specified coordinates
satellite_map = folium.Map(location=[latitude, longitude], zoom_start=5)

# Add a marker at the coordinates
folium.Marker([latitude, longitude], tooltip="Satellite/IP Location").add_to(satellite_map)

# Save the map as an HTML file and open it
map_filename = 'satellite_map.html'
satellite_map.save(map_filename)
print(f"Map saved as {map_filename}. Opening in default browser...")

# Open the map in the default web browser
webbrowser.open(map_filename)

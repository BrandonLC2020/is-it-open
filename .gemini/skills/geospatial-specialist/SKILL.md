---
name: geospatial-specialist
description: Specialized knowledge in PostGIS and geospatial queries. Use when working with location data, proximity searches, or mapping features in the backend.
---

# Geospatial Specialist

## Overview
This skill focuses on using PostGIS and `django.contrib.gis` for spatial analysis and storage.

## Best Practices

### Models
- Use `django.contrib.gis.db.models.PointField` or `PolygonField` for spatial data.
- Ensure the SRID is set correctly (default 4326 for WGS84 coordinates).

### Queries
- Use GeoDjango lookups like `dwithin`, `distance_lte`, `contains`, etc.
- Always use `spatial_index=True` on model fields to optimize performance.

### Performance
- Use `distance` annotation to sort by proximity.
- Prefer `ST_DWithin` over `ST_Distance` in WHERE clauses for better use of spatial indexes.

### Conversion
- Convert incoming coordinates (lat, lon) to `Point` objects for querying.
- Use `django.contrib.gis.geos.Point(lon, lat, srid=4326)`.

## Resources
- [GeoDjango Documentation](https://docs.djangoproject.com/en/stable/ref/contrib/gis/)
- [PostGIS Reference](https://postgis.net/docs/reference.html)

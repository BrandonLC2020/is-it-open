from django.db import models

class Place(models.Model):
    tomtom_id = models.CharField(max_length=255, unique=True)
    name = models.CharField(max_length=255)
    address = models.CharField(max_length=512)
    latitude = models.FloatField()
    longitude = models.FloatField()

    def __str__(self):
        return self.name

from django.db import models
from django.conf import settings

class Place(models.Model):
    tomtom_id = models.CharField(max_length=255, unique=True)
    name = models.CharField(max_length=255)
    address = models.CharField(max_length=512)
    latitude = models.FloatField()
    longitude = models.FloatField()

    def __str__(self):
        return self.name

class SavedPlace(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='saved_places')
    place = models.ForeignKey(Place, on_delete=models.CASCADE, related_name='saved_by')
    custom_name = models.CharField(max_length=255, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'place')

    def __str__(self):
        return f"{self.user} - {self.custom_name or self.place.name}"

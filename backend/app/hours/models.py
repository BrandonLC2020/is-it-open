from django.db import models
from app.places.models import Place

class BusinessHours(models.Model):
    place = models.ForeignKey(Place, on_delete=models.CASCADE, related_name='hours')
    day_of_week = models.IntegerField(
        choices=[
            (0, 'Monday'),
            (1, 'Tuesday'),
            (2, 'Wednesday'),
            (3, 'Thursday'),
            (4, 'Friday'),
            (5, 'Saturday'),
            (6, 'Sunday'),
        ]
    )
    open_time = models.TimeField()
    close_time = models.TimeField()

    class Meta:
        ordering = ['day_of_week', 'open_time']

    def __str__(self):
        return f"{self.place.name} - {self.get_day_of_week_display()}"

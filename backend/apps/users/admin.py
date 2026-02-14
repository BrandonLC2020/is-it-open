from django.contrib import admin
from .models import AuthToken, UserProfile

admin.site.register(AuthToken)
admin.site.register(UserProfile)

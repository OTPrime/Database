from django.urls import path
from . import views

urlpatterns = [
    path('', views.home),
    path('learner/view/', views.viewLearner),
    path('learner/register/', views.registerLearner),
    path('learner/', views.learner),
    path('instructor/', views.instructor),
    path('course/', views.course),
]
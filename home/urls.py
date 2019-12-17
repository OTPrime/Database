from django.urls import path
from . import views

urlpatterns = [
    #---------------------------------------HOME---------------------------------------------
    path('', views.home),
    #-------------------------------------LEARNER--------------------------------------------
    path('learner/', views.learner),
    path('learner/view/', views.viewLearner),
    path('learner/register/', views.registerLearner),
    path('learner/remove/', views.removeLearner),
    #------------------------------------INSTRUCTOR------------------------------------------
    path('instructor/', views.instructor),
    path('instructor/view/', views.viewInstructor),
    path('instructor/register/', views.registerInstructor),
    path('instructor/remove/', views.removeInstructor),
    #--------------------------------------COURSE--------------------------------------------
    path('course/', views.course),
    path('course/view/', views.viewCourse),
]
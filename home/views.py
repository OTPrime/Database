from django.shortcuts import render
from .forms import RegistrationForm, GetInforLearner
from django.http import HttpResponseRedirect
# Create your views here.
def home(request):
    return render(request, 'pages/home.html')

def registerLearner(request):
    form = RegistrationForm(request.POST or None)
    if request.method =='POST' and form.is_valid():
        form.save()
        return HttpResponseRedirect('/learner/view/')
    return render(request, 'pages/learner/register.html', {'form': form})

from django.db import connection
# ---------------------------------GET DATA IN DATABASE WITH DICTIONARY DATATYPE-----------------------
def learner(request):
    return render(request, 'pages/learner.html')


def dictfetchall(cursor): 
    "Returns all rows from a cursor as a dict" 
    desc = cursor.description 
    return [
            dict(zip([col[0] for col in desc], row)) 
            for row in cursor.fetchall() 
    ]

def viewLearner(request):
    form = GetInforLearner(request.POST or None)
    if request.method == 'POST' and form.is_valid():
        ID = form.cleaned_data['learner_ID']
        cursor = connection.cursor()
        if ID == '-1':
            cursor.execute("SELECT Learner_ID, Username, Name, Sex, Birth_day FROM learner")
        else:
            cursor.execute("SELECT Learner_ID, Username, Name, Sex, Birth_day FROM learner WHERE learner_ID = {}".format(ID))
        infors = dictfetchall(cursor)
        data = {}
        data['form'] = form
        data['infors'] = infors
        return render(request, 'pages/learner/view.html', data)
    return render(request, 'pages/learner/view.html', {'form': form})


def instructor(request):
    return render(request, 'pages/instructor.html')

def course(request):
    return render(request, 'pages/course.html')
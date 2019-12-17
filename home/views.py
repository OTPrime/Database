from django.shortcuts import render
from .forms import RegistrationForm, GetInforLearner, RemoveLearner, GetInforInstructor, RegistrationFormIns, RemoveInstructor, GetInforCourse
from django.http import HttpResponseRedirect
from django.db import connection
# Create your views here.
# ----------------------------------------------------DICTFETCHALL------------------------------------------

def dictfetchall(cursor): 
    "Returns all rows from a cursor as a dict" 
    desc = cursor.description 
    return [
            dict(zip([col[0] for col in desc], row)) 
            for row in cursor.fetchall() 
    ]
# ----------------------------------------------------HOME-----------------------------------------------------

def home(request):
    return render(request, 'pages/home.html')
# ----------------------------------------------------LEARNER---------------------------------------------------

def learner(request):
    return render(request, 'pages/learner.html')

def viewLearner(request):
    form = GetInforLearner(request.POST or None)
    if request.method == 'POST' and form.is_valid():
        ID = form.cleaned_data['name']
        cursor = connection.cursor()
        if ID == '-1':
            cursor.execute("SELECT Learner_ID, Username, Name, Sex, Birth_day FROM learner")
        else:
            cursor.execute("SELECT Learner_ID, Username, Name, Sex, Birth_day FROM learner WHERE Name LIKE N'%{}%'".format(ID))
        infors = dictfetchall(cursor)
        data = {}
        data['form'] = form
        data['infors'] = infors
        return render(request, 'pages/learner/view.html', data)
    return render(request, 'pages/learner/view.html', {'form': form})

def registerLearner(request):
    form = RegistrationForm(request.POST or None)
    if request.method =='POST' and form.is_valid():
        form.save()
        return HttpResponseRedirect('/learner/view/')
    return render(request, 'pages/learner/register.html', {'form': form})

def removeLearner(request):
    form = RemoveLearner(request.POST or None)
    if request.method =='POST' and form.is_valid():
        form.remove()
        return HttpResponseRedirect('/learner/view/')
    return render(request, 'pages/learner/remove.html', {'form': form})

# ---------------------------------------------------INSTRUCTOR---------------------------------------------
def instructor(request):
    return render(request, 'pages/instructor.html')

def viewInstructor(request):
    form = GetInforInstructor(request.POST or None)
    if request.method == 'POST' and form.is_valid():
        name = form.cleaned_data['name']
        cursor = connection.cursor()
        if name == '-1':
            cursor.execute("SELECT Instructor_ID, Username, Name, Sex, Birth_day, Bio, Field, Email FROM Instructor")
        else:
            cursor.execute("SELECT  Instructor_ID, Username, Name, Sex, Birth_day, Bio, Field, Email FROM Instructor WHERE Name = '{}'".format(name))
        infors = dictfetchall(cursor)
        data = {}
        data['form'] = form
        data['infors'] = infors
        return render(request, 'pages/instructor/view.html', data)
    return render(request, 'pages/instructor/view.html', {'form': form})

def registerInstructor(request):
    form = RegistrationFormIns(request.POST or None)
    if request.method =='POST' and form.is_valid():
        form.save()
        return HttpResponseRedirect('/instructor/view/')
    return render(request, 'pages/instructor/register.html', {'form': form})

def removeInstructor(request):
    form = RemoveInstructor(request.POST or None)
    if request.method =='POST' and form.is_valid():
        form.remove()
        return HttpResponseRedirect('/instructor/view/')
    return render(request, 'pages/instructor/remove.html', {'form': form})

# -------------------------------------------------------COURSE---------------------------------------------
def course(request):
    return render(request, 'pages/course.html')

def viewCourse(request):
    form = GetInforCourse(request.POST or None)
    if request.method == 'POST' and form.is_valid():
        title = form.cleaned_data['title']
        cursor = connection.cursor()
        if title == '-1':
            cursor.execute("SELECT Course_ID, Title, Description, Time_to_finish, Cost FROM Course")
        else:
            cursor.execute("SELECT Course_ID, Title, Description, Time_to_finish, Cost FROM Course WHERE Title = '{}'".format(title))
        infors = dictfetchall(cursor)
        data = {}
        data['form'] = form
        data['infors'] = infors
        return render(request, 'pages/course/view.html', data)
    return render(request, 'pages/course/view.html', {'form': form})
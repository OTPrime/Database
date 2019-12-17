from django import forms
import re
from django.db import connection

# ---------------------------------------------------LEARNER ------------------------------------------------
class GetInforLearner(forms.Form):
    name = forms.CharField(label='Your name', max_length=30)

class RegistrationForm(forms.Form):
    SEX_CHOICE = [
        ('male', 'Male'),
        ('female', 'Female'),
        ('other', 'Other'),
    ]
    username = forms.CharField(label='Username', max_length=30, min_length=6)
    name = forms.CharField(label='Full name', max_length=50)
    birth_day = forms.DateField(label='Birth day(yyyy-mm-dd)')
    password1 = forms.CharField(label='Password', widget=forms.PasswordInput(), min_length=8)
    password2 = forms.CharField(label='Confirm password', widget=forms.PasswordInput(), min_length=8)
    email = forms.EmailField(label='Email')
    sex = forms.CharField(label='Sex', widget=forms.RadioSelect(choices=SEX_CHOICE))
    
    def clean_password2(self):
        if 'password1' in self.cleaned_data:
            password1 = self.cleaned_data['password1']
            password2 = self.cleaned_data['password2']
            if password1 == password2 and password1:
                return password2
            raise forms.ValidationError('Password is not valid!')
        
    def clean_username(self):
        username = self.cleaned_data['username']
        cursor = connection.cursor()
        cursor.execute("SELECT Username FROM Learner WHERE Username = '{}'".format(username))
        if not username:
            raise forms.ValidationError('Username is not valid!')
        elif cursor.fetchone() is not None:
            raise forms.ValidationError('Username already exist!')
        return username

    def save(self):
        cursor = connection.cursor()
        cursor.execute("SELECT MAX(Learner_ID) FROM Learner")
        learner_ID = int(cursor.fetchone()[0]) + 1
        cursor.execute("EXECUTE PR_InsertLearner '{}', '{}', '{}', N'{}',  '{}', '{}', '{}'".format(learner_ID, self.cleaned_data['username'], self.cleaned_data['password1'], self.cleaned_data['name'], self.cleaned_data['sex'], self.cleaned_data['birth_day'], self.cleaned_data['email']))
        print(cursor)
        
class RemoveLearner(forms.Form):
    username = forms.CharField(label='Username', max_length=30, min_length=6)
    password1 = forms.CharField(label='Password', widget=forms.PasswordInput(), min_length=8)
    password2 = forms.CharField(label='Confirm password', widget=forms.PasswordInput(), min_length=8)
    
    def clean_password2(self):
        if 'password1' in self.cleaned_data:
            password1 = self.cleaned_data['password1']
            password2 = self.cleaned_data['password2']
            if password1 == password2 and password1:
                return password2
            raise forms.ValidationError('Password is not valid!')
    
    def clean_username(self):
        username = self.cleaned_data['username']
        cursor = connection.cursor()
        cursor.execute("SELECT Username FROM Learner WHERE Username = '{}'".format(username))
        if not username:
            raise forms.ValidationError('Username is not valid!')
        elif cursor.fetchone() is None:
            raise forms.ValidationError('Username does not exist!')
        return username
    
    def clean_account(self):
        username = self.cleaned_data['username']
        password1 = self.cleaned_data['password1']
        cursor = connection.cursor()
        cursor.execute("SELECT Username FROM Learner WHERE Username = '{}' AND Password = '{}'".format(username, password1))
        if cursor.fetchone() is None:
            raise forms.ValidationError('password incorrect!')
        return username
    
    def remove(self):
        cursor = connection.cursor()
        cursor.execute("DELETE FROM Learner WHERE Username = '{}' AND Password = '{}'".format(self.cleaned_data['username'], self.cleaned_data['password1']))

# ------------------------------------------------------------------INSTRUCTOR---------------------------------------------------
class GetInforInstructor(forms.Form):
    name = forms.CharField(label='Your name', max_length=30)

class RegistrationFormIns(forms.Form):
    SEX_CHOICE = [
        ('male', 'Male'),
        ('female', 'Female'),
        ('other', 'Other'),
    ]
    username = forms.CharField(label='Username', max_length=30, min_length=6)
    name = forms.CharField(label='Full name', max_length=50)
    birth_day = forms.DateField(label='Birth day(yyyy-mm-dd)')
    password1 = forms.CharField(label='Password', widget=forms.PasswordInput(), min_length=8)
    password2 = forms.CharField(label='Confirm password', widget=forms.PasswordInput(), min_length=8)
    email = forms.EmailField(label='Email')
    field = forms.CharField(label='Field', max_length=50)
    sex = forms.CharField(label='Sex', widget=forms.RadioSelect(choices=SEX_CHOICE))
    bio = forms.CharField(widget=forms.Textarea)
    
    def clean_password2(self):
        if 'password1' in self.cleaned_data:
            password1 = self.cleaned_data['password1']
            password2 = self.cleaned_data['password2']
            if password1 == password2 and password1:
                return password2
            raise forms.ValidationError('Password is not valid!')
        
    def clean_username(self):
        username = self.cleaned_data['username']
        cursor = connection.cursor()
        cursor.execute("SELECT Username FROM Instructor WHERE Username = '{}'".format(username))
        if not username:
            raise forms.ValidationError('Username is not valid!')
        elif cursor.fetchone() is not None:
            raise forms.ValidationError('Username already exist!')
        return username

    def save(self):
        cursor = connection.cursor()
        cursor.execute("SELECT MAX(Instructor_ID) FROM Instructor")
        Instructor_ID = int(cursor.fetchone()[0]) + 1
        cursor.execute("""  INSERT INTO Instructor(Instructor_ID, Username, Password, Name, Sex, Birth_day, Bio, Field, Email)
                            VALUES ('{}', '{}', '{}', N'{}',  '{}', '{}', '{}', '{}', '{}')""".format(Instructor_ID, self.cleaned_data['username'], self.cleaned_data['password1'], self.cleaned_data['name'], self.cleaned_data['sex'], self.cleaned_data['birth_day'], self.cleaned_data['bio'], self.cleaned_data['field'], self.cleaned_data['email']))
        print(cursor)

class RemoveInstructor(forms.Form):
    username = forms.CharField(label='Username', max_length=30, min_length=6)
    password1 = forms.CharField(label='Password', widget=forms.PasswordInput(), min_length=8)
    password2 = forms.CharField(label='Confirm password', widget=forms.PasswordInput(), min_length=8)
    
    def clean_password2(self):
        if 'password1' in self.cleaned_data:
            password1 = self.cleaned_data['password1']
            password2 = self.cleaned_data['password2']
            if password1 == password2 and password1:
                return password2
            raise forms.ValidationError('Password is not valid!')
    
    def clean_username(self):
        username = self.cleaned_data['username']
        cursor = connection.cursor()
        cursor.execute("SELECT Username FROM Instructor WHERE Username = '{}'".format(username))
        if not username:
            raise forms.ValidationError('Username is not valid!')
        elif cursor.fetchone() is None:
            raise forms.ValidationError('Username does not exist!')
        return username
    
    def clean_account(self):
        username = self.cleaned_data['username']
        password1 = self.cleaned_data['password1']
        cursor = connection.cursor()
        cursor.execute("SELECT Username FROM Instructor WHERE Username = '{}' AND Password = '{}'".format(username, password1))
        if cursor.fetchone() is None:
            raise forms.ValidationError('Password incorrect!')
        return username
    
    def remove(self):
        cursor = connection.cursor()
        cursor.execute("DELETE FROM Instructor WHERE Username = '{}' AND Password = '{}'".format(self.cleaned_data['username'], self.cleaned_data['password1']))

# --------------------------------------------------------------COURSE--------------------------------------------------------------
class GetInforCourse(forms.Form):
    title = forms.CharField(label='Course', max_length=100)
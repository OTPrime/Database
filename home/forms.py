from django import forms
import re
from django.db import connection

class RegistrationForm(forms.Form):
    username = forms.CharField(label='Username', max_length=30)
    name = forms.CharField(label='Full name', max_length=50)
    sex = forms.CharField(label='Sex(male or femal)', max_length=6)
    birth_day = forms.DateField(label='Birth day')
    password1 = forms.CharField(label='Password', widget=forms.PasswordInput())
    password2 = forms.CharField(label='Confirm password', widget=forms.PasswordInput())
    
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
        cursor.execute("EXECUTE InsertLearner '{}', '{}', '{}', N'{}',  '{}', '{}'".format(learner_ID, self.cleaned_data['username'], self.cleaned_data['password1'], self.cleaned_data['name'], self.cleaned_data['sex'], self.cleaned_data['birth_day']))
        print(cursor)
        
class GetInforLearner(forms.Form):
    learner_ID = forms.CharField(label='Your ID', max_length=30)
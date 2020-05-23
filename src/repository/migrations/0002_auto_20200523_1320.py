# -*- coding: utf-8 -*-
# Generated by Django 1.11.28 on 2020-05-23 12:20
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('repository', '0001_initial'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='repository',
            options={'verbose_name_plural': 'repositories'},
        ),
        migrations.AddField(
            model_name='repository',
            name='object_name',
            field=models.CharField(default='article', help_text='eg. preprint or article', max_length=255),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='repository',
            name='object_name_plural',
            field=models.CharField(default='articles', help_text='eg. preprints or articles', max_length=255),
            preserve_default=False,
        ),
    ]

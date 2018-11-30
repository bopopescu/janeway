"""
Utilities for designing and working with models
"""
__copyright__ = "Copyright 2018 Birkbeck, University of London"
__author__ = "Birkbeck Centre for Technology and Publishing"
__license__ = "AGPL v3"
__maintainer__ = "Birkbeck Centre for Technology and Publishing"

from django.db import models
from django.http.request import split_domain_port


class AbstractSiteModel(models.Model):
    """Adds site-like functionality"""
    DOMAIN_CACHE = {}

    domain = models.CharField(
            max_length=255, default="www.example.com", unique=True)

    class Meta:
        abstract = True

    @classmethod
    def get_by_request(cls, request):
        domain = request.get_host()
        obj = cls.DOMAIN_CACHE.get(domain)
        if obj is None:
            #Lookup by domain with/without port
            try:
                obj = cls.objects.get(domain=domain)
            except cls.DoesNotExist:
                #Lookup without port
                domain, _port = split_domain_port(domain)
                obj = cls.objects.get(domain=domain)
            cls.DOMAIN_CACHE[domain] = obj
        return obj
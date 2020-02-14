## collect feature film data from the Hungarian Film Archive
# http://mandarchiv.hu/tart/jatekfilm


from bs4 import BeautifulSoup as soup, Tag
from bs4 import BeautifulSoup
import requests
import pandas as pd
import random
import re

import json


# 
USER_AGENTS = [
    # Chrome
    'Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36',
    # Firefox
    'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:25.0) Gecko/20100101 Firefox/25.0',
    # Opera
    'Opera/9.80 (Windows NT 6.0) Presto/2.12.388 Version/12.14',
    # Safari
    'Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25',
    # Internet Explorer
    'Mozilla/5.0 (compatible; MSIE 10.6; Windows NT 6.1; Trident/5.0; InfoPath.2; SLCC1; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 2.0.50727) 3gpp-gba UNTRUSTED/1.0',
]


def get_header(agents):
    return {'User-agent': random.choice(agents)}




years = list(range(1912, 1915))

data = {}

for year in list(years):
    url = 'http://mandarchiv.hu/tart/jatekfilm?action=search&title=&stab=&szereplo=&gyarto=&szinesseg=&gyartas_tol=' + str(year) + '&gyartas_ig=' + str(year) + '&tartalom=&dij='
    response = requests.get(url, headers=get_header(USER_AGENTS))
    soup = BeautifulSoup(response.content, "html.parser")
    
    link = []

    input_link = soup.findAll('a', {'class': 'title'})
    for l in input_link:
        l_temp = l.get("href")
        l_temp = l_temp[-9:]
        l_temp = re.sub("[^0-9]", "", l_temp)
        link.append(l_temp)
        


    for film_id in list(link):
        url = 'http://mandarchiv.hu/tart/jatekfilm?name=jatekfilm&action=film&id=' + str(film_id) #target webpage
        response = requests.get(url, headers=get_header(USER_AGENTS))
        soup = BeautifulSoup(response.content, "html.parser")
    
        # necessary lists
        director = []
        cinematographer = []
        writer = []
        editor = []
        producer = []
        
        
        # title
        input_title = soup.find("div", {"class": "w_480"}).findNext('h2')
        for T in input_title:
            title = input_title.text

        # year
        input_year = soup.find('p', {'class': 'date'})
        for Y in input_year:
            Y_temp = input_year.text
            year = Y_temp[-5:]
            
        # director
        for d in soup.findAll(text='rendező / director:'):
            for item in d.parent.next_siblings:
                if isinstance(item, Tag):
                    if 'class' in item.attrs and 'name' in item.attrs['class']:
                        break
                    d_body = item.text
                    director.append(d_body)

        # writer
        for w in soup.findAll(text='forgatókönyvíró / writer (screenplay):'):
            for item in w.parent.next_siblings:
                if isinstance(item, Tag):
                    if 'class' in item.attrs and 'name' in item.attrs['class']:
                        break
                    w_body = item.text
                    writer.append(w_body)

        # cinematographer
        for c in soup.findAll(text='operatőr / cinematographer:'):
            for item in c.parent.next_siblings:
                if isinstance(item, Tag):
                    if 'class' in item.attrs and 'name' in item.attrs['class']:
                        break
                    c_body = item.text
                    cinematographer.append(c_body)

        # editor
        for e in soup.findAll(text='vágó / editor:'):
            for item in e.parent.next_siblings:
                if isinstance(item, Tag):
                    if 'class' in item.attrs and 'name' in item.attrs['class']:
                        break
                    e_body = item.text
                    editor.append(e_body)

        # producer
        for t in soup.findAll(text='producer / producer:'):
            for item in t.parent.next_siblings:
                if isinstance(item, Tag):
                    if 'class' in item.attrs and 'name' in item.attrs['class']:
                        break
                    p_body = item.text
                    producer.append(p_body)
    
        data[film_id] = {
                'title' : title,
                'year' : year,
                'director' : director,
                'writer' : writer,
                'cinematographer' : cinematographer,
                'editor' : editor,
                'producer' : producer}




with open('data/all-movies.txt', 'w') as outfile:
    json.dump(data, outfile)


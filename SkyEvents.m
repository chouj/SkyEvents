%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Auto post sky event by crawling SkyEvents' static webpage

% Note: Noncommercial use only.
%       ThingSpeak friendly.

% Thanks to http://www.seasky.org/

% demo: https://t.me/SkyEvents

% Author: github.com/chouj
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Y=num2str(year(datetime('now'))); % present year

% Target statisc webpage
url=['http://www.seasky.org/astronomy/astronomy-calendar-',Y,'.html'];

% crawling
skyurl=urlread(url); 
liclass=regexp(skyurl,'<li class="b(\d*)">','tokens');
datetext=regexp(skyurl,'<span class="date-text">(\w*\s\d*).*?</span>','tokens');
titletext=regexp(skyurl,'<span class="title-text">(.*?).</span>','tokens');
content=regexp(skyurl,'<span class="title-text">.*?</span>(.*?)</p>\S*\s+</li>','tokens');

% get item of sky event
for i=1:length(datetext)
    clear string
    string=datetext{i};
    string=string{1};
    if strcmp(string(end-1),' ')==1
        newdate{i}=[string(1:end-1),'0',string(end)];
    else
        newdate{i}=string;
    end
end

n=find(strcmp(datestr(now-8/24+1,'mmmm dd'),newdate)==1);

% generate text for posting and utilize webhook at IFTTT
options = weboptions('RequestMethod','post');

if length(n)>0

    for i=1:length(n)
        clear string1 string2 string3
        if length(liclass{n(i)})>1
            string1=['http://www.seasky.org/astronomy/assets/images/astrocal',cell2mat(liclass{n(i)}),'.jpg'];
        else
            string1=['http://www.seasky.org/astronomy/assets/images/astrocal0',cell2mat(liclass{n(i)}),'.jpg'];
        end
        
        string2=[cell2mat(datetext{n(i)}),' - ',cell2mat(titletext{n(i)})];
        string3=content{n(i)};
    
        response = webwrite('https://maker.ifttt.com/trigger/{EventName}/with/key/{YourKEY}', 'value1',string1,'value2',string2,'value3',string3, options);
    end
end

root(1).  

feature(1, 'Movement Control System',[]).  

feature(2, 'Sensor', []).  

feature(3, 'Speed Sensor', []).  

feature(4, 'Position Sensor', []).  

feature(5, 'Feedback', []).  

feature(6, 'Audio', [att1, att2]).  

feature(7, 'Vibration', [att3, att4]).  

attribute(att1, 'Volume', [integer]).  

attribute(att2, 'Volume', [0, 1, 2, 3, 4, 5]). 

attribute(att3, 'Type', [string]). 

attribute(att4, 'Intensity', [integer]).  

dependency(1, 1, 2, 'mandatory').  

dependency(2, 1, 5, 'mandatory'). 

dependency(3, 2, 3, 'optional'). 

dependency(4, 2, 4, 'optional').  

dependency(5, 5, 6, 'mandatory').  

dependency(6, 5, 7, 'optional').  

dependency(7, 7, 5, 'requires').  

dependency(8, 3, 7, 'excludes'). 

groupCardinality([3, 4], 1, 3).  

groupCardinality([5, 6], 1, 1). 
head_pred(graspable,1). 

body_pred(shape,2). 

body_pred(weight,2). 

body_pred(cube,1). 

body_pred(sphere,1). 

body_pred(cylinder,1). 

body_pred(irregular,1). 

body_pred(light,1). 

body_pred(heavy,1). 

 

type(graspable,(object,)). 

type(shape,(object,shape_type)). 

type(weight,(object,weight_type)). 

type(cube,(shape_type,)). 

type(sphere,(shape_type,)). 

type(cylinder,(shape_type,)). 

type(irregular,(shape_type,)). 

type(light,(weight_type,)). 

type(heavy,(weight_type,)). 

 

direction(graspable,(in,)). 

direction(shape,(in,out)). 

direction(weight,(in,out)). 

direction(cube,(in,)). 

direction(sphere,(in,)). 

direction(cylinder,(in,)). 

direction(irregular,(in,)). 

direction(light,(in,)). 

direction(heavy,(in,)). 

-- At first, we'll try to keep everything commented, but that will be dropped
-- soon enough, so get used to figuring things out!

-- "local" variables mean that they belong only to this code module. More on
-- that later.

-- Window resolution
local W, H	

-- Maximum number of obejcts
local MAX_OBJECTS

--Speed
local Speed = 250

--Mass
local m = 1

--Radius
local Radius = 16

-- The list of all game objects
local objects

-- Holds the source object containing the "bounce" sound effect
local bounce_sfx --= love.audio.newSource( 'pingpongbat.ogg', 'ogg' )

--[[ Auxiliary functions ]]--

--- Creates a new game object.
--  We start with an empty table, then define the 'x' and 'y' fields as the
--  coordinates of the object, and in the end choose a move direction, in
--  radians, that is converted to a unitary directional vector using a little
--  trigonometry.
--  See https://love2d.org/wiki/love.math.random
local function newObject ()
  local new_object = {}
  	
  new_object.x = Radius + love.math.random()*(W - 2*Radius)
  new_object.y = Radius + love.math.random()*(H - 2*Radius)
  
  local dir = love.math.random()*2*math.pi
  new_object.dir_x = math.cos(dir)
  new_object.dir_y = math.sin(dir)
  new_object.r = math.random()*255
  new_object.g = math.random()*255
  new_object.b = math.random()*255
  new_object.speed_x = Speed
  new_object.speed_y = Speed

  return new_object
end
 
local function collision (object1, object2)
	local dist = math.sqrt((object1.x - object2.x)*(object1.x - object2.x) + (object1.y - object2.y)*(object1.y - object2.y))
	if dist <= 2*Radius then
    object1_aux_x = object1.dir_x
    object1_aux_y = object1.dir_y
    object1.dir_x = object2.dir_x
    object1.dir_y = object2.dir_y
    object2.dir_x = object1_aux_x
    object2.dir_y = object1_aux_y
    
    ang = math.atan2((object2.y - object1.y) , (object2.x - object1.x))
    object1.x = object1.x - ((2*Radius - dist)/2)*math.cos(ang)
		object2.x = object2.x + ((2*Radius - dist)/2)*math.cos(ang)
		object1.y = object1.y - ((2*Radius - dist)/2)*math.sin(ang)
		object2.y = object2.y + ((2*Radius - dist)/2)*math.sin(ang)
	end
    
	
end

local function forcea(object , dt)
	mouse_x , mouse_y = love.mouse.getPosition()
	
	force_dir_x , force_dir_y = (mouse_x - object.x) ,(mouse_y - object.y)
	distance = math.sqrt(force_dir_x^2 + force_dir_y^2)
	force = (1.0 / distance)*70000
	object.speed_x = Speed + force*force_dir_x*dt
	object.speed_y = Speed + force*force_dir_y*dt
end

--- Move the given object as if 'dt' seconds had passed. Basically follow
--  the uniform movement equation: S = S0 + v*dt.
local function moveObject (object, dt)
  object.x = object.x + object.speed_x*object.dir_x*dt
  object.y = object.y + object.speed_y*object.dir_y*dt
  if object.x < Radius or object.x > W - Radius then
  	object.dir_x = -object.dir_x
  	
  	object.x = math.max(Radius, math.min(object.x, W-Radius))
  	
  	love.audio.play( bounce_sfx )
  end
  if object.y < Radius or object.y > H - Radius then
  	object.dir_y = -object.dir_y
  	
  	object.y = math.max(Radius, math.min(object.y, H-Radius))
  	
  	love.audio.play( bounce_sfx )
  end
end

--[[ Main game functions ]]--

--- Here we load up all necessary resources and information needed for the game
--  to run. We start by getting the screen resolution (which will be used for
--  drawing) then define the maximum number of objects. Finally we create a
--  list of game objects to draw and interact. Note that we also use a table
--  for the list, but in a different way than above.
--  See https://love2d.org/wiki/love.graphics.getDimensions
function love.load ()
  W, H = love.graphics.getDimensions()
  MAX_OBJECTS = 25
  objects = {}
  for i=1,MAX_OBJECTS do
    table.insert(objects, newObject())
  end
  bounce_sfx = love.audio.newSource( "pingpongbat.ogg" , "stream")
end

--- Update the game's state, which in this case means properly moving each
--  game object according to its moving direction and current position.
function love.update (dt)
  for i,object1 in ipairs(objects) do
  
  if love.mouse.isDown(1) then  
    	forcea(object1 , dt)
    else 
    end
  
    moveObject(object1, dt)
    for j = i + 1, #objects do
    	collision(object1, objects[j])
    end
    
  end
  
end

--- Detects when the player presses a keyboard button. Closes the game if it
--  was the ESC button.
--  See https://love2d.org/wiki/love.event.push
function love.keypressed (key)
  if key == 'escape' then
    love.event.push 'quit'
  end
end


--- Draw all game objects as simle white circles. We will improve on that.
--  See https://love2d.org/wiki/love.graphics.circle
function love.draw ()
  for i,object in ipairs(objects) do
  	love.graphics.setColor(object.r, object.b, object.g, 255)
    love.graphics.circle('fill', object.x, object.y, Radius, 16)
  end
end


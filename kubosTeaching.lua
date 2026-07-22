--// A, looks at B //--
local A = workspace.A
local B = workspace.B
local dir = B.Position - A.Position

--//Welcome everyone to CFrame introduction since why not where i help you out on CFrames//--

--[[
What are CFrames or Coordinate Frames

these are basically in math what we call matrices or matrix
they look like weird tables in a way

[1 0 0 0]  here's a four time four matrix and basically these are what CFrames are
[0 1 0 0]  now u may wonder why 4x4 well im not gonna go too deep into what they are since these are pretty complicated stuff ngl
[0 0 1 0]  but we actually 4D to render stuff in game engines. or in another a fake row
[0 0 0 1]  anyways how these works?


so a matrix is just  
row x,n
collum y, n 


n is the amount of collum there is in a matrix

x:3, y:2

[1, 3, 4]  
[0, 0, 2]

we can multiply them but like i said CFrames are Matrix's so they multiply weirdly
since i dint want to complicate thing ill show u how we can transform a CFrame with a Vector

so when we actually use CFrame or Vectors they are all matrix's

CFrame:	            Vector:
[1 0 0 tx]	         	[x]
[0 1 0 ty]	         	[y]
[0 0 1 tz]	         	[z]
[0 0 0 1]	         	[1] it always 1

so the issue is the first 3x3 row, we can only rotate something with them since rotation doesnt make it move away from the origine, same for scaling
but moving a part around is a different story. the first 3x3 matrix u see in roblox CFrames represent they rotation of a part, meaning were missing an extra collum
that less us move around are part by adding values do x, y, z as the position. meaning we need an extra collum so 4 x 3, yes but robloxes uses 4x4 like this:

[1 0 0 tx]	         	[x]
[0 1 0 ty]	         	[y]
[0 0 1 tz]	         	[z]
[0 0 0 1]	         	[1] it always 1
--
[1 0 4 40]	         	[x] -- the tx, y, z area represent the position, but roblox can also use them for scale
[0 4 0 10]	         	[y] -- the 4th dimension is required to be able to add an tx amount to x do move the part
[0 0 3 15]	         	[z]
[0 0 0 1 ]	         	[1] it always 1 -- this is always the same no matter what



-- LET LOOK FURTHER WHY WE USE EXTRA DIMENSION --
because of shearing: shearing is a weird way to stretch a thing almost into a parallelogram and the reason it works is because it stays at the origine and doesnt budge

picture this let say we have a line and want to make it move in 1D

A------------------B

what if i add a dimension and shear it?




	A------------------B
   /                  /
  /                  /
 +------------------+
 
 what if i put it back to normal
 
   A------------------B
   
   
end  

see how it did a translation by simply adding a dimension? that why we use 4D to move 3D objects
in game engines. this could show u once again why roblox cframe use a 4x4 matrix since u need one
to make part translate, u need a row that store position, not just rotation



-- Operations --

OK now we got that covered and why we use matrix's how do we multiply them??

well it simple:

let take a 2x2 matrix and a a 1x2 matrix

this is just like CFrame * Vector3 in this case it a Vector2 and 2x2 CFrame

[1 2]  [2]
[0 1]  [1]

[1x2 1x2] = [4]
[2x0 1x1] = [1] -- notice again this is a 1 Dimensional engine example but it always 1, the extra dimension

and that it for normal operation so let say we have cframe 1 * cframe2

cf1 is equal to your average translation cframe so :: cframe.new(0, 5, 20)
cf2 is equal to your rotation cframe so :: cframe.Angle(math.rad(90), 0, 0))

so what u multiply them

finalcf = | 1  0  0  00 |  | 0  0  0 00 |  is going be equal to = | 1  0  0  00 | 
		  | 0  0 -1  00 |  | 0  0  0 05 |                         | 0  0 -1  05 | 
		  | 0  1  0  00 |  | 0  0  0 20 |                         | 0  1  0  20 | 
          | 0  0  0  00 |  | 0  0  0 01 |                         | 0  0  0  01 |
end

so this is the end i guess, i know it was mostly matrix, but this is how roblox kind of does uhm or handles the CFrames
mind you matrix's and CFrames are not the same. but they share a lot thing in common, the matrixs are only here to store the values of CFrames such as
Orientation and Position the issue again is that a translation isnt a linear transformation it requires you to move your part somewhere else
this requirement is the actual reason why we use another dimension, the shearing thing, was just another example to prove you we needed an extra Dimension.
]]

--// SCRIPTING //--


----------------
-- Properties -- 

--> A.CFrame.Position -- position aka tx, ty and tz
--> A.CFrame.LookVector -- front of something -- negation is back
--> A.CFrame.RightVector -- right of something -- negation is left
--> A.CFrame.UpVector -- up of something -- negation is down
--> A.CFrame.Rotation -- return tx, ty, tz = 0 but it gives the 3x3 orientation matrix
--> A.CFrame.X -- tx 
--> A.CFrame.Y -- ty
--> A.CFrame.Z -- tz

-- Properties -- 
----------------





-- Constructos // Functions --

-- new()
--> local cf_new = CFrame.new(A.Position, B.Position)
--> A.CFrame = cf_new

-- lookAt()
--> A.CFrame = CFrame.lookAt(A.Position, B.Position)

-- lookAlong()
--> A.CFrame = CFrame.lookAlong(A.Position, dir)

-- Angle()
--> A.CFrame *= CFrame.Angles(math.rad(0), math.rad(-90), math.rad(0))

-- fromOrientation()
--> A.CFrame *= CFrame.fromOrientation(math.rad(0), math.rad(-90), math.rad(0))

-- fromAxisAngle()
--> A.CFrame *= CFrame.fromAxisAngle(Vector3.new(0, 1, 0), math.rad(-90))

-- fromEulerAngles() u can switch the order with {{Enum.RotationOrder.(ur order)}}
--> A.CFrame *= CFrame.fromEulerAngles(math.rad(0), math.rad(-90), math.rad(0))

-- fromEuleurAnglesXYZ() and YXZ
--> A.CFrame *= CFrame.fromEulerAnglesXYZ(math.rad(90), math.rad(-90), math.rad(0))

-- YXS means Y is first and has priority over normal XYZ
--> A.CFrame *= CFrame.new(math.rad(0), math.rad(-90), math.rad(0))

-- fromRotationBetweenVectors() this is my least favorite one
--> A.CFrame *= CFrame.fromRotationBetweenVectors(A.CFrame.LookVector, B.CFrame.RightVector)

-- fromMatrix() arguably the hardest one to understand ngl but yeah
-- requires knowledge around matrices which i did not have and still dont

--> A.CFrame = CFrame.fromMatrix(A.Position, A.CFrame.LookVector, B.CFrame.UpVector) this is pure bullshit


--[[functions with CFrames]]--

-- INVERSE()
-- self explainotary (sorry for the ass spelling just incase)
--> A.CFrame = A.CFrame:Inverse() it reverses rotation if ur part has one for example 0, 0, 0 wont really invert it at all

-- LERP()
-- gives a number in between 2 numbers, let say u have 4 and u want to add 50% of the number between 4 and 8 first find their differences so 8 - 4 = 4 then u do 4 * alpha = 2 if alpha is 0.5 then add 4 + 2 = 6
-- so what is this 6 result so if start from 4 and your goal is 8 and u travel 50% of that track starting from 4 u end up at 6
-- Visualizer
--    4 ------x---------> 8
--            6 right about here from ur goal

--[[task.wait(3)
while true do
	task.wait(1)
	A.CFrame = A.CFrame:Lerp(
		A.CFrame * CFrame.new(Vector3.new(0, 0, 12)),
		0.1 -- were travelling 10% from the difference of the start to the goal
	)
end]]

-- if u go above the goal it fine it like travelling 150% of the distance of difference between the start and the goal, if u go above 5 in this case ur above ur goal which is perfectly fine
-- example 10 start, 15 goal if alpha is equal to 150% or 1.5 then it will go like this 15 - 10 = 5 :: 5 * 1.5 = 7.5 and finally add the start back and u get 17.5


-- ORTHONORMALIZE()
-- whenever a CFrame rotates(transforms) or multiplies with another CFrame the Rotation Axis can change such instead of having 1 a hole number u get 0.9999898 or 1.0000021 which are not perpendicular, orthonormalize fixes this issue by making them perpendicular like 1, 0, 0 or 0, 1, 0
--> print(A.CFrame:Orthonormalize()) --> looks clean and beautiful

-- TOWORLDSPACE() AND TOOBJECTSPACE()
-- world space is basically the origine when u say:
--> local cf1 = cf2, if cf2 is equal to something like 0, 0, 4 then that bad cuz the part is going to change position based on the origine or 0, 0, 0

-- TOOBJECTSPACE() FIXES THE ISSUE by making the object the reference instead of the world (origine)
--> print(A.CFrame:ToObjectSpace(CFrame.new(0, 5, 9)):Orthonormalize()) -- useage to orthonormalize to make sure we get hole numbers
--> A.CFrame = A.CFrame:Inverse():ToObjectSpace(CFrame.new(12, 0, -8)):Orthonormalize() -- for some specific cases this becomes a very usefull method // THIS IS DOESNT GIVE THE SAME RESULT AS A.CFrame *= n :: CFrame // HIGHLY SUGGEST INVERSING THE CFRAME, it easier to read the position u want by doing so

--> TOWORLDOBJECTSPACE() may not seem as good as toobjectspace()
-- it works the same way as toobjectspace() tho the reference is 0, 0, 0
--> local offset = cf2:ToWorldObject(cf1:Inverse())

-- VECTORTOOBJECTSPACE() AND VECTORTOWORLDSPACE()
-- imagine being able to fuze a cframe and a vector and having that result in vector well this is what it exactly does (it only fuze with the rotation part of a CFrame )
--> print(A.CFrame)
--> print(A.CFrame:VectorToObjectSpace(Vector3.new(3, 4, 9))) -- only multiplies with orientation of CFrame
--> print(A.CFrame * Vector3.new(3, 4, 9)) -- this is how you multiply full CFrames with vectors
--> print(A.CFrame:VectorToWorldSpace(Vector3.new(3, 4, 9))) -- no difference


-- POINTTOWORLDSPACE() AND POINTTOOBJECTSPACE()
-- multiplies a cframe with a vector and returns that as a vector, it multiplies with the cframes position matrix
--> print(A.CFrame.Position)
--> print(A.CFrame:PointToWorldSpace(Vector3.new(10, 30, 29)))
--> print(A.CFrame.Position)
--> print(A.CFrame:PointToObjectSpace(Vector3.new(10, 30, 29)))

-- TOEULERANGLE() AND TOEULERANGLEXYS() AND TOEULERANGLEXYS()
--> print(A.CFrame:ToEulerAngles())
--> print(A.CFrame:ToEulerAnglesYXZ())
--> print(A.CFrame:ToEulerAnglesXYZ())

-- TOORIENTATION()
-- does exactly the same thing as TOEULERANGLEXYS()
--> print(A.CFrame:ToOrientation())

-- TOAXISANGLE()
-- if it print something like 1, 0, 0 number, it means that it turning X amount of (number:Radiant) 
--> print(A.CFrame:ToAxisAngle())

-- GETCOMPONENTS()
-- components of cframe; 3x3 Rotation Matrix, and the tX, tY, tZ position
--> print(A.CFrame:GetComponents())

-- components()
-- equivelant of GETCOMPONENTS() // or literally the same
--> print(A.CFrame:components())

-- FUZZYEQ()
-- checks if A.CFrame semi= B.CFrame then returns true else false 
--> print(A.CFrame:FuzzyEq(B.CFrame)) -- false

-- ANGLEBETWEEN()
--> angle = A.CFrame:AngleBetween(B.CFrame)
--> cfturn = CFrame.Angles(0, -angle/2, 0)
--> A.CFrame *= cfturn

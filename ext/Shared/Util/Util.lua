local matrix = require "__shared/Util/matrix"

function MergeTables(p_Old, p_New)
	if(p_New == nil) then
		return p_Old
	end

	if(p_Old == nil) then
		return p_New
	end

	for k,v in pairs(p_New) do
		p_Old[k] = v
	end

	return p_Old
end

function MergeUserdata(p_Old, p_New)
	if(p_Old == nil) then
		return p_New
	end
	if(p_New == nil) then
		return nil
	end
	for k,v in pairs(p_New) do
		p_Old[k] = v
	end
	return p_Old
end

function GetChanges(p_Old, p_New)
	local s_Changes = {}
	for k,v in pairs(p_New) do
		if(tostring(p_Old[k]) ~= tostring(p_New[k])) then
			if type(p_Old[k]) == "table" then
				for k1,v1 in pairs(p_Old[k]) do
					if(p_Old[k][k1] ~= p_New[k][k1]) then
						table.insert(s_Changes, k)
					end
				end
			else
				table.insert(s_Changes, k)
			end
		end
	end
	return s_Changes
end


function DecodeParams(p_Table)
    if(p_Table == nil) then
        print("No table received")
        return false
    end
	for s_Key, s_Value in pairs(p_Table) do
		if s_Key == 'transform' then
			local s_LinearTransform = LinearTransform(
					Vec3(s_Value.left.x, s_Value.left.y, s_Value.left.z),
					Vec3(s_Value.up.x, s_Value.up.y, s_Value.up.z),
					Vec3(s_Value.forward.x, s_Value.forward.y, s_Value.forward.z),
					Vec3(s_Value.trans.x, s_Value.trans.y, s_Value.trans.z))

			p_Table[s_Key] = s_LinearTransform

		elseif type(s_Value) == "table" then
			DecodeParams(s_Value)
		end

	end

	return p_Table
end


function ToWorld(p_Local, p_ParentWorld)
	p_Local = SanitizeLT(p_Local)
	p_ParentWorld = SanitizeLT(p_ParentWorld)

	local s_LinearTransform = LinearTransform()

	local s_MatrixParent = matrix{
		{p_ParentWorld.left.x,p_ParentWorld.left.y,p_ParentWorld.left.z,0},
		{p_ParentWorld.up.x,p_ParentWorld.up.y,p_ParentWorld.up.z,0},
		{p_ParentWorld.forward.x,p_ParentWorld.forward.y,p_ParentWorld.forward.z,0},
		{p_ParentWorld.trans.x,p_ParentWorld.trans.y,p_ParentWorld.trans.z,1}
	}
	
	local s_MatrixLocal = matrix{
		{p_Local.left.x,p_Local.left.y,p_Local.left.z,0},
		{p_Local.up.x,p_Local.up.y,p_Local.up.z,0},
		{p_Local.forward.x,p_Local.forward.y,p_Local.forward.z,0},
		{p_Local.trans.x,p_Local.trans.y,p_Local.trans.z,1}
	}

	local s_MatrixWorld = s_MatrixLocal * s_MatrixParent 

	s_LinearTransform.left = Vec3(s_MatrixWorld[1][1],s_MatrixWorld[1][2],s_MatrixWorld[1][3])
	s_LinearTransform.up = Vec3(s_MatrixWorld[2][1],s_MatrixWorld[2][2],s_MatrixWorld[2][3])
	s_LinearTransform.forward = Vec3(s_MatrixWorld[3][1],s_MatrixWorld[3][2],s_MatrixWorld[3][3])
	s_LinearTransform.trans = Vec3(s_MatrixWorld[4][1],s_MatrixWorld[4][2],s_MatrixWorld[4][3])

	return SanitizeLT(s_LinearTransform)
end


function ToLocal(world, p_ParentWorld)
	world = SanitizeLT(world)
	p_ParentWorld = SanitizeLT(p_ParentWorld)

    local s_LinearTransform = LinearTransform()

		local s_MatrixParent = matrix{
			{p_ParentWorld.left.x,p_ParentWorld.left.y,p_ParentWorld.left.z,0},
			{p_ParentWorld.up.x,p_ParentWorld.up.y,p_ParentWorld.up.z,0},
			{p_ParentWorld.forward.x,p_ParentWorld.forward.y,p_ParentWorld.forward.z,0},
			{p_ParentWorld.trans.x,p_ParentWorld.trans.y,p_ParentWorld.trans.z,1}
		}
		
		local s_MatrixWorld = matrix{
			{world.left.x,world.left.y,world.left.z,0},
			{world.up.x,world.up.y,world.up.z,0},
			{world.forward.x,world.forward.y,world.forward.z,0},
			{world.trans.x,world.trans.y,world.trans.z,1}
		}

		local s_MatrixParent_Inv = matrix.invert(s_MatrixParent) 
		local s_MatrixLocal = s_MatrixWorld * s_MatrixParent_Inv 


		s_LinearTransform.left = Vec3(s_MatrixLocal[1][1],s_MatrixLocal[1][2],s_MatrixLocal[1][3])
		s_LinearTransform.up = Vec3(s_MatrixLocal[2][1],s_MatrixLocal[2][2],s_MatrixLocal[2][3])
		s_LinearTransform.forward = Vec3(s_MatrixLocal[3][1],s_MatrixLocal[3][2],s_MatrixLocal[3][3])
		s_LinearTransform.trans = Vec3(s_MatrixLocal[4][1],s_MatrixLocal[4][2],s_MatrixLocal[4][3])
		-- s_LinearTransform.trans.x = world.left.x * t.x +
		--     	world.left.y * t.x +
		--     	world.left.z * t.x
		-- s_LinearTransform.trans.y = world.up.x * t.y +
		--     	world.up.y * t.y +
		--     	world.up.z * t.y
		-- s_LinearTransform.trans.z = world.forward.x * t.z +
		--     	world.forward.y * t.z +
		--     	world.forward.z * t.z

    -- s_LinearTransform.trans.x = world.trans.x - p_ParentWorld.trans.x
    -- s_LinearTransform.trans.y = world.trans.y - p_ParentWorld.trans.y
    -- s_LinearTransform.trans.z = world.trans.z - p_ParentWorld.trans.z
		-- print(s_LinearTransform.trans) --(15.818466, -0.016708, -24.546097)

    return SanitizeLT(s_LinearTransform)
end

function SanitizeLT (lt) 
	lt.left = SanitizeVec3(lt.left)
	lt.up = SanitizeVec3(lt.up)
	lt.forward = SanitizeVec3(lt.forward)
	lt.trans = SanitizeVec3(lt.trans)
	return lt
end
function SanitizeVec3( vec )
	vec.x = SanitizeFloat(vec.x)
	vec.y = SanitizeFloat(vec.y)
	vec.z = SanitizeFloat(vec.z)
	return vec
end

function SanitizeFloat( f )
	if( f < 0.000000001 and f > -0.000000001 ) then
		return 0
	end
	return f
end


function InverseSafe (f)
    if (f > 0.00000000000001) then
        return 1.0 / f
    else
        return 0.0
    end
end

function InverseVec3 (v)
    return Vec3 (InverseSafe (v.x), InverseSafe (v.y), InverseSafe (v.z));
end

function InverseQuat (v)
    return Quat (InverseSafe (v.x), InverseSafe (v.y), InverseSafe (v.z), InverseSafe (v.w));
end

function dus_MatrixParent(o)
	if(o == nil) then
		print("tried to load jack shit")
	end
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			s = s .. '['..k..'] = ' .. dus_MatrixParent(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end

function IsVanillaGuid(guid)
	if guid == nil then
		return false
	end
	return guid:sub(1, 8):upper() == "ED170120"
end

function Set (list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

function h()
    local vars = {"A","B","C","D","E","F","0","1","2","3","4","5","6","7","8","9"}
    return vars[math.floor(MathUtils:GetRandomInt(1,16))]..vars[math.floor(MathUtils:GetRandomInt(1,16))]
end

function GenerateGuid()
    return Guid(h()..h()..h()..h().."-"..h()..h().."-"..h()..h().."-"..h()..h().."-"..h()..h()..h()..h()..h()..h(), "D")
end

function GenerateStaticGuid(n)
	return Guid("ED170120-0000-0000-0000-"..GetFilledNumberAsString(n, 12), "D")
end

function GetFilledNumberAsString(n, stringLength)
	local n_string = tostring(n)
	local prefix = ""

	if string.len(n_string) < stringLength then
		for i=1,stringLength - string.len(n_string) do
			prefix = prefix .."0"
		end
	end

	return (prefix..n_string)
end
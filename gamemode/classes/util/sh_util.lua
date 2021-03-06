--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
--]]

SF.Util = {}

function SF.Util:SetColorAlpha(col, alpha)
	col.a = alpha
	return col
end

function SF.Util:Cross2D(u, v)
	return u.y * v.x - u.x * v.y
end

function SF.Util:SameSign(x, y)
	return (x >= 0 and y >= 0) or (x < 0 and y < 0)
end

function SF.Util:SimpleTrace(startpos, endpos, mask)
	mask = mask or nil
    local t = util.TraceLine({
    	start = startpos,
    	endpos = endpos,
    	mask = MASK_SOLID_BRUSHONLY
    }) 

    if (t.Hit) then
        return t
    end
    
    return false
end

function SF.Util:TestTriangle(position, v)
	local a = Vector(v[1].x, v[1].y)
	local b = Vector(v[2].x, v[2].y)
	local c = Vector(v[3].x, v[3].y)
	local p = Vector(position.x, position.y)

	local pab = self:Cross2D(p - a, b - a)
	local pbc = self:Cross2D(p - b, c - b)

	if (!self:SameSign(pab, pbc)) then return false end

	local pca = SF.Util:Cross2D(p - c, a - c)

	if (!self:SameSign(pab, pca)) then return false end

	return true
end

-- Some useful mesh/triangle functions

function SF.Util:Vertex(pos, u, v, normal)
	return {pos = pos, u = u, v = v, normal = normal}
end

function SF.Util:Triangle(tbl, p1, p2, p3, normal)
	table.insert(tbl, self:Vertex(p1, 0, 0, normal))
	table.insert(tbl, self:Vertex(p2, 0, 1, normal))
	table.insert(tbl, self:Vertex(p3, 1, 0, normal))
end

function SF.Util:Quad(tbl, p1, p2, p3, p4)

	local normal = Vector(0, 0, 1)
	table.insert(tbl, self:Vertex(p1, 0, 0, normal))
	table.insert(tbl, self:Vertex(p2, 1, 0, normal))
	table.insert(tbl, self:Vertex(p3, 0, 1, normal))

	table.insert(tbl, self:Vertex(p2, 1, 0, normal))
	table.insert(tbl, self:Vertex(p4, 1, 1, normal))
	table.insert(tbl, self:Vertex(p3, 0, 1, normal))
end

function SF.Util:Plane(tbl, p1, p2, normal)

	local tl = Vector(p1.x, p1.y, p1.z)
	local tr = Vector(p2.x, p1.y, p1.z)
	local bl = Vector(p1.x, p2.y, p2.z)
	local br = Vector(p2.x, p2.y, p2.z)

	self:Triangle(tbl, tl, bl, tr, normal)
	self:Triangle(tbl, tr, bl, br, normal)
end

function SF.Util:FovFix(fov, ratio)
	if (SERVER and !ratio) then error("NEEDS RATIO ON SERVERSIDE") end
	local fov = fov or 90
	local ratio = ratio or ScrW()/ScrH()
	return (math.atan(math.tan((fov * math.pi) / 360) * (ratio / (4/3) )) * 360) / math.pi
end

function SF.Util:ScreenToAimVector(x, y, w, h, camAngle, fov)
	local fov = fov or 90
	local hw = w/2
	local hh = h/2
	local d = hw/math.tan(fov/2)
	local forward = camAngle:Forward()
	local right = camAngle:Right()
	local up = camAngle:Up()

	return (forward*d + right*(x-hw) + up*(hh-y)):GetNormal()
end

local RAND_ID = 1
function SF.Util:Random()
	local seed = CurTime()..RAND_ID
	RAND_ID = RAND_ID + 1
	return util.CRC(seed)
end

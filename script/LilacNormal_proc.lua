EFFECT_CHANGE_SUMMON_PROC_TRIBUTE     = EVENT_CUSTOM+300
EFFECT_CHANGE_SUMMON_SET_PROC_TRIBUTE = EVENT_CUSTOM+400

function GetTributeCount(c,tp,ne,min,max,bool)
	local eff=bool and Duel.IsPlayerAffectedByEffect(tp,EFFECT_CHANGE_SUMMON_PROC_TRIBUTE) or Duel.IsPlayerAffectedByEffect(tp,EFFECT_CHANGE_SUMMON_SET_PROC_TRIBUTE)
	if not (eff and eff:CheckCountLimit(tp)) then return min,max end
	local efftarget=eff:GetTarget()
	local value=eff:GetValue()
	local nemin,nemax=ne:GetLabel()
	if efftarget and not efftarget(eff,c,nemin,nemax) then return min,max end
	if type(value)=="function" then
		return value(eff,c,nemin,nemax)
	else
		return value,value
	end
end
--tribute
function Auxiliary.AddNormalSummonProcedure(c,ns,opt,min,max,val,desc,f,sumop)
	val = val or SUMMON_TYPE_TRIBUTE
	local e1=Effect.CreateEffect(c)
	if desc then e1:SetDescription(desc) end
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	if ns and opt then
		e1:SetCode(EFFECT_SUMMON_PROC)
	else
		e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	end
	if ns then
		e1:SetCondition(Auxiliary.NormalSummonCondition1(min,max,f,opt))
		e1:SetTarget(Auxiliary.NormalSummonTarget(min,max,f))
		e1:SetOperation(Auxiliary.NormalSummonOperation(min,max,sumop))
	else
		e1:SetCondition(Auxiliary.NormalSummonCondition2())
	end
	e1:SetValue(val)
	e1:SetLabel(min,max)
	c:RegisterEffect(e1)
	return e1
end
function maplevel(level)
	if level>=5 and level<=6 then
		return 1
	elseif level>=7 then
		return 2
	end
	return 0
end
function Auxiliary.NormalSummonCondition1(min,max,f,opt)
	return function (e,c,minc,zone,relzone,exeff)
		if c==nil then return true end
		local tp=c:GetControler()
		min,max=GetTributeCount(e:GetHandler(),tp,e,min,max,true)
		local mg=Duel.GetTributeGroup(c):Match(Auxiliary.IsZone,nil,relzone,tp)
		if f then
			mg:Match(f,nil,tp)
		end
		local tributes=maplevel(c:GetLevel())
		return (not opt or (tributes>0 and tributes~=max)) and minc<=min and Duel.CheckTribute(c,min,max,mg,tp,zone)
	end
end
function Auxiliary.NormalSummonCondition2()
	return function (e,c,minc,zone,relzone,exeff)
		if c==nil then return true end
		return false
	end
end
function Auxiliary.NormalSummonTarget(min,max,f)
	return function (e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
		min,max=GetTributeCount(e:GetHandler(),tp,e,min,max,true)
		local mg=Duel.GetTributeGroup(c):Match(Auxiliary.IsZone,nil,relzone,tp)
		if f then
			mg:Match(f,nil,tp)
		end
		local g=Duel.SelectTribute(tp,c,min,max,mg,tp,zone,Duel.IsSummonCancelable())
		if g and #g>0 then
			g:KeepAlive()
			e:SetLabelObject(g)
			return true
		end
		return false
	end
end
function Auxiliary.NormalSummonOperation(min,max,sumop)
	return function (e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
		local g=e:GetLabelObject()
		local nemin,nemax
		c:SetMaterial(g)
		local ct=Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
		local eff=Duel.IsPlayerAffectedByEffect(tp,EFFECT_CHANGE_SUMMON_PROC_TRIBUTE)
		if eff and eff:CheckCountLimit(tp) then
			local efftarget=eff:GetTarget()
			local effvalue=eff:GetValue()
			if efftarget and efftarget(eff,e:GetHandler()) then
				if type(effvalue)=="function" then
					nemin,nemax=effvalue(eff,e:GetHandler(),min,max)
				else
					nemin,nemax=effvalue,effvalue
				end
			else
				if type(effvalue)=="function" then
					nemin,nemax=effvalue(eff,e:GetHandler(),min,max)
				else
					nemin,nemax=effvalue,effvalue
				end
			end
			if ct==nemin or ct==nemax then
				eff:UseCountLimit(tp)
			end
		end
		if sumop then
			sumop(g:Clone(),e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
		end
		g:DeleteGroup()
	end
end
--add normal set
function Auxiliary.AddNormalSetProcedure(c,ns,opt,min,max,val,desc,f,sumop)
	val = val or SUMMON_TYPE_TRIBUTE
	local e1=Effect.CreateEffect(c)
	if desc then e1:SetDescription(desc) end
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	if ns and opt then
		e1:SetCode(EFFECT_SET_PROC)
	else
		e1:SetCode(EFFECT_LIMIT_SET_PROC)
	end
	if ns then
		e1:SetCondition(Auxiliary.NormalSetCondition1(min,max,f))
		e1:SetTarget(Auxiliary.NormalSetTarget(min,max,f))
		e1:SetOperation(Auxiliary.NormalSetOperation(min,max,sumop))
	else
		e1:SetCondition(Auxiliary.NormalSetCondition2())
	end
	e1:SetValue(val)
	e1:SetLabel(min,max)
	c:RegisterEffect(e1)
	return e1
end
function Auxiliary.NormalSetCondition1(min,max,f,opt)
	return function (e,c,minc,zone,relzone,exeff)
		if c==nil then return true end
		local tp=c:GetControler()
		min,max=GetTributeCount(e:GetHandler(),tp,e,min,max,false)
		local mg=Duel.GetTributeGroup(c):Match(Auxiliary.IsZone,nil,relzone,tp)
		if f then
			mg:Match(f,nil,tp)
		end
		local tributes=maplevel(c:GetLevel())
		return (not opt or (tributes>0 and tributes~=max)) and minc<=min and Duel.CheckTribute(c,min,max,mg,tp,zone)
	end
end
function Auxiliary.NormalSetCondition2()
	return function (e,c,minc,zone,relzone,exeff)
		if c==nil then return true end
		return false
	end
end
function Auxiliary.NormalSetTarget(min,max,f)
	return function (e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
		min,max=GetTributeCount(e:GetHandler(),tp,e,min,max,false)
		local mg=Duel.GetTributeGroup(c):Match(Auxiliary.IsZone,nil,relzone,tp)
		if f then
			mg:Match(f,nil,tp)
		end
		local g=Duel.SelectTribute(tp,c,min,max,mg,tp,zone,Duel.IsSummonCancelable())
		if g and #g>0 then
			g:KeepAlive()
			e:SetLabelObject(g)
			return true
		end
		return false
	end
end
function Auxiliary.NormalSetOperation(min,max,sumop)
	return function (e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
		local g=e:GetLabelObject()
		local nemin,nemax
		c:SetMaterial(g)
		local ct=Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
		local eff=Duel.IsPlayerAffectedByEffect(tp,EFFECT_CHANGE_SUMMON_SET_PROC_TRIBUTE)
		if eff and eff:CheckCountLimit(tp) then
			local efftarget=eff:GetTarget()
			local effvalue=eff:GetValue()
			if efftarget and efftarget(eff,e:GetHandler(),min,max) then
				if type(effvalue)=="function" then
					nemin,nemax=effvalue(eff,e:GetHandler(),min,max)
				else
					nemin,nemax=effvalue,effvalue
				end
			else
				if type(effvalue)=="function" then
					nemin,nemax=effvalue(eff,e:GetHandler(),min,max)
				else
					nemin,nemax=effvalue,effvalue
				end
			end
			if ct==nemin or ct==nemax then
				eff:UseCountLimit(tp)
			end
		end
		if sumop then
			sumop(g:Clone(),e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
		end
		g:DeleteGroup()
	end
end

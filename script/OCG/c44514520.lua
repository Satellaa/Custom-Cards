--Ancient Gear Weapon
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixRep(c,true,true,s.mfilter,2,99,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_ANCIENT_GEAR))
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.fuslimit,nil,nil,false)
	--Pierce 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Extra Attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.mtcon)
	e3:SetOperation(s.mtop)
	c:RegisterEffect(e3)
	--actlimit
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,1)
	e5:SetValue(s.aclimit)
	e5:SetCondition(s.actcon)
	c:RegisterEffect(e5)
end
s.material_setcode={SET_ANCIENT_GEAR}
s.listed_series={SET_ANCIENT_GEAR,SET_GADGET}

function s.fuslimit(e,se,sp,st)
    return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
function s.mfilter(c,fc,sumtype,tp,sub,mg,sg,contact)
	if contact then sumtype=0 end
	return c:IsRace(RACE_MACHINE,fc,sumtype,tp) and (not contact or c:IsType(TYPE_MONSTER,fc,sumtype,tp))
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,tp)
end
function s.cfilter(c,tp)
	return c:IsAbleToGraveAsCost() and (c:IsControler(tp) or c:IsFaceup())
end
function s.contactop(g,tp,c)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
end
function s.agearfilter(c)
	return c:IsSetCard(SET_ANCIENT_GEAR) and c:IsLevelAbove(8)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local g=c:GetMaterial()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and g:IsExists(s.agearfilter,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
end
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
  local g=c:GetMaterial()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and g:IsExists(Card.IsSetCard,1,nil,SET_GADGET)
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,2))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_EXTRA_ATTACK)
		e2:SetValue(c:GetMaterialCount()-1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
end
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler()
end
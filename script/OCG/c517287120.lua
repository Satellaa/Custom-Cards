--Ancient Gear Remold Golem 
Duel.LoadScript("SP_CARDS.lua")
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,CARD_ANCIENT_GOLEM,1,aux.FilterBoolFunctionEx(Card.IsRace,RACE_MACHINE),1)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,nil,nil,nil,false)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.atkcon)
	e3:SetOperation(s.atkop)
	e3:SetLabelObject(e2)
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
	--pierce
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_PIERCE)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	--+ 1000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
s.material_setcode={CARD_ANCIENT_GOLEM}
s.listed_names={CARD_ANCIENT_GOLEM}
	if contact then sumtype=0 end
	
function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,tp)
end
function s.cfilter(c,tp)
	return c:IsAbleToGraveAsCost() and (c:IsControler(tp) or c:IsFaceup())
end
function s.contactop(g,tp,c)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
end
function s.valcheck(e,c)
local g=c:GetMaterial()
	local atk=0
	local tc=g:GetFirst()
	if tc:IsCode(CARD_ANCIENT_GOLEM) or tc:CheckFusionSubstitute(c) then tc=g:GetNext() end
	if not tc:IsCode(CARD_ANCIENT_GOLEM) then
		atk=tc:GetBaseAttack()/2
	end
	e:SetLabel(atk)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=e:GetLabelObject():GetLabel()
	if atk>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler()
end
	function s.damop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local ac=Duel.GetAttacker()
local dc=Duel.GetAttackTarget()
if c==ac and dc and dc:IsDefensePos() and Duel.GetBattleDamage(1-tp)>0 and c:IsHasEffect(EFFECT_PIERCE)
	then Duel.ChangeBattleDamage(1-tp,Duel.GetBattleDamage(1-tp)+1000)
	end
end
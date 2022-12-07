--Phantasmal Succession
--Scripted by Eerie Code
Duel.LoadScript("SP_CARDS.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,{CARD_URIA,CARD_HAMON,CARD_RAVIEL},s.ffilter)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--Cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Uria Effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.trcon)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--Uria 2nd effect
	local e3=e2:Clone()
		e3:SetDescription(3113)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetValue(s.efilter)
		c:RegisterEffect(e3)
		--Hamon effect
	local e4=Effect.CreateEffect(c)
		e4:SetDescription(3113)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e4:SetRange(LOCATION_MZONE)
		e4:SetCode(EFFECT_IMMUNE_EFFECT)
		e4:SetCondition(s.mgcon)
		e4:SetValue(s.mgfilter2)
		c:RegisterEffect(e4)
		--Hammon 2nd Effect
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCondition(s.atkcon)
	e5:SetValue(4000)
	c:RegisterEffect(e5)
	--Raviel Effect
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.rvcon)
	e6:SetValue(4000)
	c:RegisterEffect(e6)
	--Raviel 2nd effect
	local e7=e6:Clone()
	e7:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e7)
	end
s.listed_names={CARD_URIA,CARD_HAMON,CARD_RAVIEL}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsType(TYPE_EFFECT,fc,sumtype,tp)
end
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_MATERIAL)
end
function s.trcon(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer() and (c:IsSummonType(SUMMON_TYPE_FUSION) or c:IsSummonType(SUMMON_TYPE_SPECIAL)) and c:GetMaterial():IsExists(s.trfilter,1,nil,c)
end
function s.trfilter(c)
	return c:IsCode(CARD_URIA)
end
	function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer() and re:IsActiveType(TYPE_TRAP)
end
function s.atkfilter(c)
	return c:GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*1000
end
function s.mgcon(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	return (c:IsSummonType(SUMMON_TYPE_FUSION) or c:IsSummonType(SUMMON_TYPE_SPECIAL)) and c:GetMaterial():IsExists(s.mgfilter,1,nil,c)
end
function s.mgfilter(c)
	return c:IsCode(CARD_HAMON)
end
	function s.mgfilter2(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer() and re:IsActiveType(TYPE_SPELL)
end
function s.atkcon(e)
local c=e:GetHandler()
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer() and (c:IsSummonType(SUMMON_TYPE_FUSION) or c:IsSummonType(SUMMON_TYPE_SPECIAL)) and
	    c:GetMaterial():IsExists(s.mgfilter,1,nil,c)
end
function s.rvcon(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer() and (c:IsSummonType(SUMMON_TYPE_FUSION) or c:IsSummonType(SUMMON_TYPE_SPECIAL)) and c:GetMaterial():IsExists(s.rvfilter,1,nil,c)
end
function s.rvfilter(c)
	return c:IsCode(CARD_RAVIEL)
end

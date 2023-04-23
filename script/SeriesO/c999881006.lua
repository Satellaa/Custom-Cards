-- 閃術姫ーロゼ
-- Strategic Ace - Roze
-- Scripted by Lilac
Duel.LoadScript("custom_constant.lua")
Duel.LoadScript("c419.lua")
local s,id=GetID()
function s.initial_effect(c)
	-- Treat as Spell
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- Inflict damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e2:SetCost(aux.selftogravecost)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SKY_STRIKER,SET_SKY_STRIKER_ACE}
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(999,RESET_PHASE+PHASE_END,0,1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(511001265)
	e1:SetRange(LOCATION_ALL)
	e1:SetCondition(s.damcon)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
function s.diffilter1(c,g)
	local dif=0
	local val=0
	if c:GetFlagEffect(284)>0 then val=c:GetFlagEffectLabel(284) end
	if c:GetAttack()>val then dif=c:GetAttack()-val
	else dif=val-c:GetAttack() end
	return g:IsExists(s.diffilter2,1,c,dif)
end
function s.diffilter2(c,dif)
	local dif2=0
	local val=0
	if c:GetFlagEffect(284)>0 then val=c:GetFlagEffectLabel(284) end
	if c:GetAttack()>val then dif2=c:GetAttack()-val
	else dif2=val-c:GetAttack() end
	return dif~=dif2
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(999)>0 and (re:GetHandler():IsSetCard(SET_SKY_STRIKER) or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,{63288573,90673288}),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil))
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	local g=eg:Filter(s.diffilter1,nil,eg)
	local g2=Group.CreateGroup()
	if #g>0 then g2=g:Select(tp,1,1,nil) ec=g2:GetFirst() end
	if #g2>0 then Duel.HintSelection(g2) end
	local dam=0
	local val=0
	if ec:GetFlagEffect(284)>0 then val=ec:GetFlagEffectLabel(284) end
	if ec:GetAttack()>val then dam=ec:GetAttack()-val
	else dam=val-ec:GetAttack() end
	if Duel.Damage(1-tp,dam,REASON_EFFECT)<300 then return end
	local sg=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsSetCard,SET_SKY_STRIKER),tp,LOCATION_REMOVED,0,1,1,nil)
	if #sg>0 then 
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

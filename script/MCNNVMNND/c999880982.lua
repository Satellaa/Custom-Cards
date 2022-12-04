local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,2,s.lcheck)
    local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetTarget(s.immval)
    c:RegisterEffect(e2)
end
s.listed_series={0x8e}
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsRace,1,nil,RACE_ZOMBIE,lc,sumtype,tp)
end
function s.indtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
function s.immval(e,re)
	if not re:IsActivated() or not e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) or e:GetOwnerPlayer()==re:GetOwnerPlayer() then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g or not g:IsContains(e:GetHandler())
end
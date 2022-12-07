--Darklord Goddess of Paradise Lost
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_DARKLORD),aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT))
	--Fusion summon cannot be negated
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCondition(s.effcon)
	c:RegisterEffect(e3)
	--your opponent cannot activate trap 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.aclimit)
	c:RegisterEffect(e1)
	--copy effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetCost(s.cpcost)
	e2:SetTarget(s.cptg)
	e2:SetOperation(s.cpop)
	c:RegisterEffect(e2)
	end
	s.listed_series={SET_DARKLORD,SET_FORBIDDEN}
	s.material_setcode={SET_DARKLORD} 
	function s.effcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_FUSION 
end
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_TRAP)
end
function s.copfilter(c)
    return c:IsAbleToGraveAsCost() and c:IsSetCard(SET_DARKLORD) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:CheckActivateEffect(true,true,false)~=nil 
end
function s.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,1000) and Duel.IsExistingMatchingCard(s.copfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.PayLPCost(tp,1000)
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        local te=e:GetLabelObject()
        return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
    end
    if chk==0 then return Duel.IsExistingMatchingCard(s.copfilter,tp,LOCATION_DECK,0,1,nil) end
    local g=Duel.SelectMatchingCard(tp,s.copfilter,tp,LOCATION_DECK,0,1,1,nil)
    if not Duel.SendtoGrave(g,REASON_COST) then return end
    local te=g:GetFirst():CheckActivateEffect(true,true,false)
    e:SetLabel(te:GetLabel())
    e:SetLabelObject(te:GetLabelObject())
    local tg=te:GetTarget()
    if tg then
        tg(e,tp,eg,ep,ev,re,r,rp,1)
    end
    te:SetLabel(e:GetLabel())
    te:SetLabelObject(e:GetLabelObject())
    e:SetLabelObject(te)
    Duel.ClearOperationInfo(0)
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
    local te=e:GetLabelObject()
    if te then
        e:SetLabel(te:GetLabel())
        e:SetLabelObject(te:GetLabelObject())
        local op=te:GetOperation()
        if op then op(e,tp,eg,ep,ev,re,r,rp) end
        te:SetLabel(e:GetLabel())
        te:SetLabelObject(e:GetLabelObject())
    end
end
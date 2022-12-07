--Darklord Deity Morningstar 
Duel.LoadScript("SP_CARDS.lua")
local s,id=GetID()
function s.initial_effect(c)
c:SetUniqueOnField(1,0,id)
	--Fusion materials
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.ffilter,4)
		--Special Summon condition
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e8:SetCode(EFFECT_SPSUMMON_CONDITION)
	e8:SetValue(aux.fuslimit)
	c:RegisterEffect(e8)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--immune Effect 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.immval)
	c:RegisterEffect(e1)
	 --Attack all monsters 
	local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_ATTACK_ALL)
    e3:SetValue(1)
	  c:RegisterEffect(e3)
	--copy effect
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1)
	e4:SetCost(s.cpcost)
	e4:SetTarget(s.cptg)
	e4:SetOperation(s.cpop)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_FIRST_DARKLORD}
s.listed_series={SET_DARKLORD}

function s.ffilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_DARK,fc,sumtype,tp) and c:IsRace(RACE_FAIRY,fc,sumtype,tp)
end
function s.spfilter1(c)
	return c:IsCode(CARD_FIRST_DARKLORD) and c:IsAbleToGraveAsCost()
end
function s.spfilter2(c)
	return c:IsSetCard(SET_DARKLORD) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(s.chk,1,nil,sg)
end
function s.chk(c,sg)
	return c:IsCode(CARD_FIRST_DARKLORD) and sg:IsExists(Card.IsSetCard,1,c,SET_DARKLORD)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local g1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
	local g=g1:Clone()
	g:Merge(g2)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and #g1>0 and #g2>0 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
	g1:Merge(g2)
	local g=aux.SelectUnselectGroup(g1,e,tp,2,2,s.rescon,1,tp,HINTMSG_TOGRAVE)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
		c:SetMaterial(g)
		g:DeleteGroup()
end
function s.immval(e,te)
	return te:GetOwner()~=e:GetHandler() and te:IsActivated()
end
function s.copfilter(c)
    return c:IsAbleToGraveAsCost() and c:IsSetCard(SET_DARKLORD) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:CheckActivateEffect(true,true,false)~=nil 
end
function s.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,2000) and Duel.IsExistingMatchingCard(s.copfilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,nil) end
    Duel.PayLPCost(tp,2000)
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        local te=e:GetLabelObject()
        return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
    end
    if chk==0 then return Duel.IsExistingMatchingCard(s.copfilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,nil) end
    local g=Duel.SelectMatchingCard(tp,s.copfilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,1,nil)
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
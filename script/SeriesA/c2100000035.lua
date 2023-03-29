-- Anne, Verre of the Azurist
-- Scripted by Lilac
Duel.LoadScript("custom_constant.lua")
local s,id=GetID()
function s.initial_effect(c)
	-- Link Summon procedure
	Link.AddProcedure(c,s.matfilter,2,2,s.lcheck)
	c:EnableReviveLimit()
	-- Negate the activation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	-- Send cards in the same column as the targeted monster to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_AZURIST}
function s.matfilter(c,sc,st,tp)
	return c:IsRace(RACE_SPELLCASTER,sc,st,tp) and not c:IsType(TYPE_TOKEN,sc,st,tp)
end
function s.lcheck(g,lc,sumtype,tp)
	return g:CheckDifferentProperty(Card.GetCode,lc,sumtype,tp)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	local rc=re:GetHandler()
	return (loc&LOCATION_ONFIELD)~=0 and re:IsActiveType(TYPE_MONSTER) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and Duel.IsChainNegatable(ev) and rc~=e:GetHandler()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsSetCard,1,false,nil,nil,SET_AZURIST) end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsSetCard,1,1,false,nil,nil,SET_AZURIST)
	Duel.Release(g,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsRelateToEffect(re) then
		Duel.SendtoGrave(eg,REASON_EFFECT)
	end
end
function s.columnfilter(c)
	return c:GetColumnGroupCount()>0 and c:IsSetCard(SET_AZURIST) and c:IsFaceup()
end
function s.tgfilter(c,g)
	return g:IsContains(c) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.columnfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and Duel.IsExistingTarget(s.columnfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.columnfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPTION)
	local op=nil
	local cg=g:GetFirst():GetColumnGroup()
	cg:KeepAlive()
	if not cg:IsExists(Card.IsMonster,1,nil) then op=Duel.SelectOption(tp,aux.Stringid(id,3))
	elseif not cg:IsExists(Card.IsSpellTrap,1,nil) then op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	else op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))+2 end
	e:SetLabel(op)
	Duel.SetChainLimit(function(e,rp,tp) return not cg:IsContains(e:GetHandler()) end)
	local c=e:GetHandler()
	-- An effect for deleting group "cg" has been retained by the "KeepAlive" function, if not deleted it will be retained forever.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_END)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_ALL)
	e1:SetOperation(s.deleteop)
	e1:SetLabelObject(cg)
	c:RegisterEffect(e1)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,cg,#cg,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local cg=tc:GetColumnGroup()
	local g=nil
	if (e:GetLabel()==0 or e:GetLabel()==3) then g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_STZONE,LOCATION_STZONE,nil,cg)
	else g=tc+Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg) end
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function s.deleteop(e,tp,eg,ep,ev,re,r,rp)
	local ctg=e:GetLabelObject()
	if #ctg==0 then return false end
	ctg:DeleteGroup()
end
-- Starrytail Wishing
-- Scripted by Lilac
Duel.LoadScript("custom_constant&function.lua")
local s,id=GetID()
function s.initial_effect(c)
	-- Ritual Summon
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsSetCard,SET_STARRYTAIL),extrafil=s.extrafil,extraop=s.extraop,matfilter=s.forcedgroup})
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e1)
end
s.listed_series={SET_STARRYTAIL}
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetFieldGroup(tp,LOCATION_DECK,0)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	return Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.forcedgroup(c,e,tp)
	return c:IsLocation(LOCATION_DECK) and c:IsRitualMonster() and c:IsAbleToGrave()
end
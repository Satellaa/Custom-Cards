-- Craig, Ultimate Wizard of the Azurist
-- Scripted by Lilac
Duel.LoadScript("custom_constant.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Link Summon procedure
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_AZURIST),2)
	-- Special Summon as many "Azurist" monsters with different names from your GY to your zones this card points to as possible
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- All other "Azurist" monsters you control gain 400 ATK/DEF
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
s.listed_series={SET_AZURIST}
function s.spfilter(c,e,tp,zone)
	return c:IsSetCard(SET_AZURIST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp,zone)
end
function s.disfilter(c,g)
	return g:IsContains(c) and not c:IsCode(2100000036)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,e:GetHandler():GetLinkedZone(tp)) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp,zone)
	if #sg==0 then return end
	local ft=math.min(sg:GetClassCount(Card.GetCode),Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone))
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local rg=aux.SelectUnselectGroup(sg,e,tp,ft,ft,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	if #rg==0 then return end
	if Duel.SpecialSummon(rg,0,tp,tp,false,false,POS_FACEUP_DEFENSE,zone)~=0 then
			local og=Duel.GetOperatedGroup()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPTION)
			local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
			Duel.BreakEffect()
			for tc in aux.Next(og) do
				local cg=tc:GetColumnGroup()
				local dg=nil
				if op==0 then dg=tc+Duel.GetMatchingGroup(s.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg)
				else dg=Duel.GetMatchingGroup(s.disfilter,tp,LOCATION_STZONE,LOCATION_STZONE,nil,cg) end
				for tc2 in aux.Next(dg) do
					Duel.NegateRelatedChain(tc2,RESET_TURN_SET)
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_DISABLE)
					e1:SetReset(RESET_EVENT|RESETS_STANDARD)
					tc2:RegisterEffect(e1)
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_DISABLE_EFFECT)
					e2:SetReset(RESET_EVENT|RESETS_STANDARD)
					tc2:RegisterEffect(e2)
					if tc2:IsType(TYPE_TRAPMONSTER) then
						local e3=Effect.CreateEffect(c)
						e3:SetType(EFFECT_TYPE_SINGLE)
						e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
						e3:SetReset(RESET_EVENT|RESETS_STANDARD)
						tc2:RegisterEffect(e3)
					end
				end
			end
		end
	end
function s.atktg(e,c)
	return c:IsSetCard(SET_AZURIST) and c:IsFaceup() and c~=e:GetHandler()
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_AZURIST)
end
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(s.atkfilter,c:GetControler(),LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetAttribute)*400
end
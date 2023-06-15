-- 大導劇人ドラマティス
-- Dramatis of Dogmatika
-- Scripted by Lilac
Duel.LoadScript("LilacRitual_proc.lua")
local s,id=GetID()
function s.initial_effect(c)
	-- This card can also be Ritual Summoned from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_RITUAL_LOCATION)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_DECK)
	e1:SetCountLimit(1,id)
	e1:SetTarget(function(_,rc) return rc:IsSetCard(SET_DOGMATIKA) and not rc:IsCode(id) end)
	c:RegisterEffect(e1)
	local e2=Ritual.AddProcGreater({
		handler=c,
		filter=aux.FilterBoolFunction(Card.IsSetCard,SET_DOGMATIKA),
		location=LOCATION_HAND,
		lv=s.GetLevelRankLink,
		extrafil=s.extramat,
		requirementfunc=s.GetLevelRankLink,
		forcedselection=s.ritcheck,
		stage2=s.stage2
	})
	-- Ritual Summon 1 "Dogmatika" monster from your hand
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.ritcost)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return not c:IsSummonLocation(LOCATION_EXTRA) end)
end
s.listed_series={SET_DOGMATIKA}
s.listed_names={id,51522296}
function s.ritcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- Cannot Special Summon monsters from the Extra Deck
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_OATH|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) end)
	e1:SetReset(RESET_PHASE|PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
end
function s.GetLevelRankLink(c)
	local lv,rk,lr=c:GetLevel() or 0,c:GetControler()==1 and c:GetRank() or 0,c:GetControler()==1 and c:GetLink() or 0
	return lv+rk+lr
end
function s.extramatfilter(c,tp)
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_MZONE) 
		and c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.extramat(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.extramatfilter,tp,0,LOCATION_MZONE,nil,tp)
end
function s.ritcheck(e,tp,g,sc)
	local extrag=g:FilterCount(s.extramatfilter,nil,tp)
	return extrag==0 or extrag==1 
end
function s.stage2(mg,e,tp,eg,ep,ev,re,r,rp,tc)
	if tc:IsCode(51522296) then
		local effs={tc:GetCardEffect()}
		if not effs then return false end
		for _,eff1 in ipairs(effs) do
			if (eff1:GetType()&EFFECT_TYPE_IGNITION)>0 then
				eff1:SetCondition(aux.NOT(s.albazoaquickcon))
				local eff2=eff1:Clone()
				eff2:SetType(EFFECT_TYPE_QUICK_O)
				eff2:SetCode(EVENT_FREE_CHAIN)
				eff2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
				eff2:SetCondition(s.albazoaquickcon)
				eff2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
				tc:RegisterEffect(eff2)
				tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
			end
		end
	end
end
function s.albazoaquickcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():HasFlagEffect(id)
end
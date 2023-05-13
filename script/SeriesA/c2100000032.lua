-- Azurite
-- Scripted by Lilac
Duel.LoadScript("custom_constant&function.lua")
local s,id=GetID()
local codes={}
function s.initial_effect(c)
	-- Special Summon 1 "Azurist" Link Monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- Make 1 "Azurist" monster on the field be able to be used as material for the Summon of a Spellcaster monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.freetg)
	e2:SetOperation(s.freeop)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
	ge1:SetOperation(s.checkop)
	Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={SET_AZURIST}
function s.cfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsMonster() and c:IsSetCard(SET_AZURIST) and c:IsLevel(4)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.cfilter,nil)
	for tc in aux.Next(tg) do
		local code=tc:GetCode()
		table.insert(codes,code)
	end
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.spcheck(sg,tp,exg,e)
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg,sg:GetSum(Card.GetLink),sg:FilterCount(aux.NOT(Card.IsLinkMonster),nil),#sg,sg)
end
function s.spfilter(c,e,tp,sg,lc,lr,ct,g)
	if not (c:IsLink({lr+lc,ct}) and c:IsSetCard(SET_AZURIST) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	return Duel.GetLocationCountFromEx(tp,tp,sg,c)>0 and not g:IsExists(Card.IsCode,1,nil,c:GetCode())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then
			if e:GetLabel()~=100 then return false end
			e:SetLabel(0)
			return Duel.CheckReleaseGroupCost(tp,nil,1,99,false,s.spcheck,nil,e)
		end
		local sg=Duel.SelectReleaseGroupCost(tp,nil,1,99,false,s.spcheck,nil,e)
		local lc=sg:GetSum(Card.GetLink)
		local lr=sg:FilterCount(aux.NOT(Card.IsLinkMonster),nil)
		e:SetLabel(lc,lr,#sg)
		Duel.Release(sg,REASON_COST)
		local og=Duel.GetOperatedGroup()
		og:KeepAlive()
		e:SetLabelObject(og)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local lc,lr,ct=e:GetLabel()
	local dn=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil,lc,lr,ct,dn):GetFirst()
	if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP) then
		sc:CompleteProcedure()
	end
	dn:DeleteGroup()
end
function s.checkflag(c)
	for _,v in ipairs(codes) do 
		if c:GetFlagEffect(v)>0 then 
			return true
		end
	end
	return false
end
function s.freefilter(c)
	return c:IsSetCard(SET_AZURIST) and c:IsFaceup() and c:IsLevel(4) and s.checkflag(c)
end
function s.freetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.freefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function s.freeop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local tc=Duel.SelectMatchingCard(tp,s.freefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then
		Duel.HintSelection(tc,true)
		tc:RegisterFlagEffect(CARD_THE_AZURE_PROJECT,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,0,1,aux.Stringid(id,3))
		Duel.RaiseEvent(tc,EVENT_CUSTOM+tc:GetCode(),e,0,0,0,0)
	end
end

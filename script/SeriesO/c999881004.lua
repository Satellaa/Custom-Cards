-- ファイアウォール・ドラゴン・ダークフルードーネガティブ
-- Firewall Dragon Darkfluid - Negative
-- Phòng Hoả Tường Long - Hắc Ám Lưu Thể Phụ Diện
-- Scripted by Lilac-chan
Duel.LoadScript("custom_constant.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_CYBERSE),3)
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAIN_ACTIVATING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCondition(s.discon)
    e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	local con2=e1:Clone()
	con2:SetCondition(s.discon2)
	c:RegisterEffect(con2)
	local con3=e1:Clone()
	con3:SetCondition(s.discon3)
	c:RegisterEffect(con3)
	local con4=e1:Clone()
	con4:SetCondition(s.discon4)
	c:RegisterEffect(con4)
	local con5=e1:Clone()
	con5:SetCondition(s.discon5)
	c:RegisterEffect(con5)
	local con6=e1:Clone()
	con6:SetCondition(s.discon6)
	c:RegisterEffect(con6)
	local con7=e1:Clone()
	con7:SetCondition(s.discon7)
	c:RegisterEffect(con7)
	local con8=e1:Clone()
	con8:SetCondition(s.discon8)
	c:RegisterEffect(con8)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(s.exatcon)
    e2:SetCost(s.exatcost)
	e2:SetOperation(s.exatop)
	c:RegisterEffect(e2)
    aux.GlobalCheck(s,function()
		s.typ_list={}
		s.typ_list[0]=0
		s.typ_list[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PHASE+PHASE_END)
		ge1:SetCountLimit(1)
		ge1:SetCondition(s.resetop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={SET_FIREWALL}
function s.discon(e,tp,eg,ep,ev,re,r,rp)
    if tp==ep or not Duel.IsChainDisablable(ev) or not e:GetHandler():IsExtraLinked() then return false end
	if not re:IsHasCategory(CATEGORY_REMOVE) or not Duel.GetOperationInfo(ev,CATEGORY_REMOVE) then return false end
	local ex,tg,tc,p,cv=Duel.GetOperationInfo(ev,CATEGORY_REMOVE)
	return ex and (cv&LOCATION_ONFIELD>0
		or (tg and tg:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD))) or re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(15693423)
end
function s.discon2(e,tp,eg,ep,ev,re,r,rp)
    if tp==ep or not Duel.IsChainDisablable(ev) or not e:GetHandler():IsExtraLinked() then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-#tg>0
end
function s.discon3(e,tp,eg,ep,ev,re,r,rp)
    if tp==ep or not Duel.IsChainDisablable(ev) or not e:GetHandler():IsExtraLinked() then return false end
	if not re:IsHasCategory(CATEGORY_TOHAND) or not Duel.GetOperationInfo(ev,CATEGORY_TOHAND) then return false end
	local ex,tg,tc,p,cv=Duel.GetOperationInfo(ev,CATEGORY_TOHAND)
	return ex and (cv&LOCATION_ONFIELD>0
		or (tg and tg:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD)))
end
function s.discon4(e,tp,eg,ep,ev,re,r,rp)
    if tp==ep or not Duel.IsChainDisablable(ev) or not e:GetHandler():IsExtraLinked() then return false end
	if not re:IsHasCategory(CATEGORY_TODECK) or not Duel.GetOperationInfo(ev,CATEGORY_TODECK) then return false end
	local ex,tg,tc,p,cv=Duel.GetOperationInfo(ev,CATEGORY_TODECK)
	return ex and (cv&LOCATION_ONFIELD>0
		or (tg and tg:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD)))
end
function s.discon5(e,tp,eg,ep,ev,re,r,rp)
    if tp==ep or not Duel.IsChainDisablable(ev) or not e:GetHandler():IsExtraLinked() then return false end
	if not re:IsHasCategory(CATEGORY_TOGRAVE) or not Duel.GetOperationInfo(ev,CATEGORY_TOGRAVE) then return false end
	local ex,tg,tc,p,cv=Duel.GetOperationInfo(ev,CATEGORY_TOGRAVE)
	return ex and (cv&LOCATION_ONFIELD>0
		or (tg and tg:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD))) or re:GetHandler():IsCode(93854893,44595286)
end
function s.discon6(e,tp,eg,ep,ev,re,r,rp)
    if tp==ep or not Duel.IsChainDisablable(ev) or not e:GetHandler():IsExtraLinked() then return false end
	if not re:IsHasCategory(CATEGORY_FUSION_SUMMON) or not Duel.GetOperationInfo(ev,CATEGORY_FUSION_SUMMON) then return false end
	local ex,tg,tc,p,cv=Duel.GetOperationInfo(ev,CATEGORY_FUSION_SUMMON)
	return ex and (cv&LOCATION_ONFIELD>0
		or (tg and tg:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD)))
end
function s.discon7(e,tp,eg,ep,ev,re,r,rp)
    if tp==ep or not Duel.IsChainDisablable(ev) or not e:GetHandler():IsExtraLinked() then return false end
	return (re:IsHasCategory(CATEGORY_FUSION_SUMMON) or Duel.GetOperationInfo(ev,CATEGORY_FUSION_SUMMON)) and 
    (re:GetHandler():IsCode(87746184,70534340,82738008,34995106,99543666,44362883,6763530,68468459,46136942,30118701,60822251,58657303,95515789,39396763,42878636,29280589,71736213,65331686,93657021,86938484,31887806,511003228,89181134,51858200,34325937,54527349,55824220,47705572,12450071,34933456,74063034,40003819,65956182,21011044,67526112,59514116,80033124,1784686,13234975,23299957,37630732,40110009,44227727,44771289,71490127,87669904,79059098,98570539,10833828,11493868,29143457,31444249,43698897,73360025,95034141,52963531,7241272,73511233,62895219,42002073,91584698,29719112,84040113,31855260,511000635,74078255,37961969,572850) or 
     re:GetHandler():IsSetCard(SET_FUSION)) and not re:GetHandler():IsCode(1845204,6498706,17194258,39261576,49469105,54283059,59419719,59432181,72490637,43225434,95286165,7394770,40597694,77565204,27967615,74694807,34449261,72029628,81223446,89719143,27581098,57355219,73026394)
end
function s.discon8(e,tp,eg,ep,ev,re,r,rp)
    if tp==ep or not Duel.IsChainDisablable(ev) or not e:GetHandler():IsExtraLinked() then return false end
	return (re:IsHasCategory(CATEGORY_REMOVE) or Duel.GetOperationInfo(ev,CATEGORY_REMOVE)) and re:GetHandler():IsCode(15693423)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
		Duel.NegateEffect(ev)
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	s.typ_list[0]=0
	s.typ_list[1]=0
	return false
end
function s.exatcon(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()
   return Duel.GetAttacker()==c and aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and c:CanChainAttack(0)
end
function s.costfilter(c,e,tp)
	local typ=c:GetType()
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) and c:IsAbleToRemoveAsCost() and s.typ_list[tp]&typ&(TYPE_FUSION|TYPE_XYZ|TYPE_SYNCHRO|TYPE_RITUAL)==0
end
function s.exatcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetType())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.exatop(e,tp,eg,ep,ev,re,r,rp)
   local type=e:GetLabel()
   Duel.ChainAttack()
	s.typ_list[tp]=s.typ_list[tp]|type
	for _,str in aux.GetTypeStrings(type) do
		e:GetHandler():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,str)
	end
end
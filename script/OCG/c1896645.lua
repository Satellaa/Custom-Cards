--Blue-Eyes Stately Dragon of White
local s,id=GetID()
function s.initial_effect(c)
	--link summon AddProcedure
	Link.AddProcedure(c,nil,2,99,s.lcheck)
	--How it's summon Limit 
	c:EnableReviveLimit()
	--Extra Attack 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(s.extcon)
	e1:SetTarget(s.exttg)
	e1:SetOperation(s.extop)
	c:RegisterEffect(e1)
	--cannot be targeted by attacks
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetCondition(s.imcon)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--Cannot be destroyed by your opponent's card effect 
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetValue(s.tgvalue)
	c:RegisterEffect(e3)
	--Target 1 Dragon monster Special summon it to a zone this card points to 
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_BLUEEYES_W_DRAGON}

function s.lcheck(sg,lc,sumtype,tp)
	return sg:IsExists(Card.IsCode,tp,lc,sumtype,tp,CARD_BLUEEYES_W_DRAGON,1)
end
function s.extcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local ph=Duel.GetCurrentPhase()
	local tp=Duel.GetTurnPlayer()
	return c:IsRelateToBattle() and bc:IsMonster() and 
	      tp==e:GetHandler():GetControler() and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function s.exttg(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return e:GetHandler():IsRelateToBattle() and not e:GetHandler():IsHasEffect(EFFECT_EXTRA_ATTACK) end
end
function s.extop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	if not c:IsRelateToBattle() then return end
	--Can make a second attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3201)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	c:RegisterEffect(e1)
 end
 function s.imcon(e)
	return e:GetHandler():IsInExtraMZone()
end
function s.tgvalue(e,re,rp)
	return rp~=e:GetHandlerPlayer()
end
function s.spfilter(c,e,tp,zone)
    	return c:IsRace(RACE_DRAGON) and c:GetAttack()>=2500
    	  and (c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp,zone[1-tp]) or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone[tp])) and 
    	   (Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone[tp])<=0
		          or Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone[1-tp])<=0)
  end
	function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone={}
	zone[0]=c:GetLinkedZone(0)
	zone[1]=c:GetLinkedZone(1)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,zone) and
	  (Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone[tp])<=0
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone[1-tp])<=0) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,zone)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone={}
	zone[0]=c:GetLinkedZone(0)
	zone[1]=c:GetLinkedZone(1)
	local tc=Duel.GetFirstTarget()
	if tc then
		local sump=tp
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp,zone[1-tp])
			and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone[tp]) or Duel.SelectYesNo(tp,aux.Stringid(id,0))) then
			sump=1-tp
		end
		Duel.SpecialSummon(tc,0,tp,sump,false,false,POS_FACEUP,zone[sump])
	   end
	end
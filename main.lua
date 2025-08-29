--- STEAMODDED HEADER
 --- MOD_NAME: Punchline
 --- MOD_ID: Punch
 --- MOD_AUTHOR: [gfsgfs for art and EricTheToon for code]
 --- MOD_DESCRIPTION: Silly lil mod for silly lil people
 --- BADGE_COLOUR: 4e215c
 --- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0812d, Talisman>=2.0.0-beta8,]
 --- PREFIX: punch
 --- PRIORITY: -69419
----------------------------------------------
------------MOD CODE -------------------------
--My code is too strong for you, player
--You can't handle my code. They're too strong for you.
--My code would kill you, player. You cannot handle my code.
-- thingy for text Color= C:color ,Highlighting text= X:attention ,Size= S:1 (1 is normal) e:1 makes move it
SMODS.optional_features.cardareas.unscored = true
SMODS.current_mod.optional_features = function()
    return {
        retrigger_joker = true,
		post_trigger = true,
    }
end


local punch = loc_colour
function loc_colour(_c, _default)
    if not G.ARGS.LOC_COLOURS then
        punch()
    end
    G.ARGS.LOC_COLOURS.punch_test = HEX("BA45D1")
    G.ARGS.LOC_COLOURS.punch_light = HEX("fccf50")
	G.ARGS.LOC_COLOURS.punch_dark = HEX("4f6367")
	G.ARGS.LOC_COLOURS.punch_small_blind = HEX("2240a3")
	G.ARGS.LOC_COLOURS.punch_big_blind = HEX("de9f35")
	G.ARGS.LOC_COLOURS.punch_code_backg = HEX("0b0b0b")
	G.ARGS.LOC_COLOURS.punch_code_text = HEX("23a457")
	G.ARGS.LOC_COLOURS.punch_relics = HEX("6E260E")
	
    return punch(_c, _default)
end

SMODS.Atlas{
    key = 'Jokers', 
    path = 'Jokers.png', 
    px = 71, 
    py = 95 
	}
SMODS.Atlas{
	key = 'balatro',
    path = 'balatro.png',
    px = 332 ,
    py = 216 ,
    prefix_config = {key = false}

}
SMODS.Atlas({
	key = "modicon",
	path = "hd_icon.png",
	px = 32,
	py = 32
})
SMODS.Atlas{
    key = 'Jokersba', 
    path = 'bananana.png', 
    px = 139, 
    py = 187 
}

SMODS.Joker {
  key = 'kch',
  loc_txt = {
    name = 'Kitchen crate holster',
    text = {
      "Each {C:attention}4 {}&{C:attention} 7{}",
      "played together gives {C:mult}+10{} mult",
	  "{C:inactive}[Allan please add more effects]{}"
    }
  },
  atlas = 'Jokers', -- atlas' key
  rarity = 1,
  cost = 5, 
  unlocked = true,
  discovered = true,
  blueprint_compat = true,
  eternal_compat = false,
  perishable_compat = false,
  pos = {x = 0, y = 0},
  config = {
    extra = {
      mult = 10, 
      triggered = false
    }
  },

  check_for_unlock = function(self, args)
      if args.type == 'derek_loves_you' then
          unlock_card(self)
      end
      unlock_card(self)
  end,

 calculate = function(self,card,context)
    if context.individual and context.cardarea == G.play then
        if context.other_card:get_id() == 4 then john_has_4 = true end
        if context.other_card:get_id() == 7 then john_has_7 = true end

        if john_has_4 and john_has_7 then
            return {
                mult = card.ability.extra.mult,
            }
        end
    end
    if context.after then
        john_has_4 = false
        john_has_7 = false
    end
end
}

SMODS.Joker {
  key = 'the_ace',
  loc_txt = {
    name = '{s:1.5} The{} Ace',
    text = {
      "First played {C:money}Ace{} card",
      "gives {X:mult,C:white}X#1#{} when scored"
    }
  },
  config = { extra = {Xmult = 3 } 
  },
  rarity = 1,
  atlas = 'Jokers',
  pos = { x = 1, y = 0 },
  cost = 5,
  blueprint_compat = true,

loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.Xmult }
	}
  end,

  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play then
      local first_ace = nil
      for i = 1, #context.scoring_hand do
        if context.scoring_hand[i]:get_id() == 14 then 
          first_ace = context.scoring_hand[i]
          break
        end
      end

      if context.other_card == first_ace then
        return {
          xmult = card.ability.extra.Xmult,
          colour = G.C.MULT
        }
      end
    end
  end
 }
SMODS.Joker({
    key = 'grindr',
    loc_txt = {
        name = 'Literally just Grindr',
        text = {
            "If the played hand is a {C:attention}pair{}",
            "and has 2{C:attention} Kings{} or 2{C:attention} Jacks{}, {X:mult,C:white}X#1#{} Mult",
            "{E:1,C:inactive}[They're boys and they're kissing]"
        }
    },
    rarity = 1,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 9, y = 0 },
    blueprint_compat = true,
    config = {
        extra = {
            Xmult = 3,  -- Multiplier for 2 Kings or 2 Jacks
            charge = 0,
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.Xmult }  -- Refer to multiplier correctly
        }
    end,

    calculate = function(self, card, context)
        -- Ensure extra values are set (for safety)
        if not card.ability.extra then
            card.ability.extra = { Xmult = 3 }
        end

        -- Check if the played hand contains a Pair
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            if context.scoring_name == "Pair" then
                local counts = { [11] = 0, [13] = 0 }  -- Jack = 11, King = 13

                -- Count Kings and Jacks in the scoring hand
                for _, scoring_card in ipairs(context.scoring_hand) do
                    local value = scoring_card:get_id()
                    if counts[value] ~= nil then
                        counts[value] = counts[value] + 1
                    end
                end

                -- Check if we have 2 Kings or 2 Jacks
                if counts[11] == 2 or counts[13] == 2 then
                    card.ability.extra.charge = (card.ability.extra.charge or 0) + 1
                    -- No multiplier is applied yet; we just confirm the condition
                    return
                end
            end
        end

        -- Now, apply the multiplier ONLY after all conditions are met
        if context.joker_main and card.ability.extra.charge >= 1 then
            -- Reset charge counter after activation
            card.ability.extra.charge = 0
            return {
                x_mult = card.ability.extra.Xmult,
                card = self
            }
        end
    end
})



SMODS.Joker({
    key = 'kit',
    loc_txt = {
        name = 'Kit Joker',
        text = {
            "After {C:attention}2{} rounds",
            "gives a {E:1}random {C:mult}Rare{} Joker",
            "and {C:mult}self destructs",
            "(Currently {C:attention}#1#{}/#2#)",
            "{S:0.5,C:inactive}[Make it yourself!]"
        }
    },
    rarity = 1,
    cost = 5,
    atlas = 'Jokers',
    pos = {x = 0, y = 1},
    blueprint_compat = true,
    config = {
        extra = {
            rounds = 0,  -- Track rounds
            max_rounds = 2,  -- The number of rounds before self-destruct
            joker_created = false,  -- Flag to track if a joker has been created
        }
    },
    
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.rounds,
                card.ability.extra.max_rounds,
            }
        }
    end,

    calculate = function(self, card, context)
        -- Reset rounds counter at the end of each round
        if context.end_of_round and not context.repetition and not context.individual then
            card.ability.extra.rounds = card.ability.extra.rounds + 1
        end

        -- Track the rounds progress and trigger joker creation
        if card.ability.extra.rounds >= card.ability.extra.max_rounds and not card.ability.extra.joker_created then
            -- Summon a random Rare Joker when the condition is met
            G.E_MANAGER:add_event(Event({
                func = function()
                    if G.jokers then
                        -- Randomly decide if it's legendary or rare (0% chance legendary)
                        local is_legendary = math.random() < 0.0  -- 0% chance to be true (legendary)

                        -- Create the card: first `true` for legendary, `false` for rare
                        local created_card = create_card("Joker", G.jokers, is_legendary, 4, nil, nil, nil, "")

                        -- Add it to the deck and materialize
                        created_card:add_to_deck()
                        created_card:start_materialize()
                        G.jokers:emplace(created_card)

                        return true
                    end
                end,
            }))
            
            -- Mark joker as created to avoid triggering it again
            card.ability.extra.joker_created = true
			--trigger self-destruction
            card:start_dissolve()
        end
    end,
})

SMODS.Joker {
    key = 'nana',
    loc_txt = {
        name = '{s:1.5}Big michel',
        text = {
            "{C:mult}+#1#{} Mult {C:attention}-2{} Joker slots"
        }
    },
    rarity = 1,
    display_size = { w = 2.1 * 71, h = 2.1 * 95 },
    cost = 5,
    atlas = 'Jokersba',
    pos = { x = 0, y = 0 },
    blueprint_compat = true,

    config = {
        extra = {
            mult = 100,
        },
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.mult
            }
        }
    end,

    add_to_deck = function()
        if G.jokers and G.jokers.config.card_limit then
            G.jokers.config.card_limit = G.jokers.config.card_limit - 2
        end
    end,

    remove_from_deck = function()
        if G.jokers and G.jokers.config.card_limit then
            G.jokers.config.card_limit = G.jokers.config.card_limit + 2
        end
    end,

    calculate = function(self, card, context)
        if context.blueprint then return end

        if context.joker_main then
        return {
                mult = card.ability.extra.mult,
            }
        end
    end
}

SMODS.Joker({
    key = 'jokerinp',
    loc_txt = {
        name = 'Joke in a Box',
        text = {
            "Sell {C:attention}#2# Jokers{} to get a higher rarity Joker",
            "{C:inactive}(Cannot make legendaries ,sorry){}",
            
        }
    },
    rarity = 1,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 1, y = 1 },
    blueprint_compat = true,

    config = {
        extra = {
            sold_count = 0,
            target_sold = 2,
            rarity_value = 0,
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.sold_count,
                card.ability.extra.target_sold,
            }
        }
    end,

    calculate = function(self, card, context)
        -- Ensure the card being sold has a valid rarity before proceeding
        if context.selling_card and context.card ~= card and context.card.config.center.rarity then
            local card_rarity = context.card.config.center.rarity
            
            -- Only proceed if the card has a valid rarity
            if card_rarity then
                card.ability.extra.sold_count = card.ability.extra.sold_count + 1
                card.ability.extra.rarity_value = card.ability.extra.rarity_value + card_rarity
                -- Cap the rarity at 3 (rare)
                if card.ability.extra.rarity_value > 3 then
                    card.ability.extra.rarity_value = 3
                end

                if card.ability.extra.sold_count >= card.ability.extra.target_sold then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local rarity_val = card.ability.extra.rarity_value
                            local created_card

                            if rarity_val == 4 then
                                created_card = create_card("Joker", G.jokers, true, 4)
                            elseif rarity_val == 3 then
                                created_card = create_card("Joker", G.jokers, false, 4)
                            elseif rarity_val == 2 then
                                created_card = create_card("Joker", G.jokers, nil, 0.9, nil, nil, nil, 'uta')
                            else
                                created_card = create_card('Joker', G.jokers, nil, 0, nil, nil, nil, 'rif')
                            end

                            created_card:add_to_deck()
                            created_card:start_materialize()
                            G.jokers:emplace(created_card)

                            card:start_dissolve()
                            return true
                        end
                    }))
                end
            end
        end
    end,
})
	
SMODS.Joker {
    key = 'birth_certificate',
    loc_txt = {
        name = 'Birth Certificate',
        text = {
            "Scoring a {C:attention}King{} and {C:attention}Queen",
            "adds 1 {C:attention}Jack{} to your draw",
            "pile that inherits a suit",
            "{C:green}#1# in #2#{} chance for twins",
			"{C:inactive}Congratulation"
        }
    },
    atlas = 'Jokers',
    pos = { x = 3, y = 1 },
    config = { extra = { twins_chance = 4 } },
    rarity = 1,
    cost = 6,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return {vars = {(G.GAME and G.GAME.probabilities.normal or 1), card.ability.extra.twins_chance}}
    end,
    calculate = function(self, card, context)
        if context.after then
            local king = 0
            local queen = 0
            local king_suits = {}
            local queen_suits = {}
            for i, v in ipairs(context.scoring_hand) do
                if context.scoring_hand[i]:get_id() == 13 then
                    king = king + 1
                    table.insert(king_suits, context.scoring_hand[i].base.suit)
                elseif context.scoring_hand[i]:get_id() == 12 then
                    queen = queen + 1
                    table.insert(queen_suits, context.scoring_hand[i].base.suit)
                end
            end
            for i = 1, king do
                if queen > 0 then
                    queen = queen - 1
                    local twins = 1
                    if pseudorandom('birth_twins') < G.GAME.probabilities.normal / card.ability.extra.twins_chance then
                        twins = 2
                    end
                    for j = 1, twins do
                        local _card = create_playing_card({
                            front = G.P_CARDS['S_J'],
                            center = G.P_CENTERS.c_base
                        }, G.discard, true, nil, { G.C.SECONDARY_SET.Enhanced }, true)
                        local _suits = { king_suits[i], queen_suits[i] }
                        _card:change_suit(pseudorandom_element(_suits, pseudoseed('birth_cert')))
                        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                card:juice_up()
                                G.deck:emplace(_card)
                                G.deck.config.card_limit = G.deck.config.card_limit + 1
                                return true
                            end
                        }))
                        playing_card_joker_effects({ _card })
                    end
                    if twins > 1 then
                        card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'Twins!', colour = G.C.FILTER })
                    else
                        card_eval_status_text(card, 'extra', nil, nil, nil, { message = '+1 Jack', colour = G.C.FILTER })
                    end
                end
            end
        end
    end

}
--binary joker functions
function Card:get_id()
    -- Check if this card is a Stone card (hidden identity)
    if self.config and self.config.center == G.P_CENTERS.m_stone then
        return -math.random(100, 1000000)
    end
	
    -- Check if the 'Binary Joker' is present
    local bin_card = next(SMODS.find_card('j_punch_bin'))

    -- If not present, return the normal ID
    if not bin_card then
        return self.base.id
    end

    -- If 'Binary Joker' is present, force 2 and 10 to be treated as the same 
    if self.base.id == 2 or self.base.id == 10 then
        return 10 and 2
    end

    -- Default return
    return self.base.id
end


-- Define the Joker with its properties
SMODS.Joker {
    key = 'bin',
    loc_txt = {
        name = '01101010 01101111 01101011 01100101 01110010',  -- Binary name
        text = {
            "{X:punch_code_backg,C:punch_code_text}2s{}{X:punch_code_backg,C:punch_code_text}and{X:punch_code_backg,C:punch_code_text}10s{}{X:punch_code_backg,C:punch_code_text}are{X:punch_code_backg,C:punch_code_text}considered{X:punch_code_backg,C:punch_code_text}the{X:punch_code_backg,C:punch_code_text}same{X:punch_code_backg,C:punch_code_text}rank"
        }
    },
    rarity = 1,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 3, y = 2 },
    blueprint_compat = true
}

SMODS.Joker({
    key = 'calli',
    loc_txt = {
        name = 'Calligram Joker',
        text = {
            "{C:mult}+#6#{} Mult per {C:attention}#1#, #2#, #3#, #4#{} scored",
            "If played hand contains all the rank shown ",
			"this joker gains {C:mult}+#5#{} Mult",
            "Changes every hand",
        }
    },
    rarity = 1,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 4, y = 0 },
    blueprint_compat = true,

    config = {
        extra = (function()
            local pool = {}
            for i = 2, 14 do table.insert(pool, i) end
            for i = #pool, 2, -1 do
                local j = math.random(1, i)
                pool[i], pool[j] = pool[j], pool[i]
            end
            local values = {pool[1], pool[2], pool[3], pool[4]}
            table.sort(values)
            return {
                value1 = values[1],
                value2 = values[2],
                value3 = values[3],
                value4 = values[4],
                mult_add = 2,
                mult = 5,
            }
        end)()
    },

    loc_vars = function(self, info_queue, card)
        local function display_value(v)
            return ({[11] = 'J', [12] = 'Q', [13] = 'K', [14] = 'A'})[v] or tostring(v)
        end
        return {
            vars = {
                display_value(card.ability.extra.value1),
                display_value(card.ability.extra.value2),
                display_value(card.ability.extra.value3),
                display_value(card.ability.extra.value4),
                card.ability.extra.mult_add,
                card.ability.extra.mult
            }
        }
    end,

    calculate = function(self, card, context)
        -- Reroll values every hand
        if context.final_scoring_step then
            local pool = {}
            for i = 2, 14 do table.insert(pool, i) end
            for i = #pool, 2, -1 do
                local j = math.random(1, i)
                pool[i], pool[j] = pool[j], pool[i]
            end
            local values = {pool[1], pool[2], pool[3], pool[4]}
            table.sort(values)
            card.ability.extra.value1 = values[1]
            card.ability.extra.value2 = values[2]
            card.ability.extra.value3 = values[3]
            card.ability.extra.value4 = values[4]
        end

        local target_values = {
            [card.ability.extra.value1] = true,
            [card.ability.extra.value2] = true,
            [card.ability.extra.value3] = true,
            [card.ability.extra.value4] = true
        }

        -- If hand contains all 4 required values, increase base mult
        if context.joker_main and context.scoring_hand then
            local found = {}
            for _, c in ipairs(context.scoring_hand) do
                found[c:get_id()] = true
            end

            local all_found = true
            for _, v in ipairs({card.ability.extra.value1, card.ability.extra.value2, card.ability.extra.value3, card.ability.extra.value4}) do
                if not found[v] then
                    all_found = false
                    break
                end
            end

            if all_found then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_add
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.Mult,
                    card = card
                }
            end
        end

        -- Give mult per matching scoring card
        if context.individual and context.cardarea == G.play then
            if target_values[context.other_card:get_id()] then
                return {
                    mult = card.ability.extra.mult,
                    card = card
                }
            end
        end
    end
})

SMODS.Joker({
    key = 'shadow',
    loc_txt = {
        name = 'Shadow Puppet Joker',
        text = {
            "{X:punch_light}When{C:punch_dark,X:punch_light}joker{C:punch_dark,X:punch_light}is{C:punch_dark,X:punch_light}sold{C:punch_dark,X:punch_light}during",
            "{X:punch_light}a{X:punch_light}round{X:punch_light}gain{X:punch_light}+#1#{X:punch_light}hand",
            "{X:punch_light}[Resets{X:punch_light}every{X:punch_light}boss{X:punch_light}blind]",
        }
    },
    rarity = 1,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 5, y = 0 },
    blueprint_compat = true,

    config = {
        extra = {
            hands = 1,
			charge = 0,
			added = 0,
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.hands, card.ability.extra.added, card.ability.extra.charge }
        }
    end,
	
	remove_from_deck = function(self, card)
        local e = card.ability.extra
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - e.added
        ease_hands_played(-e.added)
    end,

    calculate = function(self, card, context)
	
		if context.end_of_round and context.main_eval and not context.blueprint then
			card.ability.extra.charge = 0
		end
		
		if context.setting_blind then
			card.ability.extra.charge = 1
		end
		
		if G.GAME.blind and G.GAME.blind.name and card.ability.extra.charge == 1 then
			if context.selling_card and context.card ~= card and context.card.config.center.rarity then
				G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.extra.hands
				ease_hands_played(card.ability.extra.hands)
			card.ability.extra.added = card.ability.extra.added + card.ability.extra.hands
			end
		end
		if context.end_of_round and context.main_eval and not context.blueprint then
            -- Check if it's a boss blind
            if G.GAME.blind and G.GAME.blind.boss then
                -- Reset on boss blind
				G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.added
				ease_hands_played(-card.ability.extra.added)
                card.ability.extra.added = 0
                return {
                    message = localize('k_reset'),
                    card = card
                }
			end
		end
    end
})


SMODS.Joker {
    key = '253',
    loc_txt = {
        name = 'Joker 253',
        text = {
            "Randomize each {C:attention}unscored card"
        }
    },
    rarity = 1,
    atlas = "Jokers", pos = {x = 0, y = 5},
    cost = 5,
    unlocked = true,
    discovered = false,
    eternal_compat = true,
    blueprint_compat = true,
    perishable_compat = false,
    config = {extra = {mult_add = 1, mult = 0}},

    loc_vars = function(self, info_queue, card)
        return {vars = {card.ability.extra.mult_add, card.ability.extra.mult}}
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before and not context.blueprint then 
            local scoringSet = {}
            for _, played_card in ipairs(context.scoring_hand or {}) do
                scoringSet[played_card] = true
            end

            local unscoredCards = {}
            for _, thisCard in ipairs(context.full_hand or {}) do
                if not scoringSet[thisCard] then
                    table.insert(unscoredCards, thisCard)
                end
            end

            if #unscoredCards > 0 then
                for _, c in ipairs(unscoredCards) do
					
					if math.random() <= 0.9 then
						local suits = {"Hearts", "Diamonds", "Clubs", "Spades"}
						local new_suit = suits[math.random(#suits)]
                        SMODS.change_base(c, new_suit)
					end
					
					if math.random() <= 0.7 then
						local face_ranks = {"2", "3", "4", "5", "6", "7", "8", "9", "T","J", "Q", "K", "A"} -- Possible cards
                        local selected_face = face_ranks[math.random(#face_ranks)] -- Randomly select a card

                        -- Change card to the selected card of its current suit
                        local suit_prefix = string.sub(c.base.suit, 1, 1)..'_'
                        c:set_base(G.P_CARDS[suit_prefix..selected_face])
					end
					
					if math.random() <= 0.5 then
                        c:set_ability(G.P_CENTERS[SMODS.poll_enhancement({key = 'junk', guaranteed = true})], true)
                    end

                    if math.random() <= 0.3 then
                        c:set_edition(poll_edition('junk_edition', 1, true, true), true)
                    end

                    if math.random() <= 0.2 then
                        c:set_seal(SMODS.poll_seal({key = 'junk', guaranteed = true}), true)
                    end
					
                end


                return {
                    message = "Randomized!",
                    colour = G.C.Lucky,
                    card = card
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'media',
    loc_txt = {
        name = 'Missing Media Joker',
        text = {
            "Earn {C:money}$#1#{} for each {C:attention}unscoring{} Joker and Card",
        }
    },
    rarity = 2,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 9, y = 4 },
    config = {
        extra = {
            money = 1,
        },
    },
    blueprint_compat = true,

    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.money, card.ability.extra.cards_triggered }
        }
    end,

    calculate = function(self, card, context)
    -- Track unscored cards individually
    if context.individual and context.cardarea == "unscored" then
        return {
            dollars = card.ability.extra.money
        }
    end

    -- At start of scoring: reset trigger tracking
    if context.before then
        for _, j in ipairs(G.jokers.cards) do
            if j.ability then
                j.ability.extra = j.ability.extra or {}
                j.ability.extra._media_triggered = false
            end
        end
    end

    -- Mark jokers as triggered (excluding self)
    if context.post_trigger and context.other_joker and context.other_joker ~= card then
        if context.other_joker.ability then
            context.other_joker.ability.extra = context.other_joker.ability.extra or {}
            context.other_joker.ability.extra._media_triggered = true
        end
    end

    -- After scoring: grant money for each untriggered joker (excluding self)
    if context.after then
        for _, j in ipairs(G.jokers.cards) do
            if j ~= card and j.ability and not j.ability.eternal then
                j.ability.extra = j.ability.extra or {}
                if not j.ability.extra._media_triggered then
                    ease_dollars(card.ability.extra.money)
                end
            end
        end
    end
end,
}



SMODS.Joker{
    key = 'miss',
    loc_txt = {
        name = 'Misspled',
        text = {
            ""
        }
    },
    rarity = 1,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 8, y = 0 },
    blueprint_compat = true,
    config = { extra = { chips = 0, Xchips = 1, mode = "flat", text = "aaaaa" } },

    loc_vars = function(self, info_queue, card)
        local operators = {"+", "-", "/", "%", "X", "^"}
        local num = tostring(math.random(0, 69))
        local op = operators[math.random(#operators)]
        local rand_string = op .. num

        local dynatext_obj = DynaText({
            string = {
                {string = '+ 0 rand()', colour = G.C.JOKER_GREY},
                {string = "#@"..(G.deck and G.deck.cards[1] and G.deck.cards[#G.deck.cards].base.id or 11)..(G.deck and G.deck.cards[1] and G.deck.cards[#G.deck.cards].base.suit:sub(1,1) or 'D'), colour = G.C.RED},
                {string = 'aaaaaaa', colour = G.C.SECONDARY_SET.Tarot},
				{string = 'help me.....', colour = G.C.MULT},
				{string = 'X2 Chips', colour = G.C.CHIPS},
				{string = 'X2 Chops', colour = G.C.CHIPS},
				{string = '+ 0 Chips lol', colour = G.C.CHIPS},
				{string = '+ 1 Ships', colour = G.C.CHIPS},
				{string = '+ 2 Trips', colour = G.C.CHIPS},
				{string = '+ 3 Slips', colour = G.C.CHIPS},
				{string = '+14 Drips', colour = G.C.CHIPS},
				{string = '+15 Flips', colour = G.C.CHIPS},
				{string = '+16 Grips', colour = G.C.CHIPS},
                {string = '+01 Chips i hope', colour = G.C.CHIPS},
                {string = '+02 Chips?', colour = G.C.CHIPS},
                {string = '+03 Chips', colour = G.C.CHIPS},
                {string = '+04 Cbips', colour = G.C.CHIPS},
                {string = '+ 5 Chips', colour = G.C.CHIPS},
                {string = '+ 6 Chisp', colour = G.C.CHIPS},
                {string = '+ 7 Chips', colour = G.C.CHIPS},
                {string = '+ 8 Chisn', colour = G.C.CHIPS},
                {string = '+ 9 Chips', colour = G.C.CHIPS},
                {string = '+10 Chips', colour = G.C.CHIPS},
                {string = '+11 Ch1ps', colour = G.C.CHIPS},
                {string = '+12 Chpis', colour = G.C.CHIPS},
                {string = '+13 Phips', colour = G.C.CHIPS},
                {string = '+14 Chips', colour = G.C.CHIPS},
                {string = '+15 Chips', colour = G.C.CHIPS},
                {string = '+16 Shies', colour = G.C.CHIPS},
                {string = '+17 Chips', colour = G.C.CHIPS},
                {string = '+18 Chtps', colour = G.C.CHIPS},
                {string = '+19 Chips', colour = G.C.CHIPS},
                {string = '+20 Cmips', colour = G.C.CHIPS},
                {string = '+21 Chips', colour = G.C.CHIPS},
                {string = '+22 Chips', colour = G.C.CHIPS},
                {string = '+23 Khips', colour = G.C.CHIPS},
                {string = '+24 Chips', colour = G.C.CHIPS},
                {string = '+25 Mpips', colour = G.C.CHIPS},
                {string = '+26 Chips', colour = G.C.CHIPS},
                {string = '+27 Chios', colour = G.C.CHIPS},
                {string = '+28 Chips', colour = G.C.CHIPS},
                {string = '+29 Chass', colour = G.C.CHIPS},
                {string = '+38 Chips', colour = G.C.CHIPS},
                {string = '+39 Chlps', colour = G.C.CHIPS},
                {string = '+40 Chips', colour = G.C.CHIPS},
                {string = '+41 Caips', colour = G.C.CHIPS},
                {string = '+42 Chini', colour = G.C.CHIPS},
                {string = '+43 Chip5', colour = G.C.CHIPS},
                {string = '+44 Chip6', colour = G.C.CHIPS},
                {string = '+45 Qhips', colour = G.C.CHIPS},
                {string = '+46 Chips.', colour = G.C.CHIPS},
                {string = '+47 Ahijs', colour = G.C.CHIPS},
                {string = '+48 Chips', colour = G.C.CHIPS},
                {string = '+49 Cwsps', colour = G.C.CHIPS},
                {string = '+50 Chipz', colour = G.C.CHIPS},
                {string = '+51 Chips', colour = G.C.CHIPS},
                {string = '+52 Chips', colour = G.C.CHIPS},
                {string = '+62 Chips', colour = G.C.CHIPS},
                {string = '+63 Chips', colour = G.C.CHIPS},
                {string = '+64 Chips', colour = G.C.CHIPS},
                {string = '+65 Chips', colour = G.C.CHIPS},
                {string = '+66 Chaos', colour = G.C.CHIPS},
                {string = '+67 Chips', colour = G.C.CHIPS},
                {string = '+68 Chips', colour = G.C.CHIPS},
                {string = '+69 Chips eheh', colour = G.C.CHIPS},
            },
            colours = {G.C.UI.TEXT_DARK},
            pop_in_rate = 511,
            silent = true,
			random_element = true,
            pop_delay = 0.7,
            scale = 0.32,
            min_cycle_time = 0
        })

        return { main_start = {{n=G.UIT.O, config={object = dynatext_obj}}} }
    end,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            local is_x2 = pseudorandom('misspled_roll', 1, 8) == 1
            if is_x2 then
                card.ability.extra.mode = "xchips"
                card.ability.extra.Xchips = 2
                card.ability.extra.chips = 0
            else
                card.ability.extra.mode = "flat"
                card.ability.extra.chips = pseudorandom('misspled_val', 0, 69)
                card.ability.extra.Xchips = 1
            end
        end
        if context.joker_main then
            if card.ability.extra.mode == "xchips" then
                return {
                    x_chips = card.ability.extra.Xchips,
                    card = card,
                }
            else
                return {
                    chips = card.ability.extra.chips,
                    card = card,
                }
            end
        end
    end,
}

SMODS.Joker {
    key = 'vanitas',
    loc_txt = {
        name = 'Vanitas',
        text = {
            "Gains {C:mult}+#2# Mult{} for every sold consumable",
            "and {C:mult}+#3# Mult{} for card {C:mult}destroyed",
            "{C:inactive}[Currently{} {C:mult}+#1#{}{C:inactive}]",
			"{C:inactive}Memento mori",
        }
    },
    rarity = 2,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 2, y = 1 },
    blueprint_compat = true,
    config = {
        extra = { mult = 0, multmod = 2, multmod2 = 4 }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.mult,
                card.ability.extra.multmod,
                card.ability.extra.multmod2
            }
        }
    end,

    calculate = function(self, card, context)
        -- Helper function to update the multiplier
        local function update_multiplier(card, multiplier)
            card.ability.extra.mult = card.ability.extra.mult + multiplier
            G.E_MANAGER:add_event(Event({
                func = function()
                    card_eval_status_text(
                        card,
                        "extra",
                        nil,
                        nil,
                        nil,
                        {
                            message = localize('k_upgrade_ex'),
                            colour = G.C.Mult,
                            card = card
                        }
                    )
                    return true
                end,
            }))
        end

        -- If any consumable is sold, increase multiplier
        if (context.selling_card and context.card ~= card and not context.card.config.center.rarity) then
            update_multiplier(card, card.ability.extra.multmod)
            return
        end

        -- If cards are destroyed, add multiplier
        if context.remove_playing_cards then
            for _, pcard in ipairs(context.removed) do
                update_multiplier(card, card.ability.extra.multmod2)
            end
        end

        -- When joker is the main joker, return multiplier info (unchanged)
        if context.joker_main then
        return {
                mult = card.ability.extra.mult,
            }
        end
    end
}


-- roseta stone functions
function Card:is_suit(suit, bypass_debuff, flush_calc)

	-- Check if this card is a Stone card (hidden identity)
    if self.config and self.config.center == G.P_CENTERS.m_stone then
        self.base.suit = nil
    end
	
    -- Check if the 'j_punch_stone' card is present
    local stone_card = next(SMODS.find_card('j_punch_stone'))

    -- If 'stone_card' is not found, perform the normal is_suit behavior
    if not stone_card then
        -- Fallback to default suit check here, if issuitref is unavailable
        if self.base.suit == suit then
            return true
        end
        return false
    end

    -- If 'stone_card' is found, modify suit behavior for Spades and Diamonds
    if stone_card then
        if flush_calc then
            if (self.base.suit == 'Diamonds' or self.base.suit == 'Spades') == (suit == 'Diamonds' or suit == 'Spades') then
                return true
            end
            -- Assuming flush_calc condition requires normal suit check
            if self.base.suit == suit then
                return true
            end
            return false
        else
            if self.debuff and not bypass_debuff then return end
            if (self.base.suit == 'Diamonds' or self.base.suit == 'Spades') == (suit == 'Diamonds' or suit == 'Spades') then
                return true
            end
            -- Fallback suit check if no Joker effect
            if self.base.suit == suit then
                return true
            end
            return false
        end
    end
end


-- Define the Joker with its properties
SMODS.Joker {
    key = 'stone',
    loc_txt = {
        name = 'Roseta Stone',
        text = {
            "All {C:spades}Spades{} and {C:diamonds}Diamonds{} cards",
            "are considered the same suit"
        }
    },
    rarity = 2,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 4, y = 1 },
    blueprint_compat = true
}


SMODS.Joker {
    key = 'painter',
    loc_txt = {
        name = 'Painter',
        text = {
            "Gains a random {C:dark_edition}Edition{} each round,",
            "its effect is doubled if it has one",
            "{C:green}#3# in #2#{} chance to gain {C:white,X:black}Negative{}",
            "which grants {C:chips}+1{} Joker slot permanently",
        }
    },
    rarity = 2,
    cost = 6,
    atlas = 'Jokers',
    pos = { x = 5, y = 1 },
    blueprint_compat = true,
    config = {
        extra = {
            odds = 16, -- 1 in 16 chance for negative
            edition = nil -- store the selected edition here
        }
    },
    
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.edition,
                card.ability.extra.odds,
                '' .. (G.GAME and G.GAME.probabilities.normal or 1),
                card.ability.extra.multmod
            }
        }
    end,
    
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local got_negative = false

            -- Check for negative edition
            if pseudorandom('painter_negative') < G.GAME.probabilities.normal/card.ability.extra.odds then
                card:set_edition({ negative = true }, true)
                G.jokers.config.card_limit = G.jokers.config.card_limit + 1
				got_negative = true
            end

            -- Select a random edition if no negative
            if not got_negative then
                local random_edition = poll_edition(nil, nil, false, true)
                if random_edition then
                    -- Store the selected edition in extra
                    card.ability.extra.edition = random_edition

                    card:set_edition(random_edition, true)

                    G.E_MANAGER:add_event(Event({
                        func = function()
                            card:juice_up(0.5, 0.4)
                            return true
                        end
                    }))
                end
            end
        end

        -- If context.joker_main, check the selected edition and apply effects
        if context.joker_main and card.ability.extra.edition == 'e_foil' then
            -- Apply special effects if 'foil' edition is selected
            return {
                chips = 50,
            }
        end
        if context.joker_main and card.ability.extra.edition == 'e_holo' then
            -- Apply special effects if 'holo' edition is selected
            return {
                mult = 10,
            }
        end
        if context.joker_main and card.ability.extra.edition == 'e_polychrome' then
            -- Apply special effects if 'polychrome' edition is selected
            return {
                x_mult = 1.5,
            }
        end
		if context.joker_main and card.ability.extra.edition == 'e_ortalab_anaglyphic' then
            -- Apply special effects if 'anaglyphic' edition is selected
            return {
                chips = 20,
				mult = 6,
            }
        end
		if context.cardarea == G.jokers and context.end_of_round and card.ability.extra.edition == 'e_ortalab_fluorescent' then
            -- Apply special effects if 'fluorescent' edition is selected
            return {
                dollars = 4,
            }
        end
		if context.joker_main and card.ability.extra.edition == 'e_cry_mosaic' then
            -- Apply special effects if 'mosaic' edition is selected
            return {
                x_chips = 2.5,
            }
        end
		if context.joker_main and card.ability.extra.edition == 'e_cry_glass' then
            -- Apply special effects if 'fragile' edition is selected
            return {
                x_mult = 3,
            }
        end
		if context.joker_main and card.ability.extra.edition == 'e_cry_gold' then
            -- Apply special effects if 'gold' edition is selected
            return {
                dollars = 2,
            }
        end
		if context.joker_main and card.ability.extra.edition == 'e_cry_astral' then
            -- Apply special effects if 'fragile' edition is selected
            return {
                e_mult = 1.1,
            }
        end
		if context.joker_main and card.ability.extra.edition == 'e_cry_noisy' then
            -- Apply special effects if 'noisy' edition is selected
            return {
                mult = math.random(0, 30),
				chips = math.random(0, 150)
            }
        end
		if context.joker_main and card.ability.extra.edition == 'e_cry_m' then
            -- Apply special effects if 'jolly' edition is selected
            return {
                mult = 8
            }
        end
    end
}
SMODS.Joker {
    key = 'Tamale',
    loc_txt = {
        name = 'Tamale',
        text = {
            "Earn {C:money}$#1#{} at the end of round for every two {C:attention}2's{} in the deck",
            "Amount increases after beating a boss blind"
        }
    },
    rarity = 2,
    cost = 6,
    atlas = 'Jokers',
    pos = { x = 4, y = 3 },
    blueprint_compat = true,
    config = {
        extra = {
            money = 2
        }
    },
	
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money or 1 } }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual then
            -- Count the number of 2s in deck (includes hand, deck, discard, etc.)
            local count_twos = 0
            for _, c in ipairs(G.playing_cards) do
                if c:get_id() == 2 then
                    count_twos = count_twos + 1
                end
            end

            local reward = math.floor(count_twos / 2) * (card.ability.extra.money or 1)
            if reward > 0 then
                ease_dollars(reward)
            end
        end

        if context.end_of_round and context.main_eval and not context.blueprint then
            -- If this was a boss blind, increase money value
            if G.GAME.blind and G.GAME.blind.boss then
                card.ability.extra.money = (card.ability.extra.money or 1) + 1
            end
        end
    end
}

SMODS.Atlas{
    key = 'lag', 
    path = 'lag.png', 
    px = 71, 
    py = 95 
	}
	
SMODS.Joker({
    key = 'lag',
    loc_txt = {
        name = 'Lag',
        text = {
            "{C:green}#2# in #1#{} chance to retrigger a random card {C:attention}1-2{} times",
        }
    },
    rarity = 2,
    cost = 8,
    atlas = 'lag',
    pos = { x = 0, y = 0 },
    blueprint_compat = true,
    config = {
        extra = {
            odds = 4,          -- odds
            repetitions = 1,   -- retriggers if roll fails
			selected = 0,
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.odds,
                G.GAME.probabilities.normal,
                card.ability.extra.selected,
            }
        }
    end,

    calculate = function(self, card, context)

        -- Select two distinct scoring cards to potentially retrigger if roll fails
        if (context.cardarea == G.jokers and context.before and not context.blueprint) then
            local sel_card = #context.scoring_hand
            if sel_card >= 1 then
                card.ability.extra.selected = math.random(1, sel_card)
            end
        end

        -- Retrigger selected scoring cards if roll succeeded
        if context.repetition and context.cardarea == G.play and pseudorandom('im lagging!!!') < (G.GAME.probabilities.normal / card.ability.extra.odds) then
            if context.other_card == context.scoring_hand[card.ability.extra.selected] then
                return { repetitions = math.random(1,2) }
            end
        end
    end,
})


-- Timer and Game:update override for animation logic
local upd = Game.update
punch_lag_dt = 0

function Game:update(dt)
    upd(self, dt)
    punch_lag_dt = punch_lag_dt + dt

    if G.P_CENTERS and G.P_CENTERS.j_punch_lag and punch_lag_dt > 0.1 then
        punch_lag_dt = 0
        local obj = G.P_CENTERS.j_punch_lag

        -- Simple animation: increment x, reset after hitting 20
        if obj.pos.x <= 6 then
            obj.pos.x = obj.pos.x + 1
        else
            obj.pos.x = 0
        end
    end
end
SMODS.Atlas{
    key = 'plinko', 
    path = 'plinko.png', 
    px = 71, 
    py = 95 
	}
	
SMODS.Joker {
    key = 'plinko',
    loc_txt = {
        name = 'Plinko',
		text = {
            "If this can take {C:money}$2{}",
			"Roll for either {X:mult,C:white}X3{}, {X:mult,C:white}X2{}, {X:mult,C:white}X1.5{}, {C:mult}+50{}, {C:mult}+30{}",
			"Else roll for {C:chips}+30{}, {C:mult}+10{}",
        }
    },
    rarity = 2,
    cost = 7,
    atlas = 'plinko',
    pos = { x = 0, y = 0 },
    blueprint_compat = true,

    config = {
        extra = {
            roll = 0,
            xmult = 0,
			dollars = 0,
        }
    },

    calculate = function(self, card, context)
        if context.joker_main then
            local roll = math.random(1, 69)
            card.ability.extra.roll = roll
			
            if to_big(G.GAME.dollars) > to_big(card.ability.extra.dollars) then
                ease_dollars(-2)
				
				--lets go gambling!!!
				
				if card.ability.extra.roll <= 5 then
					return { x_mult = 3 }
				end
				
				if card.ability.extra.roll >= 6 and card.ability.extra.roll <= 13 then
					return { x_mult = 2 }
				end
				
				if card.ability.extra.roll >= 14 and card.ability.extra.roll <= 25 then
					return { x_mult = 1.5 }
				end
				
				if card.ability.extra.roll >= 26 and card.ability.extra.roll <= 45 then
					return { mult = 50 }
				end
				
				if card.ability.extra.roll >= 46 and card.ability.extra.roll <= 69 then
					return { mult = 30 }
				end
				
            end
			
			if to_big(G.GAME.dollars) <= to_big(card.ability.extra.dollars) then
				if roll > 40 then
					return { chips = 30 }
				else
					return { mult = 10 }
				end
			end
        end
    end
}


-- Timer and Game:update override for animation logic
local upd = Game.update
punch_plinko_dt = 0

function Game:update(dt)
    upd(self, dt)
    punch_plinko_dt = punch_plinko_dt + dt

    if G.P_CENTERS and G.P_CENTERS.j_punch_plinko and punch_plinko_dt > 0.1 then
        punch_plinko_dt = 0
        local obj = G.P_CENTERS.j_punch_plinko

        -- Simple animation: increment x, reset after hitting 20
        if obj.pos.x <= 31 then
            obj.pos.x = obj.pos.x + 1
        else
            obj.pos.x = 0
        end
    end
end
SMODS.Joker {
    key = 'carri',
    loc_txt = {
        ['en-us'] = {
            name = 'Carricature Joker',
            text = {
                "A random played card permanently gains {C:chips}+#1#{} Chips",
                "once per hand every hand"
            }
        }
    },
    atlas = 'Jokers',
    pos = { x = 7, y = 0 },
    config = {
        extra = {
            chip_bonus = 60, -- chip bonus
            applied_this_hand = false,
            card_to_upgrade = nil, -- Store the card to upgrade
        }
    },
    rarity = 2,
    cost = 5,
    blueprint_compat = false,

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.chip_bonus
            }
        }
    end,

    calculate = function(self, card, context)
        -- Ensure extra values are set (for safety)
        if not card.ability.extra then
            card.ability.extra = { chip_bonus = 60 }
        end

        -- Phase before card is played: Select a random card to upgrade
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            if not self.config.extra.applied_this_hand and not self.config.extra.card_to_upgrade then
                -- Select a random card from the played hand
                local played_cards = G.play.cards
                if #played_cards > 0 then
                    local chosen = pseudorandom_element(played_cards)
                    self.config.extra.card_to_upgrade = chosen  -- Store the chosen card
                end
            end
        end

        -- Apply the bonus to the selected card when it is actually played (waiting for it)
        if context.individual and context.cardarea == G.play and self.config.extra.card_to_upgrade then
            local chosen = self.config.extra.card_to_upgrade

            -- Wait until the chosen card comes around to be played
            if context.other_card == chosen then
                -- Apply the chip bonus
                chosen.ability.perma_bonus = (chosen.ability.perma_bonus or 0) + self.config.extra.chip_bonus

                -- Mark the upgrade as applied
                self.config.extra.applied_this_hand = true
                self.config.extra.card_to_upgrade = nil  -- Reset the selected card

                return {
                    extra = { message = "Upgrade!", colour = G.C.CHIPS },
                    colour = G.C.CHIPS,
                    card = chosen
                }
            end
        end

        return nil  -- Return nothing if no upgrade is applicable yet
    end,

    update = function(self)
        -- Reset per hand logic at the beginning of each hand
        if G.STATE == G.STATES.DRAW_TO_HAND then
            self.config.extra.applied_this_hand = false
        end
    end
}

SMODS.Joker {
    key = 'liquid', 
    loc_txt = {
        name = 'Liquid Death',
        text = {
            "When {C:attention}small blind selected{}",
			"Gain {C:attention}2{} {C:dark_edition}Double Tags{} and {C:attention}-#1#{} {C:mult}Discards{}",
            "Expires in {C:attention}#2#{} boss blinds",
        }
    },
    rarity = 2,
    cost = 7,
    atlas = 'Jokers',
    pos = { x = 8, y = 4 },
    config = {
        extra = {
            discards = 4,     -- Count of discardeds
			og_discards = 0, -- Track how many discards you had before doing this
			blinds = 3, -- Blinds left until destruction
			skips = 0, -- Count of Skips
			tags = 0, -- Count tags recieved
        },
    },
    blueprint_compat = true,
    
    loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = G.P_TAGS.tag_double
        return {
            vars = { card.ability.extra.discards, card.ability.extra.blinds, card.ability.extra.og_discards, card.ability.extra.skips, card.ability.extra.tags  }  -- Refer to multiplier correctly
        }
    end,
	
	add_to_deck = function(self, card)
        card.ability.extra.og_discards = G.GAME.round_resets.discards
    end,
	
	remove_from_deck = function(self, card)
        G.GAME.round_resets.discards = card.ability.extra.og_discards
    end,
    
    calculate = function(self, card, context)
        -- Triggered when setting blind and no skips
        if context.setting_blind and card.ability.extra.skips == 0 and card.ability.extra.tags == 0 and not (context.blueprint_card or self).getting_sliced then
			G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.discards
			ease_discard(-card.ability.extra.discards)
			add_tag(Tag('tag_double'))
			add_tag(Tag('tag_double'))
			card.ability.extra.tags = card.ability.extra.tags + 1
		end
		
		-- Triggered when setting boss blind and 1 skips
        if context.setting_blind and G.GAME.blind and G.GAME.blind.boss and card.ability.extra.skips == 1 and not (context.blueprint_card or self).getting_sliced then
			G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.discards
			ease_discard(-card.ability.extra.discards)
		end
		
		-- Check after round starts if you have any skips and reset them
		if context.first_hand_drawn and card.ability.extra.skips >= 1 then
			card.ability.extra.skips = 0
		end
		
		--Check if skip
		if context.skip_blind then
			card.ability.extra.skips = card.ability.extra.skips + 1
			G.GAME.round_resets.discards = card.ability.extra.og_discards
		end
		
		-- Check if end of round
		if context.end_of_round and context.main_eval and not context.blueprint then
            -- If this was a boss blind decrease blinds left
            if G.GAME.blind and G.GAME.blind.boss then
				G.GAME.round_resets.discards = card.ability.extra.og_discards
				card.ability.extra.tags = 0
                card.ability.extra.blinds = card.ability.extra.blinds - 1
            end
        end
		
		-- Destroy if fully used
		if card.ability.extra.blinds == 0 then
			card:start_dissolve()
		end
    end,
}
SMODS.Joker {
    key = 'luck',
    loc_txt = {
        name = 'Luck Magnet',
        text = {
            "Makes the probability of the joker",
            "on the {C:attention}right{} {C:green}100%"
        }
    },
    rarity = 2,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 9, y = 3 },
    blueprint_compat = true,

    config = {
        extra = {
            _tracked_joker = nil,
            _tracked_value = nil,
            _was_odds = nil
        }
    },

    update = function(self, card)
        self:apply_luck(card)
    end,

    calculate = function(self, card, context)
        self:apply_luck(card)
    end,

    apply_luck = function(self, card)
        local tracked = card.ability.extra
        local right_joker = nil

        -- Find the Joker to the right of this one
        if G.jokers then
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then
                    right_joker = G.jokers.cards[i + 1]
                    break
                end
            end
        end

        -- Restore previous odds or extra if needed
        if tracked._tracked_joker and tracked._tracked_joker ~= right_joker then
            if tracked._was_odds and tracked._tracked_joker.ability and tracked._tracked_joker.ability.extra then
                tracked._tracked_joker.ability.extra.odds = tracked._tracked_value
            elseif tracked._tracked_joker.ability then
                tracked._tracked_joker.ability.extra = tracked._tracked_value
            end
            tracked._tracked_joker = nil
            tracked._tracked_value = nil
            tracked._was_odds = nil
        end

        -- Apply effect to new right joker
        if right_joker and right_joker.ability then
            local extra = right_joker.ability.extra
            if type(extra) == "table" then
                if extra.odds and extra.odds ~= 1 then
                    tracked._tracked_joker = right_joker
                    tracked._tracked_value = extra.odds
                    tracked._was_odds = true
                    extra.odds = 1
                end
            else
                if extra ~= 1 then
                    tracked._tracked_joker = right_joker
                    tracked._tracked_value = extra
                    tracked._was_odds = false
                    right_joker.ability.extra = 1
                end
            end
        end
    end
}
SMODS.Joker {
    key = 'pyrite', 
    loc_txt = {
        name = 'Pyrite',
        text = {
            "{C:attention}Steel{} cards in hand give an additional {X:mult,C:white}X#2#{} Mult",
            "{C:green}#3# in #4#{} chance to turn {C:money}Gold{}",
        }
    },
    rarity = 2,
    cost = 7,
    atlas = 'Jokers',
    pos = { x = 4, y = 5 },
    config = {
        extra = {
            Xmult = 1.8,
            Xmult_add = 0.8,
            odds = 17,
        },
    },
    blueprint_compat = true,

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_gold
        return {
            vars = {
                card.ability.extra.Xmult,
                card.ability.extra.Xmult_add,
                G.GAME.probabilities.normal,
                card.ability.extra.odds
            }
        }
    end,

    calculate = function(self, card, context)
        -- Apply mult to Steel cards during scoring
        if context.individual and context.cardarea == G.hand and not context.final_scoring_step and not context.end_of_round then
            if context.other_card and context.other_card.ability.name == 'Steel Card' then
                -- Try converting Steel to Gold first
                if pseudorandom('pyrite_gold') < G.GAME.probabilities.normal / card.ability.extra.odds then
                    context.other_card:set_ability(G.P_CENTERS.m_gold, nil, true)
                else
                    -- If not converted, apply the multiplier
                    return {
                        x_mult = card.ability.extra.Xmult,
                        card = card
                    }
                end
            end
        end
    end,
}
SMODS.Joker {
    key = 'rupert', 
    loc_txt = {
        name = 'Prince Rupert\'s',
        text = {
            "Played {C:attention}Glass{} cards give an additional {X:mult,C:white}X#1#{} Mult",
            "{C:attention}Glass{} cards are more likely to {C:mult}break{} when retriggering",
			"Gain {X:mult,C:white}X#2#{} Mult if a glass card breaks in this way",
        }
    },
    rarity = 2,
    cost = 7,
    atlas = 'Jokers',
    pos = { x = 7, y = 5 },
    config = {
        extra = {
            Xmult = 1,
            Xmult_add = 0.5,
            odds = 4,
        },
    },
    blueprint_compat = true,

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.Xmult,
                card.ability.extra.Xmult_add,
                G.GAME.probabilities.normal,
                card.ability.extra.odds
            }
        }
    end,

    calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play then
        if context.other_card and context.other_card.ability.name == 'Glass Card' then
            local glass_card = context.other_card
            local will_shatter = false
			

            if pseudorandom('rupert_break') < G.GAME.probabilities.normal / card.ability.extra.odds then
				card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_add
                will_shatter = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function()
                        if glass_card and not glass_card.debuffed and not glass_card.destroyed then
                            glass_card:shatter()
                        end
                        return true
                    end
                }))
            end

            return {
                x_mult = will_shatter and card.ability.extra.Xmult_add or card.ability.extra.Xmult,
                card = card
            }
        end
    end
end
}
SMODS.Atlas{
    key = 'jittery', 
    path = 'jittery.png', 
    px = 71, 
    py = 95 
	}
SMODS.Joker {
    key = 'jittery', -- Changed to match the lookup below
    loc_txt = {
        name = 'Jittery',
        text = {
            "Earn {C:money}$#1#{} for every {C:attention}6{} cards triggered this hand",
        }
    },
    rarity = 2,
    cost = 5,
    atlas = 'jittery',
    pos = { x = 0, y = 0 },
    config = {
        extra = {
            money = 5,
			cards_triggered = 0,
        },
    },
    blueprint_compat = true,
    
    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.money, card.ability.extra.cards_triggered }
        }
    end,

    calculate = function(self, card, context)

        -- count triggered cards
        if context.individual and context.cardarea == G.play then
			card.ability.extra.cards_triggered = card.ability.extra.cards_triggered + 1
        end
		
		-- if not 6 simply reset
		if card.ability.extra.cards_triggered < 6 and context.final_scoring_step then
			card.ability.extra.cards_triggered = 0
		end
		
        -- if 6 or more then give money and reset
        if card.ability.extra.cards_triggered >= 6 and context.final_scoring_step then
			local reward = math.floor(card.ability.extra.cards_triggered / 6)
			card.ability.extra.cards_triggered = 0
			return {
                dollars = card.ability.extra.money * reward,
            }
		end
    end,
}
	

-- Timer and Game:update override for animation logic
local upd = Game.update
punch_jittery_dt = 0

function Game:update(dt)
    upd(self, dt)
    punch_jittery_dt = punch_jittery_dt + dt

    if G.P_CENTERS and G.P_CENTERS.j_punch_jittery and punch_jittery_dt > 0.1 then ---lower=FASTER
        punch_jittery_dt = 0
        local obj = G.P_CENTERS.j_punch_jittery

        -- Simple animation: increment x, reset after hitting 20
        if obj.pos.x <= 2 then
            obj.pos.x = obj.pos.x + 1
        else
            obj.pos.x = 0
        end
    end
end
--[[
SMODS.Joker {
    key = 'dust',
    loc_txt = {
        name = 'Dust Joker',
        text = {
            "{C:mult}Destroy{} the {C:attention}First card{} of the {C:attention}First Hand{}",
            "and adds the values to this card",
			"Currently {X:mult,C:white}X#1#{} Mult {C:mult}+#2#{} Mult {X:chips,C:white}X#3#{} Chips {C:chips}+#4#{} Chips "
			
        }
    },
    rarity = 2,
    cost = 6,
    atlas = 'Jokers',
    pos = { x = 1, y = 4 },
    config = {
        extra = {
            xmult = 1,
			mult = 0,
			xchips = 1,
			chips = 0,
        },
    },
    blueprint_compat = true,

    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.xmult, card.ability.extra.mult, card.ability.extra.xchips, card.ability.extra.chips }
        }
    end,

    calculate = function(self, card, context)
		if context.joker_main then
			if G.GAME.current_round.hands_played == 0 and context.full_hand then
				local first_card = context.full_hand[1]
				if first_card then
                -- Get chip value and add it
					local rank_value = SMODS.Ranks[first_card.base.value].nominal or 0
					card.ability.extra.chips = card.ability.extra.chips + rank_value
					
					--check for every possible edition that would be relevant here
					if first_card.edition and first_card.edition.key == 'e_foil' then
						card.ability.extra.chips = card.ability.extra.chips + 50
					end
					
					if first_card.edition and first_card.edition.key == 'e_holo' then
						card.ability.extra.mult = card.ability.extra.mult + 10
					end
					
					if first_card.edition and first_card.edition.key == 'e_polychrome' then
						card.ability.extra.xmult = card.ability.extra.xmult + 1.5
					end
					
					if first_card.edition and first_card.edition.key == 'e_ortalab_anaglyphic' then
						card.ability.extra.chips = card.ability.extra.chips + 20
						card.ability.extra.mult = card.ability.extra.mult + 6
					end
					
					if first_card.edition and first_card.edition.key == 'e_ortalab_overexposed' then
						card.ability.extra.chips = card.ability.extra.chips + rank_value
					end
					
					if first_card.edition and first_card.edition.key == 'e_yahimod_evil' then
						card.ability.extra.xchips = card.ability.extra.xchips + 1.5
					end
					
					if first_card.edition and first_card.edition.key == 'e_cry_mosaic' then
						card.ability.extra.xchips = card.ability.extra.xchips + 2.5
					end
					
					if first_card.edition and first_card.edition.key == 'e_cry_oversat' then
						card.ability.extra.chips = card.ability.extra.chips + rank_value
					end
					
					if first_card.edition and first_card.edition.key == 'e_cry_glass' then
						card.ability.extra.xmult = card.ability.extra.xmult + 3
					end
					
					if first_card.edition and first_card.edition.key == 'e_cry_noisy' then
						card.ability.extra.mult = card.ability.extra.mult + math.random(0, 30)
						card.ability.extra.chips = card.ability.extra.chips + math.random(0, 150)
					end
					
					if first_card.edition and first_card.edition.key == 'e_cry_m' then
						card.ability.extra.mult = card.ability.extra.mult + 8
					end
					-- now we check for seals...
					if first_card.seal and first_card.seal == "Red" then
						card.ability.extra.chips = card.ability.extra.chips + rank_value
					end
					
					if first_card.seal and first_card.seal == "yahimod_whatsapp_seal" then
						card.ability.extra.mult = card.ability.extra.mult + 1
						card.ability.extra.chips = card.ability.extra.chips + 10
						card.ability.extra.xmult = card.ability.extra.xmult + 1.1
					end
					
					if first_card.seal and first_card.seal == "yahimod_horse_seal" then
						card.ability.extra.mult = card.ability.extra.mult - 1
						card.ability.extra.chips = card.ability.extra.chips - 5
						card.ability.extra.xmult = card.ability.extra.xmult + 0.9
					end
					
					if first_card.seal and first_card.seal == "yahimod_ifunny_seal" then
						card.ability.extra.chips = card.ability.extra.chips + rank_value
					end
					
					-- Alright chat now we check for enhancements yippee!
					
					if first_card.config.center == G.P_CENTERS.m_bonus then
						card.ability.extra.chips = card.ability.extra.chips + 30
					end
					
					if first_card.config.center == G.P_CENTERS.m_mult then
						card.ability.extra.mult = card.ability.extra.mult + 4
					end
					
					if first_card.config.center == G.P_CENTERS.m_glass then
						card.ability.extra.xmult = card.ability.extra.xmult + 2
					end
					
					if first_card.config.center == G.P_CENTERS.m_steel then
						card.ability.extra.xmult = card.ability.extra.xmult + 1.5
					end
					
					if first_card.config.center == G.P_CENTERS.m_stone then
						card.ability.extra.chips = card.ability.extra.chips + 50
					end
					
					if first_card.config.center == G.P_CENTERS.m_lucky then
						card.ability.extra.mult = card.ability.extra.mult + 20
					end
					
					if first_card.config.center == G.P_CENTERS.m_fn_Crystal then
						card.ability.extra.chips = card.ability.extra.chips + 50
						card.ability.extra.xmult = card.ability.extra.xmult + 1.5
					end
					
					if first_card.config.center == G.P_CENTERS.m_fn_Wood then
						card.ability.extra.chips = card.ability.extra.chips + 15
						card.ability.extra.xmult = card.ability.extra.xmult + 1.2
					end
					
					if first_card.config.center == G.P_CENTERS.m_fn_Brick then
						card.ability.extra.chips = card.ability.extra.chips + 40
						card.ability.extra.xmult = card.ability.extra.xmult + 1.3
					end
					
					if first_card.config.center == G.P_CENTERS.m_fn_Metal then
						card.ability.extra.chips = card.ability.extra.chips + 60
						card.ability.extra.xmult = card.ability.extra.xmult + 1.5
					end
					
					if first_card.config.center == G.P_CENTERS.m_fn_StormSurge then
						card.ability.extra.chips = card.ability.extra.chips + 100
						card.ability.extra.mult = card.ability.extra.mult + 10
					end
					
					if first_card.config.center == G.P_CENTERS.m_fn_Legendary then
						card.ability.extra.xmult = card.ability.extra.xmult + 0.4
					end
					
					if first_card.config.center == G.P_CENTERS.m_fn_Cubic then
						card.ability.extra.xchips = card.ability.extra.xchips + 3
						card.ability.extra.xmult = card.ability.extra.xmult + 0.6
					end
					
					if first_card.config.center == G.P_CENTERS.m_fn_Shell then
						card.ability.extra.xmult = card.ability.extra.xmult + 1.2
					end
					
					if first_card.config.center == G.P_CENTERS.m_fn_Heavy then
						card.ability.extra.mult = card.ability.extra.mult + 10
					end
					
					if first_card.config.center == G.P_CENTERS.m_fn_Light then
						card.ability.extra.chips = card.ability.extra.chips + 75
					end
					
					if first_card.config.center == G.P_CENTERS.m_fn_Medium then
						card.ability.extra.xchips = card.ability.extra.xchips + 1.1
					end
					
					if first_card.config.center == G.P_CENTERS.m_fn_Rocket then
						card.ability.extra.chips = card.ability.extra.chips + rank_value
					end
					
					if first_card.config.center == G.P_CENTERS.m_ortalab_post then
						card.ability.extra.chips = card.ability.extra.chips + 10
					end
					
					if first_card.config.center == G.P_CENTERS.m_ortalab_bent then
						card.ability.extra.mult = card.ability.extra.mult + 2
					end
					
					if first_card.config.center == G.P_CENTERS.m_ortalab_sand then
						card.ability.extra.xchips = card.ability.extra.xchips + 0.25
					end
					
					if first_card.config.center == G.P_CENTERS.m_ortalab_rusty then
						card.ability.extra.xchips = card.ability.extra.xchips + 0.75
					end
					
					if first_card.config.center == G.P_CENTERS.m_ortalab_ore then
						card.ability.extra.mult = card.ability.extra.mult + 15
					end
					
					if first_card.config.center == G.P_CENTERS.m_ortalab_recycled then
						card.ability.extra.chips = card.ability.extra.chips + 100
					end
					
					if first_card.config.center == G.P_CENTERS.m_cry_echo then
						card.ability.extra.chips = card.ability.extra.chips + rank_value + rank_value
					end
					
					if first_card.config.center == G.P_CENTERS.m_cry_light then
						card.ability.extra.xmult = card.ability.extra.xmult + 1
					end
					
					if first_card.config.center == G.P_CENTERS.m_aij_fervent then
						card.ability.extra.chips = card.ability.extra.chips + 10
					end
					
					-- wooo that took fucking forever but this should work
					
					-- NOW WE FINALLY DESTROY THE CARD after 0.2 seconds so it still counts properly for things
					G.E_MANAGER:add_event(Event({
						trigger = 'after',
						delay = 0.2, -- tweak this delay as needed (seconds)
						func = function()
							if first_card then
								card:juice_up()
								first_card:start_dissolve()
							end
							return true
						end
					}))
				end
			end

            return {
                chips = card.ability.extra.chips,
				mult = card.ability.extra.mult,
                x_chips = card.ability.extra.xchips,
				x_mult = card.ability.extra.xmult,
            }
        end
    end
}

SMODS.Joker({
    key = 'pole',
    loc_txt = {
        name = 'Pole Jump',
        text = {
            "Each played {C:attention}number{} card with value above {C:attention}#1#",
            "Increases its own counter once per hand (max 5)",
            "Turns {C:money}that many cards in hand Gold",
            "Changes every hand"
        }
    },
    rarity = 2,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 8, y = 6 },
    blueprint_compat = true,

    config = {
        extra = (function()
            local t = { value1 = math.random(2, 9) }
            for i = 3, 10 do
                t['count_' .. i] = 0
            end
            return t
        end)()
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_gold
        return {
            vars = { tostring(card.ability.extra.value1) }
        }
    end,

    calculate = function(self, card, context)
        if (not context.first_hand_drawn and context.hand_drawn) or context.end_of_round then
            card.ability.extra.value1 = math.random(2, 9)
        end

        if context.joker_main and context.full_hand then
            local threshold = card.ability.extra.value1
            local values_seen = {}
            local total_gold = 0

            -- Identify unique number card values > threshold
            for _, c in ipairs(context.scoring_hand) do
                local id = c:get_id()
                if id > threshold and id <= 10 then
                    values_seen[id] = true
                end
            end

            -- Increment and cap counts, compute total Gold reward
            for value, _ in pairs(values_seen) do
                local key = 'count_' .. value
                local prev = card.ability.extra[key] or 0
                if prev < 5 then
                    card.ability.extra[key] = prev + 1
                end
                total_gold = total_gold + card.ability.extra[key]
            end

            -- Get eligible hand cards (not already Gold)
            local candidates = {}
            for _, c in ipairs(G.hand.cards) do
                if c.ability.center ~= G.P_CENTERS.m_gold then
                    table.insert(candidates, c)
                end
            end

            -- Apply Gold to up to total_gold eligible cards
            for i = 1, total_gold do
                if #candidates == 0 then break end
                local picked = pseudorandom_element(candidates)
                picked:set_ability(G.P_CENTERS.m_gold, nil, true)
                for j, c in ipairs(candidates) do
                    if c == picked then
                        table.remove(candidates, j)
                        break
                    end
                end
            end

            -- Debug print
            local debug_counts = {}
            for i = 3, 10 do
                table.insert(debug_counts, tostring(i) .. "=" .. tostring(card.ability.extra["count_" .. i]))
            end
            print("Pole Jump counts: [" .. table.concat(debug_counts, ", ") .. "]")
        end
    end
})]]
SMODS.Joker {
    key = 'ena',
    loc_txt = {
        name = 'Jena',
        text = {
            "Gains {C:chips}+#3#{} Chips per {C:chips}Hands{} remaining on {C:white,X:punch_small_blind}Small {C:white,X:punch_small_blind}blind ",
            "{X:mult,C:white}X#4#{} Mult per {C:red}Discards{} remaining on {X:punch_big_blind}Big{}{X:punch_big_blind}Blind",
            "{C:inactive}(Currently {C:chips}+#1#{} {C:inactive}Chips, {X:mult,C:white}X#2#{}{C:inactive} Mult)",
            "{C:inactive}[Resets every boss blind]"
        }
    },
    rarity = 2,
    cost = 6,
    atlas = 'Jokers',
    pos = { x = 9, y = 1 },
    blueprint_compat = true,
    config = {
        extra = {
            chips = 0, -- current chips
            xmult = 1, -- current x_mult
            chipmod = 20, -- added chips
            multmod = 0.5 -- added x_mult
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.chips,
                card.ability.extra.xmult,
                card.ability.extra.chipmod,
                card.ability.extra.multmod,
            }
        }
    end,
    
    calculate = function(self, card, context)
        -- Gain charge when any hand is played, but check for boss blind
        if context.end_of_round and context.main_eval and not context.blueprint then
            -- Check if it's a boss blind
            if G.GAME.blind and G.GAME.blind.boss then
                -- Reset on boss blind
                card.ability.extra.chips = 0
                card.ability.extra.xmult = 1
                return {
                    message = localize('k_reset'),
                    card = card
                }
            else
                -- Get the remaining hands and discards from the current round
                local remaining_hands = G.GAME.current_round.hands_left
                local remaining_discards = G.GAME.current_round.discards_left
                
                if G.GAME.blind and G.GAME.blind.name == 'Small Blind' then
                    -- Gain +40 chips per remaining hand
                    card.ability.extra.chips = card.ability.extra.chipmod * remaining_hands + card.ability.extra.chips
                    return {
                        message = localize('k_upgrade_ex'),
                        colour = G.C.Mult,
                        card = card
                    }
                elseif G.GAME.blind and G.GAME.blind.name == 'Big Blind' then
                    -- Gain 0.5x multiplier per discard remaining
                    card.ability.extra.xmult = card.ability.extra.multmod * remaining_discards + card.ability.extra.xmult
                    return {
                        message = localize('k_upgrade_ex'),
                        colour = G.C.Mult,
                        card = card
                    }
                end
            end
        end

        if context.joker_main then
            return {
                x_mult = card.ability.extra.xmult,
                chips = card.ability.extra.chips,
            }
        end
    end
}
SMODS.Joker {
    key = 'live',
    atlas = 'Jokers',
    pos = {x = 0, y = 2},
	rarity = 3,
    cost = 12,
    loc_txt = {
        name = 'Positive affirmation',
        text = {
            'When a {C:attention}Hand is upgraded{}',
            'Also upgrade {C:attention}Pair{}'
        }
    },
    config = {},

    calculate = function(self, card, context)
        if context.using_consumeable
        and context.consumeable
        and context.consumeable.config
        and context.consumeable.config.center
        and context.consumeable.config.center.set == 'Planet' then

            local k = 'Pair'
            local v = G.GAME.hands[k]

            -- First update: show current hand info
            update_hand_text(
                {sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3},
                {
                    handname = localize(k, 'poker_hands'),
                    chips = v.chips,
                    mult = v.mult,
                    level = v.level
                }
            )

            -- Perform the upgrade
            level_up_hand(card, k)


            -- Clear update popup
            update_hand_text(
                {sound = 'button', volume = 0.7, pitch = 1.1, delay = 0},
                {mult = 0, chips = 0, handname = '', level = ''}
            )
        end
    end
}
SMODS.Joker {
    key = 'triple_self_portrait',
    loc_txt = {
        name = 'Triple self portrait',
        text = {
            "When a {C:attention}3 of kind{} is scored",
			"adds a {C:attention}random enchantement{} to the first card",
			"a {C:attention}random edition{} to the second card",
			"and a {C:attention}random seal{} to the thrid card",
        }
    },
    rarity = 3,
    cost = 8,
    atlas = 'Jokers',
    pos = { x = 6, y = 0 },
    blueprint_compat = true,

    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            if context.scoring_name == 'Three of a Kind' then
                local scoring_hand = context.scoring_hand

                -- Ensure there are at least 3 cards in the hand and that they are not nil
                if #scoring_hand >= 3 and scoring_hand[1] and scoring_hand[2] and scoring_hand[3] then
                    -- Apply random enhancement to the first card
                    local enhancement_key = {key = 'perk', guaranteed = true}
                    local random_enhancement = G.P_CENTERS[SMODS.poll_enhancement(enhancement_key)]
                    if random_enhancement then
                        scoring_hand[1]:set_ability(random_enhancement, true)
                    end

                    -- Apply random edition to the second card
                    local random_edition = poll_edition(nil, nil, false, true)
                    if random_edition then
                        scoring_hand[2]:set_edition(random_edition, true)
                    end
                    -- Apply backup edition if 'j_punch_depression' exists
                    if SMODS.find_card('j_punch_depression') then
                        local base_editions = {
                            'holo', 'polychrome', 'negative', 'foil',
                        }
                        local backup_edition = base_editions[math.random(1, #base_editions)]
                        scoring_hand[2]:set_edition({[backup_edition] = true}, true)
                    end

                    -- Apply random seal to the third card
                    local random_seal = SMODS.poll_seal({key = 'supercharge', guaranteed = true})
                    if random_seal then
                        scoring_hand[3]:set_seal(random_seal, true)
                    end

                    -- Add a visual effect to "juice up" the third card after sealing
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            scoring_hand[3]:juice_up(0.3, 0.4)
                            return true
                        end
                    }))
                else
                    -- Log an error if there are not enough cards in the hand
                    print("Error: Scoring hand does not contain 3 valid cards.")
                end
            end
        end
    end
}
SMODS.Joker{
    key = 'Stamp',
    loc_txt = {
        name = '{e:1}Stamp of Approval',
        text = {
            'Converts any scored card with a non-red seal',
            'into a {C:red}Red Seal{}'
        }
    },
    atlas = 'Jokers',
    rarity = 3,
    cost = 9,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    pos = {x = 2, y = 0},
	soul_pos = { x = 3, y = 0 },
    config = {
        extra = {
            seal_color = 'Red'
        }
    },
    calculate = function(self, card, context)
        if context.joker_main then
            return { Xmult_mod = 1 }
        end

        if context.individual and context.cardarea == G.play and not context.blueprint then
            local scored_card = context.other_card
            local current_seal = scored_card:get_seal()

            if current_seal and current_seal ~= 'Red' then
                scored_card:set_seal('Red', true)
                return {
                    message = 'Approved!',
                    colour = G.C.SEAL,
                    card = scored_card
                }
            end
        end
    end
	}

--[[
SMODS.Joker {
    key = 'home',
    loc_txt = {
        name = 'My math homework',
        text = {
            "Ok im not going to lie im kinda of {C:red,s:1.5}COOKED{} rn",
			"so please can you answer the questions",
			"Im going to give you in less than {C:attention}3 boss blinds{}",
			"Answer with {C:attention}cards{}, i'll give you like",
			"{X:mult,C:white}X5{} mult for every {C:diamonds}Diamond{} and {C:spades}Spade{} scored after it",
			"Current question : {C:attention}2+2",
			"{C:inactive}[Questions remaining 1/3]"
        }
		},
    rarity = 3,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 1, y = 2 },
    blueprint_compat = true
}]]--
SMODS.Joker {
    key = 'meta',
    loc_txt = {
        name = ' ',
        text = {
            "{X:white,C:white}vv{}{X:black}vvvvvvvvvvvvvvvvvvvvvvvvvvvv{}{X:white,C:white}vv", 
            "{X:black}vvvv{}{X:white,C:white}vvvvvvvvvvvvvvvvvvvvvvvv{}{X:black}vvvv",
            "{X:black}vv{}{X:white,C:white}vvvvvvvvvvvvvvvvvvvvvvvvvvvv{}{X:black}vv",
            "{X:black}vv{}{X:white,C:white}vvvvvvvvvvvv{}{X:mult,C:red}vv{}{X:white,C:white}vvvvvvvvvvvvv{}{X:black}vv",
            "{X:black}vv{}{X:white,C:white}vvvvvvv{}{X:attention,C:attention}vvvv{}{X:mult,C:red}vvvvvv{}{X:attention,C:attention}vvvv{}{X:white,C:white}vvvvv{}{X:black}vv",
            "{X:black}vv{}{X:white,C:white}vvvvvvvv{}{X:attention,C:attention}vv{}{X:mult,C:red}vvvvvv{}{X:attention,C:attention}vv{}{X:white,C:white}vvvvvvvv{}{X:black}vv",
            "{X:black}vv{}{X:white,C:white}vvvvvvvvvvv{}{X:attention,C:attention}vv{}{X:white,C:white}vv{}{X:attention,C:attention}vv{}{X:white,C:white}vvvvvvvvv{}{X:black}vv",
            "{X:black}vv{}{X:white,C:white}vvvvvvvvv{}{X:chips,C:chips}vv{}{X:white,C:white}vv{}{X:mult,C:red}vv{}{X:white,C:white}vv{}{X:chips,C:chips}vv{}{X:white,C:white}vvvvvv{}{X:black}vv",
            "{X:black}vv{}{X:white,C:white}vvvvvvv{}{X:chips,C:chips}vvvvvvvvvvvvvv{}{X:white,C:white}vvvvvv{}{X:black}vv",
            "{X:black}vv{}{X:white,C:white}vvvvvvvvv{}{X:chips,C:chips}vvvvvvvvvv{}{X:white,C:white}vvvvvvvv{}{X:black}vv",
            "{X:black}vv{}{X:white,C:white}vvvvvvvvv{}{X:chips,C:chips}vv{}{X:white,C:white}vvvvvv{}{X:chips,C:chips}vv{}{X:white,C:white}vvvvvvv{}{X:black}vv",
            "{X:black}vv{}{X:white,C:white}vvvvvvvvvvvvvvvvvvvvvvvvvvvv{}{X:black}vv",
            "{X:black}vvvv{}{X:white,C:white}vvvvvvvvvvvvvvvvvvvvvvvv{}{X:black}vvvv",
            "{X:white,C:white}vv{}{X:black}vvvvvvvvvvvvvvvvvvvvvvvvvvvv{}{X:white,C:white}vv"
        }
    },
    rarity = 3,
    cost = 8,
    atlas = 'Jokers',
    pos = { x = 2, y = 2 },
    config = { 
        extra = { 
            d_repetitions = 0, 
            h_repetitions = 0, 
            s_repetitions = 0, 
            c_repetitions = 0 
        } 
    },
    blueprint_compat = true,
    
    calculate = function(self, card, context)
        -- Check if this is the main Joker calculation
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            -- Reset suit repetitions
			card.ability.extra.d_repetitions = 0
			card.ability.extra.h_repetitions = 0
            card.ability.extra.s_repetitions = 0
			card.ability.extra.c_repetitions = 0

            -- Count the number of Suits in the played hand
            for _, played_card in ipairs(context.scoring_hand) do
				if played_card:is_suit("Diamonds") then
                    card.ability.extra.d_repetitions = card.ability.extra.d_repetitions + 1
                end
				if played_card:is_suit("Hearts") then
                    card.ability.extra.h_repetitions = card.ability.extra.h_repetitions + 1
                end
                if played_card:is_suit("Spades") then
                    card.ability.extra.s_repetitions = card.ability.extra.s_repetitions + 1
                end
				if played_card:is_suit("Clubs") then
                    card.ability.extra.c_repetitions = card.ability.extra.c_repetitions + 1
                end
            end
        end
        
		--retrigger check with rarity
		if (context.retrigger_joker_check and not context.retrigger_joker and context.other_card.config.center.rarity == 4) then
            return {
             repetitions = card.ability.extra.d_repetitions
            }
        end
		if (context.retrigger_joker_check and not context.retrigger_joker and context.other_card.config.center.rarity == 3) then
            return {
                repetitions = card.ability.extra.h_repetitions
            }
        end
        if (context.retrigger_joker_check and not context.retrigger_joker and context.other_card.config.center.rarity == 2) then
            return {
                repetitions = card.ability.extra.s_repetitions
            }
        end
		if (context.retrigger_joker_check and not context.retrigger_joker and context.other_card.config.center.rarity == 1) then
            return {
                repetitions = card.ability.extra.c_repetitions
            }
        end
		if context.end_of_round then
            -- Reset suit repetitions
			card.ability.extra.d_repetitions = 0
			card.ability.extra.h_repetitions = 0
            card.ability.extra.s_repetitions = 0
			card.ability.extra.c_repetitions = 0
		end
    end,
}

SMODS.Joker {
    key = 'chromosome',
    loc_txt = {
        name = 'Chromosome',
        text = {
            "If {C:attention}First Hand{} is only {C:attention}1{} card",
            "Destroy the {C:attention}lowest-ranked{} card in hand,",
            "then create a copy of the single card"
        }
    },
    rarity = 3,
    cost = 8,
    atlas = 'Jokers',
    pos = { x = 8, y = 5 },
    blueprint_compat = true,

    calculate = function(self, card, context)
        if context.first_hand_drawn and not context.blueprint then
            local eval = function() return G.GAME.current_round.hands_played == 0 and not G.RESET_JIGGLES end
            juice_card_until(card, eval, true)
        end

        if context.joker_main and G.GAME.current_round.hands_played == 0 and #context.full_hand == 1 then
            local played_card = context.full_hand[1]
            local lowest_card = nil
            local lowest_value = 15

            for _, c in ipairs(G.hand.cards) do
                if c ~= played_card then
                    local value = c:get_id()
                    if value and value < lowest_value then
                        lowest_value = value
                        lowest_card = c
                    end
                end
            end

            if lowest_card then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        lowest_card:start_dissolve()

                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.1,
                            func = function()
                                local copy = copy_card(played_card)
                                G.hand:emplace(copy)
								copy:add_to_deck()
								G.deck.config.card_limit = G.deck.config.card_limit + 1
								table.insert(G.playing_cards, copy)
                                copy:start_materialize(nil, nil)

                                -- Optional: trigger card effects if needed
                                playing_card_joker_effects({copy})

                                return true
                            end
                        }))

                        return true
                    end
                }))
            else
                print("[Chromosome] No valid lowest card found to destroy and copy")
            end
        end
    end,
}


--billboard stuff

local igo = Game.init_game_object
Game.init_game_object = function(self)
    local ret = igo(self)

    -- Conditional/tracking Modifiers
    ret.purchased_jokers = {}
    ret.last_bought = {
        card = nil,
        pos = nil
    }

    ret.current_round.zombie_target = {
        card = nil,
        pos = nil
    }

    return ret
end

local save_r = save_run
save_run = function(self)
    if G.GAME.current_round.zombie_target and G.GAME.current_round.zombie_target.card then
        local pos = 1
        for k, v in pairs(G.jokers.cards) do
            if v == G.GAME.current_round.zombie_target.card then
                G.GAME.current_round.zombie_target.pos = pos
                break
            end
            pos = pos + 1
        end
    end

    if G.GAME.last_bought and G.GAME.last_bought.card then
        local pos = 1
        for k, v in pairs(G.jokers.cards) do
            if v == G.GAME.last_bought.card then
                G.GAME.last_bought.pos = pos
                break
            end
            pos = pos + 1
        end
    end

    save_r(self)
end

local start_r = Game.start_run
Game.start_run = function(self, args)
    start_r(self, args)

    if G.GAME.last_bought and G.GAME.last_bought.pos then
        G.GAME.last_bought.card = G.jokers.cards[G.GAME.last_bought.pos]
        G.GAME.last_bought.pos = nil
    end

    if G.GAME.current_round.zombie_target and G.GAME.current_round.zombie_target.pos then
        G.GAME.current_round.zombie_target.card = G.jokers.cards[G.GAME.current_round.zombie_target.pos]
        G.GAME.current_round.zombie_target.pos = nil
    end
end


SMODS.Joker {
    key = 'aceking', 
    loc_txt = {
        name = 'Sorry For Aceking',
        text = {
            "Aces gain {X:mult,C:white}X#2#{} per {C:mult}Discarded{} {C:attention}Face Card{}",
			"Resets when an {C:attention}Ace{} is played",
			"{C:inactive}[Currently {}{X:mult,C:white}X#1#{} {C:inactive}mult]",
        }
    },
    rarity = 3,
    cost = 8,
    atlas = 'Jokers',
    pos = { x = 3, y = 3 },
    config = {
        extra = {
            Xmult = 1,
            Xmult_add = 0.5,
			ace_played = 0,
        },
    },
    blueprint_compat = true,
    
    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.Xmult, card.ability.extra.Xmult_add }
        }
    end,

    calculate = function(self, card, context)
        -- If a face card is discarded (Jack=11, Queen=12, King=13)
        if context.discard and not context.blueprint and not context.other_card.debuff then
            local id = context.other_card:get_id()
            if id == 11 or id == 12 or id == 13 then
                card.ability.extra.Xmult = (card.ability.extra.Xmult or 0) + (card.ability.extra.Xmult_add or 0.5)
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.Mult,
                    card = card
                }
            end
        end

        -- Apply mult to Aces during scoring
        if context.individual and context.cardarea == G.play then
            local card_id = context.other_card:get_id()
            if card_id == 14 then
				card.ability.extra.ace_played = 1
                return {
                    x_mult = card.ability.extra.Xmult,  -- Apply multiplier to the current card
                    card = card
                }
            end
        end

        -- Reset when Ace is played
        if card.ability.extra.ace_played == 1 and context.final_scoring_step then
			card.ability.extra.ace_played = 0
			card.ability.extra.Xmult = 1
			return {
                message = localize('k_reset'),
                colour = G.C.Mult,
                card = card
            }
        end
    end,
}
SMODS.Joker {
    key = 'billboard',
    loc_txt = {
        name = 'Billboard',
        text = { 'Copies the {C:attention}last bought Joker', 'Currently: {C:red}#1#{}' }
    },
    atlas = 'Jokers',
    pos = {
        x = 1,
        y = 3
    },
    rarity = 3,
    config = {},
    blueprint_compat = true,
    cost = 8,
    loc_vars = function(self, info_queue, card)
        if G.GAME.last_bought.card ~= nil then
            local copied_key = G.GAME.last_bought.card.config.center.key
            info_queue[#info_queue + 1] = G.P_CENTERS[copied_key]
            return {
                vars = { G.localization.descriptions.Joker[copied_key].name }
            }
        else
            return {
                vars = { 'None' }
            }
        end
    end,
    calculate = function(self, card, context)
        if G.GAME.last_bought.card and not context.no_blueprint then
            context.blueprint = (context.blueprint and (context.blueprint + 1)) or 1
            context.blueprint_card = context.blueprint_card or card
            local bootleg_target_ret = G.GAME.last_bought.card:calculate_joker(context)
            context.blueprint = nil
            local eff_card = context.blueprint_card or self
            context.blueprint_card = nil
            if bootleg_target_ret then
                bootleg_target_ret.card = eff_card
                bootleg_target_ret.colour = G.C.YELLOW
                return bootleg_target_ret
            end
        end

        if context.buying_card and context.card.config.center.blueprint_compat
            and (context.card ~= card or context.card.config.center.key ~= "j_punch_billboard") then
            G.GAME.last_bought.card = context.card
            card:juice_up(0.3, 0.4)
        end
    end,
    remove_from_deck = function(self, card, context)
        if not next(SMODS.find_card('j_punch_billboard')) then
            G.GAME.last_bought.card = nil
        end
    end
}

--[[
SMODS.Atlas{
    key = 'BlindJoker', 
    path = 'BlindJoker.png', 
    px = 71, 
    py = 95 
	}

SMODS.Joker{
    key = 'soul', 
    config = {
        extra = {
            animated = true,
            frame = 0,
            timer = 0,
            last_time = 0
        }
    },
    loc_txt = {
        name = 'soul test',
        text = {
            "animation test"
        }
    },
    rarity = 1,
    cost = 5,
    atlas = 'BlindJoker',
    pos = { x = 0, y = 0 },
    soul_pos = { x = 0, y = 1 },
    blueprint_compat = true,

    update = function(self, card)
        local extra = card.ability.extra
        if not extra.animated then return end

        local fps = 9    -- higher number is faster again
        local max_frame = 21 -- how many animation frames there are

        -- Delta time calculation
        local current_time = G.TIMERS.REAL
        local delta = current_time - (extra.last_time or 0)
        extra.last_time = current_time

        -- Add delta to timer
        extra.timer = (extra.timer or 0) + delta

        if extra.timer >= (1 / fps) then
            extra.timer = 0
            extra.frame = ((extra.frame or 0) + 1) % (max_frame + 1)

            if card.children and card.children.floating_sprite then
                card.children.floating_sprite:set_sprite_pos({ x = extra.frame, y = 1 })
            end
        end
    end
}
]]--


SMODS.Joker {
    key = "depression",
    name = "Depression",
    atlas = 'Jokers',
    pos = { x = 7, y = 3 },
    rarity = 3,
    cost = 10,
    loc_txt = {
        ['en-us'] = {
            name = "Depression",
            text = {
                "{C:attention}15%{} chance a joker is {C:dark_edition}negative{} in the shop ",
            }
        }
    },

    remove_from_deck = function(self, card)
        function poll_edition(_key, _mod, _no_neg, _guaranteed)
            return {negative=false}
        end
    end,

    calculate = function(self, card, context)
        -- every shop 30% chance any joker is negative
        if context.reroll_shop then
            if pseudorandom('depression_neg_chance') < 0.15 then
                function poll_edition(_key, _mod, _no_neg, _guaranteed)
                    return {negative=true}
                end
            else
                function poll_edition(_key, _mod, _no_neg, _guaranteed)
                    return {negative=false}
                end
            end
        end

        -- Reset poll_edition once shop finishes populating
        if context.ending_shop then
            function poll_edition(_key, _mod, _no_neg, _guaranteed)
                return {negative=false}
            end
        end
    end
}

SMODS.Joker{
    key = 'Eric',
    loc_txt = {
        name = 'Eric',
        text = {
            "Creates a {C:dark_edition}Negative{} clone of {C:attention}#1#{} random",
            "{C:attention}Cards{} or {C:attention}Jokers{} in possession",
            "at the start of every round",
            "{C:inactive}He can just do that btw"
        }
    },
    config = {
        extra = { cards = 1 }
    },
    rarity = 4,
    cost = 20,
    blueprint_compat = true,
    discovered = true,
    unlocked = true,
    pos = { x = 5, y = 3 },
    soul_pos = { x = 6, y = 3 },
    atlas = 'Jokers',
    
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.cards or 1 } }
    end,

    calculate = function(self, card, context)
        if context.first_hand_drawn then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    local count = card.ability.extra.cards or 1
                    local pool = {}

                    for _, pile in ipairs({
                        {cards = G.hand.cards, zone = G.hand},
                        {cards = G.jokers.cards, zone = G.jokers}, --removed consumables his ass is NOT perkeo :skull:
																			  
                    }) do
                        for _, c in ipairs(pile.cards) do
                            table.insert(pool, {card = c, zone = pile.zone})
                        end
                    end

                    if #pool == 0 then return false end

                    -- Shuffle pool
                    for i = #pool, 2, -1 do
                        local j = math.random(i)
                        pool[i], pool[j] = pool[j], pool[i]
                    end

                    local selected = {}
                    for i = 1, math.min(count, #pool) do
                        table.insert(selected, pool[i])
                    end

                    local new_cards = {}
                    for _, entry in ipairs(selected) do
                        local src_card = entry.card
                        local zone = entry.zone

                        local clone = copy_card(src_card)

                        -- Mitosis callout if cloning Eric
                        if src_card.ability and src_card.ability.name == G.P_CENTERS.j_punch_Eric.name then
                            SMODS.eval_this(card, {
                                message = "Mitosis!",
                                colour = G.C.SECONDARY_SET.Tarot
                            })
                        end

                        -- Make the clone negative, like a decoy grenade
                        clone:set_edition({negative = true}, true)

                        -- Handle hand cards by adding to deck
                        if zone == G.hand then
                            clone:add_to_deck()
                            G.deck.config.card_limit = G.deck.config.card_limit + 1
                            table.insert(G.playing_cards, clone)
                        end

                        -- Add the clone to the correct zone
                        zone:emplace(clone)
                        clone:start_materialize(nil, nil)
                        table.insert(new_cards, clone)

                        -- Add "Duplicated!" callout if the card is NOT Eric
                        if src_card.ability and src_card.ability.name ~= G.P_CENTERS.j_punch_Eric.name then
                            SMODS.eval_this(card, {
                                message = "Duplicated!",
                                colour = G.C.SECONDARY_SET.Tarot
                            })
                        end
                    end

                    playing_card_joker_effects(new_cards)
                    return true
                end
            }))
        end
    end
}
SMODS.Joker{
    key = 'gfs',
    loc_txt = {
        name = 'Gfs',
        text = {
            "Yo that's me :D, well I guess I'll retrigger all the joker", 
            "The number of times cards have been triggered this hand",
            "Broken? Yes, Fun? Yes, Hotel? Trivago"
        }
    },
    atlas = "Jokers",
    pos = { x = 7, y = 1 },
    soul_pos = { x = 8, y = 1 },
    rarity = 4,
    order = 32,
    cost = 20,
	config = {
        extra = {
            repetitions = 0, -- Number of times to retrigger for scoring cards and Jokers
        },
    },
    blueprint_compat = true,
	
	loc_vars = function(self, info_queue, center)
        return {
            vars = { "" .. self.config.extra.repetitions }
        }
    end,
	
	calculate = function(self, card, context)
        -- Check for retriggering (excluding consumables)
		if context.cardarea == G.jokers and context.before and not context.blueprint then
			self.config.extra.repetitions = #context.scoring_hand
		end
		
        if (context.retrigger_joker_check and not context.retrigger_joker and context.other_card ~= self) or
           context.jokers then

            -- Loop through the configured repetitions
            for i = 1, self.config.extra.repetitions do
                G.GAME.pool_flags.clam = true  -- Ensure 'clam' flag is set
				local text_choices = {
					'AGAIIINN!!!', 'You get a retrigger you get a retrigger you...', 'hope you didn\'t play to many cards', 'maybe this is too broken huh', 'Swag', 'Balantro', 'guess what ?', 'wake up', 'JACKPOT', 'The voices', 'You win !', '#####', '42', 'ERROR TEXT NOT FOUND',
                }
                local text_id = text_choices[math.random(1, #text_choices)]

                -- Return a message for each repetition
                return {
                    message = text_id,
                    colour = G.C.SECONDARY_SET.Tarot,    -- Set the color to red for emphasis
                    repetitions = self.config.extra.repetitions, -- How many times to retrigger
                    card = card,         -- Attach the card context
                }
            end
        end
		--reset the triggers after the round
		if context.end_of_round and not context.repetition and not context.individual then
			self.config.extra.repetitions = 0
		end
    end,
}
SMODS.Joker {
    key = 'henry', 
    loc_txt = {
        name = 'Henry The 8th',
        text = {
            "Gain {X:mult,C:white}X#2#{} Mult",
            "Every {C:attention}6{} {C:inactive}[#3#]{} Queens discarded",
            "{C:inactive}[Currently{} {X:mult,C:white}X#1#{} {C:inactive}Mult]",
        }
    },
    rarity = 4,
    cost = 20,
    atlas = 'Jokers',
    pos = { x = 2, y = 7 },
	soul_pos = { x = 1, y = 7},
    config = {
        extra = {
            Xmult = 1,         -- Starting multiplier
            Xmult_add = 1,     -- Multiplier added when 6 queens are discarded
            discarded = 0,     -- Count of discarded Queens
        },
    },
    blueprint_compat = true,
    
    loc_vars = function(self, info_queue, card)
        return {
            vars = { card.ability.extra.Xmult, card.ability.extra.Xmult_add, card.ability.extra.discarded }  -- Refer to multiplier correctly
        }
    end,
    
    calculate = function(self, card, context)
        -- Triggered when a card is discarded
        if context.discard and not context.blueprint and
            not context.other_card.debuff and
            context.other_card:get_id() == 12 then  -- 12 is the ID for Queens
            
            -- Increment discarded counter
            card.ability.extra.discarded = (card.ability.extra.discarded or 0) + 1
            
            -- If 6 Queens discarded, reset counter and increase multiplier
            if card.ability.extra.discarded >= 6 then
                card.ability.extra.discarded = 0
                card.ability.extra.Xmult = (card.ability.extra.Xmult or 1) + card.ability.extra.Xmult_add
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.Mult,
                    card = card
                }
            end
        end

        -- Calculate multiplier when used
        if context.joker_main then
            return {
                xmult = card.ability.extra.Xmult
            }
        end
    end,
}
SMODS.Joker{
  key = 'elizabeth',
  loc_txt = {
    name = 'Elizabeth',
    text = {
      "Gain {X:mult,C:white}X#1#{} Mult if played hand",
      "Does not contain a {C:attention}King{}",
      "{C:inactive}[Currently {X:mult,C:white}X#2#{C:inactive} Mult]"
    }
  },
  rarity = 4,
  atlas = "Jokers", 
  pos = {x = 4, y = 7},
  soul_pos = {x = 3, y = 7},
  cost = 20,
  unlocked = true,
  discovered = false,
  eternal_compat = true,
  blueprint_compat = true,
  perishable_compat = false,

  config = {
    extra = {
      Xmult_add = 0.05,
      Xmult = 1,
    }
  },

  loc_vars = function(self, info_queue, card)
    return {
      vars = {
        card.ability.extra.Xmult_add or 0.05,
        card.ability.extra.Xmult or 1
      }
    }
  end,

  calculate = function(self, card, context)
    -- Only check once per full hand, not per card
    if context.cardarea == G.jokers and context.before and not context.blueprint then
      local has_king = false
      for _, c in ipairs(context.full_hand) do
        if c:get_id() == 13 then
          has_king = true
          break
        end
      end

      if not has_king then
        card.ability.extra.Xmult = (card.ability.extra.Xmult or 1) + (card.ability.extra.Xmult_add or 0.2)
        return {
          message = localize('k_upgrade_ex'),
          colour = G.C.Mult,
          card = card
        }
      end
    end

    -- Apply multiplier when joker effects resolve
    if context.joker_main then
      return {
        message = localize{type='variable', key='a_xmult', vars={card.ability.extra.Xmult or 1}},
        Xmult_mod = card.ability.extra.Xmult or 1
      }
    end
  end
}
--[[(
SMODS.Atlas{
    key = 'life', 
    path = 'life.png', 
    px = 71, 
    py = 95 
	}
	
SMODS.Joker {
    key = 'life', -- Changed to match the lookup below
    loc_txt = {
        name = 'life',
        text = {
            "animation test"
        }
    },
    rarity = 1,
    cost = 5,
    atlas = 'life',
    pos = { x = 0, y = 0 },
    blueprint_compat = true
	
}

-- Timer and Game:update override for animation logic
local upd = Game.update
punch_life_dt = 0

function Game:update(dt)
    upd(self, dt)
    punch_life_dt = punch_life_dt + dt

    if G.P_CENTERS and G.P_CENTERS.j_punch_life and punch_life_dt > 0.6 then ---lower=FASTER
        punch_life_dt = 0
        local obj = G.P_CENTERS.j_punch_life

        -- Simple animation: increment x, reset after hitting 20
        if obj.pos.x <= 10 then
            obj.pos.x = obj.pos.x + 1
        else
            obj.pos.x = 0
        end
    end
end

SMODS.Atlas{
    key = 'jittery', 
    path = 'jittery.png', 
    px = 71, 
    py = 95 
	}
SMODS.Joker {
    key = 'jittery', -- Changed to match the lookup below
    loc_txt = {
        name = 'jittery',
        text = {
            "animation test"
        }
    },
    rarity = 1,
    cost = 5,
    atlas = 'jittery',
    pos = { x = 0, y = 0 },
    blueprint_compat = true
	
}

-- Timer and Game:update override for animation logic
local upd = Game.update
punch_jittery_dt = 0

function Game:update(dt)
    upd(self, dt)
    punch_jittery_dt = punch_jittery_dt + dt

    if G.P_CENTERS and G.P_CENTERS.j_punch_jittery and punch_jittery_dt > 0.1 then ---lower=FASTER
        punch_jittery_dt = 0
        local obj = G.P_CENTERS.j_punch_jittery

        -- Simple animation: increment x, reset after hitting 20
        if obj.pos.x <= 2 then
            obj.pos.x = obj.pos.x + 1
        else
            obj.pos.x = 0
        end
    end
end
]]--


-----------------------------------------------------------------
--consumables
SMODS.Atlas{
    key = 'Consumables', 
    path = 'Consumables.png', 
    px = 71, 
    py = 95 
}
--relics are actually pretty cool I recognise most of these maybe i'll comment on them for you weirdos reading the code <3
SMODS.ConsumableType{
    key = 'Relics', --consumable type key

    collection_rows = {5,5}, --amount of cards in one page
    primary_colour = HEX("6E260E"), --first color
    secondary_colour = HEX("6E260E"), --second color
    loc_txt = {
        collection = 'Relics', --name displayed in collection
        name = 'Relics', --name displayed in badge
        undiscovered = {
            name = 'Hidden Relic', --undiscovered name
            text = {'You dont know about this relic'} --undiscovered text
        }
    },
    shop_rate = 1, --rate in shop out of 100
}

-- wheel of fortune but you suffer even more lol
SMODS.Consumable{
    key = 'wheel', -- key
    set = 'Relics', -- the set of the card: corresponds to a consumable type
    atlas = 'Consumables', -- atlas
    pos = {x = 1, y = 0}, -- position in atlas
    loc_txt = {
        name = 'Stone Wheel', -- name of card
        text = { -- text of card
            '{C:green}#3# in #2#{} chance to',
            'Add a random edition to {C:attention}#1#{} Jokers',
        }
    },
    config = {
        extra = {
            cards = 2, -- Jokers value
            odds = 8, -- Odds (3 in 8 chance by default)
        }
    },
    loc_vars = function(self, info_queue, center)
        if center and center.ability and center.ability.extra then
            return {vars = {center.ability.extra.cards, center.ability.extra.odds, G.GAME.probabilities.normal }} 
        end
        return {vars = {}}
    end,
    can_use = function(self, card)
        return #G.jokers.cards > 0
    end,
    use = function(self, card, area, copier)
        if not (G and card and card.ability and card.ability.extra) then
            print("Invalid game state or consumable configuration.")
            return
        end
        
        local maxCards = card.ability.extra.cards or 2
        local odds = card.ability.extra.odds or 8
        local selectedJokers = {}

        -- Collect all jokers as potential targets
        for _, joker in ipairs(G.jokers.cards) do
            table.insert(selectedJokers, joker)
        end

        if #selectedJokers == 0 then
            print("No jokers available for Stone Wheel.")
            return
        end

        -- Randomly select the specified number of jokers
        local targetCount = math.min(#selectedJokers, maxCards)
		if pseudorandom('death') < G.GAME.probabilities.normal/card.ability.extra.odds then
			for i = 1, targetCount do
				local randomIndex = math.random(#selectedJokers)
				local target = selectedJokers[randomIndex]
				table.remove(selectedJokers, randomIndex)

            -- Apply edition with chance
                target:set_edition(poll_edition('random key', nil, false, true))
            end
        end
    end,
}

-- yoooooo dr bright real!!
SMODS.Consumable{
    key = 'scp',
    set = 'Relics',
    atlas = 'Consumables',
    pos = {x = 3, y = 1},
    loc_txt = {
        name = 'SCP-963-1',
        text = {
            'Cannot be used',
            'Converts played cards to {C:attention}#1#{}',
			'{C:green}#4# in #5#{} chance to destroy them instead',
            'For the next {C:attention}#2#{} hands',
        }
    },
    config = {
        extra = { suit = nil, hands = 3, current_hand = 0, odds = 4 },
    },
    loc_vars = function(self, info_queue, center)
        if center and center.ability and center.ability.extra then
            local suit = center.ability.extra.suit or "First played Suit"
            local hands = center.ability.extra.hands
            local current_hand = center.ability.extra.current_hand
            local odds = center.ability.extra.odds
            return {vars = {suit, hands, current_hand, G.GAME.probabilities.normal, odds}}
        end
        return {vars = {}}
    end,
    can_use = function(self, card)
        return false
    end,
    calculate = function(self, card, context)
        if not (card and card.ability and card.ability.extra) then return end
        local extra = card.ability.extra

        local function detect_suit(c)
            if c:is_suit("Hearts") then return "Hearts" end
            if c:is_suit("Diamonds") then return "Diamonds" end
            if c:is_suit("Clubs") then return "Clubs" end
            if c:is_suit("Spades") then return "Spades" end
            return nil
        end

        if context.cardarea == G.consumeables and context.before and not context.blueprint then 
            extra.current_hand = extra.current_hand + 1
            if extra.current_hand == 1 and context.scoring_hand and #context.scoring_hand > 0 and not extra.suit then
                extra.suit = detect_suit(context.scoring_hand[1]) or "None"
                return
            end

            if extra.current_hand >= 2 and extra.current_hand <= 4 then
                for _, c in ipairs(context.scoring_hand) do
                    if pseudorandom('SCP') < G.GAME.probabilities.normal/card.ability.extra.odds then
                        c:start_dissolve()
                    else
                        SMODS.change_base(c, extra.suit)
                    end
                end
                extra.hands = extra.hands - 1
            end

            if extra.current_hand == 5 or extra.hands == 0 then
                card:start_dissolve()
            end
        end
    end
}

-- hey this book was in Fortnite! It's ash ketchums backbling!
SMODS.Consumable{
    key = 'necronomicon', -- key
    set = 'Relics', -- the set of the card: corresponds to a consumable type
    atlas = 'Consumables', -- atlas
    pos = {x = 1, y = 1}, -- position in atlas
    loc_txt = {
        name = 'Necronomicon', -- name of card
        text = { -- text of card
            'Every card has a {C:green}#1# in #2#{} chance to gain a random Enhancement',
            '{C:green}#1# in #3#{} chance to destroy them instead',
        }
    },
    config = {
        extra = {
            odds_e = 2, -- Odds for enhancement (1 in 4 chance)
            odds_d = 6, -- Odds for destruction (1 in 6 chance)
        }
    },
    loc_vars = function(self, info_queue, center)
        if center and center.ability and center.ability.extra then
            return {vars = {
                G.GAME.probabilities.normal, 
                center.ability.extra.odds_e, 
                center.ability.extra.odds_d
            }} 
        end
        return {vars = {}}
    end,
    can_use = function(self, card)
        return #G.hand.cards > 0 -- Only use if hand has cards
    end,
    use = function(self, card, area, copier)
        if not (G and card and card.ability and card.ability.extra) then
            print("Invalid game state or consumable configuration.")
            return
        end

        local odds_e = card.ability.extra.odds_e or 4 -- Enhancement odds
        local odds_d = card.ability.extra.odds_d or 6 -- Destruction odds

        -- Event Manager ensures all changes are processed correctly
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
            local valid_cards = {}
            for _, hand_card in ipairs(G.hand.cards) do
                if hand_card.config.center == G.P_CENTERS.c_base or hand_card.config.center ~= G.P_CENTERS.c_base  then
                    table.insert(valid_cards, hand_card)
                end
            end

            for _, target in ipairs(valid_cards) do
                local rand_value = pseudorandom('necronomicon')

                -- Enhancement Chance
                if rand_value < G.GAME.probabilities.normal / odds_e then
                    local enhancement_key = {key = 'upgrade', guaranteed = true}
                    local random_enhancement = G.P_CENTERS[SMODS.poll_enhancement(enhancement_key)]
                    target:set_ability(random_enhancement, nil, true)
                    target:juice_up()
                end

                -- Destruction Chance
                if rand_value < G.GAME.probabilities.normal / odds_d then
                    target:start_dissolve()
                end
            end

            return true
        end}))
    end,
}

-- egg
SMODS.Consumable{
    key = 'egg', -- key
    set = 'Relics', -- the set of the card: corresponds to a consumable type
    atlas = 'Consumables', -- atlas
    pos = {x = 7, y = 0}, -- position in atlas
    loc_txt = {
        name = 'Dinosaur Egg', -- name of card
        text = { -- text of card
            'Give {C:attention}#1#{} random {C:dark_edition}Negative{} {C:planet}Planet{} and {C:tarot}Tarot{} card',
            'Per every {C:attention}2{} antes',
        }
    },
    config = {
        extra = {
            cards = 1, -- Number of Negative Planet and Tarot cards to give
        }
    },
    loc_vars = function(self, info_queue, center)
        if center and center.ability and center.ability.extra then
            return {vars = {center.ability.extra.cards}} 
        end
        return {vars = {}}
    end,
    can_use = function(self, card)
        return true -- Always usable
    end,
    use = function(self, card, area, copier)
        if not (G and card and card.ability and card.ability.extra) then
            print("Invalid game state or consumable configuration.")
            return
        end

        local extra = card.ability.extra
        local current_ante = G.GAME.round_resets.ante or 0

        if current_ante <= 1 then
            local type = math.random(2) == 1 and 'Planet' or 'Tarot'
            local neg_card = create_card(type, G.consumeables)
            if neg_card then
                neg_card:set_edition({negative = true}, true)
                G.consumeables:emplace(neg_card)
            end
            return
        end

        -- Adjust to nearest even ante above 2
        local adjusted_ante = math.max(2, current_ante - (current_ante % 2))
        local cards_to_give = math.floor(extra.cards * (adjusted_ante / 2))

        -- Give Negative Planet and Tarot cards
        for i = 1, cards_to_give do
            local neg_planet = create_card('Planet', G.consumeables)
            if neg_planet then
                neg_planet:set_edition({negative = true}, true)
                G.consumeables:emplace(neg_planet)
            end

            local neg_tarot = create_card('Tarot', G.consumeables)
            if neg_tarot then
                neg_tarot:set_edition({negative = true}, true)
                G.consumeables:emplace(neg_tarot)
            end
        end
    end,
}

-- imagine making a product so bad that complaints about it from 3700 years ago still exist 💀
SMODS.Consumable{
    key = 'tablet',
    set = 'Relics',
    atlas = 'Consumables',
    pos = {x = 6, y = 0},
    loc_txt = {
        name = 'Ea-nāṣir\'s Tablet',
        text = {
            'Refund half the price of all used {C:punch_relics}Relics'
        }
    },
    config = { extra = { dollars = 0 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,

    can_use = function(self, card)
        return true -- Always usable
    end,

    use = function(self, card, area, copier)
    -- Ensure the table exists
    local usage = G.GAME.consumeable_usage or {}
    
    -- Count all used relics (3$ each)
    local wheel = (usage['c_punch_wheel'] and usage['c_punch_wheel'].count) or 0
    local egg = (usage['c_punch_egg'] and usage['c_punch_egg'].count) or 0
    local necro = (usage['c_punch_necronomicon'] and usage['c_punch_necronomicon'].count) or 0
    local tablet = (usage['c_punch_tablet'] and usage['c_punch_tablet'].count) or 0
	local holy = (usage['c_punch_holy'] and usage['c_punch_holy'].count) or 0
	local pandora = (usage['c_punch_pandora'] and usage['c_punch_pandora'].count) or 0
	local mask = (usage['c_punch_mask'] and usage['c_punch_mask'].count) or 0
    local grail = (usage['c_punch_grail'] and usage['c_punch_grail'].count) or 0
	local paw = (usage['c_punch_paw'] and usage['c_punch_paw'].count) or 0
	local paws = paw / 5
	
    local totals = tablet + egg + necro + wheel + holy + pandora + mask + grail + paws
    local total_spent = totals * 3

    -- Calculate refund (half of total spent)
    local refund = math.floor(total_spent / 2)
    card.ability.extra.dollars = refund

    -- Apply the refund immediately
    if refund > 0 then
        ease_dollars(refund)
        G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + refund
    else
        print("No relics used. No refund. this shouldnt happen?")
    end

    -- Reset all relic counts
    if usage['c_punch_wheel'] then usage['c_punch_wheel'].count = 0 end
    if usage['c_punch_egg'] then usage['c_punch_egg'].count = 0 end
    if usage['c_punch_necronomicon'] then usage['c_punch_necronomicon'].count = 0 end
    if usage['c_punch_tablet'] then usage['c_punch_tablet'].count = 0 end
	if usage['c_punch_holy'] then usage['c_punch_holy'].count = 0 end
	if usage['c_punch_pandora'] then usage['c_punch_pandora'].count = 0 end
	if usage['c_punch_mask'] then usage['c_punch_mask'].count = 0 end
	if usage['c_punch_grail'] then usage['c_punch_grail'].count = 0 end
	if usage['c_punch_paw'] then usage['c_punch_paw'].count = 0 end
end,
}
--'Tis but a scratch.
SMODS.Consumable{
    key = 'holy',
    set = 'Relics',
    atlas = 'Consumables',
    pos = {x = 0, y = 0},
    loc_txt = {
        name = 'Holy Nade',
        text = {
            'Apply a random tarot effect up to {C:attention}#1#{} selected cards',
            'Also apply to adjacent cards',
        }
    },
    config = {
        extra = {
            cards = 1, -- configurable value
        }
    },
    loc_vars = function(self, info_queue, center)
        if center and center.ability and center.ability.extra then
            return {vars = {center.ability.extra.cards}} 
        end
        return {vars = {}}
    end,
    can_use = function(self, card)
        return G and G.hand and G.hand.highlighted and card.ability and card.ability.extra and 
            card.ability.extra.cards and #G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.extra.cards
    end,

    -- List of possible tarot effects using set_ability
    random_tarot_effects = {
        G.P_CENTERS.m_steel, -- Steel Tarot
        G.P_CENTERS.m_glass, -- Glass Tarot
        G.P_CENTERS.m_stone, -- Stone Tarot
        G.P_CENTERS.m_gold, -- Gold Tarot
        G.P_CENTERS.m_lucky, -- Lucky Tarot
		G.P_CENTERS.m_mult, -- Mult Tarot
		G.P_CENTERS.m_bonus, -- Bonus Tarot
		G.P_CENTERS.m_wild, --Wild Tarot
    },

    use = function(self, card, area, copier)
        if G and G.hand and G.hand.highlighted and #G.hand.highlighted > 0 then
            for _, selected_card in ipairs(G.hand.highlighted) do
                -- Apply random tarot effect to the selected card
                local effect = self.random_tarot_effects[math.random(#self.random_tarot_effects)]
                selected_card:set_ability(effect)

                -- Find adjacent cards
                local left_card, right_card
                for i = 1, #G.hand.cards do
                    if G.hand.cards[i] == selected_card then
                        left_card = G.hand.cards[i-1]
                        right_card = G.hand.cards[i+1]
                        break
                    end
                end

                -- Apply to adjacent cards
                if left_card then left_card:set_ability(effect) end
                if right_card then right_card:set_ability(effect) end

                -- Juice-up visual effect
                G.E_MANAGER:add_event(Event({
                    func = function()
                        selected_card:juice_up()
                        if left_card then left_card:juice_up() end
                        if right_card then right_card:juice_up() end
                        return true
                    end
                }))
            end
        end
    end,
}
--maybe the missing link was the friends we made along the way
SMODS.Consumable({
    key = 'link',
    set = 'Relics',
    atlas = 'Consumables',
    pos = {x = 3, y = 0},
    loc_txt = {
        name = 'Missing Link',
        text = {
            'The next {C:attention}#1# {C:mult}discarded{} cards',
            'Become {C:hearts}Wild{}',
        }
    },
    config = {
        extra = { cards = 5, used = 0 },
    },

    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_wild
        if center and center.ability and center.ability.extra then
            local cards = center.ability.extra.cards
            return {vars = { cards }}
        end
        return {vars = {}}
    end,

    can_use = function(self, card)
        return card.ability.extra.used == 0
    end,

    use = function(self, card, area, copier)
        local _card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, 'c_punch_link')
        _card:add_to_deck()
        G.vouchers:emplace(_card)

        _card.ability.extra.used = 1
    end,

    calculate = function(self, card, context)
        if not (card and card.ability and card.ability.extra) then return end
        local extra = card.ability.extra

        if context.discard and context.other_card and extra.used == 1 then
            if extra.cards > 0 then
                context.other_card:set_ability(G.P_CENTERS.m_wild)
                extra.cards = extra.cards - 1
            end

            if extra.cards <= 0 then
                card:start_dissolve()
            end
        end
    end
})


--hey this was in Fortnite that one time! But then malaria opened it and hope was upset.
SMODS.Consumable{
    key = 'pandora',
    set = 'Relics',
    atlas = 'Consumables',
    pos = {x = 4, y = 0},
    loc_txt = {
        name = 'Pandora\'s Box',
        text = {
            'Turns {C:attention}half{} your hand into the {C:attention}highest rank{} in hand',
			'Turn the other {C:attention}half{} into {C:attention}lowest rank{} in hand',
        }
    },
    config = {
        extra = {
            cards = 2, -- Configurable value (default to 2 cards)
        },
    },
    loc_vars = function(self, info_queue, center)
        if center and center.ability and center.ability.extra then
            return {vars = {center.ability.extra.cards}} 
        end
        return {vars = {}}
    end,

    can_use = function(self, card)
        return G and G.hand and #G.hand.cards > 0
    end,

    use = function(self, card, area, copier)
        if G and G.hand and G.hand.cards then
            local highest_id = 0
            local lowest_id = math.huge

            -- Find highest and lowest card IDs in hand
            for _, hand_card in ipairs(G.hand.cards) do
                local id = hand_card:get_id()
                if id then
                    if id > highest_id then highest_id = id end
                    if id < lowest_id then lowest_id = id end
                end
            end

            if highest_id == 0 or lowest_id == math.huge then return end

            local function id_to_rank(id)
                if id == 11 then return 'J' end
                if id == 12 then return 'Q' end
                if id == 13 then return 'K' end
                if id == 14 then return 'A' end
                return tostring(id)
            end

            local highest_rank = id_to_rank(highest_id)
            local lowest_rank = id_to_rank(lowest_id)

            local hand_cards = {}
            for i, c in ipairs(G.hand.cards) do hand_cards[i] = c end
            -- Shuffle to randomize which cards get transformed
            for i = #hand_cards, 2, -1 do
                local j = math.random(i)
                hand_cards[i], hand_cards[j] = hand_cards[j], hand_cards[i]
            end

            local half_count = math.floor(#hand_cards / 2)

            -- Transform first half into highest rank
            for i = 1, half_count do
                local hand_card = hand_cards[i]
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        hand_card:flip()
                        play_sound("tarot1", 1.0, 0.6)
                        hand_card:juice_up(0.3, 0.3)

                        local suit_prefix = string.sub(hand_card.base.suit, 1, 1)..'_'
                        hand_card:set_base(G.P_CARDS[suit_prefix..highest_rank])

                        hand_card:flip()
                        play_sound("tarot2", 1.0, 0.6)
                        hand_card:juice_up(0.3, 0.3)
                        return true
                    end
                }))
            end

            -- Transform second half into lowest rank
            for i = half_count + 1, #hand_cards do
                local hand_card = hand_cards[i]
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        hand_card:flip()
                        play_sound("tarot1", 1.0, 0.6)
                        hand_card:juice_up(0.3, 0.3)

                        local suit_prefix = string.sub(hand_card.base.suit, 1, 1)..'_'
                        hand_card:set_base(G.P_CARDS[suit_prefix..lowest_rank])

                        hand_card:flip()
                        play_sound("tarot2", 1.0, 0.6)
                        hand_card:juice_up(0.3, 0.3)
                        return true
                    end
                }))
            end
        end
    end,
}

-- 🎵 So wear the mask play the part of someone harder in the heart and never someone easy to break 🎵
SMODS.Consumable{
    key = 'mask',
    set = 'Relics',
    atlas = 'Consumables',
    pos = {x = 2, y = 1},
    loc_txt = {
        name = 'Stone Mask',
        text = {
            'Changes all {C:attention}#1#\'s{} in hand to {C:attention}#2#\'s{}',
        }
    },
    config = {
        extra = {
            selected_rank = math.random(2, 14), -- Random initial value (2-A)
            new_rank = math.random(2, 14), -- Random initial value (2-A)
        },
    },
    loc_vars = function(self, info_queue, card)
        local rank_names = { [11] = 'J', [12] = 'Q', [13] = 'K', [14] = 'A' }
        return {
            vars = {
                rank_names[card.ability.extra.selected_rank] or card.ability.extra.selected_rank,
                rank_names[card.ability.extra.new_rank] or card.ability.extra.new_rank,
            }
        }
    end,
    
    calculate = function(self, card, context)
        if context.hand_drawn then
            if G and G.hand and G.hand.cards then
                local available_ids = {}
                for _, hand_card in ipairs(G.hand.cards) do
                    table.insert(available_ids, hand_card:get_id())
                end

                if #available_ids == 0 then return end
                card.ability.extra.selected_rank = available_ids[math.random(#available_ids)]
                card.ability.extra.new_rank = math.random(2, 14)
            end
        end
    end,

    can_use = function(self, card)
        return G and G.hand and #G.hand.cards > 0
    end,
    
    use = function(self, card, area, copier)
        if G and G.hand and G.hand.cards then
            local selected_id = card.ability.extra.selected_rank
            local new_rank = card.ability.extra.new_rank

            local rank_names = { [10] = 'T', [11] = 'J', [12] = 'Q', [13] = 'K', [14] = 'A' }

            for _, hand_card in ipairs(G.hand.cards) do
                if hand_card:get_id() == selected_id then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.1,
                        func = function()
                            hand_card:flip()
                            play_sound("tarot1", 1.0, 0.6)
                            hand_card:juice_up(0.3, 0.3)
                            
                            local suit_prefix = string.sub(hand_card.base.suit, 1, 1)..'_'
                            hand_card:set_base(G.P_CARDS[suit_prefix..(rank_names[new_rank] or new_rank)])

                            hand_card:flip()
                            play_sound("tarot2", 1.0, 0.6)
                            hand_card:juice_up(0.3, 0.3)
                            return true
                        end
                    }))
                end
            end
        end
    end,
}

SMODS.Consumable{
    key = 'grail',
    set = 'Relics',
    atlas = 'Consumables',
    pos = {x = 6, y = 1},
    loc_txt = {
        name = 'Holy Grail',
        text = {
            'Add {C:attention}+#1#{} to card selection on currently held consumables',
        }
    },
    config = {
        extra = {
			cards = 1,
        }
    },
    loc_vars = function(self, info_queue, center)
        if center and center.ability and center.ability.extra then
            return {vars = {center.ability.extra.cards}} 
        end
        return {vars = {}}
    end,

    can_use = function(self, card)
        return G and G.consumeables and G.consumeables.cards and #G.consumeables.cards > 0
    end,

    use = function(self, card, area, copier)
        self:apply_grail(card)
    end,


apply_grail = function(self, card)
        -- Apply to all consumables
        if G and G.consumeables and G.consumeables.cards then
            for _, consumable in ipairs(G.consumeables.cards) do
                if consumable.ability and consumable.ability.set ~= 'Planet' then
                    local extra = consumable.ability.extra
                    if type(extra) == "table" then
                        for key, value in pairs(extra) do
                            if type(value) == "number" then
                                extra[key] = value + card.ability.extra.cards
                            end
                        end
                    else
                        consumable.ability.max_highlighted = (consumable.ability.max_highlighted or 0) + card.ability.extra.cards
                        if consumable.ability.consumeable then
                            consumable.ability.consumeable.max_highlighted = 
                                (consumable.ability.consumeable.max_highlighted or 0) + card.ability.extra.cards
                        end
                    end
                end
            end
        end
    end
}


SMODS.Consumable{
    key = 'paw', -- key
    set = 'Relics', -- the set of the card: corresponds to a consumable type
    atlas = 'Consumables', -- eating a burger with no honey mustard
    pos = {x = 2, y = 0}, -- position in atlas
    loc_txt = {
        name = 'Monkey Paw', -- name of card
        text = { -- text of card
            'Gives {C:chips}#1# Hands{} and {C:mult}#2# Discards{} next round',
            '{C:attention}#3#{} uses left',
        }
    },
    config = {
        extra = {
            hands = 1, discards = -1, uses = 5, hands_add = 0, discards_lose = 0 -- configurable values
        },
    },
    loc_vars = function(self, info_queue, center)
        if center and center.ability and center.ability.extra then
            return {vars = {center.ability.extra.hands, center.ability.extra.discards, center.ability.extra.uses, center.ability.extra.hands_add, center.ability.extra.discards_lose}} 
        end
        return {vars = {}}
    end,

    can_use = function(self, card)
        return card.ability.extra.uses > 0
    end,

    use = function(self, card, area, copier)
        card.ability.extra.uses = card.ability.extra.uses - 1
        card.ability.extra.hands_add = card.ability.extra.hands_add + 1
        card.ability.extra.discards_lose = card.ability.extra.discards_lose - 1

        local _card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, 'c_punch_paw')
        _card:add_to_deck()
        G.consumeables:emplace(_card)

        _card.ability.extra.uses = card.ability.extra.uses 
        _card.ability.extra.hands_add = card.ability.extra.hands_add
        _card.ability.extra.discards_lose = card.ability.extra.discards_lose
    end,

    calculate = function(self, card, context)
        if context.setting_blind then
            G.E_MANAGER:add_event(Event({
                trigger = 'after', delay = 0.1,
                func = function()
                    ease_hands_played(card.ability.extra.hands_add or 1)
                    ease_discard(card.ability.extra.discards_lose or 1)
					card.ability.extra.hands_add = 0
					card.ability.extra.discards_lose = 0
                    return true
                end
            }))
			if card.ability.extra.uses == 0 then
				card:start_dissolve()
			end
        end
    end,
}

SMODS.Consumable{
    key = 'lamp', -- key
    set = 'Relics', -- the set of the card: corresponds to a consumable type
    atlas = 'Consumables', -- atlas
    pos = {x = 4, y = 1}, -- position in atlas
    loc_txt = {
        name = 'Genie Lamp', -- name of card
        text = { -- text of card
            'Meet the genie and make {C:attention}3{} wishes',
			'Current wish: #1#',
            '{C:attention}#2#{} wishes left',
        }
    },
    config = {
        extra = {
            wish = 'give me money', uses = 3, handsize = 2,  -- configurable values
        },
    },
    loc_vars = function(self, info_queue, center)
        if center and center.ability and center.ability.extra then
            return {vars = {center.ability.extra.wish, center.ability.extra.uses }} 
        end
        return {vars = {}}
    end,

    can_use = function(self, card)
        return card.ability.extra.uses > 0
    end,

    use = function(self, card, area, copier)
		if card.ability.extra.wish == 'give me money' then
			local reward = to_big(G.GAME.dollars) / 3
			ease_dollars(reward)
			card.ability.extra.uses = card.ability.extra.uses - 1
		
			local _card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, 'c_punch_lamp')
			_card:add_to_deck()
			G.consumeables:emplace(_card)

			_card.ability.extra.uses = card.ability.extra.uses 
			_card.ability.extra.wish = 'give me hands'
		end
		
		if card.ability.extra.wish == 'give me hands' then
			G.GAME.round_resets.hands = G.GAME.round_resets.hands + 2
			ease_hands_played(2)
			card.ability.extra.uses = card.ability.extra.uses - 1
		
			local _card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, 'c_punch_lamp')
			_card:add_to_deck()
			G.consumeables:emplace(_card)

			_card.ability.extra.uses = card.ability.extra.uses 
			_card.ability.extra.wish = 'give me handsize'
		end
		
		if card.ability.extra.wish == 'give me handsize' then
			G.hand.config.card_limit = G.hand.config.card_limit + 2
		end
    end,
}

--Implement G.GAME.cards_destroyed_count for space dagger
-- Save original method
local start_dissolve_original = Card.start_dissolve

-- Override method
function Card:start_dissolve(...)

    -- Initialize and increment total destroyed count
    G.GAME.cards_destroyed_count = (G.GAME.cards_destroyed_count or 0) + 1

    -- Call original method to keep normal dissolve behavior
    return start_dissolve_original(self, ...)
end


SMODS.Consumable{
    key = 'space',
    set = 'Relics',
    atlas = 'Consumables',
    pos = {x = 5, y = 1},
    loc_txt = {
        name = 'Space Dagger',
        text = {
            'Level up most played hand by {C:attention}1{}',
			'For every {C:attention}2{} cards {C:mult}destroyed{}',
        }
    },
    config = {
        extra = {
            level = 1
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.level
            }
        }
    end,

    can_use = function(self, card)
        return true
    end,
	
	-- G.GAME.cards_destroyed_count is not a base game function check above if you want to implement this
    use = function(self, card, area, copier)
		card.ability.extra.level = G.GAME.cards_destroyed_count / 3 --unsure why i have to divide by 3 here to get every 2 destroyed but it works
        local most_played = nil
        local max_played = 0
        for k, v in pairs(G.GAME.hands) do
            if v.visible and v.played > max_played then
                max_played = v.played
                most_played = k
            end
        end

        if most_played then
            local hand_data = G.GAME.hands[most_played]

            update_hand_text(
                {sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3},
                {
                    handname = localize(most_played, 'poker_hands'),
                    chips = hand_data.chips,
                    mult = hand_data.mult,
                    level = hand_data.level
                }
            )

            for i = 1, card.ability.extra.level do
                level_up_hand(card, most_played)
            end

            update_hand_text(
                {sound = 'button', volume = 0.7, pitch = 1.1, delay = 0},
                {mult = 0, chips = 0, handname = '', level = ''}
            )
        end
    end
}

SMODS.Consumable{
    key = 'corn',
    set = 'Relics',
    atlas = 'Consumables',
    pos = {x = 7, y = 1},
    loc_txt = {
        name = 'Cornucopia',
        text = {
            '{C:attention}#1#{} more card for the next booster pack used',
        }
    },
    config = {
        extra = {
            choices = 1
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.choices
            }
        }
    end,
	
	can_use = function(self, card)
		return true
	end,
	use = function(self, card, area, copier)
		G.GAME.cry_oboe = (G.GAME.cry_oboe or 0) + card.ability.extra.choices
	end,
}

SMODS.Consumable{
    key = 'xiu',
    set = 'Relics',
    atlas = 'Consumables',
    pos = {x = 5, y = 0},
    loc_txt = {
        name = 'Xiuhpghualli',
        text = {
            'Double the next {C:planet}planet{} you {C:attention}use{}'
        }
    },
    config = {
        extra = {
            used = 0,
            hand_snapshot = {}
        }
    },

    loc_vars = function(self, info_queue, center)
        return {vars = {}}
    end,

    add_to_deck = function(self, card)
        if card.ability.extra.used == 0 then
            card.ability.extra.used = 1

            -- Store only level snapshot
            card.ability.extra.hand_snapshot = {}
            for k, v in pairs(G.GAME.hands) do
                card.ability.extra.hand_snapshot[k] = v.level or 0
            end
        end
    end,

    can_use = function(self, card)
        return card.ability.extra.used ~= 2 
    end,

    use = function(self, card, area, copier)
        card.ability.extra.used = 2
        card:start_dissolve()

        -- Snapshot levels
        card.ability.extra.hand_snapshot = {}
        for k, v in pairs(G.GAME.hands) do
            card.ability.extra.hand_snapshot[k] = v.level or 0
        end

        -- Duplicate card
        local _card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, 'c_punch_xiu')
        _card.ability.extra.used = 2
        _card.ability.extra.hand_snapshot = {}
        for k, v in pairs(G.GAME.hands) do
            _card.ability.extra.hand_snapshot[k] = v.level or 0
        end

        _card:add_to_deck()
        G.vouchers:emplace(_card)
    end,

    calculate = function(self, card, context)
        if card.ability.extra.used == 2 
        and context.using_consumeable
        and context.consumeable
        and context.consumeable.config
        and context.consumeable.config.center
        and context.consumeable.config.center.set == 'Planet' then

            local snapshot = card.ability.extra.hand_snapshot
            for k, v in pairs(G.GAME.hands) do
                local old_level = snapshot[k]
                if old_level and v.level ~= old_level then

                    -- First update: current hand info
                    update_hand_text(
                        {sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3},
                        {
                            handname = localize(k, 'poker_hands'),
                            chips = v.chips,
                            mult = v.mult,
                            level = v.level
                        }
                    )

                    level_up_hand(card, k)
                    card:start_dissolve()

                    local _card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, 'c_punch_xiu')
                    _card:add_to_deck()
                    G.play:emplace(_card)
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.1,
                        func = function()
                            _card:start_dissolve()
							return true
                        end
                    }))

                    -- Clear update popup
                    update_hand_text(
                        {sound = 'button', volume = 0.7, pitch = 1.1, delay = 0},
                        {mult = 0, chips = 0, handname = '', level = ''}
                    )

                    break
                end
            end

            card.ability.extra.used = 2
        end
    end
}


--blinds
SMODS.Atlas({ key = "BlindChips", atlas_table = "ANIMATION_ATLAS", path = "BlindChips.png", px = 34, py = 34, frames = 21 })

SMODS.Blind({
    loc_txt = {
        name = 'The Loser',
        text = { 'First hand draws ', 'the lowest ranked cards' }
    },
    key = 'Loser',
    name = 'The Loser',
    atlas = 'BlindChips',
    pos = {x = 0, y = 0},
    dollars = 5,
    boss = {min = 1, max = 10, hardcore = true},
    boss_colour = HEX("237875"),
    config = {
        extra = {
            ranks = {},
            cards = 0,
            _tracked_hologram = nil,
            _tracked_value = nil
        }
    }, 

    -- Trigger effect immediately when the blind is activated
    set_blind = function(self)
        -- Dynamically set 'cards' to the value of G.hand.config.card_limit
        self.config.extra.cards = G.hand.config.card_limit

        local possible_ranks = {}
        
        -- Gather all cards and find their rank using SMODS.Ranks
        for _, card in pairs(G.deck.cards) do
            if not card.config.center.no_rank then
                local rank_value = SMODS.Ranks[card.base.value] and SMODS.Ranks[card.base.value].nominal or 0
                table.insert(possible_ranks, {id = card:get_id(), rank = rank_value})
            end
        end

        -- Sort by rank (lowest first)
        table.sort(possible_ranks, function(a, b) return a.rank < b.rank end)

        -- Store the lowest ranked cards based on cards count
        self.config.extra.ranks = {}
        for i = 1, math.min(#possible_ranks, self.config.extra.cards) do
            table.insert(self.config.extra.ranks, possible_ranks[i].id)
        end

        -- Create copies of the selected cards and add them to the hand
        local new_cards = {}
        for _, card_id in ipairs(self.config.extra.ranks) do
            local card = nil
            for _, c in pairs(G.deck.cards) do
                if c:get_id() == card_id then
                    card = c
                    break
                end
            end

            -- Ensure the card exists before trying to remove it
            if card then
                -- Create a copy of the card without negative edition
                local _card = copy_card(card)

                -- Add the copy to the deck and hand
                _card:add_to_deck()
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                table.insert(G.playing_cards, _card)
                G.hand:emplace(_card)

                -- Start materializing the new card with visual feedback
                _card:start_materialize(nil, nil)
                new_cards[#new_cards + 1] = _card

                -- Destroy the original card after copying it
                card:start_dissolve()

                -- Remove the original card from the deck and hand
                G.deck:remove_card(card)
            else
                -- Log or handle the error where the card doesn't exist
                print("Card with ID " .. tostring(card_id) .. " not found in deck.")
            end
        end

        -- Apply any additional effects to the new cards if necessary
        playing_card_joker_effects(new_cards)

        -- Clear ranks after drawing
        self.config.extra.ranks = {}

        -- Apply the Hologram fix using the new function
        self:apply_hologram_fix()
        
        -- Mark the blind as triggered (instant trigger)
        self.triggered = true
        G.GAME.blind:set_text()
    end,
	-- This next part of code is rated pg 18 readers discretion is advised 

	--[[Fuck you, Hologram! If you're dumb enough to buy a new card this weekend, you're a big enough schmuck to come to Big Jimbo Hell's Cards! 
	Bad deals! Cards that break down! Thieves! If you think you're going to find a bargain at Big Jimbo's, you can kiss my ass!
	It's our belief that you're such a stupid motherfucker, you'll fall for this bullshit—guaranteed! If you find a better deal, shove it up your ugly ass!
	You heard us right! Shove it up your ugly ass! Bring your trade! Bring your title! Bring your Jokers! We'll fuck them! That's right! We'll fuck your Jokers!
	Because at Big Jimbo Hell's, you're fucked six ways from Sunday! Take a hike to Big Jimbo Hell's—Home of Challenge Pissing! That's right! Challenge Pissing!
	How does it work? If you can piss six feet in the air straight up and not get wet, you get X10 Mult!
	Don't wait! Don't delay! Don't fuck with us, or we'll rip your Mult off! Only at Big Jimbo Hell's, the only dealer that tells you to fuck off!
	Hurry up, asshole! This event ends the minute after you play a hand, and it better score or you're a dead motherfucker!
	Go to hell—Big Jimbo Hell's Cars! Balatro's filthiest and exclusive home of the meanest sons-of-bitches in the state of Indiana—guaranteed!
	--]]
	
    -- Apply Hologram Fix like Luck Magnet
    apply_hologram_fix = function(self)
        local tracked = self.config.extra
        local hologram_value = 0.25
        local hologram_fix = self.config.extra.cards * hologram_value
        local hologram = SMODS.find_card('j_hologram')[1]  -- Track Hologram

        -- Restore previous x_mult if tracked and not the same
        if tracked._tracked_hologram and tracked._tracked_hologram ~= hologram then
            tracked._tracked_hologram.ability.x_mult = tracked._tracked_value
            tracked._tracked_hologram = nil
            tracked._tracked_value = nil
        end

        -- Apply fix to the new Hologram Joker
        if hologram then
            -- Store original x_mult
            if not tracked._tracked_hologram then
                tracked._tracked_hologram = hologram
                tracked._tracked_value = hologram.ability.x_mult
            end
            -- Set the fixed value
            hologram.ability.x_mult = hologram.ability.x_mult - hologram_fix
        end
    end
})

SMODS.Blind {
    loc_txt = {
        name = 'The Champion',
        text = { 'Must play highest',
		'ranked card in hand' }
    },
    key = 'Champion',
    name = 'The Champion',
    config = {
        highest_id = 0
    },
    boss = { min = 1, max = 10, hardcore = true },
    boss_colour = HEX("f6ab1b"),
    atlas = "BlindChips",
    pos = { x = 0, y = 1 },
    dollars = 5,

    drawn_to_hand = function(self)
        -- Track the highest ID from cards drawn to hand
        self:recalculate_highest_id(G.hand.cards)
    end,

    recalculate_highest_id = function(self, cards)
        -- Recalculate highest ID whenever cards are drawn or discarded
        self.config.highest_id = 0 -- Reset to zero before recalculating
        for _, card in ipairs(cards) do
            local id = card:get_id()
            if id and id > self.config.highest_id then
                self.config.highest_id = id
            end
        end
    end,

    debuff_hand = function(self, cards, hand, handname, check)
        -- Disallow hand if it doesn't contain the highest ID card
        local contains_highest = false
        for _, card in ipairs(cards) do
            if card:get_id() == self.config.highest_id then
                contains_highest = true
                break
            end
        end

        if not contains_highest then
            -- Recalculate the highest ID in case it was discarded
            self:recalculate_highest_id(G.hand.cards)
            return true -- Block hand if it doesn't contain the highest ID card
        end

        return false -- Valid hand (contains the highest ID card)
    end
}

SMODS.Blind {
    loc_txt = {
        name = 'The Truth',
        text = { 'Ignores all seals, enhancements,',
		'and editions for cards played' }
    },
    key = 'Truth',
    name = 'The Truth',
    config = {},
    boss = { min = 1, max = 10, hardcore = true },
    boss_colour = HEX("7f7373"),
    atlas = "BlindChips",
    pos = { x = 0, y = 2 },
    dollars = 5,

    press_play = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                for _, card in ipairs(G.play.cards) do
                    card._truth_backup = {
                        seal = card.seal,
                        edition = card.edition,
                        ability_key = card.config.center
                    }

                    if card.ability then
                        card:set_ability(G.P_CENTERS.c_base)
                        card.seal = nil
                        card.edition = nil
                    end
                end
                return true
            end
        }))
        return true
    end,

    drawn_to_hand = function(self)
        for _, pile in ipairs({G.play, G.hand, G.discard}) do
            for _, card in ipairs(pile.cards) do
                if card._truth_backup then
                    if card._truth_backup.ability_key then
                        card:set_ability(card._truth_backup.ability_key)
                    else
                        card:set_ability(G.P_CENTERS.c_base)
                    end
                    card.seal = card._truth_backup.seal
                    card.edition = card._truth_backup.edition
                    card._truth_backup = nil
                end
            end
        end
 end,
	
	defeat = function(self)
        for _, pile in ipairs({G.play, G.hand, G.discard}) do
            for _, card in ipairs(pile.cards) do
                if card._truth_backup then
                    if card._truth_backup.ability_key then
                        card:set_ability(card._truth_backup.ability_key)
                    else
                        card:set_ability(G.P_CENTERS.c_base)
                    end
                    card.seal = card._truth_backup.seal
                    card.edition = card._truth_backup.edition
                    card._truth_backup = nil
                end
            end
        end
    end
}


SMODS.Blind {
    loc_txt = {
        name = 'Agate Balance',
        text = { 'Hands and Discards',
		'remaining are always equal' }
    },
    key = 'Balance',
    name = 'Agate Balance',
    boss = {showdown = true, min = 10, max = 10, hardcore = true}, 
    showdown = true,			
    boss_colour = HEX("d7cc0d"),
    atlas = "BlindChips",
    pos = { x = 0, y = 25 },
    dollars = 8,

    drawn_to_hand = function(self)
        self:sync_remaining_uses()
    end,

    use_discard = function(self)
        self:sync_remaining_uses()
    end,

    sync_remaining_uses = function(self)
        if G.GAME and G.GAME.current_round then
            local remaining_hands = G.GAME.current_round.hands_left
            local remaining_discards = G.GAME.current_round.discards_left
            local min_value = math.min(remaining_hands, remaining_discards)

            G.GAME.current_round.hands_left = min_value
            G.GAME.current_round.discards_left = min_value

            if min_value == 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.STATE = G.STATES.HAND_PLAYED
						G.STATE_COMPLETE = true
						end_round()
                        return true
                    end
                }))
            end
        end
    end,
}

-- tags

SMODS.Atlas{
    key = 'tags', 
    path = 'tags.png', 
    px = 17, 
    py = 17, 
}

SMODS.Tag{
    key = 'RelicTag1',
    atlas = 'tags',
    pos = {x = 0, y = 0},
    name = "Treasure Tag",
    order = 1,
    min_ante = 1,
    loc_txt = {
        name = 'Treasure Tag',
        text = {
            'Gives a free',
            '{C:punch_relics}Mega Relic Pack'
        },
    },
    config = {type = "new_blind_choice"},
    apply = function(self, tag, context)
        if context.type == "new_blind_choice" then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true

            tag:yep('+', G.C.SECONDARY_SET.Spectral, function()
                -- Corrected key generation
                local key = 'p_punch_RelicBooster7'

                -- Validate the center exists
                local center = G.P_CENTERS[key]
                if not center then
                    print("Error: Center not found for key: " .. key)
                    G.CONTROLLER.locks[lock] = nil
                    return false -- Exit safely
                end

                -- Create the card with the validated center
                local card = Card(
                    G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2,
                    G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2,
                    G.CARD_W * 1.27, 
                    G.CARD_H * 1.27, 
                    G.P_CARDS.empty, 
                    center, 
                    {bypass_discovery_center = true, bypass_discovery_ui = true}
                )
                card.cost = 0
                card.from_tag = true

                -- Use the card and materialize it
                G.FUNCS.use_card({config = {ref_table = card}})
                card:start_materialize()
                G.CONTROLLER.locks[lock] = nil
                return true
            end)

            tag.triggered = true
            return true
        end
    end,
}


-- boosters

SMODS.Atlas{
    key = 'Boosters', 
    path = 'Boosters.png', 
    px = 71, 
    py = 95 
}

local disabled = {
    c_punch_lamp = true,
	c_punch_scp = true,
}

SMODS.Booster({
    key = 'RelicBooster1',
    atlas = 'Boosters',
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = 'Relic Pack',
        text = {
            'Choose {C:attention}#1#{} of up to',
            '{C:attention}#2#{} {C:punch_relics}Relic{} cards to',
            'be used immediately'
        }
    },
    config = { extra = 3, choose = 1 },
    weight = 1,
    cost = 4,
    group_key = 'punch_RelicBooster1',
    draw_hand = true,
    unlocked = true,
    discovered = true,
    create_card = function(self, card)
        local i = 0
        repeat
            i = i + 1  -- Increment to prevent infinite loop
            card = create_card("Relics", G.pack_cards, nil, nil, true, true, nil, "punch_Relics")  -- Long card creation logic
        until not disabled[card.config.center.key] or i > 100 or card:remove()  -- If the card is disabled, regenerate it or clean up after 100 attempts
        return card  -- Return the valid card
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.config.center.config.choose, card.ability.extra } }
    end,
    ease_background_colour = function(self)
        local effects = {
            { new_colour = G.C.SET.Relics, special_colour = G.C.GREEN, contrast = 1 },
        }
        local random_index = math.random(#effects)
        local chosen_effect = effects[random_index]
        ease_colour(G.C.DYN_UI.MAIN, G.C.SET.Relics)
        ease_background_colour(chosen_effect)
    end
})



local disabled = {
    c_punch_lamp = true,
	c_punch_scp = true,
}

SMODS.Booster({
    key = 'RelicBooster2',
    atlas = 'Boosters',
    pos = { x = 1, y = 0 },
    loc_txt = {
        name = 'Relic Pack',
        text = {
            'Choose {C:attention}#1#{} of up to',
            '{C:attention}#2#{} {C:punch_relics}Relic{} cards to',
            'be used immediately'
        }
    },
    config = { extra = 3, choose = 1 },
    weight = 1,
    cost = 4,
    group_key = 'punch_RelicBooster2',
    draw_hand = true,
    unlocked = true,
    discovered = true,
    create_card = function(self, card)
        local i = 0
        repeat
            i = i + 1  -- Increment to prevent infinite loop
            card = create_card("Relics", G.pack_cards, nil, nil, true, true, nil, "punch_Relics")  -- Long card creation logic
        until not disabled[card.config.center.key] or i > 100 or card:remove()  -- If the card is disabled, regenerate it or clean up after 100 attempts
        return card  -- Return the valid card
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.config.center.config.choose, card.ability.extra } }
    end,
    ease_background_colour = function(self)
        local effects = {
            { new_colour = G.C.SET.Relics, special_colour = G.C.PURPLE, contrast = 1 },
        }
        local random_index = math.random(#effects)
        local chosen_effect = effects[random_index]
        ease_colour(G.C.DYN_UI.MAIN, G.C.SET.Relics)
        ease_background_colour(chosen_effect)
    end
})


local disabled = {
    c_punch_lamp = true,
	c_punch_scp = true,
}

SMODS.Booster({
    key = 'RelicBooster3',
    atlas = 'Boosters',
    pos = { x = 2, y = 0 },
    loc_txt = {
        name = 'Relic Pack',
        text = {
            'Choose {C:attention}#1#{} of up to',
            '{C:attention}#2#{} {C:punch_relics}Relic{} cards to',
            'be used immediately'
        }
    },
    config = { extra = 3, choose = 1 },
    weight = 1,
    cost = 4,
    group_key = 'punch_RelicBooster3',
    draw_hand = true,
    unlocked = true,
    discovered = true,
    create_card = function(self, card)
        local i = 0
        repeat
            i = i + 1  -- Increment to prevent infinite loop
            card = create_card("Relics", G.pack_cards, nil, nil, true, true, nil, "punch_Relics")  -- Long card creation logic
        until not disabled[card.config.center.key] or i > 100 or card:remove()  -- If the card is disabled, regenerate it or clean up after 100 attempts
        return card  -- Return the valid card
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.config.center.config.choose, card.ability.extra } }
    end,
    ease_background_colour = function(self)
        local effects = {
            { new_colour = G.C.SET.Spectral, special_colour = G.C.BLUE, contrast = 1 },
        }
        local random_index = math.random(#effects)
        local chosen_effect = effects[random_index]
        ease_colour(G.C.DYN_UI.MAIN, G.C.SET.Relics)
        ease_background_colour(chosen_effect)
    end
})


local disabled = {
    c_punch_lamp = true,
	c_punch_scp = true,
}

SMODS.Booster({
    key = 'RelicBooster4',
    atlas = 'Boosters',
    pos = { x = 3, y = 0 },
    loc_txt = {
        name = 'Relic Pack',
        text = {
            'Choose {C:attention}#1#{} of up to',
            '{C:attention}#2#{} {C:punch_relics}Relic{} cards to',
            'be used immediately'
        }
    },
    config = { extra = 3, choose = 1 },
    weight = 1,
    cost = 4,
    group_key = 'punch_RelicBooster4',
    draw_hand = true,
    unlocked = true,
    discovered = true,
    create_card = function(self, card)
        local i = 0
        repeat
            i = i + 1  -- Increment to prevent infinite loop
            card = create_card("Relics", G.pack_cards, nil, nil, true, true, nil, "punch_Relics")  -- Long card creation logic
        until not disabled[card.config.center.key] or i > 100 or card:remove()  -- If the card is disabled, regenerate it or clean up after 100 attempts
        return card  -- Return the valid card
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.config.center.config.choose, card.ability.extra } }
    end,
    ease_background_colour = function(self)
        local effects = {
            { new_colour = G.C.SET.Relics, special_colour = G.C.FILTER, contrast = 1 },
        }
        local random_index = math.random(#effects)
        local chosen_effect = effects[random_index]
        ease_colour(G.C.DYN_UI.MAIN, G.C.SET.Relics)
        ease_background_colour(chosen_effect)
    end
})



local disabled = {
    c_punch_lamp = true,
	c_punch_scp = true,
}

SMODS.Booster({
    key = 'RelicBooster5',
    atlas = 'Boosters',
    pos = { x = 0, y = 1 },
    loc_txt = {
        name = 'Jumbo Relic Pack',
        text = {
            'Choose {C:attention}#1#{} of up to',
            '{C:attention}#2#{} {C:punch_relics}Relic{} cards to',
            'be used immediately'
        }
    },
    config = { extra = 5, choose = 1 },
    weight = 1,
    cost = 6,
    group_key = 'punch_RelicBooster5',
    draw_hand = true,
    unlocked = true,
    discovered = true,
    create_card = function(self, card)
        local i = 0
        repeat
            i = i + 1  -- Increment to prevent infinite loop
            card = create_card("Relics", G.pack_cards, nil, nil, true, true, nil, "punch_Relics")  -- Long card creation logic
        until not disabled[card.config.center.key] or i > 100 or card:remove()  -- If the card is disabled, regenerate it or clean up after 100 attempts
        return card  -- Return the valid card
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.config.center.config.choose, card.ability.extra } }
    end,
    ease_background_colour = function(self)
        local effects = {
            { new_colour = G.C.SET.Relics, special_colour = G.C.MONEY, contrast = 1 },
        }
        local random_index = math.random(#effects)
        local chosen_effect = effects[random_index]
        ease_colour(G.C.DYN_UI.MAIN, G.C.SET.Relics)
        ease_background_colour(chosen_effect)
    end
})

SMODS.Booster({
    key = 'RelicBooster6',
    atlas = 'Boosters',
    pos = { x = 1, y = 1 },
    loc_txt = {
        name = 'Jumbo Relic Pack',
        text = {
            'Choose {C:attention}#1#{} of up to',
            '{C:attention}#2#{} {C:punch_relics}Relic{} cards to',
            'be used immediately'
        }
    },
    config = { extra = 5, choose = 1 },
    weight = 1,
    cost = 6,
    group_key = 'punch_RelicBooster6',
    draw_hand = true,
    unlocked = true,
    discovered = true,
    create_card = function(self, card)
        local i = 0
        repeat
            i = i + 1  -- Increment to prevent infinite loop
            card = create_card("Relics", G.pack_cards, nil, nil, true, true, nil, "punch_Relics")  -- Long card creation logic
        until not disabled[card.config.center.key] or i > 100 or card:remove()  -- If the card is disabled, regenerate it or clean up after 100 attempts
        return card  -- Return the valid card
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.config.center.config.choose, card.ability.extra } }
    end,
    ease_background_colour = function(self)
        local effects = {
            { new_colour = G.C.SET.Relics, special_colour = G.C.RED, contrast = 1 },
        }
        local random_index = math.random(#effects)
        local chosen_effect = effects[random_index]
        ease_colour(G.C.DYN_UI.MAIN, G.C.SET.Relics)
        ease_background_colour(chosen_effect)
    end
})



SMODS.Booster({
    key = 'RelicBooster7',
    atlas = 'Boosters',
    pos = { x = 2, y = 1 },
    loc_txt = {
        name = 'Mega Relic Pack',
        text = {
            'Choose {C:attention}#1#{} of up to',
            '{C:attention}#2#{} {C:punch_relics}Relic{} cards to',
            'be used immediately'
        }
    },
    config = { extra = 5, choose = 2 },
    weight = 1,
    cost = 8,
    group_key = 'punch_RelicBooster7',
    draw_hand = true,
    unlocked = true,
    discovered = true,
    create_card = function(self, card)
        local i = 0
        repeat
            i = i + 1  -- Increment to prevent infinite loop
            card = create_card("Relics", G.pack_cards, nil, nil, true, true, nil, "punch_Relics")  -- Long card creation logic
        until not disabled[card.config.center.key] or i > 100 or card:remove()  -- If the card is disabled, regenerate it or clean up after 100 attempts
        return card  -- Return the valid card
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.config.center.config.choose, card.ability.extra } }
    end,
    ease_background_colour = function(self)
        local effects = {
            { new_colour = G.C.SET.Relics, special_colour = G.C.PURPLE, contrast = 1 },
        }
        local random_index = math.random(#effects)
        local chosen_effect = effects[random_index]
        ease_colour(G.C.DYN_UI.MAIN, G.C.SET.Relics)
        ease_background_colour(chosen_effect)
    end
})


SMODS.Booster({
    key = 'RelicBooster8',
    atlas = 'Boosters',
    pos = { x = 3, y = 1 },
    loc_txt = {
        name = 'Mega Relic Pack',
        text = {
            'Choose {C:attention}#1#{} of up to',
            '{C:attention}#2#{} {C:punch_relics}Relic{} cards to',
            'be used immediately'
        }
    },
    config = { extra = 5, choose = 2 },
    weight = 1,
    cost = 8,
    group_key = 'punch_RelicBooster8',
    draw_hand = true,
    unlocked = true,
    discovered = true,
    create_card = function(self, card)
        local i = 0
        repeat
            i = i + 1  -- Increment to prevent infinite loop
            card = create_card("Relics", G.pack_cards, nil, nil, true, true, nil, "punch_Relics")  -- Long card creation logic
        until not disabled[card.config.center.key] or i > 100 or card:remove()  -- If the card is disabled, regenerate it or clean up after 100 attempts
        return card  -- Return the valid card
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.config.center.config.choose, card.ability.extra } }
    end,
    ease_background_colour = function(self)
        local effects = {
            { new_colour = G.C.SET.Relics, special_colour = G.C.PALE_GREEN, contrast = 1 },
        }
        local random_index = math.random(#effects)
        local chosen_effect = effects[random_index]
        ease_colour(G.C.DYN_UI.MAIN, G.C.SET.Relics)
        ease_background_colour(chosen_effect)
    end
})

--[[
SMODS.Shader({key = 'fridgemagnet', path = "fridgemagnet.fs"})

SMODS.Edition({
    key = "fridge",
    loc_txt = {
        name = "Fridge",
        text = {
            "i turned myself into a fridge magnet!!! im fridge magnet JIMBO!!!!",
        },
    },
    discovered = false,
    unlocked = true,
    shader = 'fridgemagnet',
    config = { handsize = 1 }, -- triggers twice, so actual gain is double
    in_shop = true,
    weight = 15, -- how likely the edition is
    extra_cost = 4, -- how much having this edition increases price
	badge_colour = HEX("ea763e"),
    apply_to_float = true,
	
    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.handsize * 2 } }
    end,
})
--]]


----------------------------------------------
------------MOD CODE END----------------------


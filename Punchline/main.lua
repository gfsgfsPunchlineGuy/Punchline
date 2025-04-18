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
-- thingy for text Color= C:color ,Highlighting text= X:attention ,Size= S:1 (1 is normal) e:1 makes move it
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
            "{C:inactive}(Cannot make legendaries){}",
            
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
            "{C:green}#1# in #2#{} chance for twins"
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

--[[
SMODS.Joker {
    key = 'calli',
    loc_txt = {
        name = 'Calligram joker',
        text = {
            "If your played hand contains this [AAJ2]",
			"gives +20 mult (changes every hand)"
        }
    },
    rarity = 1,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 4, y = 0 },
    blueprint_compat = true
}

SMODS.Joker {
    key = 'shadow',
    loc_txt = {
        name = 'Shadow puppet joker',
        text = {
            "{X:punch_light}When{C:punch_dark,X:punch_light}joker{C:punch_dark,X:punch_light}is{C:punch_dark,X:punch_light}sold{C:punch_dark,X:punch_light}during",
            "{X:punch_light}a{X:punch_light}round{X:punch_light}gain{X:punch_light}+1{X:punch_light}hand",
			"{X:punch_light}[Resets{X:punch_light}every{X:punch_light}boss{X:punch_light}blind]"
        }
    },
    rarity = 1,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 5, y = 0 },
    blueprint_compat = true
	}

]]
	
--[[

SMODS.Joker {
    key = 'carri',
    loc_txt = {
        name = 'Carricature joker',
        text = {
            "A random played card permently gains {C:chips}+60{} Chips",
			"every hand"
        }
    },
    rarity = 2,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 7, y = 0 },
    blueprint_compat = true
}

SMODS.Joker {
    key = 'miss',
    loc_txt = {
        name = 'Misspled',
        text = {
            "no idea how to do the fucking glitch",
            "effect of the missprint card"
        }
    },
    rarity = 1,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 8, y = 0 },
    blueprint_compat = true
}
]]


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

--[[
SMODS.Joker {
    key = 'gfs',
    loc_txt = {
        name = 'Gfs',
        text = {
            "Yo that's me :D ,well i guess i'll retrigger all the joker", 
			"the number of time cards have been triggered this hand",
			"Broken? Yes, Fun? Yes, Hotel? Trivago"
        }
    },
    rarity = 4,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 7, y = 1 },
	soul_pos = { x = 8, y = 1 },
    blueprint_compat = true
}
]]
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
    key = 'triple_self_portrait',
    loc_txt = {
        name = 'Triple self portrait',
        text = {
            "When a {C:attention}3 of kind{} is scored",
			"adds a {C:attention}random enchantement{} to the first card",
			"a {C:attention}random edition{} to second card",
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
}
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
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 2, y = 2 },
    blueprint_compat = true
}
]]


--[[
SMODS.Joker {
    key = 'bbillyn',
    loc_txt = {
        name = 'Billboard',
        text = {
            "k"
        }
    },
    rarity = 1,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 1, y = 3 },
    blueprint_compat = true
}

SMODS.Joker {
    key = 'bomb',
    loc_txt = {
        name = 'Oh God it\'a bomb',
        text = {
            "{C:attention}2s{} and {C:attention}10s{} are considered the same rank"
        }
    },
    rarity = 1,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 4, y = 2 },
    blueprint_compat = true
}

--------------------------------------------------------------------
	-- Timer and Game:update override for animation logic

SMODS.Atlas{
    key = 'lag', 
    path = 'lag.png', 
    px = 71, 
    py = 95 
	}
	
SMODS.Joker {
    key = 'lag', -- Changed to match the lookup below
    loc_txt = {
        name = 'Ohtest',
        text = {
            "animation test"
        }
    },
    rarity = 1,
    cost = 5,
    atlas = 'lag',
    pos = { x = 0, y = 0 },
    blueprint_compat = true
	
}

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
    key = 'plinko', -- Changed to match the lookup below
    loc_txt = {
        name = 'Ohtest',
        text = {
            "animation test"
        }
    },
    rarity = 1,
    cost = 5,
    atlas = 'plinko',
    pos = { x = 0, y = 0 },
    blueprint_compat = true
	
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
SMODS.Joker {
    key = 'Tamale', 
    loc_txt = {
        name = 'Classic joker',
        text = {
            "Earn $2 at the end of round for every two 2's in the deck",
			"Amount increases after beating a boss blind"
        }
    },
    rarity = 3,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 4, y = 3 },
    blueprint_compat = true
}
]]
SMODS.Joker{
    key = 'Eric',
    loc_txt = {
        name = 'Eric',
        text = {
            "Creates a clone of {C:attention}#1#{} random {C:attention}Consumables{},",
			"{C:attention}Cards{} or {C:attention}Jokers{} in possession",
			"at the start of every round"
        }
    },
    config = {
        extra = { cards = 1 }
    },
    rarity = 4,
    cost = 10,
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
                        {cards = G.jokers.cards, zone = G.jokers},
                        {cards = G.consumeables.cards, zone = G.consumeables},
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
                    end

                    playing_card_joker_effects(new_cards)
                    return true
                end
            }))
        end
    end
}
SMODS.Joker {
    key = "depression",
    name = "Depression",
    atlas = 'Jokers',
    pos = { x = 7, y = 3 },
    rarity = 3,
    cost = 8,
    loc_txt = {
        ['en-us'] = {
            name = "Depression",
            text = {
                "{C:attention}30%{} more chance for {C:dark_edition}negative{} jokers to appear in shop",
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
            if pseudorandom('depression_neg_chance') < 0.3 then
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
--[[
SMODS.Joker {
    key = 'old', 
    loc_txt = {
        name = 'Classic joker',
        text = {
            "Acts like the first played card"
        }
    },
    rarity = 3,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 8, y = 3 },
    blueprint_compat = true
	
}

SMODS.Joker {
    key = 'luck', 
    loc_txt = {
        name = 'Luck magnet',
        text = {
            "Makes the probability of the joker",
			"on the right to {C:green}100%"
        }
    },
    rarity = 3,
    cost = 5,
    atlas = 'Jokers',
    pos = { x = 9, y = 3 },
    blueprint_compat = true
	
}
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
]]
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

-----------------------------------------------------------------

--blinds
SMODS.Atlas({ key = "BlindChips", atlas_table = "ANIMATION_ATLAS", path = "BlindChips.png", px = 34, py = 34, frames = 21 })

SMODS.Blind({
    loc_txt = {
        name = 'The Loser',
        text = { 'First hand draws ',
		'the lowest ranked cards' }
    },
    key = 'Loser',
    name = 'The Loser',
    atlas = 'BlindChips',
    pos = {x = 0, y = 0},
    dollars = 5,
    boss = {min = 1, max = 10, hardcore = true},
    boss_colour = HEX("237875"),
    config = {extra = {ranks = {}, cards = 0}},  -- Set cards to 0 by default

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
        for i = 1, math.min(#possible_ranks, self.config.extra.cards) do  -- Use 'cards' for the count
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

        -- Mark the blind as triggered (instant trigger)
        self.triggered = true
        G.GAME.blind:set_text()
    end,
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
		'and editions for cards' }
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
    boss = { min = 8, max = 10, hardcore = true },
    boss_colour = HEX("d7cc0d"),
    atlas = "BlindChips",
    pos = { x = 0, y = 25 },
    dollars = 5,

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



----------------------------------------------
------------MOD CODE END----------------------

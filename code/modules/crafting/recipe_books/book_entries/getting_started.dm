// Practical OOC instructions for Bad Drakian. Keep detailed formulas in their own references.
/datum/book_entry/getting_started
	abstract_type = /datum/book_entry/getting_started
	category = null

/datum/book_entry/getting_started/character
	name = "01. Your First Character"

/datum/book_entry/getting_started/character/inner_book_html(mob/user)
	return {"
		<p>Start with a role whose description interests you and whose responsibilities you understand. A quieter town role gives you time to learn with other people nearby. Leadership and specialized combat roles can be demanding for a first round.</p>
		<p>Read your role and subclass descriptions. Skills affect what your character can reliably do: being able to pick up a tool or weapon does not mean you are trained to use it.</p>
		<p>Before joining, open <b>Content Toggles</b> in the character sheet's upper-right corner to review gameplay, display, sound and content preferences. <b>Keybinds</b> is just above it. You can change bindings there if a default is uncomfortable.</p>
		<p>Read the server rules before playing. Introduce yourself to someone in character and ask where your workplace or a useful service is. You do not need to learn every system before you start roleplaying.</p>
		<p>You can return to this guide through <b>OOC &rarr; Encyclopedia &rarr; Getting Started</b>.</p>
	"}

/datum/book_entry/getting_started/controls
	name = "02. Essential Controls"

/datum/book_entry/getting_started/controls/inner_book_html(mob/user)
	return {"
		<p>These are default hotkeys. Your own bindings may differ; check <b>Keybinds</b> on the character sheet.</p>
		<ul>
			<li><b>Left-click</b> to interact. Your held item and selected intent can change the action, so try an empty hand when you mean to handle an object.</li>
			<li><b>Shift-click</b> to examine. Read the result in chat; equipment tooltips, question marks and Mechanics explanations can reveal more.</li>
			<li><b>Q / E</b> select your left / right hand. Pressing the key for the already active hand uses the item in it.</li>
			<li><b>Z</b> drops the held item or releases a held grab.</li>
			<li><b>V</b> toggles standing and resting. <b>X</b> resists grabs, restraints and other situations you may be able to escape.</li>
			<li><b>C</b> toggles combat mode. Check its state before clicking another character.</li>
			<li>Drag a character's sprite onto your own to inspect their equipment. Drag your own sprite onto itself to inspect yours.</li>
		</ul>
		<p>Right-click and middle-click have context-sensitive actions. Examine an unfamiliar item or intent before experimenting on another person.</p>
	"}

/datum/book_entry/getting_started/equipment
	name = "03. Equipment & Storage"

/datum/book_entry/getting_started/equipment/inner_book_html(mob/user)
	return {"
		<p>Select the hand you want to use, pick up an item, then click a compatible equipment slot to wear it. Not every item fits every slot. Examine the item and hover over slots if you are unsure.</p>
		<p>Storage differs by container. Satchels can be accessed while worn; backpacks generally need taking off first. If a bag will not open, free a hand and try holding it. Containers have limits on both item size and capacity.</p>
		<p>Clicking a wieldable weapon in your active hand can grip it with both hands when the other hand is free. Use the same action to release the second grip. The <b>Alt-grip / Twirl</b> binding, normally <b>Alt+G</b>, performs the held item's right-click action; its result depends on the item and your current state.</p>
		<p>Use the appropriate draw/stow binding for a weapon's equipment slot. Compatible sheathed weapons can be drawn without taking the sheath out of its storage. Slot bindings and the weapon's own interactions are listed in <b>Keybinds</b>.</p>
		<p>Bows, crossbows and slings need matching ammunition. Compatible quivers and pouches support quick loading; examine the weapon and ammunition container for their controls. A crossbow must also be cocked before loading.</p>
	"}

/datum/book_entry/getting_started/roleplay
	name = "04. Talking & Finding Roleplay"

/datum/book_entry/getting_started/roleplay/inner_book_html(mob/user)
	return {"
		<p>Use <b>Say</b> for your character's speech and <b>Whisper</b> for quieter speech. Starting a Say message with <b>*</b> writes an emote, describing what your character does. Nearby characters can usually hear ordinary speech; whispers are not guaranteed to be private.</p>
		<p><b>LOOC</b> is local out-of-character chat. Use it for a brief clarification, such as asking how a control works or checking a scene preference. Keep your character's speech and knowledge separate from OOC discussion.</p>
		<p><b>Set Roleplay Ad</b>, below Content Toggles on the character sheet, lets you advertise the kind of roleplay you are seeking. The <b>Rosewall's Personal Ads</b> tab lets you browse other players' ads. A saved renewing ad can be posted automatically when you spawn.</p>
		<p>Ask another player for mechanical help when appropriate. Use <b>Adminhelp</b> for administrator assistance, rule questions or problems that need mediation. Preferences and ads communicate interests; they do not replace consent or the server rules.</p>
	"}

/datum/book_entry/getting_started/upkeep
	name = "05. Food, Water & Rest"

/datum/book_entry/getting_started/upkeep/inner_book_html(mob/user)
	return {"
		<p>Watch your hunger, thirst and energy indicators. Buy or barter for food and safe drinking water from other characters, and carry some before travelling. Unfamiliar berries may be poisonous; stagnant water, swamp water and sewage are unsafe drinking sources.</p>
		<p>A well and a bucket are a useful source of water. Drink from a suitable filled container using its normal interaction. Keep water you intend to drink separate from contaminated liquids.</p>
		<p>To sleep, lie down and close your eyes using the eye control on your HUD. A bed or bedroll improves rest. If you cannot fall asleep, check your armor, traits and the feedback in chat; some equipment and character choices restrict sleeping.</p>
		<p>Sleep helps recovery and gives access to the dream-based skill progression system. Spending stamina also uses long-term energy, so a moment's pause does not replace food and rest after a long expedition.</p>
	"}

/datum/book_entry/getting_started/injuries
	name = "06. When You Are Hurt"

/datum/book_entry/getting_started/injuries/inner_book_html(mob/user)
	return {"
		<p>Injuries are more than a single health bar. Bleeding, pain, damaged limbs and blood loss can leave you helpless even if you survived the initial hit. Read your alerts and seek help early.</p>
		<p>For a bleeding wound, select the injured body zone on the aiming doll and apply a bandage. You can use a <b>bandage roll directly</b> on yourself or another character; a piece is taken from the roll for the treatment.</p>
		<p>A sewing needle can close suitable wounds, with Medicine skill affecting treatment. Bandaging or sewing one wound does not necessarily repair a fracture, replace lost blood or fix damaged organs.</p>
		<p>If you are badly hurt, get to safety, call for medical help and tell the healer what happened. Avoid testing unfamiliar surgery on yourself or another player. If someone collapses, ask for a trained healer rather than assuming food or ordinary rest will save them.</p>
	"}

/datum/book_entry/getting_started/safety
	name = "07. Staying Safe & Leaving Town"

/datum/book_entry/getting_started/safety/inner_book_html(mob/user)
	return {"
		<h3>Before leaving town</h3>
		<p>Bring <b>food, water, a light source, bandages and suitable equipment</b>. Find someone to travel with, learn your route back and tell companions if you are inexperienced. Wilderness creatures and ambushes can overwhelm an unprepared traveller.</p>
		<h3>If a fight starts</h3>
		<ul>
			<li>Turn on <b>combat mode</b> when you intend to defend yourself.</li>
			<li>Hold a weapon you are trained to use. Suitable armor and defensive equipment matter too.</li>
			<li>Watch your stamina and leave room to retreat before you exhaust yourself.</li>
			<li>Use <b>Resist</b>, normally X, if a creature grabs you. Escape attempts are not guaranteed.</li>
			<li>Practice unfamiliar mechanics with a willing partner in a safe place.</li>
		</ul>
		<p>You do not need to join every fight you encounter. Give scenes room to develop, communicate when needed and follow BD's conflict rules. Mechanical <b>Yield</b> signals surrender to players; do not expect hostile NPCs to respect it.</p>
	"}

/datum/book_entry/getting_started/death
	name = "08. Death & Getting Help"

/datum/book_entry/getting_started/death/inner_book_html(mob/user)
	return {"
		<p><b>Read the instructions in chat when you die.</b> Death does not always end your round. If you want recovery, staying in your body is usually the simplest way to remain available for it.</p>
		<p>Eligible characters can normally rise as a <b>deadite</b> after about [DEAD_TO_ZOMBIE_TIME / (1 MINUTES)] minutes. Roles, traits and world conditions can change what happens. Once risen, seek help to have the rot removed and recover; follow BD's rules and your death message.</p>
		<p>Depending on your condition, recovery may involve a healer, rot-removal surgery, a Cure Rot miracle, lux-based revival or a religious ritual. Missing body parts and character traits can change which options work. Ask a healer rather than assuming every method is available.</p>
		<p><b>DNR</b> changes your revival options, but does not prevent every form of deadite recovery. The death message explains relevant exceptions. Avoid selecting irreversible ghost or respawn options without reading their warnings if you want to return to your original character.</p>
	"}

/datum/book_entry/getting_started/troubleshooting
	name = "09. Why Is This Not Working?"

/datum/book_entry/getting_started/troubleshooting/inner_book_html(mob/user)
	return {"
		<p>Check the latest chat message first: many failed actions explain what is missing.</p>
		<ul>
			<li><b>Wrong action?</b> Check your active hand, held item, attack intent, middle-click intent and combat mode.</li>
			<li><b>Cannot pick up or use something?</b> Free a hand, stand closer and check whether you are restrained, incapacitated or already performing an action.</li>
			<li><b>Cannot open or fill storage?</b> Some bags need removing. Check the container's capacity and whether the item is too large.</li>
			<li><b>Cannot wield a weapon?</b> Free your other hand and examine its requirements. Some items cannot be wielded at all.</li>
			<li><b>Treatment or crafting keeps failing?</b> Check the targeted body zone, tools, materials and required skill.</li>
			<li><b>Cannot sleep or move comfortably?</b> Check equipment restrictions, injuries, restraints and character traits.</li>
			<li><b>Hotkey does nothing?</b> Check Keybinds and whether a text input currently has keyboard focus.</li>
		</ul>
		<p>Examine the item, look for a Mechanics explanation and ask someone nearby. A short LOOC question can resolve confusion without interrupting the whole scene.</p>
	"}

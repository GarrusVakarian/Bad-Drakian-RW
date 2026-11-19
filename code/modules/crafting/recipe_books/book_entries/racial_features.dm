// Practical racial interactions. Keep role-dependent spells distinct from innate features.
/datum/book_entry/racial_features
	abstract_type = /datum/book_entry/racial_features
	category = null

/datum/book_entry/racial_features/overview
	name = "00. About Racial Features"

/datum/book_entry/racial_features/overview/inner_book_html(mob/user)
	return {"
		<p>Use these chapters for practical instructions about racial abilities, unusual bodies and special interactions. Your origin, class, equipment and chosen features may add or change abilities. Read your character sheet and action tooltips for your actual traits and spells.</p>
		<p>Classes and origins are separate from race: not every character of a race receives the same spells. Races with only ordinary attribute changes do not need a separate chapter here.</p>
	"}

/datum/book_entry/racial_features/construct
	name = "01. Metal Constructs"

/datum/book_entry/racial_features/construct/inner_book_html(mob/user)
	return {"
		<h2>Energy and fuel</h2><p>You cannot sleep. Combat mode and exertion spend energy; turn combat mode off and lie down to recover. Absorb coal or charcoal for 250 energy, or a small log for 50, up to your maximum. Use the fuel on yourself without weak intent. Another person can refuel you too.</p>
		<h2>Stones mend your frame</h2><p>Use a stone on yourself outside combat mode for a short healing effect. Stones repair wounds and bodily damage; they do not refill energy. Magically potent stones heal more effectively.</p>
		<h2>Hammer repairs</h2><p>Turn combat mode off, select the damaged body part and use a repair hammer or mallet on yourself. Repairs repeat until the part is mended or interrupted. Tongs are not required. Another person can repair you faster; Engineering speeds up each repair.</p>
		<h2>Learning</h2><p>You earn skill experience but cannot sleep to advance it. Ask a non-Construct with Journeyman Engineering or better to install a Construct skill exhibitor. The modified exhibitor permits self-use.</p>
		<h2>Your artificial body</h2><p>You do not need food or breath, do not bleed and feel no pain. Ordinary reagents are not metabolized. Campfires and many ordinary healing effects do not repair you. You are immune to toxins and deadite infection, so do not rely on deadite recovery.</p>
		<h2>Temperature</h2><p>Extreme cold makes your frame brittle and more vulnerable to critical injuries. Overheating lowers Willpower while increasing Speed. Metal does not make you immune to fire or environmental damage.</p>
	"}

/datum/book_entry/racial_features/doll
	name = "02. Dolls"

/datum/book_entry/racial_features/doll/inner_book_html(mob/user)
	return {"
		<h2>Construct upkeep</h2><p>Like Metal Constructs, you can absorb coal, charcoal or small logs for energy, stones for healing, and use a hammer or mallet outside combat mode to repair selected body parts. Engineering speeds up repairs; tongs are not needed. Lie down to regain energy.</p>
		<h2>Learning and medicine</h2><p>You cannot sleep or metabolize ordinary reagents. Skill advancement needs a Construct skill exhibitor, as described in the Metal Constructs chapter. You do not need food or breath, do not bleed, feel no pain and cannot become a deadite.</p>
		<h2>Fragile frame</h2><p>Your body is Beautiful but especially vulnerable to critical injuries and dismemberment. You can attach replacement limbs through your Limb Attachment trait. Select the missing body part and apply the replacement limb. Extreme cold and overheating affect you as they do other Constructs.</p>
	"}

/datum/book_entry/racial_features/ooze
	name = "03. Oozes"

/datum/book_entry/racial_features/ooze/inner_book_html(mob/user)
	return {"
		<h2>Body and recovery</h2><p>You do not breathe and are immune to deadite infection. Your boneless, bloodless body loses limbs easily. Sleeping can regrow missing arms and legs when you have enough nutrition; eat beforehand, as regrowth consumes it. Your appetite tolerates food that would upset ordinary eaters.</p>
		<h2>Closing wounds</h2><p>Ooze wounds cannot be sewn with an ordinary needle. Use a suitable lit torch on the affected body part to singe sewable wounds closed. Medicine improves treatment.</p>
		<h2>Blob Form</h2><p>Granted during class setup: temporarily become a small blob. Your humanoid body and equipment are stored while transformed. If the blob is killed, you return to your original body rather than dying with the blob; the ability then has a longer recovery period.</p>
		<h2>Ooze Reshape</h2><p>Also granted during class setup: opens appearance customization without needing a mirror. It takes a brief uninterrupted action to open. This changes appearance, not your race or class.</p>
		<h2>Losing your form</h2><p>A fatal injury collapses you into a weak, suffering blob rather than a deadite. You need revival to regain your humanoid form; the reanimation chair explicitly supports suffering Oozes. This is different from voluntarily using Blob Form. Seek help and keep the blob safe.</p>
	"}

/datum/book_entry/racial_features/seelie
	name = "04. Seelies"

/datum/book_entry/racial_features/seelie/inner_book_html(mob/user)
	return {"
		<h2>Small and fragile</h2><p>Your tiny body can pass through other characters and tables. You resist fall damage but are vulnerable to critical injuries. Your clothing choices are restricted by size; decorative wings do not grant unrestricted flight.</p>
		<h2>Glow and luck</h2><p>The Seelie tab contains Seelie glow, which toggles your light, and Luck aura, which switches between blessing and misery. The aura affects nearby non-Seelie characters. You can speak Faexin with the ,t language prefix.</p>
		<h2>Role-dependent magic</h2><p>Your role determines which fae spells you receive; choosing Seelie does not grant every spell. Implemented spells include Seelie Dust (disorienting powder), Call Beast (summons a rat, with a rare Rous), Strip Clothes (removes a worn item), Drain (takes nearby energy), Replenish Nature (restores eligible natural growth), Tame Rous (calms a Rous), Regenerative Kiss (healing with nausea) and Water Splash (a water projectile). Read the abilities actually granted to your character.</p>
	"}

/datum/book_entry/racial_features/arachnid
	name = "05. Arachnids"

/datum/book_entry/racial_features/arachnid/inner_book_html(mob/user)
	return {"
		<h2>Weave Web</h2><p>Creates thin webbing and then attempts to reinforce it. Move or cancel during reinforcement to leave a thin web. Your own Webwalker trait lets you cross webs freely; other characters may be caught.</p>
		<h2>Spin Silk Bed</h2><p>Creates silk bedding on clear floor. Weave on the same bedding again to add an overhead veil and ordinary-bed comfort. The action takes time and can be interrupted.</p>
		<h2>Weave Cocoon</h2><p>Wrap yourself or an adjacent living character in supporting silk. It takes five seconds and movement interrupts weaving. Three uses recover separately after five minutes each. The cocoon slowly restores bodily damage, breathing and blood, but does not repair Constructs. Occupants can resist to escape; others can cut or break it open.</p>
		<h2>Other features</h2><p>Longstrider helps you cross rough terrain. You ignore caltrops and can inject venom by chewing someone you have bitten. These abilities belong to the Arachnid race; merely selecting a spider-shaped taur body does not grant the full racial spell set.</p>
	"}

/datum/book_entry/racial_features/revenant
	name = "06. Revenants"

/datum/book_entry/racial_features/revenant/inner_book_html(mob/user)
	return {"
		<h2>Undead survival</h2><p>You do not need food or breath and cannot become a deadite. Severe injuries can still leave you helpless: rest and seek treatment rather than relying on ordinary death and deadite recovery.</p>
		<h2>Detachable head</h2><p>Your head can be removed without immediately ending your existence. Keep it safe: destroying it kills you. While headless you become easier to critically injure and dismember, cannot run or cast spells, and lose several protective combat traits until reattached.</p>
		<h2>Head and body</h2><p>The Revenant Vision action switches your viewpoint between head and body while headless. Keep your own head safe and reattach it to restore normal function; another person can help.</p>
	"}

/datum/book_entry/racial_features/lamia
	name = "07. Lamias"

/datum/book_entry/racial_features/lamia/inner_book_html(mob/user)
	return {"
		<h2>Tail combat</h2><p>Your tail changes unarmed combat, including a longer-reaching tail strike against targets up to two tiles away. Keep an eye on your selected intent and target; it is not an extra weapon slot.</p>
		<h2>Venom and travel</h2><p>Chewing someone you have bitten can inject venom. Longstrider helps with rough terrain and you ignore caltrops. Your serpentine body restricts ordinary legwear and footwear.</p>
	"}

/datum/book_entry/racial_features/kobold
	name = "08. Kobolds"

/datum/book_entry/racial_features/kobold/inner_book_html(mob/user)
	return {"
		<h2>Stones and gems</h2><p>Outside combat mode, use stones or gems on yourself to eat them. Stones provide a short wound-healing and blood-recovery effect. Gems provide a brief, stronger healing effect; better gems heal more. These are healing interactions, not Construct fuel.</p>
		<h2>Feral appetite</h2><p>You can eat organs and tolerate food that upsets ordinary eaters. This does not make every poison or hazardous substance safe.</p>
	"}

/datum/book_entry/racial_features/dwarf
	name = "09. Dwarves"

/datum/book_entry/racial_features/dwarf/inner_book_html(mob/user)
	return {"
		<h2>Drunken healing</h2><p>Alcohol of sufficient strength gradually heals brute and burn damage while metabolizing. You still suffer the normal dangers of alcohol; drinking more is not automatically safer or better.</p>
		<h2>Dwarvish knowledge</h2><p>Your racial trait unlocks Dwarven anvil recipes. You still need the required crafting skills and materials. You can speak Dwarvish with ,d.</p>
	"}

/datum/book_entry/racial_features/fluvian
	name = "10. Fluvians"

/datum/book_entry/racial_features/fluvian/inner_book_html(mob/user)
	return {"
		<h2>Rigged games</h2><p>Your Blackleg trait lets you choose a result when preparing a coin flip or die roll. With a single coin, use its self-action; right-click a die to choose its outcome, then roll it normally. You can also choose to play fairly.</p>
		<h2>Wings</h2><p>Your appearance choices do not automatically grant unrestricted flight. Check your actual traits and action buttons for any additional movement abilities.</p>
	"}

/datum/book_entry/racial_features/harpy
	name = "11. Harpies"

/datum/book_entry/racial_features/harpy/inner_book_html(mob/user)
	return {"
		<h2>Talons and equipment</h2><p>Your natural feet prevent ordinary boots from being worn. You have strong bites and start with singing training. Flightless Harpies gain Talon Kicks.</p>
		<h2>Flight or Flightless</h2><p>Choose your racial bonus during character setup. Flight gives access to Harpy Flight with suitable wings. Activate it while standing, free of armor, buckles and grabs. Flight spends stamina; Athletics makes it less tiring, and the flight effect has environmental limits. Flightless changes your attributes and trades flight for Talon Kicks. Both variants retain limited fall protection.</p>
	"}

/datum/book_entry/racial_features/axian
	name = "12. Axians"

/datum/book_entry/racial_features/axian/inner_book_html(mob/user)
	return {"
		<h2>Aquatic life</h2><p>You can breathe underwater and drink seawater. Waterloving helps you tolerate swimming in cold water. You still need to manage injury, fatigue and other hazards; waterbreathing is not general invulnerability.</p>
	"}

/datum/book_entry/racial_features/drakian
	name = "13. Drakians"

/datum/book_entry/racial_features/drakian/inner_book_html(mob/user)
	return {"
		<h2>Wing Bound</h2><p>Your wings soften falls. This is limited protection rather than unrestricted flight or immunity to falling damage.</p>
	"}

/datum/book_entry/racial_features/tiefling
	name = "14. Tieflings"

/datum/book_entry/racial_features/tiefling/inner_book_html(mob/user)
	return {"
		<h2>Hellspawn</h2><p>Your bloodline resists catching fire. You can still suffer burns and other heat damage; do not treat this as lava immunity.</p>
	"}

/datum/book_entry/racial_features/humen
	name = "15. Humens"

/datum/book_entry/racial_features/humen/inner_book_html(mob/user)
	return {"
		<h2>Ingenuity</h2><p>You gain skill experience more efficiently. You still need to meet advancement requirements and rest to advance skills; this is not immediate mastery.</p>
	"}

/datum/book_entry/racial_features/critterkin
	name = "16. Critterkin"

/datum/book_entry/racial_features/critterkin/inner_book_html(mob/user)
	return {"
		<h2>Keen Ears</h2><p>You can hear speech between nearby floors under circumstances where ordinary ears cannot. IC → Toggle Keen Ears lets you dull or restore this hearing. Walls, distance and speech conditions still matter.</p>
	"}

/datum/book_entry/racial_features/lupian
	name = "17. Lupians"

/datum/book_entry/racial_features/lupian/inner_book_html(mob/user)
	return {"
		<h2>Sleuth</h2><p>You can track more frequently, keep tracking while moving and examine tracks immediately. Your trait also grants access to available gossip links when examining people; it does not reveal private thoughts.</p>
	"}

/datum/book_entry/racial_features/venardine
	name = "18. Venardines"

/datum/book_entry/racial_features/venardine/inner_book_html(mob/user)
	return {"
		<h2>Sleuth</h2><p>You can track more frequently, keep tracking while moving and examine tracks immediately. Your trait also grants access to available gossip links when examining people; it does not reveal private thoughts.</p>
	"}

/datum/book_entry/racial_features/tabaxi
	name = "19. Tabaxi"

/datum/book_entry/racial_features/tabaxi/inner_book_html(mob/user)
	return {"
		<h2>Light Steps</h2><p>You disturb snow less and take reduced caltrop damage. This is a reduction, not complete immunity to traps or hazardous floors.</p>
	"}

/datum/book_entry/racial_features/sissean
	name = "20. Sisseans"

/datum/book_entry/racial_features/sissean/inner_book_html(mob/user)
	return {"
		<h2>Wild appetite</h2><p>Your Wild Eater trait helps you tolerate raw food and eat without some ordinary dining penalties. It does not make all poisons or unsafe reagents harmless.</p>
	"}

/datum/book_entry/racial_features/elf
	name = "21. Elves"

/datum/book_entry/racial_features/elf/inner_book_html(mob/user)
	return {"
		<h2>Woodwalker</h2><p>You move through wilderness vegetation with fewer disturbances and avoid ordinary vegetation-triggered ambush checks in the interactions that recognize Woodwalker. Running can still break vegetation; this does not pacify enemies already present.</p>
	"}

/datum/book_entry/racial_features/dark_elf
	name = "22. Dark Elves"

/datum/book_entry/racial_features/dark_elf/inner_book_html(mob/user)
	return {"
		<h2>Webs and darkness</h2><p>Webwalker lets you cross webs without being caught. Darkvision improves sight in darkness. Neither trait grants Arachnid weaving spells or immunity to every environmental hazard.</p>
	"}

/datum/book_entry/racial_features/goblin
	name = "23. Goblins"

/datum/book_entry/racial_features/goblin/inner_book_html(mob/user)
	return {"
		<h2>Darkvision</h2><p>You can see better in darkness. This does not reveal invisible creatures or grant other races' spells.</p>
	"}

/datum/book_entry/racial_features/half_orc
	name = "24. Half Orcs"

/datum/book_entry/racial_features/half_orc/inner_book_html(mob/user)
	return {"
		<h2>Big Guy</h2><p>Your immense build helps you smash wooden doors and throw people more easily.</p>
		<h2>Bed Breaker</h2><p>Strong-intent intimate actions can cause injury. Pay attention to intensity and consent settings; your racial trait is not a requirement to use forceful actions.</p>
	"}

/datum/book_entry/racial_features/aasimar
	name = "25. Aasimar"

/datum/book_entry/racial_features/aasimar/inner_book_html(mob/user)
	return {"
		<h2>Hungerless</h2><p>Your racial trait removes the ordinary need for food. It does not grant freedom from breathing, pain or injury, and does not give every holy miracle.</p>
	"}

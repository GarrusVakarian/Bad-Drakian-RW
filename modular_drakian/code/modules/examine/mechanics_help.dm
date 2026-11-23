// Mechanics tutorials adapted for Bad Drakian from Azure Peak PRs #5743 and #6079.
// Original tutorial author: Ollanius. Only help text is ported; gameplay is unchanged.

/obj/effect/track/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click the HUD eye to search for tracks and hidden dangers. Perception and Tracking improve your search.")

/obj/item/restraints/legcuffs/beartrap/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Activate in hand to arm or disarm the trap. Crafting improves your chance of arming it.")
	. += span_info("Handling an armed trap can injure you. Strike it with an item to trigger it.")

/obj/item/enchantingkit/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use the kit on a matching item to change its appearance.")

/obj/item/storage/belt/rogue/surgery_bag/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Stores surgical tools. Treatments require Medicine skill and the right tools.")

/obj/item/rogueweapon/surgery/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Target the injured body part and use the required tool on Weak intent.")
	. += span_info("Medicine skill, sedation and a bed or operating surface improve surgical success.")

/obj/item/storage/roguebag/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use the sack on a tile to gather items. Activate it in hand to empty it in front of you.")
	. += span_info("Use sacks in crafting recipes for bags and bait.")

/obj/item/bait/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Activate in hand to place bait and click it to collect it.")
	. += span_info("Leave the area to attract animals. Different bait attracts different quarry.")

/obj/item/bomb/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Light the fuse with an ignition source and move away before the bomb explodes.")

/obj/item/book/rogue/bibble/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Trained clergy can use bibles to anoint people and items.")

/obj/item/book/rogue/bibble/psy/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Activate in hand to preach. Middle-click to choose a testament.")

/obj/item/book/rogue/bibble/zizo/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Open the book to read it.")

/obj/item/roguecoin/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use coins to pay for goods and services. Their metal determines their value.")

/obj/item/roguecoin/inqcoin/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Spend these coins on Inquisitorial supplies through the mail system. Submit signed slips and evidence to earn more.")

/obj/item/roguegem/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use gems in jewelry and crafting. Recipe books and the Encyclopedia list the recipes.")

/obj/item/inqarticles/indexer/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Activate in hand to extend or retract the blade. Use the blood-drawing intent to collect a sample.")
	. += span_info("Collecting blood takes several cycles. Combine a filled indexer with Inquisitorial paperwork and mail it.")

/obj/item/inqarticles/garrote/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Target the neck and use Grab to start a chokehold, then Choke to strangle.")
	. += span_info("Struggling damages the garrote. Repair a snapped cord with inquisitorial cordage.")

/obj/item/clothing/head/inqarticles/blackbag/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Target the head to bag someone and blind them. Unconscious people are easier to bag.")
	. += span_info("Inquisitorial training speeds up the action.")

/obj/item/inqarticles/bmirror/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click to open or close the mirror. Open it to style hair.")
	. += span_info("Use the open mirror on yourself to blood it, then activate it in hand to scry a name.")

/obj/item/storage/keyring/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click a door to lock or unlock it with a matching key on this ring. The ring can stay in your hand, on your belt or inside a worn belt.")
	. += span_info("Right-click the keyring to take a key or open its storage to choose one.")

/obj/item/lockpickring/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Stores lockpicks. Right-click to take one or open its storage to choose one.")

/obj/item/roguekey/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click a door to lock or unlock it with this key in hand or on your belt, including inside a worn belt or keyring.")

/obj/item/lockpick/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use on a door to pick its lock. Lockpicking skill, pick condition and lock difficulty affect success.")

/obj/item/natural/hide/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Butcher animals for hide. Butchering improves your yield.")
	. += span_info("Place hide on a drying rack and work it with a knife to make leather. Skincrafting improves the leather yield.")

/obj/item/natural/fur/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Butcher animals with a bladed tool to collect this material. Butchering improves your yield.")
	. += span_info("Use it in equipment and tool recipes from the Craft menu.")

/obj/item/natural/saddle/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Feed a tameable animal grain or oats, then fit it with a saddle.")
	. += span_info("Drag yourself onto the mount to ride and use Resist to dismount. Movement mode controls walking and galloping.")

/obj/item/natural/bone/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Butcher animals with a bladed tool to collect this material. Butchering improves your yield.")
	. += span_info("Use it in equipment and tool recipes from the Craft menu.")

/obj/item/ash/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use on a farm plot to fertilize it.")

/obj/item/natural/fibers/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Cut grass or forage bushes for fibers. Craft fibers and a thorn into a needle, then use the needle to make cloth.")
	. += span_info("The Craft menu lists the tools, materials and skills for each recipe.")

/obj/item/natural/cloth/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use on an injured body part to bandage it and reduce bleeding. Soak cloth to clean stains.")
	. += span_info("Severe wounds can bleed through bandages and need further treatment.")

/obj/item/natural/thorn/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Forage bushes for thorns and fibers. Craft them into a needle through the Craft menu.")
	. += span_info("Sneak over fallen thorns to avoid snapping them and triggering wilderness ambushes.")

/obj/item/natural/bundle/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click to take one portion or left-click empty-handed to choose an amount.")
	. += span_info("Add matching materials to enlarge the bundle. Larger bundles take more storage space.")

/obj/item/natural/feather/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use on paper or books to write. Reading and writing require Literacy.")
	. += span_info("Use a feather to rename items, change their descriptions or decorate helmets.")

/obj/item/natural/head/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Sell bounty heads to a merchant or Headeater. Species and condition affect their value.")
	. += span_info("Turn in contract targets through the contract system.")

/obj/item/natural/poo/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use on a farm plot to fertilize it.")

/obj/item/natural/stone/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use on a bladed weapon to sharpen it. Move away to stop.")
	. += span_info("Hand sharpening reduces maximum sharpness. Use a grindstone to preserve it.")
	. += span_info("Strike objects to create sparks and light fires.")

/obj/item/natural/whetstone/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use on a bladed weapon to sharpen it. Move away to stop.")
	. += span_info("Hand sharpening reduces maximum sharpness. Use a grindstone to preserve it.")
	. += span_info("Strike objects to create sparks and light fires.")

/obj/item/natural/rock/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use Pick intent to break rocks for materials. Use a chisel to shape them into stone blocks.")

/obj/item/grown/log/tree/get_mechanics_examine(mob/user)
	. = ..()
	if(blessed)
		. += span_info("Blessed timber has a big chance to yield 1 extra small log, and a smaller chance to yield 2 extra small logs when chopped.")
	. += span_info("Split logs with an axe. Woodcutting improves the work.")
	. += span_info("Use logs, smaller logs and sticks in crafting recipes.")

/obj/item/grown/log/tree/small/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Cut into sticks with an axe or planks with a handsaw. Use small logs in tools, weapons and other recipes.")

/obj/item/grown/log/tree/stick/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Carve a stick into a stake with a cutting tool. Use sticks in torches, arrows and basic tools.")
	. += span_info("Sneak over fallen sticks to avoid snapping them and triggering wilderness ambushes.")

/obj/item/grown/log/tree/stake/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use stakes in crafting or as improvised weapons. Stake a helpless undead through the heart to finish it.")

/obj/item/storage/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Left-click empty-handed to open storage. Use a held item on it to store it.")
	. += span_info("Drag worn storage onto an empty hand to remove it. Right-click over an open storage grid to rotate the held item.")
	. += span_info("Use back and belt shortcuts to stash your held item or draw the latest stored item. Set these shortcuts in Keybinds.")

/obj/machinery/light/rogue/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Relight with an ignition source or sparks.")

/obj/machinery/light/rogue/hearth/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Add fuel to keep the hearth burning. Place a pan or pot on it to cook.")
	. += span_info("Examine the cookware for its controls.")

/obj/machinery/light/rogue/campfire/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Rest or sleep near a lit campfire to recover.")
	. += span_info("Add fuel and relight it when needed. Place pans or pots on the fire to cook.")
	. += span_info("Left-click empty-handed to remove food or cookware.")

/obj/structure/bars/passage/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Open or close the gate with its linked lever or winch. Gates can also be destroyed.")

/obj/structure/fluff/customsign/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use a dagger on Stab intent to carve a message.")

/obj/structure/fluff/statue/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click to open your personal stash and collect loadout, role and virtue equipment.")

/obj/structure/fluff/psycross/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Clergy can perform marriages by offering an apple that both partners have bitten.")

/obj/structure/flora/roguegrass/maneater/real/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Sneak through foliage to avoid maneater ambushes.")
	. += span_info("If grabbed, press Resist (default X) to start a timed struggle. Stay still while attempts repeat and your escape chance improves.")
	. += span_info("Strength helps you escape. Another person can pull you free. Escape quickly to avoid severe injuries.")

/obj/structure/mineral_door/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click to lock or unlock with a matching key in hand or at your belt, including keys stored inside a worn belt or keyring.")
	. += span_info("Kick an unlocked door to open it. Pick, force or destroy locked doors.")

/obj/structure/mineral_door/wood/deadbolt/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click the deadbolt from inside to lock or unlock it.")

/obj/structure/trap/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click the HUD eye to search for traps. Examine an adjacent trap to reveal it briefly.")

/obj/structure/fluff/walldeco/wantedposter/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Choose antagonist preferences through Villain Selection in character creation.")
	. += span_info("Read Getting Started in the Encyclopedia for basic controls.")

/obj/structure/fluff/walldeco/innsign/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Eat, drink and sleep to stay healthy. Avoid spoiled food and unsafe water.")
	. += span_info("Read Getting Started under OOC -> Encyclopedia for survival tips.")

/obj/structure/fluff/walldeco/steward/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Copper coins are worth one mammon, silver five and gold ten.")
	. += span_info("Register an account at a MEISTER to receive payments from machines.")

/obj/structure/fluff/walldeco/bsmith/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Click Skills on the HUD to view skills and traits.")
	. += span_info("Wear armor you are trained in and examine its properties to check protection, coverage and condition.")
	. += span_info("Take damaged equipment to a smith or tailor for repairs.")

/obj/structure/fluff/walldeco/barbersign/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Bandage bleeding wounds and seek medical help for serious injuries.")
	. += span_info("Medicine skill and the right tools help treat wounds, blood loss and missing organs.")

/obj/structure/fluff/walldeco/barbersignreverse/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Bandage bleeding wounds and seek medical help for serious injuries.")
	. += span_info("Medicine skill and the right tools help treat wounds, blood loss and missing organs.")

/obj/structure/fluff/walldeco/artificerflag/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Click Skills on the HUD to view skills and traits.")
	. += span_info("Wear armor you are trained in and examine its properties to check protection, coverage and condition.")
	. += span_info("Take damaged equipment to a smith or tailor for repairs.")

/obj/structure/fluff/walldeco/sign/merchantsign/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Copper coins are worth one mammon, silver five and gold ten.")
	. += span_info("Register an account at a MEISTER to receive payments from machines.")

/obj/structure/fluff/walldeco/psybanner/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Choose your faith and patron in character creation. Read Gods under OOC -> Encyclopedia for their descriptions, virtues and sins.")

/obj/structure/fluff/walldeco/med/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Control bleeding and seek trained help for serious wounds or missing organs.")
	. += span_info("Train Medicine and use the right tools for treatment.")

/obj/structure/fluff/walldeco/med2/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Control bleeding and seek trained help for serious wounds or missing organs.")
	. += span_info("Train Medicine and use the right tools for treatment.")

/obj/structure/fluff/walldeco/med3/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Control bleeding and seek trained help for serious wounds or missing organs.")
	. += span_info("Train Medicine and use the right tools for treatment.")

/obj/structure/fluff/walldeco/med4/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Control bleeding and seek trained help for serious wounds or missing organs.")
	. += span_info("Train Medicine and use the right tools for treatment.")

/obj/structure/fluff/walldeco/med5/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Control bleeding and seek trained help for serious wounds or missing organs.")
	. += span_info("Train Medicine and use the right tools for treatment.")

/obj/structure/fluff/walldeco/med6/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Control bleeding and seek trained help for serious wounds or missing organs.")
	. += span_info("Train Medicine and use the right tools for treatment.")

/obj/structure/fluff/walldeco/sign/saiga/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Drag yourself onto a saddled, tamed mount to ride. Use Resist to dismount.")

/obj/structure/well/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use a bucket or pot to draw water. Fountains also accept smaller glass containers.")
	. += span_info("Check suspicious water before drinking it.")

/obj/structure/chair/bench/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Sit on the bench to rest. Sneak to use it as a hiding place.")

/obj/item/chair/rogue/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Activate in hand to place the chair in front of you. Drag yourself onto it to sit and use Resist to get up.")

/obj/item/chair/stool/bar/rogue/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Activate in hand to place the stool in front of you. Drag yourself onto it to sit and use Resist to get up.")

/obj/structure/bed/rogue/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Close your eyes to sleep.")
	. += span_info("Remove helmets and chest armor that prevent sleep. Sleeping restores energy and helps recovery and learning.")
	. += span_info("Open your eyes to wake and use Resist to unbuckle. Press Rest/Get Up (default V) to lie down or stand.")

/obj/item/bedroll/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Activate in hand to lay out the bedroll. Click the empty bedroll to pack it up.")

/obj/structure/standingbell/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Left-click to ring the bell. After a timed action, it alerts the people assigned to its location.")

/obj/structure/gate/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Open or close the gate with its linked lever or winch. Gates can also be destroyed.")

/obj/structure/winch/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Left-click to operate the linked gate. Strength speeds up the action.")

/obj/structure/roguemachine/musicbox/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Left-click to open the music menu and choose a song.")

/obj/structure/flora/newtree/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Chop trees down with a bladed tool. Click an adjacent tree to climb it. Climbing skill helps.")
	. += span_info("Look up for a safe landing before climbing.")

/obj/structure/lever/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Left-click to operate the linked mechanism. Strength speeds up the action.")

/obj/structure/pressure_plate/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use a linking wrench and Engineering skill to connect this to another mechanism.")

/obj/structure/floordoor/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use a linking wrench and Engineering skill to connect this to another mechanism.")

/obj/structure/flora/roguetree/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use Cut, Chop or Rend intent to cut it down. Axes work best.")

/obj/structure/flora/roguetree/stump/log/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Sneak and click the hollow log to hide. Move out to leave hiding.")

/obj/structure/flora/roguegrass/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Cut foliage or forage bushes for fibers, thorns, berries and herbs.")
	. += span_info("Sneak through dangerous foliage to avoid ambushes. Jumping and flying also avoid ground triggers.")

/obj/structure/flora/rogueshroom/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use Cut, Chop or Rend intent to cut it down. Axes work best.")

/obj/structure/telescope/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Left-click to look through the telescope and learn about a celestial object.")

/obj/structure/globe/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Left-click to spin the globe and read about a place.")

/turf/closed/wall/mineral/rogue/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Click an adjacent wall to climb it. Climbing skill determines which surfaces you can scale.")
	. += span_info("Look up for a safe landing before climbing.")

/obj/item/clothing/neck/roguetown/coif/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click to adjust the coif and change its coverage.")

/obj/item/clothing/neck/roguetown/chaincoif/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click to adjust the coif and change its coverage.")

/obj/item/clothing/neck/roguetown/psicross/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Middle-click to adjust the amulet's wrist/neck display. Right-click to pray if you know how.")
	. += span_info("Use *pray to write a spoken prayer.")

/obj/item/clothing/neck/roguetown/psicross/silver/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Silver protects against some unholy effects.")

/obj/item/clothing/neck/roguetown/collar/prisoner/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Restricts magic and weakens the wearer according to their bounty. Use liberation or absolution equipment to remove it.")

/obj/item/clothing/ring/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Wear in a ring slot.")

/obj/item/clothing/ring/active/nomag/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click to activate the anti-magic ward. Let it recharge before using it again.")

/obj/item/clothing/ring/signet/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Stamp folded letters with the signet to change their processing or rewards.")

/obj/item/clothing/ring/band/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click to name and describe the band. Offer wedding bands to one another to record an existing marriage.")

/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/ornate/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Upgrade with blessed silver and smithing tools. Your training and patron affect how comfortably you wear it.")

/obj/item/clothing/suit/roguetown/armor/plate/full/bronze/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Heavy bronze armor is especially cumbersome. Check its properties and wear it with the right armor training.")

/obj/item/clothing/suit/roguetown/armor/plate/fluted/ornate/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Upgrade with blessed silver and smithing tools. Your training and patron affect how comfortably you wear it.")

/obj/item/clothing/suit/roguetown/armor/plate/full/fluted/ornate/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Upgrade with blessed silver and smithing tools. Your training and patron affect how comfortably you wear it.")

/obj/item/clothing/head/roguetown/roguehood/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click to raise or lower the hood. A drawn hood conceals your identity.")
	. += span_info("Middle-click to place it over or under your hair.")

/obj/item/clothing/head/roguetown/helmet/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click a visored helmet to raise or lower its visor. Raising it improves vision and exposes your face.")
	. += span_info("Use feathers or cloth to decorate compatible helmets.")

/obj/item/clothing/under/roguetown/tights/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Target a leg and Shift-right-click to tear off fabric for a bandage. Strength improves your chance.")

/obj/item/clothing/under/roguetown/skirt/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Target a leg and Shift-right-click to tear off fabric for a bandage. Strength improves your chance.")

/obj/item/recipe_book/survival/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Read Getting Started under OOC -> Encyclopedia. Other guides cover the economy, gods, lands, cooking and magic.")
	. += span_info("Shift-click to examine. Open Mechanics or hover question marks for more help.")
	. += span_info("Default controls: C for Combat Mode, X for Resist and V for Rest/Get Up. Change them in Keybinds.")
	. += span_info("Sneak to avoid ambushes. Use Resist to start struggling free of a maneater.")

/obj/item/roguebin/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click with an item held to wash it or empty-handed to wash yourself.")
	. += span_info("Fill the bin by pouring water into it or leaving it in rain. Washing dirties the water.")

/obj/structure/plough/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("TILTS any dirt/grass tile it's dragged over - requires user to drag it while having SNEAK active.")
	. += span_info("Tilling uses stamina.")

/obj/item/rogueweapon/thresher/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use on STRIKE intent to break up produce for seeds. THRESH on stalks to beat out grains.")
	. += span_info("Use Thresh on harvested stalks to separate fibers.")

/obj/item/rogueweapon/hoe/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("TILT intent allows you to make new plots for plants. Using it (on any intent) on a plot that already has something planted removes WEEDS.")

/obj/item/rogueweapon/pitchfork/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use RIGHT CLICK to flip compost in the bin. While wielded SCOOP intent allows you to pick up large amount (19) stalks.")
	. += span_info("Unwield it to dump the stalks.")

/obj/item/paper/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use a feather to write on it. You can create a two-page manuscript that can be turned into a book by writing on it and applying it to another piece of paper that also have something written on it.")
	. += span_info("Reading and writing require Literacy.")
	. += span_info("Wrap items in paper to make packages.")

/obj/item/paper/inqslip/accusation/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Combine an accusation with a filled indexer, fold it and mail it through HERMES. Sign with blood to identify the signer.")

/obj/item/paper/inqslip/confession/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("The accused signs with blood, then folds the confession for mailing. Add a matching indexer as evidence.")

/obj/item/paper/inqslip/arrival/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Sign with blood, fold it and mail it through HERMES to register your arrival with the Inquisition.")

/obj/item/reagent_containers/glass/bottle/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click to cork or uncork. Cork the bottle before storing it to prevent spills.")
	. += span_info("Uncork to drink or pour. Target the nose while examining to smell its contents.")

/obj/machinery/light/rogue/cauldron/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use Feed to pour liquid in and Fill to take liquid out.")
	. += span_info("Combine ingredients to brew alchemical recipes from recipe books or the Encyclopedia.")

/obj/machinery/anvil/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Heat an ingot at a forge with tongs, place it on the anvil and hammer it into a recipe.")
	. += span_info("Reheat the finished work and quench it in water. Smithing skill depends on the recipe.")
	. += span_info("Use the anvil for equipment repairs.")

/obj/machinery/light/rogue/forge/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use tongs holding an ingot on the lit forge to heat it. Add fuel and relight it when needed.")

/obj/item/rogueweapon/tongs/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Pick up ingots with the tongs, heat them at a forge and place them on an anvil. Activate in hand to release the ingot.")

/obj/item/millstone/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Grind ingredients into powder. Wet flour, knead it and add the remaining flour to make dough.")

/obj/machinery/light/rogue/oven/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use the top of the oven to load food and the bottom to add fuel.")
	. += span_info("Keep it lit while cooking and remove finished food before it burns. Left-click the top with an empty hand to take an item out.")

/obj/item/natural/worms/leech/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Leeches draw blood and remove toxins. Find and remove attached leeches through body-part examine or the health display.")

/obj/item/natural/worms/leech/cheele/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Activate in hand to switch between drawing blood and returning stored blood to the host.")

/obj/item/natural/worms/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use as fishing bait. Dig wet ground to find more worms.")

/obj/item/rogueweapon/shovel/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use Scoop to collect dirt and dig holes. Use a loaded shovel to refill them.")
	. += span_info("Widen a hole, drag items or bodies into it and cover them with dirt.")
	. += span_info("Right-click outside your active hand to change digging mode.")

/obj/item/rogueore/iron/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Smelt iron with coal in a furnace to make steel. Check its recipe for the amounts.")

/obj/item/rogueore/copper/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Smelt copper with tin to make bronze. Check the smelter's recipe for the amounts.")

/obj/item/rogueore/tin/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Smelt copper with tin to make bronze. Check the smelter's recipe for the amounts.")

/obj/item/ingot/iron/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Smelt iron with coal in a furnace to make steel. Check its recipe for the amounts.")

/obj/item/ingot/copper/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Smelt copper with tin to make bronze. Check the smelter's recipe for the amounts.")

/obj/item/ingot/tin/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Smelt copper with tin to make bronze. Check the smelter's recipe for the amounts.")

/obj/item/rogueweapon/pick/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Mine rock with the pick. Strength, Mining and the tool affect your progress.")
	. += span_info("Location and Fortune affect the materials you find.")

/obj/structure/roguemachine/atm/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Left-click empty-handed to register or access your account and receive machine payments.")

/obj/structure/roguemachine/vendor/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Left-click empty-handed to browse and buy goods. Retrieve change through the stored-coin option.")
	. += span_info("Owners can unlock the peddler to restock it and collect earnings.")

/obj/item/scomstone/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click to send a SCOM message. Middle-click to mute or unmute.")
	. += span_info("Houndstones and crownstones use the royal channel. Activate a crownstone in hand to change channels.")

/obj/item/tablecloth/silk/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use to clean stains or wear it on your head.")

/obj/item/fishingrod/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Bait the rod and use Cast intent on water. Fishing skill improves your results.")
	. += span_info("Activate in hand to stop fishing.")

/obj/item/clothing/head/get_mechanics_examine(mob/user)
	. = ..()
	if(attachment_component && istype(GetComponent(attachment_component), /datum/component/storage/concrete/roguetown/hat))
		. += span_info("Shift-right-click while holding or wearing it to open cosmetic storage.")
		. += span_info("Insert compatible flowers, feathers and unarmored headwear, masks or neckwear to display them as decorative layers.")

/obj/item/clothing/suit/roguetown/armor/get_mechanics_examine(mob/user)
	. = ..()
	if(attachment_component && istype(GetComponent(attachment_component), /datum/component/storage/concrete/roguetown/armor))
		. += span_info("Shift-right-click while holding or wearing it to open cosmetic storage.")
		. += span_info("Insert unarmored shirts, tabards, cloaks or armor to display them as decorative layers.")

/// Describe compatible cosmetic hosts without creating storage components during examine.
/obj/item/proc/get_cosmetic_attachment_help()
	var/head_cosmetic = slot_flags & (ITEM_SLOT_HEAD|ITEM_SLOT_MASK|ITEM_SLOT_NECK)
	var/body_cosmetic = slot_flags & (ITEM_SLOT_CLOAK|ITEM_SLOT_ARMOR|ITEM_SLOT_SHIRT)
	if(!(head_cosmetic || body_cosmetic))
		return
	// Matches the hat/armor components' item restrictions, before host capacity checks.
	if(length(contents) || (item_flags & ABSTRACT) || w_class > WEIGHT_CLASS_GIGANTIC)
		return
	// Both cosmetic storage types have a two-by-two grid.
	if(grid_width > 2 * world.icon_size || grid_height > 2 * world.icon_size)
		return
	if(istype(armor) && (armor.stab > 0 || armor.blunt > 0))
		return
	var/static/list/excluded_types = list(/obj/item/storage, /obj/item/rogueweapon, /obj/item/bomb, /obj/item/flashlight, /obj/item/recipe_book)
	if(is_type_in_list(src, excluded_types))
		return
	if(head_cosmetic && body_cosmetic)
		return span_info("This can be inserted into compatible headwear or armor as a decorative layer. Shift-right-click that equipment while holding or wearing it to open its cosmetic storage.")
	if(head_cosmetic)
		return span_info("This can be inserted into compatible headwear as a decorative layer. Shift-right-click that headwear while holding or wearing it to open its cosmetic storage.")
	return span_info("This can be inserted into compatible armor as a decorative layer. Shift-right-click that armor while holding or wearing it to open its cosmetic storage.")

/obj/structure/flora/roguegrass/herb/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Left-click empty-handed to pick herbs for alchemy.")

/obj/item/toy/cards/deck/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use the deck in your hand to shuffle the cards. Draw a card by clicking on it with an empty hand.")

/obj/item/reagent_containers/glass/bottle/claybottle/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Clay pottery, unlike its alloyed counterparts, can be stained in a dyebin.")

/obj/item/reagent_containers/glass/bottle/clayvase/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Clay pottery, unlike its alloyed counterparts, can be stained in a dyebin.")

/obj/item/reagent_containers/glass/bottle/clayfancyvase/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Clay pottery, unlike its alloyed counterparts, can be stained in a dyebin.")

/obj/item/reagent_containers/glass/cup/claycup/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Clay pottery, unlike its alloyed counterparts, can be stained in a dyebin.")

/obj/item/roguestatue/clay/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Clay pottery, unlike its alloyed counterparts, can be stained in a dyebin.")

/obj/item/roguestatue/glass/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Glassed pottery, unlike its alloyed counterparts, can be stained in a dyebin.")

/obj/item/carvedgem/porcelain/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Porcelain pottery can be glazed with a dye brush.")

/obj/item/reagent_containers/glass/cup/porcelain/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("It can be brushed with a dye brush to glaze it.")

/obj/item/reagent_containers/glass/bucket/pot/teapot/porcelain/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("It can be brushed with a dye brush to glaze it.")

/obj/item/reagent_containers/glass/bottle/blown/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Blown glass can be tinted in a dye bin.")

/obj/item/reagent_containers/glass/bottle/alchemical/blown/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Blown glass can be tinted in a dye bin.")

/obj/item/rogue/instrument/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use in hand to open the music menu, then choose Play Song. Use it again to stop playing.")
	. += span_info("In combat mode, using it replays your last song.")
	if(ishuman(user))
		var/mob/living/carbon/human/viewer_human = user
		if(viewer_human.inspiration)
			. += span_info("You can quickly add and remove people from your audience by <b>middle-clicking</b> on them with this instrument in your hand.")

/obj/item/magic/infernal/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("It can be used to heal Infernal summons.")

/obj/item/magic/fae/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("It can be used to heal Fae summons.")

/obj/item/magic/elemental/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("It can be used to heal Elemental summons.")

/obj/item/ammo_casing/caseless/rogue/javelin/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click it in your hand, or use Alt-grip / Twirl (default Alt+G), to twirl it one-handed. Safe at Journeyman Polearms skill.")

/obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click it in your hand, or use Alt-grip / Twirl (default Alt+G), to twirl it one-handed. Safe at Expert Crossbows skill.")

/obj/structure/autogrinder/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Left-click it with an empty hand to switch it on or off; non-skilled engineers will rarely catch their hand under the stone.")
	. += span_info("It grinds anything millable or anything an alchemy mortar and pestle could grind from its attached hopper and only works while connected to a powered rotational network with enough RPM.")
	. += span_info("Drop grain or other grindables onto the attached hopper's tile and switch the grinder on; it feeds itself.")
	. += span_info("Ground product is dropped onto the grinder's own tile.")

/obj/structure/closet/crate/chest/autogrinder/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("A lidless feed bin — drop grain or other grindables onto its tile and the autogrinder pulls them in.")

/obj/structure/infernalengine/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("This engine generates rotational power continuously for connected machinery while it remains active.")
	. += span_info("Keep it out of wet terrain. Water can extinguish it and stop the engine.")

/obj/structure/windmill/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Place it somewhere with a clear view of the sky - a roof or an upper floor stops it catching the wind.")
	. += span_info("It spins fastest on the highest level; the wind weakens, halving its output, for each z-level it sits below the top.")
	. += span_info("Middle-click it with an engineering wrench to disassemble it.")

/obj/item/ingot/sylveric/get_mechanics_examine(mob/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_DREAMWALKER))
		. += span_info("You can feel the metal resonate with your dream energy. If you strike another sylveric ingot with this one, you can shape it into a weapon.")

/obj/item/clothing/shoes/roguetown/boots/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Knives and lockpicks can be stowed inside.")

/obj/item/clothing/mask/rogue/get_mechanics_examine(mob/user)
	. = ..()
	if(is_snoutable())
		. += span_info("Alt+RMB makes room for a snout.")

/obj/item/clothing/mask/rogue/xylixmask/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Alt+RMB opens the style radial menu.")
	. += span_info("Shift+RMB toggles the snout version of the selected style.")
	. += span_info("Shift+MMB toggles identity concealment.")
	. += span_info("When using the harlequin styles: Right-click to honk.")

/obj/item/clothing/neck/roguetown/horus/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Click on a turf or an item to see how much it is worth. Avoid tables.")

/obj/item/reagent_containers/food/snacks/grown/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Smash this with a blunt object to extract seeds from it.")

/obj/item/pumpkinshell/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Using a small blade, I could stab or cut it into a variety of decorations.")

/obj/item/rogueweapon/sickle/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use on any plant to instantly harvest it. HERBS turn to fiber when attacked.")

/obj/item/armor_brush/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("To polish a weapon or a piece of armor, you must have the knowledge of a squire or how to repair the item. Follow the following steps:")
	. += span_info("I. Apply polishing cream to the item.")
	. += span_info("II. Use the coarse side (use the item to flip it) to scrub the item roughly.")
	. += span_info("III. Use the fine side to gently polish the item.")
	. += span_info("IV. Wash the item in a wooden bin with water to polish it.")
	. += span_info("A fully polished item will be slightly stronger and or more durable.")

/obj/structure/broadcast_horn/paid/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("A noble, yeoman, churchman, retinue member, or courtier can use this for a zenny. Others must insert a ziliqua.")

/obj/item/mattcoin/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("It can be used in hand to give it a disguise. Use it again to return it back to normal.")

/obj/item/reagent_containers/glass/cup/ceramic/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("It can be brushed with a dye brush to glaze it.")

/obj/item/reagent_containers/glass/bucket/pot/teapot/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("It can be brushed with a dye brush to glaze it.")

/obj/item/reagent_containers/food/snacks/fat/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use on splash intent on yourself to oil yourself up, making yourself slippery and harder to grab when uncovered. Being barefoot reduces the chance of slipping.")

/obj/item/signal_flare_gun/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Middle-click it to set its dial ahead of time, so it fires without asking.")

/obj/item/clothing/neck/roguetown/get_mechanics_examine(mob/user)
	. = ..()
	if(is_snoutable())
		. += span_info("Alt+RMB makes room for a snout.")

/obj/item/clothing/suit/roguetown/shirt/undershirt/easttats/get_mechanics_examine(mob/user)
	. = ..()
	. -= span_info("This object can be repaired using <b>Sewing</b> and a needle.")
	. += span_info("These tattoos slowly mend themselves after a minute without taking damage.")

/obj/item/bottle_kit/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("You can change the bottle colour by using the kit. Click on a fermentation keg / distiller that has finished brewing to bottle its results.")

/obj/item/reagent_containers/glass/mortar/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Left click with a pestle to grind the item inside into alchemical ingredients. Middle Click with a pestle to grind or juice them. Right click to remove it.")

/obj/structure/roguemachine/mail/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right click to write a letter, or insert coins to buy postage, parchment, and quills.")
	. += span_info("Use a paper or wrapped package on the machine to send it for free.")
	if(HAS_TRAIT(user, TRAIT_INQUISITION))
		. += span_info("The MARQUETTE can be accessed via a secret compartment fitted within the HERMES. Load a Marque to access it.")
		. += span_info("You can send arrival slips, accusation slips, fully loaded INDEXERs or confessions here.")
		. += span_info("Properly sign them. Include an INDEXER where needed. Stamp them for two additional Marques.")

/obj/structure/roguemachine/vaultbank/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Only [get_authority_label()] may withdraw or draft writs of loan from this jawbank - through a NERVELOCK's Institutional tab, not the jawbank itself.")
	. += span_info("Strike it with any weapon to throttle coins loose.")

/obj/structure/roguemachine/stockpile_saltcamp/get_mechanics_examine(mob/user)
	. = ..()
	if(!HAS_TRAIT(user, TRAIT_DUNGEONMASTER_LABOR_CAMP))
		. += span_info("Right click to deposit all the salt in front of the machine.")

/obj/structure/pillory/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Drag yourself or another person onto the unlocked pillory to buckle them in.")
	. += span_info("Right-click empty-handed to latch or unlatch an occupied, unlocked pillory.")
	. += span_info("Use a matching key or keyring on the latched pillory to lock or unlock it.")
	. += span_info("Resist to struggle free. At 18 Strength, you can break it open even while locked.")
	. += span_info("Click with a held liquid container to set it at the base.")

/obj/item/quiver/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Click on the ground to pick up ammos on the floor.")

/obj/item/signal_horn/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Using the horn will make you stand still and induce several ambushes to happen at once, enabling you to clear out an area. It cannot be used in rapid succession.")
	. += span_info("Using it will leave you exhausted for a moment. Bring friends!")

/obj/item/proc/get_repair_mechanics_examine(mob/user)
	. = list()
	if(isliving(user))
		var/mob/living/L = user
		if(L.STAINT < 9)
			return
	if(isnull(anvilrepair) && isnull(sewrepair))
		return
	else
		var/str = "This object can be repaired using "
		if(anvilrepair)
			var/datum/skill/S = anvilrepair		//Should only ever be a skill or null
			str += "<b>[initial(S.name)]</b> and a hammer."
		if(sewrepair)
			str += "<b>Sewing</b> and a needle."
		str = span_info(str)
		. += str

/obj/item/clothing/glasses/get_mechanics_examine(mob/user)
	. = ..()
	if(glass_colour_type && ishuman(user))
		. += span_info("Alt-click to toggle its colors.")

/obj/item/clothing/accessory/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("\The [src] can be attached to a uniform. Alt-click to remove it once attached.")
	if(initial(above_suit))
		. += span_info("\The [src] can be worn above or below my suit. Alt-click to toggle.")

/obj/item/clothing/suit/toggle/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Alt-click on [src] to toggle the [togglename].")

/obj/item/loan_contract/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Left-click in hand to accept or decline its terms.")

/obj/item/citizenry_letter/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Left-click in hand to claim its rights.")

/obj/structure/chair/frankenstein/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Buckle the deceased into the chair and fill its tank with Reanimation Elixir.")
	. += span_info("Right-click to crank the chair to full charge. Middle-click to attempt revival.")
	. += span_info("Requires [skill_to_string(chair_skill_level)] Medicine, [brew_required] units of elixir and a full charge.")
	. += span_info("Reviving someone with another person's brain requires Master Medicine and a full tank, which the revival consumes.")

/obj/item/storage/belt/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click a door to lock or unlock it with a matching key stored in your worn belt, including keys on a keyring.")

/obj/structure/chair/get_mechanics_examine(mob/user)
	. = ..()
	if(can_buckle)
		. += span_info("Move onto its tile and drag yourself onto it to sit. Drag another person on that tile onto it to buckle them in.")
		. += span_info("Use Resist to get up.")

/obj/structure/bed/get_mechanics_examine(mob/user)
	. = ..()
	if(can_buckle)
		. += span_info("Move the person onto the bed's tile, then drag their sprite onto the bed to buckle them in.")

/obj/structure/chair/arrestchair/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click with a wanted person buckled in to claim their bounty and fit a penance collar.")
	. += span_info("The collar prevents attacks and spells until the sentence ends, then falls off.")

/obj/structure/chair/freedomchair/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Right-click with someone buckled in to remove their Castifico collar.")

/obj/structure/chair/freedomchair/crafted/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("This machine falls apart after removing one collar.")

/obj/structure/noose/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Move the person onto its tile, then drag their sprite onto it to put the noose around their neck.")
	. += span_info("A chair beneath the occupant prevents hanging. Remove the chair to start the hanging.")
	. += span_info("Left-click empty-handed to release someone. Use Resist to try to free yourself.")

/obj/structure/guillotine/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Drag a person onto it while the blade is raised to strap them in.")
	. += span_info("Right-click to drop or raise the blade. Left-click empty-handed to release the occupant.")
	. += span_info("Use a stone on the raised blade to sharpen it.")

/obj/structure/bondage/get_mechanics_examine(mob/user)
	. = ..()
	if(!istype(src, /obj/structure/bondage/gloryhole))
		. += span_info("Drag yourself onto it to buckle in. To secure another person, restrain them or hold an aggressive grab, then drag them onto it.")
	. += span_info("Use Resist to try to free yourself. Left-click empty-handed to unbuckle another person.")

/obj/structure/bondage/gloryhole/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Drag yourself or another person onto it from an adjacent tile to buckle them in.")
	. += span_info("Stand behind it to unbuckle someone else.")
	. += span_info("To secure another person, restrain them or hold an aggressive grab first.")
	if(!isobserver(user))
		. += span_info("Right-click to step up to \the [src].")
	. += span_info("Use a liquid container on it out of combat mode to place it. Click the bucket beneath the opening with an empty hand to retrieve your container.")

/obj/structure/wooden_horse/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Drag yourself onto it to buckle in. To secure another person, restrain them or hold an aggressive grab, then drag them onto it.")
	. += span_info("Use Resist to try to free yourself. Left-click empty-handed to unbuckle another person.")
	. += span_info("Right-click to rotate it. Remaining buckled here causes damage.")

/obj/structure/target_stake/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Move the person onto its tile, then drag their sprite onto it to buckle them in.")
	. += span_info("Use a target on the stake to mount it. Left-click empty-handed to remove it.")

/obj/structure/meathook/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Pull a creature and left-click the hook empty-handed to hang them on it. This injures them.")
	. += span_info("Left-click empty-handed to free the occupant. Use Resist to try to free yourself.")
	. += span_info("Improves the yield of butchering. Also increases speed by 25%.")

/obj/structure/fluff/walldeco/chains/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Move the person onto its tile, then drag their sprite onto it to tie them in place.")
	. += span_info("Use Resist to try to free yourself. Left-click empty-handed to unbuckle another person.")

/obj/structure/roguethrone/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Move onto its tile and drag yourself onto it to sit. Use Resist to get up.")

/obj/structure/vampthrone/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Move onto its tile and drag yourself onto it to sit. Use Resist to get up.")

/obj/structure/glowshroom/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Don't touch it!")

/obj/item/manuscript/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use paper to add more pages. Finish the book with a book crafting kit, then choose its title, category and cover before archiving it.")

/obj/item/rogueweapon/scabbard/get_mechanics_examine(mob/user)
	. = ..()
	if(sheathed)
		. += span_info("Right-click to draw it; left-click with an empty hand to pick up the sheath.")

/obj/item/book/spellbook/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Reading it once per day allows you to unbind two spells and refund its spell point.")

/obj/item/capture_sack/get_mechanics_examine(mob/user)
	. = ..()
	if(!occupant)
		. += span_info("Use it on a living target to pull the sack over them. A moving target will interrupt the attempt.")
